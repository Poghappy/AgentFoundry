#!/bin/bash

# AgentFoundry 环境配置脚本
# 创建时间: 2025-01-27
# 作者: AgentFoundry Team
# 版本: v1.0.0

# 功能描述:
# - 设置开发环境
# - 设置生产环境
# - 配置环境变量
# - 安装依赖

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
ENV_FILE="$PROJECT_ROOT/.env"
ENV_EXAMPLE_FILE="$PROJECT_ROOT/.env.example"
CONFIG_DIR="$PROJECT_ROOT/configs"

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
    echo "使用方法: $0 [options]"
    echo ""
    echo "选项:"
    echo "  --env <environment>  - 环境类型 (development|staging|production)"
    echo "  --force              - 强制覆盖现有配置"
    echo "  --skip-deps          - 跳过依赖安装"
    echo "  --skip-db            - 跳过数据库设置"
    echo "  --interactive        - 交互式配置"
    echo "  --help               - 显示帮助"
    echo ""
    echo "示例:"
    echo "  $0                           - 设置开发环境"
    echo "  $0 --env production          - 设置生产环境"
    echo "  $0 --interactive             - 交互式设置"
    echo "  $0 --force --skip-deps       - 强制重新配置，跳过依赖"
}

# 解析命令行参数
parse_args() {
    ENVIRONMENT="development"
    FORCE=false
    SKIP_DEPS=false
    SKIP_DB=false
    INTERACTIVE=false
    
    while [ $# -gt 0 ]; do
        case "$1" in
            --env)
                ENVIRONMENT="$2"
                shift 2
                ;;
            --force)
                FORCE=true
                shift
                ;;
            --skip-deps)
                SKIP_DEPS=true
                shift
                ;;
            --skip-db)
                SKIP_DB=true
                shift
                ;;
            --interactive)
                INTERACTIVE=true
                shift
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
    done
    
    # 验证环境类型
    case "$ENVIRONMENT" in
        development|staging|production)
            ;;
        *)
            log_error "无效的环境类型: $ENVIRONMENT"
            exit 1
            ;;
    esac
}

# 检查系统要求
check_system_requirements() {
    log_info "检查系统要求..."
    
    local missing_tools=()
    
    # 检查必需工具
    local required_tools=("git" "curl" "docker" "docker-compose")
    
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            missing_tools+=("$tool")
        fi
    done
    
    # 检查 Python
    if ! command -v python3 >/dev/null 2>&1; then
        missing_tools+=("python3")
    else
        local python_version=$(python3 --version | cut -d' ' -f2)
        local major_version=$(echo "$python_version" | cut -d'.' -f1)
        local minor_version=$(echo "$python_version" | cut -d'.' -f2)
        
        if [ "$major_version" -lt 3 ] || ([ "$major_version" -eq 3 ] && [ "$minor_version" -lt 8 ]); then
            log_error "需要 Python 3.8 或更高版本，当前版本: $python_version"
            missing_tools+=("python3>=3.8")
        fi
    fi
    
    # 检查 Node.js
    if ! command -v node >/dev/null 2>&1; then
        missing_tools+=("node")
    else
        local node_version=$(node --version | sed 's/v//')
        local major_version=$(echo "$node_version" | cut -d'.' -f1)
        
        if [ "$major_version" -lt 16 ]; then
            log_error "需要 Node.js 16 或更高版本，当前版本: $node_version"
            missing_tools+=("node>=16")
        fi
    fi
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        log_error "缺少必需工具: ${missing_tools[*]}"
        log_info "请安装缺少的工具后重新运行此脚本"
        exit 1
    fi
    
    log_success "系统要求检查通过"
}

# 创建环境配置文件
create_env_file() {
    log_info "创建环境配置文件..."
    
    if [ -f "$ENV_FILE" ] && [ "$FORCE" = "false" ]; then
        log_warning "环境配置文件已存在: $ENV_FILE"
        if [ "$INTERACTIVE" = "true" ]; then
            echo -n "是否覆盖现有配置文件？ [y/N]: "
            read -r confirm
            if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
                log_info "跳过环境配置文件创建"
                return 0
            fi
        else
            log_info "使用 --force 选项覆盖现有配置"
            return 0
        fi
    fi
    
    # 创建环境配置
    cat > "$ENV_FILE" << EOF
# AgentFoundry 环境配置
# 环境: $ENVIRONMENT
# 生成时间: $(date)

# 应用配置
ENVIRONMENT=$ENVIRONMENT
DEBUG=$([ "$ENVIRONMENT" = "development" ] && echo "true" || echo "false")
SECRET_KEY=$(openssl rand -hex 32)
ALLOWED_HOSTS=localhost,127.0.0.1

# 数据库配置
DB_HOST=localhost
DB_PORT=5432
DB_NAME=agentfoundry
DB_USER=agentfoundry
DB_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)

