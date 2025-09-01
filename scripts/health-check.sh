#!/bin/bash

# AgentFoundry 健康检查脚本
# 创建时间: 2025-01-27
# 作者: AgentFoundry Team
# 版本: v1.0.0

# 功能描述:
# - 检查系统健康状态
# - 监控服务运行状态
# - 检查资源使用情况
# - 生成健康报告

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
LOG_FILE="$PROJECT_ROOT/logs/health-check.log"
REPORT_FILE="$PROJECT_ROOT/logs/health-report-$(date +%Y%m%d-%H%M%S).json"
TIMEOUT=30
MAX_CPU_USAGE=80
MAX_MEMORY_USAGE=80
MAX_DISK_USAGE=85

# 健康检查结果
HEALTH_STATUS="healthy"
CHECK_RESULTS=()
ERROR_COUNT=0
WARNING_COUNT=0

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] $1" >> "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [SUCCESS] $1" >> "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [WARNING] $1" >> "$LOG_FILE"
    ((WARNING_COUNT++))
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $1" >> "$LOG_FILE"
    ((ERROR_COUNT++))
    HEALTH_STATUS="unhealthy"
}

# 显示使用方法
show_usage() {
    echo "使用方法: $0 [options]"
    echo ""
    echo "选项:"
    echo "  --timeout <seconds>      - 检查超时时间 (默认: 30)"
    echo "  --output <format>        - 输出格式 (text|json|html) (默认: text)"
    echo "  --report-file <path>     - 报告文件路径"
    echo "  --no-log                - 不写入日志文件"
    echo "  --verbose                - 详细输出"
    echo "  --check <service>        - 只检查指定服务"
    echo "  --help                   - 显示帮助"
    echo ""
    echo "可检查的服务:"
    echo "  api, database, redis, storage, monitoring, all"
    echo ""
    echo "示例:"
    echo "  $0                       - 完整健康检查"
    echo "  $0 --check api           - 只检查 API 服务"
    echo "  $0 --output json         - JSON 格式输出"
    echo "  $0 --timeout 60          - 60秒超时"
}

# 解析命令行参数
parse_args() {
    OUTPUT_FORMAT="text"
    NO_LOG=false
    VERBOSE=false
    CHECK_SERVICE="all"
    
    while [ $# -gt 0 ]; do
        case "$1" in
            --timeout)
                TIMEOUT="$2"
                shift 2
                ;;
            --output)
                OUTPUT_FORMAT="$2"
                shift 2
                ;;
            --report-file)
                REPORT_FILE="$2"
                shift 2
                ;;
            --no-log)
                NO_LOG=true
                shift
                ;;
            --verbose)
                VERBOSE=true
                shift
                ;;
            --check)
                CHECK_SERVICE="$2"
                shift 2
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
    
    # 验证输出格式
    case "$OUTPUT_FORMAT" in
        text|json|html)
            ;;
        *)
            log_error "无效的输出格式: $OUTPUT_FORMAT"
            exit 1
            ;;
    esac
}

# 初始化
init_health_check() {
    # 创建日志目录
    mkdir -p "$(dirname "$LOG_FILE")"
    
    if [ "$NO_LOG" = "false" ]; then
        log_info "开始健康检查 - $(date)"
        log_info "检查服务: $CHECK_SERVICE"
        log_info "输出格式: $OUTPUT_FORMAT"
        log_info "超时时间: ${TIMEOUT}s"
    fi
}

# 添加检查结果
add_check_result() {
    local service="$1"
    local status="$2"
    local message="$3"
    local details="${4:-}"
    
    local result="{"
    result+="\"service\": \"$service\", "
    result+="\"status\": \"$status\", "
    result+="\"message\": \"$message\", "
    result+="\"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\", "
    result+="\"details\": \"$details\""
    result+="}"
    
    CHECK_RESULTS+=("$result")
}

