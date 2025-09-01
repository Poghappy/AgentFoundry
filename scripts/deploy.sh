#!/bin/bash

# AgentFoundry 部署脚本
# 创建时间: 2025-01-27
# 作者: AgentFoundry Team
# 版本: v1.0.0

# 功能描述:
# - 支持多环境部署 (staging, production)
# - 自动化构建和部署流程
# - 健康检查和回滚机制
# - 部署前验证和测试

# 设置错误处理
set -euo pipefail

# 脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置
DEPLOY_TIMEOUT=300
HEALTH_CHECK_RETRIES=10
HEALTH_CHECK_INTERVAL=30

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 显示使用方法
show_usage() {
    echo "使用方法: $0 <environment> [options]"
    echo ""
    echo "环境:"
    echo "  staging     - 测试环境"
    echo "  production  - 生产环境"
    echo ""
    echo "选项:"
    echo "  --skip-tests     - 跳过测试"
    echo "  --skip-build     - 跳过构建"
    echo "  --force          - 强制部署"
    echo "  --rollback       - 回滚到上一版本"
    echo "  --dry-run        - 模拟部署"
    echo "  --help           - 显示帮助"
    echo ""
    echo "示例:"
    echo "  $0 staging"
    echo "  $0 production --skip-tests"
    echo "  $0 staging --rollback"
}

# 解析命令行参数
parse_args() {
    if [ $# -eq 0 ]; then
        show_usage
        exit 1
    fi
    
    ENVIRONMENT="$1"
    shift
    
    # 验证环境
    case "$ENVIRONMENT" in
        staging|production)
            ;;
        --help|-h)
            show_usage
            exit 0
            ;;
        *)
            log_error "无效的环境: $ENVIRONMENT"
            show_usage
            exit 1
            ;;
    esac
    
    # 解析选项
    SKIP_TESTS=false
    SKIP_BUILD=false
    FORCE_DEPLOY=false
    ROLLBACK=false
    DRY_RUN=false
    
    while [ $# -gt 0 ]; do
        case "$1" in
            --skip-tests)
                SKIP_TESTS=true
                ;;
            --skip-build)
                SKIP_BUILD=true
                ;;
            --force)
                FORCE_DEPLOY=true
                ;;
            --rollback)
                ROLLBACK=true
                ;;
            --dry-run)
                DRY_RUN=true
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
            *)
                log_error "未知选项: $1"
                show_usage
                exit 1
                ;;
        esac
        shift
    done
}

# 加载环境配置
load_config() {
    log_info "加载 $ENVIRONMENT 环境配置..."
    
    local config_file="$PROJECT_ROOT/configs/$ENVIRONMENT.env"
    
    if [ -f "$config_file" ]; then
        source "$config_file"
        log_success "配置加载完成"
    else
        log_warning "配置文件不存在: $config_file"
        log_info "使用默认配置"
    fi
    
    # 设置默认值
    DOCKER_REGISTRY=${DOCKER_REGISTRY:-"localhost:5000"}
    IMAGE_TAG=${IMAGE_TAG:-"latest"}
    DEPLOY_HOST=${DEPLOY_HOST:-"localhost"}
    DEPLOY_USER=${DEPLOY_USER:-"deploy"}
    APP_PORT=${APP_PORT:-"8000"}
    HEALTH_CHECK_URL=${HEALTH_CHECK_URL:-"http://$DEPLOY_HOST:$APP_PORT/health"}
}

# 预部署检查
pre_deploy_checks() {
    log_info "执行预部署检查..."
    
    # 检查 Git 状态
    if [ "$ENVIRONMENT" = "production" ] && [ "$FORCE_DEPLOY" = "false" ]; then
        if ! git diff-index --quiet HEAD --; then
            log_error "工作目录有未提交的更改"
            log_info "请提交更改或使用 --force 选项"
            exit 1
        fi
        
        local current_branch=$(git rev-parse --abbrev-ref HEAD)
        if [ "$current_branch" != "main" ] && [ "$current_branch" != "master" ]; then
            log_warning "当前分支不是 main/master: $current_branch"
            if [ "$FORCE_DEPLOY" = "false" ]; then
                read -p "是否继续部署? [y/N] " -n 1 -r
                echo
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    exit 1
                fi
            fi
        fi
    fi
    
    # 检查必要工具
    local required_tools=("docker" "docker-compose")
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            log_error "缺少必要工具: $tool"
            exit 1
        fi
    done
    
    # 检查磁盘空间
    local available_space=$(df "$PROJECT_ROOT" | awk 'NR==2 {print $4}')
    local required_space=1048576  # 1GB in KB
    
    if [ "$available_space" -lt "$required_space" ]; then
        log_error "磁盘空间不足，需要至少 1GB 可用空间"
        exit 1
    fi
    
    log_success "预部署检查通过"
}

