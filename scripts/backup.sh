#!/bin/bash

# AgentFoundry 备份脚本
# 创建时间: 2025-01-27
# 作者: AgentFoundry Team
# 版本: v1.0.0

# 功能描述:
# - 数据库备份
# - 文件系统备份
# - 配置文件备份
# - 自动清理旧备份

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
BACKUP_DIR="$PROJECT_ROOT/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=30
MAX_BACKUPS=10

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
    echo "  --type <type>        - 备份类型 (full|db|files|config)"
    echo "  --output <path>      - 输出目录 (默认: $BACKUP_DIR)"
    echo "  --compress           - 压缩备份文件"
    echo "  --encrypt            - 加密备份文件"
    echo "  --remote <url>       - 上传到远程存储"
    echo "  --cleanup            - 清理旧备份"
    echo "  --list               - 列出现有备份"
    echo "  --help               - 显示帮助"
    echo ""
    echo "示例:"
    echo "  $0                           - 完整备份"
    echo "  $0 --type db                 - 仅备份数据库"
    echo "  $0 --compress --encrypt      - 压缩并加密备份"
    echo "  $0 --cleanup                 - 清理旧备份"
    echo "  $0 --list                    - 列出备份"
}

# 解析命令行参数
parse_args() {
    BACKUP_TYPE="full"
    OUTPUT_DIR="$BACKUP_DIR"
    COMPRESS=false
    ENCRYPT=false
    REMOTE_URL=""
    CLEANUP_ONLY=false
    LIST_ONLY=false
    
    while [ $# -gt 0 ]; do
        case "$1" in
            --type)
                BACKUP_TYPE="$2"
                shift 2
                ;;
            --output)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            --compress)
                COMPRESS=true
                shift
                ;;
            --encrypt)
                ENCRYPT=true
                shift
                ;;
            --remote)
                REMOTE_URL="$2"
                shift 2
                ;;
            --cleanup)
                CLEANUP_ONLY=true
                shift
                ;;
            --list)
                LIST_ONLY=true
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
    
    # 验证备份类型
    case "$BACKUP_TYPE" in
        full|db|files|config)
            ;;
        *)
            log_error "无效的备份类型: $BACKUP_TYPE"
            exit 1
            ;;
    esac
}

# 创建备份目录
setup_backup_dir() {
    mkdir -p "$OUTPUT_DIR"
    
    if [ ! -w "$OUTPUT_DIR" ]; then
        log_error "备份目录不可写: $OUTPUT_DIR"
        exit 1
    fi
    
    log_info "备份目录: $OUTPUT_DIR"
}

# 检查磁盘空间
check_disk_space() {
    local required_space=1048576  # 1GB in KB
    local available_space=$(df "$OUTPUT_DIR" | awk 'NR==2 {print $4}')
    
    if [ "$available_space" -lt "$required_space" ]; then
        log_error "磁盘空间不足，需要至少 1GB 可用空间"
        exit 1
    fi
    
    log_info "可用磁盘空间: $(( available_space / 1024 ))MB"
}

# 备份数据库
backup_database() {
    log_info "备份数据库..."
    
    local db_backup_file="$OUTPUT_DIR/database_$TIMESTAMP.sql"
    
    # 从环境变量或配置文件获取数据库连接信息
    local db_host=${DB_HOST:-"localhost"}
    local db_port=${DB_PORT:-"5432"}
    local db_name=${DB_NAME:-"agentfoundry"}
    local db_user=${DB_USER:-"agentfoundry"}
    local db_password=${DB_PASSWORD:-"password"}
    
    # 检查 PostgreSQL 是否可用
    if ! command -v pg_dump >/dev/null 2>&1; then
        log_error "pg_dump 未安装"
        return 1
    fi
    
    # 执行数据库备份
    export PGPASSWORD="$db_password"
    
    if pg_dump -h "$db_host" -p "$db_port" -U "$db_user" -d "$db_name" > "$db_backup_file"; then
        log_success "数据库备份完成: $db_backup_file"
        
        # 压缩数据库备份
        if [ "$COMPRESS" = "true" ]; then
            gzip "$db_backup_file"
            db_backup_file="$db_backup_file.gz"
            log_info "数据库备份已压缩"
        fi
        
        echo "$db_backup_file"
    else
        log_error "数据库备份失败"
        return 1
    fi
    
    unset PGPASSWORD
}