# 检查系统资源
check_system_resources() {
    if [ "$CHECK_SERVICE" != "all" ] && [ "$CHECK_SERVICE" != "system" ]; then
        return 0
    fi
    
    log_info "检查系统资源..."
    
    # 检查 CPU 使用率
    local cpu_usage
    if command -v top >/dev/null 2>&1; then
        cpu_usage=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')
    else
        cpu_usage="0"
    fi
    
    if [ "${cpu_usage%.*}" -gt "$MAX_CPU_USAGE" ]; then
        log_warning "CPU 使用率过高: ${cpu_usage}%"
        add_check_result "system" "warning" "High CPU usage: ${cpu_usage}%" "threshold: ${MAX_CPU_USAGE}%"
    else
        log_success "CPU 使用率正常: ${cpu_usage}%"
        add_check_result "system" "healthy" "CPU usage normal: ${cpu_usage}%" "threshold: ${MAX_CPU_USAGE}%"
    fi
    
    # 检查内存使用率
    local memory_usage
    if command -v free >/dev/null 2>&1; then
        memory_usage=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')
    elif command -v vm_stat >/dev/null 2>&1; then
        # macOS
        local pages_free=$(vm_stat | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
        local pages_active=$(vm_stat | grep "Pages active" | awk '{print $3}' | sed 's/\.//')
        local pages_inactive=$(vm_stat | grep "Pages inactive" | awk '{print $3}' | sed 's/\.//')
        local pages_speculative=$(vm_stat | grep "Pages speculative" | awk '{print $3}' | sed 's/\.//')
        local pages_wired=$(vm_stat | grep "Pages wired down" | awk '{print $4}' | sed 's/\.//')
        
        local total_pages=$((pages_free + pages_active + pages_inactive + pages_speculative + pages_wired))
        local used_pages=$((pages_active + pages_inactive + pages_wired))
        memory_usage=$((used_pages * 100 / total_pages))
    else
        memory_usage="0"
    fi
    
    if [ "$memory_usage" -gt "$MAX_MEMORY_USAGE" ]; then
        log_warning "内存使用率过高: ${memory_usage}%"
        add_check_result "system" "warning" "High memory usage: ${memory_usage}%" "threshold: ${MAX_MEMORY_USAGE}%"
    else
        log_success "内存使用率正常: ${memory_usage}%"
        add_check_result "system" "healthy" "Memory usage normal: ${memory_usage}%" "threshold: ${MAX_MEMORY_USAGE}%"
    fi
    
    # 检查磁盘使用率
    local disk_usage
    disk_usage=$(df "$PROJECT_ROOT" | tail -1 | awk '{print $5}' | sed 's/%//')
    
    if [ "$disk_usage" -gt "$MAX_DISK_USAGE" ]; then
        log_warning "磁盘使用率过高: ${disk_usage}%"
        add_check_result "system" "warning" "High disk usage: ${disk_usage}%" "threshold: ${MAX_DISK_USAGE}%"
    else
        log_success "磁盘使用率正常: ${disk_usage}%"
        add_check_result "system" "healthy" "Disk usage normal: ${disk_usage}%" "threshold: ${MAX_DISK_USAGE}%"
    fi
}

# 检查 API 服务
check_api_service() {
    if [ "$CHECK_SERVICE" != "all" ] && [ "$CHECK_SERVICE" != "api" ]; then
        return 0
    fi
    
    log_info "检查 API 服务..."
    
    # 从环境文件读取配置
    if [ -f "$ENV_FILE" ]; then
        source "$ENV_FILE"
    else
        API_HOST="localhost"
        API_PORT="8000"
    fi
    
    local api_url="http://${API_HOST}:${API_PORT}/health"
    
    # 检查 API 健康端点
    if curl -s --max-time "$TIMEOUT" "$api_url" >/dev/null 2>&1; then
        log_success "API 服务运行正常"
        add_check_result "api" "healthy" "API service is running" "url: $api_url"
        
        # 检查响应时间
        local response_time
        response_time=$(curl -s -w "%{time_total}" --max-time "$TIMEOUT" "$api_url" -o /dev/null)
        
        if (( $(echo "$response_time > 2.0" | bc -l) )); then
            log_warning "API 响应时间较慢: ${response_time}s"
            add_check_result "api" "warning" "Slow API response: ${response_time}s" "threshold: 2.0s"
        else
            log_success "API 响应时间正常: ${response_time}s"
            add_check_result "api" "healthy" "API response time normal: ${response_time}s" "threshold: 2.0s"
        fi
    else
        log_error "API 服务无法访问"
        add_check_result "api" "unhealthy" "API service unreachable" "url: $api_url"
    fi
}

# 检查数据库
check_database() {
    if [ "$CHECK_SERVICE" != "all" ] && [ "$CHECK_SERVICE" != "database" ]; then
        return 0
    fi
    
    log_info "检查数据库..."
    
    # 从环境文件读取配置
    if [ -f "$ENV_FILE" ]; then
        source "$ENV_FILE"
    else
        DB_HOST="localhost"
        DB_PORT="5432"
        DB_NAME="agentfoundry"
        DB_USER="agentfoundry"
    fi
    
    # 检查 PostgreSQL 连接
    if command -v pg_isready >/dev/null 2>&1; then
        if pg_isready -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" >/dev/null 2>&1; then
            log_success "数据库连接正常"
            add_check_result "database" "healthy" "Database connection successful" "host: $DB_HOST:$DB_PORT"
        else
            log_error "数据库连接失败"
            add_check_result "database" "unhealthy" "Database connection failed" "host: $DB_HOST:$DB_PORT"
        fi
    else
        # 使用 Docker 检查
        if docker ps | grep -q postgres; then
            log_success "数据库容器运行正常"
            add_check_result "database" "healthy" "Database container running" "container: postgres"
        else
            log_error "数据库容器未运行"
            add_check_result "database" "unhealthy" "Database container not running" "container: postgres"
        fi
    fi
}

# 检查 Redis
check_redis() {
    if [ "$CHECK_SERVICE" != "all" ] && [ "$CHECK_SERVICE" != "redis" ]; then
        return 0
    fi
    
    log_info "检查 Redis..."
    
    # 从环境文件读取配置
    if [ -f "$ENV_FILE" ]; then
        source "$ENV_FILE"
    else
        REDIS_HOST="localhost"
        REDIS_PORT="6379"
    fi
    
    # 检查 Redis 连接
    if command -v redis-cli >/dev/null 2>&1; then
        if redis-cli -h "$REDIS_HOST" -p "$REDIS_PORT" ping >/dev/null 2>&1; then
            log_success "Redis 连接正常"
            add_check_result "redis" "healthy" "Redis connection successful" "host: $REDIS_HOST:$REDIS_PORT"
        else
            log_error "Redis 连接失败"
            add_check_result "redis" "unhealthy" "Redis connection failed" "host: $REDIS_HOST:$REDIS_PORT"
        fi
    else
        # 使用 Docker 检查
        if docker ps | grep -q redis; then
            log_success "Redis 容器运行正常"
            add_check_result "redis" "healthy" "Redis container running" "container: redis"
        else
            log_error "Redis 容器未运行"
            add_check_result "redis" "unhealthy" "Redis container not running" "container: redis"
        fi
    fi
}

# 检查存储
check_storage() {
    if [ "$CHECK_SERVICE" != "all" ] && [ "$CHECK_SERVICE" != "storage" ]; then
        return 0
    fi
    
    log_info "检查存储..."
    
    # 检查上传目录
    local upload_dir="$PROJECT_ROOT/uploads"
    if [ -d "$upload_dir" ] && [ -w "$upload_dir" ]; then
        log_success "上传目录可写"
        add_check_result "storage" "healthy" "Upload directory writable" "path: $upload_dir"
    else
        log_error "上传目录不可写"
        add_check_result "storage" "unhealthy" "Upload directory not writable" "path: $upload_dir"
    fi
    
    # 检查日志目录
    local log_dir="$PROJECT_ROOT/logs"
    if [ -d "$log_dir" ] && [ -w "$log_dir" ]; then
        log_success "日志目录可写"
        add_check_result "storage" "healthy" "Log directory writable" "path: $log_dir"
    else
        log_error "日志目录不可写"
        add_check_result "storage" "unhealthy" "Log directory not writable" "path: $log_dir"
    fi
    
    # 检查数据目录
    local data_dir="$PROJECT_ROOT/data"
    if [ -d "$data_dir" ] && [ -w "$data_dir" ]; then
        log_success "数据目录可写"
        add_check_result "storage" "healthy" "Data directory writable" "path: $data_dir"
    else
        log_error "数据目录不可写"
        add_check_result "storage" "unhealthy" "Data directory not writable" "path: $data_dir"
    fi
}

# 检查监控服务
check_monitoring() {
    if [ "$CHECK_SERVICE" != "all" ] && [ "$CHECK_SERVICE" != "monitoring" ]; then
        return 0
    fi
    
    log_info "检查监控服务..."
    
    # 检查 Prometheus
    if curl -s --max-time "$TIMEOUT" "http://localhost:9090/api/v1/query?query=up" >/dev/null 2>&1; then
        log_success "Prometheus 运行正常"
        add_check_result "monitoring" "healthy" "Prometheus is running" "url: http://localhost:9090"
    else
        log_warning "Prometheus 无法访问"
        add_check_result "monitoring" "warning" "Prometheus unreachable" "url: http://localhost:9090"
    fi
    
    # 检查 Grafana
    if curl -s --max-time "$TIMEOUT" "http://localhost:3001/api/health" >/dev/null 2>&1; then
        log_success "Grafana 运行正常"
        add_check_result "monitoring" "healthy" "Grafana is running" "url: http://localhost:3001"
    else
        log_warning "Grafana 无法访问"
        add_check_result "monitoring" "warning" "Grafana unreachable" "url: http://localhost:3001"
    fi
}

# 检查 Docker 服务
check_docker_services() {
    if [ "$CHECK_SERVICE" != "all" ] && [ "$CHECK_SERVICE" != "docker" ]; then
        return 0
    fi
    
    log_info "检查 Docker 服务..."
    
    if ! command -v docker >/dev/null 2>&1; then
        log_warning "Docker 未安装"
        add_check_result "docker" "warning" "Docker not installed" ""
        return 0
    fi
    
    # 检查 Docker 守护进程
    if docker info >/dev/null 2>&1; then
        log_success "Docker 守护进程运行正常"
        add_check_result "docker" "healthy" "Docker daemon running" ""
        
        # 检查容器状态
        local containers
        containers=$(docker ps --format "table {{.Names}}\t{{.Status}}" | tail -n +2)
        
        if [ -n "$containers" ]; then
            log_info "运行中的容器:"
            echo "$containers"
            add_check_result "docker" "healthy" "Containers running" "count: $(echo "$containers" | wc -l)"
        else
            log_warning "没有运行中的容器"
            add_check_result "docker" "warning" "No containers running" ""
        fi
    else
        log_error "Docker 守护进程未运行"
        add_check_result "docker" "unhealthy" "Docker daemon not running" ""
    fi
}

# 生成文本报告
generate_text_report() {
    echo ""
    echo "=============================="
    echo "AgentFoundry 健康检查报告"
    echo "=============================="
    echo "检查时间: $(date)"
    echo "总体状态: $HEALTH_STATUS"
    echo "错误数量: $ERROR_COUNT"
    echo "警告数量: $WARNING_COUNT"
    echo "=============================="
    echo ""
    
    if [ ${#CHECK_RESULTS[@]} -gt 0 ]; then
        echo "详细结果:"
        for result in "${CHECK_RESULTS[@]}"; do
            local service=$(echo "$result" | jq -r '.service')
            local status=$(echo "$result" | jq -r '.status')
            local message=$(echo "$result" | jq -r '.message')
            local details=$(echo "$result" | jq -r '.details')
            
            case "$status" in
                "healthy")
                    echo -e "${GREEN}✓${NC} $service: $message"
                    ;;
                "warning")
                    echo -e "${YELLOW}⚠${NC} $service: $message"
                    ;;
                "unhealthy")
                    echo -e "${RED}✗${NC} $service: $message"
                    ;;
            esac
            
            if [ "$details" != "null" ] && [ -n "$details" ] && [ "$VERBOSE" = "true" ]; then
                echo "    详情: $details"
            fi
        done
    fi
    
    echo ""
}