# 运行测试
run_tests() {
    if [ "$SKIP_TESTS" = "true" ]; then
        log_warning "跳过测试"
        return
    fi
    
    log_info "运行测试..."
    
    cd "$PROJECT_ROOT"
    
    # 运行单元测试
    if ! make test; then
        log_error "单元测试失败"
        exit 1
    fi
    
    # 运行集成测试
    if [ -f "tests/integration/test_*.py" ]; then
        if ! python -m pytest tests/integration/ -v; then
            log_error "集成测试失败"
            exit 1
        fi
    fi
    
    # 运行安全测试
    if ! make security-scan; then
        log_error "安全扫描失败"
        exit 1
    fi
    
    log_success "所有测试通过"
}

# 构建镜像
build_image() {
    if [ "$SKIP_BUILD" = "true" ]; then
        log_warning "跳过构建"
        return
    fi
    
    log_info "构建 Docker 镜像..."
    
    cd "$PROJECT_ROOT"
    
    # 获取版本信息
    local git_commit=$(git rev-parse --short HEAD)
    local git_tag=$(git describe --tags --exact-match 2>/dev/null || echo "")
    local timestamp=$(date +%Y%m%d-%H%M%S)
    
    if [ -n "$git_tag" ]; then
        IMAGE_TAG="$git_tag"
    else
        IMAGE_TAG="$ENVIRONMENT-$git_commit-$timestamp"
    fi
    
    local image_name="$DOCKER_REGISTRY/agentfoundry:$IMAGE_TAG"
    
    # 构建镜像
    if ! docker build -t "$image_name" .; then
        log_error "镜像构建失败"
        exit 1
    fi
    
    # 推送镜像到仓库
    if [ "$DOCKER_REGISTRY" != "localhost:5000" ]; then
        log_info "推送镜像到仓库..."
        if ! docker push "$image_name"; then
            log_error "镜像推送失败"
            exit 1
        fi
    fi
    
    log_success "镜像构建完成: $image_name"
}

# 备份当前版本
backup_current_version() {
    log_info "备份当前版本..."
    
    local backup_dir="$PROJECT_ROOT/backups/$ENVIRONMENT"
    local backup_file="$backup_dir/backup-$(date +%Y%m%d-%H%M%S).tar.gz"
    
    mkdir -p "$backup_dir"
    
    # 备份配置和数据
    if [ -d "data" ]; then
        tar -czf "$backup_file" data/ configs/ || true
        log_success "备份完成: $backup_file"
    else
        log_info "无需备份数据"
    fi
}

# 部署应用
deploy_application() {
    log_info "部署应用到 $ENVIRONMENT 环境..."
    
    if [ "$DRY_RUN" = "true" ]; then
        log_info "[DRY RUN] 模拟部署过程"
        return
    fi
    
    cd "$PROJECT_ROOT"
    
    # 更新环境变量
    export ENVIRONMENT
    export IMAGE_TAG
    export DOCKER_REGISTRY
    
    # 停止旧服务
    log_info "停止旧服务..."
    docker-compose -f "docker-compose.$ENVIRONMENT.yml" down || true
    
    # 启动新服务
    log_info "启动新服务..."
    if ! docker-compose -f "docker-compose.$ENVIRONMENT.yml" up -d; then
        log_error "服务启动失败"
        exit 1
    fi
    
    log_success "应用部署完成"
}