# Redis 配置
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
REDIS_DB=0

# API 配置
API_HOST=0.0.0.0
API_PORT=8000
API_WORKERS=4
API_TIMEOUT=30

# 认证配置
JWT_SECRET_KEY=$(openssl rand -hex 32)
JWT_ALGORITHM=HS256
JWT_EXPIRATION_HOURS=24

# 文件存储配置
UPLOAD_DIR=./uploads
MAX_UPLOAD_SIZE=10485760
ALLOWED_EXTENSIONS=txt,pdf,png,jpg,jpeg,gif

# 日志配置
LOG_LEVEL=$([ "$ENVIRONMENT" = "development" ] && echo "DEBUG" || echo "INFO")
LOG_DIR=./logs
LOG_MAX_SIZE=10485760
LOG_BACKUP_COUNT=5

# 监控配置
MONITORING_ENABLED=true
METRICS_PORT=9090
HEALTH_CHECK_INTERVAL=30

# AI 模型配置
OPENAI_API_KEY=your_openai_api_key_here
OPENAI_MODEL=gpt-4
OPENAI_MAX_TOKENS=4096
OPENAI_TEMPERATURE=0.7

# 邮件配置
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your_email@gmail.com
SMTP_PASSWORD=your_app_password
SMTP_USE_TLS=true

# 缓存配置
CACHE_TTL=3600
CACHE_MAX_SIZE=1000

# 安全配置
CORS_ORIGINS=http://localhost:3000,http://localhost:8080
CSRF_PROTECTION=true
RATE_LIMIT_PER_MINUTE=60

# 开发配置
HOT_RELOAD=$([ "$ENVIRONMENT" = "development" ] && echo "true" || echo "false")
AUTO_MIGRATE=$([ "$ENVIRONMENT" = "development" ] && echo "true" || echo "false")
SEED_DATA=$([ "$ENVIRONMENT" = "development" ] && echo "true" || echo "false")
EOF
    
    # 根据环境调整配置
    case "$ENVIRONMENT" in
        production)
            # 生产环境特定配置
            cat >> "$ENV_FILE" << EOF

# 生产环境配置
SSL_ENABLED=true
SSL_CERT_PATH=/etc/ssl/certs/agentfoundry.crt
SSL_KEY_PATH=/etc/ssl/private/agentfoundry.key
SESSION_SECURE=true
SESSION_HTTPONLY=true
HSTS_ENABLED=true
EOF
            ;;
        staging)
            # 测试环境特定配置
            cat >> "$ENV_FILE" << EOF

# 测试环境配置
TEST_DATABASE=agentfoundry_test
TEST_REDIS_DB=1
MOCK_EXTERNAL_APIS=true
EOF
            ;;
        development)
            # 开发环境特定配置
            cat >> "$ENV_FILE" << EOF

# 开发环境配置
DEV_TOOLS_ENABLED=true
SQL_ECHO=true
RELOAD_ON_CHANGE=true
PROFILING_ENABLED=true
EOF
            ;;
    esac
    
    log_success "环境配置文件已创建: $ENV_FILE"
    
    # 设置文件权限
    chmod 600 "$ENV_FILE"
    log_info "环境配置文件权限已设置为 600"
}

# 创建示例配置文件
create_env_example() {
    log_info "创建示例配置文件..."
    
    # 创建不包含敏感信息的示例文件
    sed 's/=.*/=your_value_here/g' "$ENV_FILE" > "$ENV_EXAMPLE_FILE"
    
    # 添加说明注释
    cat > "$ENV_EXAMPLE_FILE.tmp" << 'EOF'
# AgentFoundry 环境配置示例
# 复制此文件为 .env 并填入实际值

# 重要提示:
# 1. 不要将包含真实密钥的 .env 文件提交到版本控制
# 2. 生产环境请使用强密码和随机密钥
# 3. 定期轮换密钥和密码

EOF
    
    cat "$ENV_EXAMPLE_FILE" >> "$ENV_EXAMPLE_FILE.tmp"
    mv "$ENV_EXAMPLE_FILE.tmp" "$ENV_EXAMPLE_FILE"
    
    log_success "示例配置文件已创建: $ENV_EXAMPLE_FILE"
}