# 备份文件系统
backup_files() {
    log_info "备份文件系统..."
    
    local files_backup_file="$OUTPUT_DIR/files_$TIMESTAMP.tar"
    
    # 定义需要备份的目录
    local backup_dirs=(
        "data"
        "uploads"
        "logs"
        "configs/local"
    )
    
    # 定义排除的文件和目录
    local exclude_patterns=(
        "--exclude=*.tmp"
        "--exclude=*.log"
        "--exclude=__pycache__"
        "--exclude=node_modules"
        "--exclude=.git"
        "--exclude=venv"
        "--exclude=.env"
    )
    
    cd "$PROJECT_ROOT"
    
    # 创建文件列表
    local existing_dirs=()
    for dir in "${backup_dirs[@]}"; do
        if [ -d "$dir" ]; then
            existing_dirs+=("$dir")
        fi
    done
    
    if [ ${#existing_dirs[@]} -eq 0 ]; then
        log_warning "没有找到需要备份的文件目录"
        return 0
    fi
    
    # 执行文件备份
    if tar "${exclude_patterns[@]}" -cf "$files_backup_file" "${existing_dirs[@]}"; then
        log_success "文件备份完成: $files_backup_file"
        
        # 压缩文件备份
        if [ "$COMPRESS" = "true" ]; then
            gzip "$files_backup_file"
            files_backup_file="$files_backup_file.gz"
            log_info "文件备份已压缩"
        fi
        
        echo "$files_backup_file"
    else
        log_error "文件备份失败"
        return 1
    fi
}

# 备份配置文件
backup_config() {
    log_info "备份配置文件..."
    
    local config_backup_file="$OUTPUT_DIR/config_$TIMESTAMP.tar"
    
    # 定义需要备份的配置文件
    local config_files=(
        "policies"
        "gates"
        "telemetry"
        "runbooks"
        "docker-compose.yml"
        "docker-compose.*.yml"
        "Dockerfile"
        "Makefile"
        "package.json"
        "requirements.txt"
        ".gitignore"
    )
    
    cd "$PROJECT_ROOT"
    
    # 创建配置文件列表
    local existing_files=()
    for pattern in "${config_files[@]}"; do
        # 使用 find 来处理通配符
        while IFS= read -r -d '' file; do
            existing_files+=("$file")
        done < <(find . -maxdepth 1 -name "$pattern" -print0 2>/dev/null || true)
    done
    
    if [ ${#existing_files[@]} -eq 0 ]; then
        log_warning "没有找到需要备份的配置文件"
        return 0
    fi
    
    # 执行配置备份
    if tar -cf "$config_backup_file" "${existing_files[@]}"; then
        log_success "配置备份完成: $config_backup_file"
        
        # 压缩配置备份
        if [ "$COMPRESS" = "true" ]; then
            gzip "$config_backup_file"
            config_backup_file="$config_backup_file.gz"
            log_info "配置备份已压缩"
        fi
        
        echo "$config_backup_file"
    else
        log_error "配置备份失败"
        return 1
    fi
}

# 加密备份文件
encrypt_backup() {
    local backup_file="$1"
    
    if [ "$ENCRYPT" = "false" ]; then
        return 0
    fi
    
    log_info "加密备份文件..."
    
    if ! command -v gpg >/dev/null 2>&1; then
        log_error "gpg 未安装，无法加密备份"
        return 1
    fi
    
    local encrypted_file="$backup_file.gpg"
    local passphrase=${BACKUP_PASSPHRASE:-"agentfoundry-backup-$(date +%Y%m)"}
    
    if gpg --batch --yes --passphrase "$passphrase" --symmetric --cipher-algo AES256 --output "$encrypted_file" "$backup_file"; then
        rm "$backup_file"
        log_success "备份文件已加密: $encrypted_file"
        echo "$encrypted_file"
    else
        log_error "备份文件加密失败"
        return 1
    fi
}

# 上传到远程存储
upload_to_remote() {
    local backup_file="$1"
    
    if [ -z "$REMOTE_URL" ]; then
        return 0
    fi
    
    log_info "上传备份到远程存储..."
    
    case "$REMOTE_URL" in
        s3://*)
            if command -v aws >/dev/null 2>&1; then
                aws s3 cp "$backup_file" "$REMOTE_URL/$(basename "$backup_file")"
                log_success "备份已上传到 S3"
            else
                log_error "aws cli 未安装"
                return 1
            fi
            ;;
        ftp://*|sftp://*)
            if command -v rsync >/dev/null 2>&1; then
                rsync -avz "$backup_file" "$REMOTE_URL/"
                log_success "备份已上传到远程服务器"
            else
                log_error "rsync 未安装"
                return 1
            fi
            ;;
        *)
            log_error "不支持的远程存储类型: $REMOTE_URL"
            return 1
            ;;
    esac
}

# 清理旧备份
cleanup_old_backups() {
    log_info "清理旧备份..."
    
    # 按时间清理
    find "$OUTPUT_DIR" -name "*.tar*" -o -name "*.sql*" -o -name "*.gpg" | \
        while read -r file; do
            if [ "$(find "$file" -mtime +$RETENTION_DAYS -print)" ]; then
                rm "$file"
                log_info "删除过期备份: $(basename "$file")"
            fi
        done
    
    # 按数量清理（保留最新的备份）
    for backup_type in "database" "files" "config"; do
        ls -t "$OUTPUT_DIR"/${backup_type}_*.* 2>/dev/null | tail -n +$((MAX_BACKUPS + 1)) | \
            while read -r file; do
                rm "$file"
                log_info "删除多余备份: $(basename "$file")"
            done
    done
    
    log_success "旧备份清理完成"
}

# 列出现有备份
list_backups() {
    log_info "现有备份列表:"
    echo ""
    
    if [ ! -d "$OUTPUT_DIR" ]; then
        log_warning "备份目录不存在: $OUTPUT_DIR"
        return
    fi
    
    local backup_files=()
    while IFS= read -r -d '' file; do
        backup_files+=("$file")
    done < <(find "$OUTPUT_DIR" -name "*.tar*" -o -name "*.sql*" -o -name "*.gpg" -print0 2>/dev/null | sort -z)
    
    if [ ${#backup_files[@]} -eq 0 ]; then
        log_warning "没有找到备份文件"
        return
    fi
    
    printf "%-20s %-15s %-10s %s\n" "类型" "时间" "大小" "文件名"
    printf "%-20s %-15s %-10s %s\n" "----" "----" "----" "--------"
    
    for file in "${backup_files[@]}"; do
        local basename=$(basename "$file")
        local size=$(du -h "$file" | cut -f1)
        local mtime=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$file" 2>/dev/null || stat -c "%y" "$file" | cut -d' ' -f1-2)
        
        local backup_type="未知"
        case "$basename" in
            database_*) backup_type="数据库" ;;
            files_*) backup_type="文件" ;;
            config_*) backup_type="配置" ;;
            full_*) backup_type="完整" ;;
        esac
        
        printf "%-20s %-15s %-10s %s\n" "$backup_type" "$mtime" "$size" "$basename"
    done
    
    echo ""
    log_info "总计 ${#backup_files[@]} 个备份文件"
}

# 创建完整备份
create_full_backup() {
    log_info "创建完整备份..."
    
    local full_backup_file="$OUTPUT_DIR/full_$TIMESTAMP.tar"
    local backup_files=()
    
    # 备份数据库
    if db_file=$(backup_database); then
        backup_files+=("$db_file")
    fi
    
    # 备份文件
    if files_file=$(backup_files); then
        backup_files+=("$files_file")
    fi
    
    # 备份配置
    if config_file=$(backup_config); then
        backup_files+=("$config_file")
    fi
    
    # 合并所有备份
    if [ ${#backup_files[@]} -gt 0 ]; then
        tar -cf "$full_backup_file" -C "$OUTPUT_DIR" $(basename "${backup_files[@]}")
        
        # 删除临时文件
        rm "${backup_files[@]}"
        
        log_success "完整备份创建完成: $full_backup_file"
        
        # 处理压缩和加密
        local final_backup="$full_backup_file"
        
        if [ "$COMPRESS" = "true" ]; then
            gzip "$final_backup"
            final_backup="$final_backup.gz"
        fi
        
        if [ "$ENCRYPT" = "true" ]; then
            final_backup=$(encrypt_backup "$final_backup")
        fi
        
        # 上传到远程
        upload_to_remote "$final_backup"
        
        echo "$final_backup"
    else
        log_error "没有创建任何备份文件"
        return 1
    fi
}

# 生成备份报告
generate_backup_report() {
    local backup_file="$1"
    local report_file="$OUTPUT_DIR/backup_report_$TIMESTAMP.txt"
    
    cat > "$report_file" << EOF
AgentFoundry 备份报告
====================

备份时间: $(date)
备份类型: $BACKUP_TYPE
备份文件: $(basename "$backup_file")
文件大小: $(du -h "$backup_file" | cut -f1)
压缩: $([ "$COMPRESS" = "true" ] && echo "是" || echo "否")
加密: $([ "$ENCRYPT" = "true" ] && echo "是" || echo "否")
远程存储: $([ -n "$REMOTE_URL" ] && echo "$REMOTE_URL" || echo "无")

系统信息:
- 主机名: $(hostname)
- 操作系统: $(uname -s)
- 磁盘使用: $(df -h "$OUTPUT_DIR" | awk 'NR==2 {print $5 " (" $3 "/" $2 ")"}')

备份内容:
EOF
    
    if [ "$BACKUP_TYPE" = "full" ] || [ "$BACKUP_TYPE" = "db" ]; then
        echo "- 数据库" >> "$report_file"
    fi
    
    if [ "$BACKUP_TYPE" = "full" ] || [ "$BACKUP_TYPE" = "files" ]; then
        echo "- 文件系统" >> "$report_file"
    fi
    
    if [ "$BACKUP_TYPE" = "full" ] || [ "$BACKUP_TYPE" = "config" ]; then
        echo "- 配置文件" >> "$report_file"
    fi
    
    log_success "备份报告生成: $report_file"
}

# 主函数
main() {
    echo "💾 AgentFoundry 备份脚本"
    echo "========================"
    echo ""
    
    parse_args "$@"
    
    if [ "$LIST_ONLY" = "true" ]; then
        list_backups
        return
    fi
    
    if [ "$CLEANUP_ONLY" = "true" ]; then
        setup_backup_dir
        cleanup_old_backups
        return
    fi
    
    setup_backup_dir
    check_disk_space
    
    local backup_file=""
    
    case "$BACKUP_TYPE" in
        full)
            backup_file=$(create_full_backup)
            ;;
        db)
            backup_file=$(backup_database)
            if [ "$ENCRYPT" = "true" ]; then
                backup_file=$(encrypt_backup "$backup_file")
            fi
            upload_to_remote "$backup_file"
            ;;
        files)
            backup_file=$(backup_files)
            if [ "$ENCRYPT" = "true" ]; then
                backup_file=$(encrypt_backup "$backup_file")
            fi
            upload_to_remote "$backup_file"
            ;;
        config)
            backup_file=$(backup_config)
            if [ "$ENCRYPT" = "true" ]; then
                backup_file=$(encrypt_backup "$backup_file")
            fi
            upload_to_remote "$backup_file"
            ;;
    esac
    
    if [ -n "$backup_file" ]; then
        generate_backup_report "$backup_file"
        cleanup_old_backups
        log_success "备份完成: $(basename "$backup_file")"
    else
        log_error "备份失败"
        exit 1
    fi
}

# 错误处理
trap 'log_error "备份过程中发生错误"' ERR

# 执行主函数
main "$@"