# 健康检查
health_check() {
    log_info "执行健康检查..."
    
    local retries=0
    local max_retries=$HEALTH_CHECK_RETRIES
    
    while [ $retries -lt $max_retries ]; do
        if curl -f "$HEALTH_CHECK_URL" >/dev/null 2>&1; then
            log_success "健康检查通过"
            return 0
        fi
        
        retries=$((retries + 1))
        log_info "健康检查失败，重试 $retries/$max_retries..."
        sleep $HEALTH_CHECK_INTERVAL
    done
    
    log_error "健康检查失败，应用可能未正常启动"
    return 1
}

# 回滚部署
rollback_deployment() {
    log_info "回滚到上一版本..."
    
    cd "$PROJECT_ROOT"
    
    # 查找最新的备份
    local backup_dir="$PROJECT_ROOT/backups/$ENVIRONMENT"
    local latest_backup=$(ls -t "$backup_dir"/backup-*.tar.gz 2>/dev/null | head -n1 || echo "")
    
    if [ -z "$latest_backup" ]; then
        log_error "未找到备份文件"
        exit 1
    fi
    
    log_info "使用备份文件: $latest_backup"
    
    # 停止当前服务
    docker-compose -f "docker-compose.$ENVIRONMENT.yml" down
    
    # 恢复备份
    tar -xzf "$latest_backup" -C "$PROJECT_ROOT"
    
    # 启动服务
    docker-compose -f "docker-compose.$ENVIRONMENT.yml" up -d
    
    # 健康检查
    if health_check; then
        log_success "回滚完成"
    else
        log_error "回滚后健康检查失败"
        exit 1
    fi
}

# 部署后清理
post_deploy_cleanup() {
    log_info "执行部署后清理..."
    
    # 清理旧镜像
    docker image prune -f
    
    # 清理旧备份（保留最近10个）
    local backup_dir="$PROJECT_ROOT/backups/$ENVIRONMENT"
    if [ -d "$backup_dir" ]; then
        ls -t "$backup_dir"/backup-*.tar.gz 2>/dev/null | tail -n +11 | xargs rm -f || true
    fi
    
    log_success "清理完成"
}

# 发送通知
send_notification() {
    local status="$1"
    local message="$2"
    
    log_info "发送部署通知..."
    
    # 这里可以集成 Slack、邮件等通知方式
    # 示例：发送到 Slack
    if [ -n "${SLACK_WEBHOOK_URL:-}" ]; then
        local payload=$(cat <<EOF
{
    "text": "AgentFoundry 部署通知",
    "attachments": [
        {
            "color": "$([ "$status" = "success" ] && echo "good" || echo "danger")",
            "fields": [
                {
                    "title": "环境",
                    "value": "$ENVIRONMENT",
                    "short": true
                },
                {
                    "title": "状态",
                    "value": "$status",
                    "short": true
                },
                {
                    "title": "消息",
                    "value": "$message",
                    "short": false
                },
                {
                    "title": "时间",
                    "value": "$(date)",
                    "short": true
                }
            ]
        }
    ]
}
EOF
        )
        
        curl -X POST -H 'Content-type: application/json' \
             --data "$payload" \
             "$SLACK_WEBHOOK_URL" || true
    fi
    
    log_success "通知发送完成"
}

# 主函数
main() {
    echo "🚀 AgentFoundry 部署脚本"
    echo "========================"
    echo ""
    
    parse_args "$@"
    load_config
    
    if [ "$ROLLBACK" = "true" ]; then
        rollback_deployment
        send_notification "success" "回滚到 $ENVIRONMENT 环境完成"
        return
    fi
    
    log_info "开始部署到 $ENVIRONMENT 环境"
    
    pre_deploy_checks
    run_tests
    build_image
    backup_current_version
    deploy_application
    
    if health_check; then
        post_deploy_cleanup
        send_notification "success" "部署到 $ENVIRONMENT 环境成功"
        log_success "部署完成！"
    else
        log_error "部署失败，开始回滚..."
        rollback_deployment
        send_notification "failure" "部署到 $ENVIRONMENT 环境失败，已回滚"
        exit 1
    fi
}

# 错误处理
trap 'log_error "部署过程中发生错误"' ERR

# 执行主函数
main "$@"