# 安装 Python 依赖
install_python_deps() {
    if [ "$SKIP_DEPS" = "true" ]; then
        log_info "跳过 Python 依赖安装"
        return 0
    fi
    
    log_info "安装 Python 依赖..."
    
    cd "$PROJECT_ROOT"
    
    # 创建虚拟环境
    if [ ! -d "venv" ]; then
        python3 -m venv venv
        log_success "Python 虚拟环境已创建"
    fi
    
    # 激活虚拟环境
    source venv/bin/activate
    
    # 升级 pip
    pip install --upgrade pip
    
    # 安装依赖
    if [ -f "requirements.txt" ]; then
        pip install -r requirements.txt
        log_success "Python 依赖安装完成"
    else
        log_warning "未找到 requirements.txt 文件"
    fi
    
    # 安装开发依赖
    if [ "$ENVIRONMENT" = "development" ] && [ -f "requirements-dev.txt" ]; then
        pip install -r requirements-dev.txt
        log_success "开发依赖安装完成"
    fi
}

# 安装 Node.js 依赖
install_node_deps() {
    if [ "$SKIP_DEPS" = "true" ]; then
        log_info "跳过 Node.js 依赖安装"
        return 0
    fi
    
    log_info "安装 Node.js 依赖..."
    
    cd "$PROJECT_ROOT"
    
    if [ -f "package.json" ]; then
        # 使用 npm 或 yarn
        if command -v yarn >/dev/null 2>&1; then
            yarn install
            log_success "Node.js 依赖安装完成 (yarn)"
        else
            npm install
            log_success "Node.js 依赖安装完成 (npm)"
        fi
    else
        log_warning "未找到 package.json 文件"
    fi
}

# 设置数据库
setup_database() {
    if [ "$SKIP_DB" = "true" ]; then
        log_info "跳过数据库设置"
        return 0
    fi
    
    log_info "设置数据库..."
    
    # 从环境文件读取数据库配置
    source "$ENV_FILE"
    
    # 检查 PostgreSQL 是否运行
    if ! docker ps | grep -q postgres; then
        log_info "启动 PostgreSQL 容器..."
        docker run -d \
            --name agentfoundry-postgres \
            -e POSTGRES_DB="$DB_NAME" \
            -e POSTGRES_USER="$DB_USER" \
            -e POSTGRES_PASSWORD="$DB_PASSWORD" \
            -p "$DB_PORT:5432" \
            postgres:15
        
        # 等待数据库启动
        log_info "等待数据库启动..."
        sleep 10
    fi
    
    # 检查 Redis 是否运行
    if ! docker ps | grep -q redis; then
        log_info "启动 Redis 容器..."
        docker run -d \
            --name agentfoundry-redis \
            -p "$REDIS_PORT:6379" \
            redis:7 redis-server --requirepass "$REDIS_PASSWORD"
    fi
    
    log_success "数据库设置完成"
}

# 创建必要目录
create_directories() {
    log_info "创建必要目录..."
    
    local dirs=(
        "logs"
        "uploads"
        "data"
        "backups"
        "tmp"
        "configs/local"
    )
    
    for dir in "${dirs[@]}"; do
        mkdir -p "$PROJECT_ROOT/$dir"
        log_info "创建目录: $dir"
    done
    
    # 设置目录权限
    chmod 755 "$PROJECT_ROOT/uploads"
    chmod 755 "$PROJECT_ROOT/logs"
    chmod 700 "$PROJECT_ROOT/configs/local"
    
    log_success "目录创建完成"
}