# 生成 JSON 报告
generate_json_report() {
    local json_results="["
    local first=true
    
    for result in "${CHECK_RESULTS[@]}"; do
        if [ "$first" = "true" ]; then
            first=false
        else
            json_results+=","
        fi
        json_results+="$result"
    done
    
    json_results+="]"
    
    local report="{"
    report+="\"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\", "
    report+="\"overall_status\": \"$HEALTH_STATUS\", "
    report+="\"error_count\": $ERROR_COUNT, "
    report+="\"warning_count\": $WARNING_COUNT, "
    report+="\"checks\": $json_results"
    report+="}"
    
    echo "$report" | jq .
}

# 生成 HTML 报告
generate_html_report() {
    cat << EOF
<!DOCTYPE html>
<html>
<head>
    <title>AgentFoundry 健康检查报告</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background: #f5f5f5; padding: 20px; border-radius: 5px; }
        .status-healthy { color: #28a745; }
        .status-warning { color: #ffc107; }
        .status-unhealthy { color: #dc3545; }
        .check-item { margin: 10px 0; padding: 10px; border-left: 4px solid #ddd; }
        .check-healthy { border-left-color: #28a745; }
        .check-warning { border-left-color: #ffc107; }
        .check-unhealthy { border-left-color: #dc3545; }
    </style>
</head>
<body>
    <div class="header">
        <h1>AgentFoundry 健康检查报告</h1>
        <p>检查时间: $(date)</p>
        <p>总体状态: <span class="status-$HEALTH_STATUS">$HEALTH_STATUS</span></p>
        <p>错误数量: $ERROR_COUNT | 警告数量: $WARNING_COUNT</p>
    </div>
    
    <h2>检查结果</h2>
EOF
    
    for result in "${CHECK_RESULTS[@]}"; do
        local service=$(echo "$result" | jq -r '.service')
        local status=$(echo "$result" | jq -r '.status')
        local message=$(echo "$result" | jq -r '.message')
        local details=$(echo "$result" | jq -r '.details')
        
        echo "    <div class='check-item check-$status'>"
        echo "        <h3>$service</h3>"
        echo "        <p><strong>状态:</strong> <span class='status-$status'>$status</span></p>"
        echo "        <p><strong>消息:</strong> $message</p>"
        if [ "$details" != "null" ] && [ -n "$details" ]; then
            echo "        <p><strong>详情:</strong> $details</p>"
        fi
        echo "    </div>"
    done
    
    cat << EOF
</body>
</html>
EOF
}

# 保存报告
save_report() {
    if [ "$OUTPUT_FORMAT" = "json" ]; then
        generate_json_report > "$REPORT_FILE"
    elif [ "$OUTPUT_FORMAT" = "html" ]; then
        generate_html_report > "$REPORT_FILE"
    else
        generate_text_report > "$REPORT_FILE"
    fi
    
    log_info "报告已保存: $REPORT_FILE"
}

# 主函数
main() {
    parse_args "$@"
    init_health_check
    
    # 执行健康检查
    check_system_resources
    check_api_service
    check_database
    check_redis
    check_storage
    check_monitoring
    check_docker_services
    
    # 生成报告
    case "$OUTPUT_FORMAT" in
        "json")
            generate_json_report
            ;;
        "html")
            generate_html_report
            ;;
        *)
            generate_text_report
            ;;
    esac
    
    # 保存报告文件
    if [ -n "$REPORT_FILE" ]; then
        save_report
    fi
    
    # 返回适当的退出码
    if [ "$HEALTH_STATUS" = "unhealthy" ]; then
        exit 1
    elif [ "$WARNING_COUNT" -gt 0 ]; then
        exit 2
    else
        exit 0
    fi
}

# 错误处理
trap 'log_error "健康检查过程中发生错误"' ERR

# 执行主函数
main "$@"