# 设置 Git hooks
setup_git_hooks() {
    if [ ! -d "$PROJECT_ROOT/.git" ]; then
        log_warning "不是 Git 仓库，跳过 Git hooks 设置"
        return 0
    fi
    
    log_info "设置 Git hooks..."
    
    local hooks_dir="$PROJECT_ROOT/.git/hooks"
    
    # Pre-commit hook
    cat > "$hooks_dir/pre-commit" << 'EOF'
#!/bin/bash
# AgentFoundry pre-commit hook

echo "运行 pre-commit 检查..."

# 检查代码格式
if command -v black >/dev/null 2>&1; then
    black --check .
fi

# 检查代码质量
if command -v flake8 >/dev/null 2>&1; then
    flake8 .
fi

# 运行测试
if [ -f "Makefile" ]; then
    make test-quick
fi

echo "Pre-commit 检查完成"
EOF
    
    chmod +x "$hooks_dir/pre-commit"
    
    log_success "Git hooks 设置完成"
}

# 交互式配置
interactive_config() {
    if [ "$INTERACTIVE" = "false" ]; then
        return 0
    fi
    
    log_info "交互式配置..."
    
    echo ""
    echo "请配置以下设置 (按 Enter 使用默认值):"
    echo ""
    
    # OpenAI API Key
    echo -n "OpenAI API Key: "
    read -r openai_key
    if [ -n "$openai_key" ]; then
        sed -i.bak "s/OPENAI_API_KEY=.*/OPENAI_API_KEY=$openai_key/" "$ENV_FILE"
    fi
    
    # 邮件配置
    echo -n "SMTP 邮箱地址: "
    read -r smtp_user
    if [ -n "$smtp_user" ]; then
        sed -i.bak "s/SMTP_USER=.*/SMTP_USER=$smtp_user/" "$ENV_FILE"
    fi
    
    echo -n "SMTP 密码: "
    read -rs smtp_password
    echo
    if [ -n "$smtp_password" ]; then
        sed -i.bak "s/SMTP_PASSWORD=.*/SMTP_PASSWORD=$smtp_password/" "$ENV_FILE"
    fi
    
    # 清理备份文件
    rm -f "$ENV_FILE.bak"
    
    log_success "交互式配置完成"
}

# 验证配置
validate_config() {
    log_info "验证配置..."
    
    local errors=0
    
    # 检查环境文件
    if [ ! -f "$ENV_FILE" ]; then
        log_error "环境配置文件不存在: $ENV_FILE"
        ((errors++))
    fi
    
    # 检查必要目录
    local required_dirs=("logs" "uploads" "data")
    for dir in "${required_dirs[@]}"; do
        if [ ! -d "$PROJECT_ROOT/$dir" ]; then
            log_error "必要目录不存在: $dir"
            ((errors++))
        fi
    done
    
    # 检查 Python 虚拟环境
    if [ "$SKIP_DEPS" = "false" ] && [ ! -d "$PROJECT_ROOT/venv" ]; then
        log_error "Python 虚拟环境不存在"
        ((errors++))
    fi
    
    if [ $errors -eq 0 ]; then
        log_success "配置验证通过"
    else
        log_error "配置验证失败，发现 $errors 个错误"
        return 1
    fi
}

# 显示后续步骤
show_next_steps() {
    echo ""
    log_success "环境设置完成！"
    echo ""
    echo "后续步骤:"
    echo "1. 编辑 .env 文件，填入实际的 API 密钥和配置"
    echo "2. 启动服务: make dev"
    echo "3. 运行测试: make test"
    echo "4. 查看文档: make docs"
    echo ""
    echo "常用命令:"
    echo "- 激活虚拟环境: source venv/bin/activate"
    echo "- 启动开发服务器: make dev"
    echo "- 查看日志: make logs"
    echo "- 运行备份: ./scripts/backup.sh"
    echo ""
    echo "配置文件位置:"
    echo "- 环境配置: $ENV_FILE"
    echo "- 示例配置: $ENV_EXAMPLE_FILE"
    echo ""
}

# 主函数
main() {
    echo "⚙️  AgentFoundry 环境配置脚本"
    echo "=============================="
    echo ""
    
    parse_args "$@"
    
    log_info "设置 $ENVIRONMENT 环境"
    echo ""
    
    check_system_requirements
    create_env_file
    create_env_example
    create_directories
    install_python_deps
    install_node_deps
    setup_database
    setup_git_hooks
    interactive_config
    validate_config
    show_next_steps
}

# 错误处理
trap 'log_error "环境设置过程中发生错误"' ERR

# 执行主函数
main "$@"