#!/bin/bash

# AgentFoundry 恢复脚本
# 创建时间: 2025-01-27
# 作者: AgentFoundry Team
# 版本: v1.0.0

# 功能描述:
# - 从备份恢复数据库
# - 从备份恢复文件系统
# - 从备份恢复配置文件
# - 验证恢复完整性

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
RESTORE_DIR="$PROJECT_ROOT/restore_temp"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

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
    echo "  --backup <file>      - 备份文件路径"
    echo "  --type <type>        - 恢复类型 (full|db|files|config)"
    echo "  --target <path>      - 恢复目标目录 (默认: 当前项目)"
    echo "  --decrypt            - 解密备份文件"
    echo "  --verify             - 验证恢复完整性"
    echo "  --dry-run            - 模拟恢复过程"
    echo "  --force              - 强制覆盖现有文件"
    echo "  --list               - 列出可用备份"
    echo "  --help               - 显示帮助"
    echo ""
    echo "示例:"
    echo "  $0 --backup backups/full_20250127_120000.tar.gz"
    echo "  $0 --backup backups/database_20250127_120000.sql --type db"
    echo "  $0 --list"
    echo "  $0 --backup encrypted.tar.gz.gpg --decrypt"
    echo "  $0 --dry-run --backup full_backup.tar"
}

# 解析命令行参数
parse_args() {
    BACKUP_FILE=""
    RESTORE_TYPE="auto"
    TARGET_DIR="$PROJECT_ROOT"
    DECRYPT=false
    VERIFY=true
    DRY_RUN=false
    FORCE=false
    LIST_ONLY=false
    
    while [ $# -gt 0 ]; do
        case "$1" in
            --backup)
                BACKUP_FILE="$2"
                shift 2
                ;;
            --type)
                RESTORE_TYPE="$2"
                shift 2
                ;;
            --target)
                TARGET_DIR="$2"
                shift 2
                ;;
            --decrypt)
                DECRYPT=true
                shift
                ;;
            --verify)
                VERIFY=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --force)
                FORCE=true
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
    
    # 验证恢复类型
    case "$RESTORE_TYPE" in
        auto|full|db|files|config)
            ;;
        *)
            log_error "无效的恢复类型: $RESTORE_TYPE"
            exit 1
            ;;
    esac
}

# 列出可用备份
list_available_backups() {
    log_info "可用备份列表:"
    echo ""
    
    if [ ! -d "$BACKUP_DIR" ]; then
        log_warning "备份目录不存在: $BACKUP_DIR"
        return
    fi
    
    local backup_files=()
    while IFS= read -r -d '' file; do
        backup_files+=("$file")
    done < <(find "$BACKUP_DIR" -name "*.tar*" -o -name "*.sql*" -o -name "*.gpg" -print0 2>/dev/null | sort -z -r)
    
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

# 验证备份文件
validate_backup_file() {
    if [ -z "$BACKUP_FILE" ]; then
        log_error "请指定备份文件"
        return 1
    fi
    
    # 如果是相对路径，尝试在备份目录中查找
    if [ ! -f "$BACKUP_FILE" ] && [ -f "$BACKUP_DIR/$BACKUP_FILE" ]; then
        BACKUP_FILE="$BACKUP_DIR/$BACKUP_FILE"
    fi
    
    if [ ! -f "$BACKUP_FILE" ]; then
        log_error "备份文件不存在: $BACKUP_FILE"
        return 1
    fi
    
    if [ ! -r "$BACKUP_FILE" ]; then
        log_error "备份文件不可读: $BACKUP_FILE"
        return 1
    fi
    
    log_info "备份文件: $BACKUP_FILE"
    log_info "文件大小: $(du -h "$BACKUP_FILE" | cut -f1)"
    
    # 自动检测恢复类型
    if [ "$RESTORE_TYPE" = "auto" ]; then
        local basename=$(basename "$BACKUP_FILE")
        case "$basename" in
            database_*|*.sql*)
                RESTORE_TYPE="db"
                ;;
            files_*)
                RESTORE_TYPE="files"
                ;;
            config_*)
                RESTORE_TYPE="config"
                ;;
            full_*)
                RESTORE_TYPE="full"
                ;;
            *)
                RESTORE_TYPE="full"
                log_warning "无法自动检测备份类型，默认使用完整恢复"
                ;;
        esac
        log_info "自动检测恢复类型: $RESTORE_TYPE"
    fi
}

# 解密备份文件
decrypt_backup() {
    if [ "$DECRYPT" = "false" ]; then
        return 0
    fi
    
    log_info "解密备份文件..."
    
    if ! command -v gpg >/dev/null 2>&1; then
        log_error "gpg 未安装，无法解密备份"
        return 1
    fi
    
    local encrypted_file="$BACKUP_FILE"
    local decrypted_file="${encrypted_file%.gpg}"
    
    if [ "$encrypted_file" = "$decrypted_file" ]; then
        log_error "文件不是加密文件: $BACKUP_FILE"
        return 1
    fi
    
    local passphrase=${BACKUP_PASSPHRASE:-"agentfoundry-backup-$(date +%Y%m)"}
    
    if [ "$DRY_RUN" = "true" ]; then
        log_info "[模拟] 解密文件: $encrypted_file -> $decrypted_file"
        BACKUP_FILE="$decrypted_file"
        return 0
    fi
    
    if gpg --batch --yes --passphrase "$passphrase" --decrypt "$encrypted_file" > "$decrypted_file"; then
        BACKUP_FILE="$decrypted_file"
        log_success "备份文件已解密: $decrypted_file"
    else
        log_error "备份文件解密失败"
        return 1
    fi
}

# 创建恢复目录
setup_restore_dir() {
    if [ "$DRY_RUN" = "true" ]; then
        log_info "[模拟] 创建恢复临时目录: $RESTORE_DIR"
        return 0
    fi
    
    rm -rf "$RESTORE_DIR"
    mkdir -p "$RESTORE_DIR"
    
    if [ ! -w "$RESTORE_DIR" ]; then
        log_error "恢复目录不可写: $RESTORE_DIR"
        return 1
    fi
    
    log_info "恢复临时目录: $RESTORE_DIR"
}

# 提取备份文件
extract_backup() {
    log_info "提取备份文件..."
    
    local backup_file="$BACKUP_FILE"
    local extract_dir="$RESTORE_DIR"
    
    if [ "$DRY_RUN" = "true" ]; then
        log_info "[模拟] 提取备份: $backup_file -> $extract_dir"
        return 0
    fi
    
    case "$backup_file" in
        *.tar.gz|*.tgz)
            tar -xzf "$backup_file" -C "$extract_dir"
            ;;
        *.tar.bz2|*.tbz2)
            tar -xjf "$backup_file" -C "$extract_dir"
            ;;
        *.tar)
            tar -xf "$backup_file" -C "$extract_dir"
            ;;
        *.sql|*.sql.gz)
            # SQL 文件不需要提取
            return 0
            ;;
        *)
            log_error "不支持的备份文件格式: $backup_file"
            return 1
            ;;
    esac
    
    log_success "备份文件提取完成"
}

# 恢复数据库
restore_database() {
    log_info "恢复数据库..."
    
    local db_file="$BACKUP_FILE"
    
    # 如果是从完整备份中恢复，查找数据库文件
    if [ "$RESTORE_TYPE" = "full" ]; then
        local found_db_file=$(find "$RESTORE_DIR" -name "database_*.sql*" | head -1)
        if [ -n "$found_db_file" ]; then
            db_file="$found_db_file"
        else
            log_error "在完整备份中未找到数据库文件"
            return 1
        fi
    fi
    
    # 从环境变量或配置文件获取数据库连接信息
    local db_host=${DB_HOST:-"localhost"}
    local db_port=${DB_PORT:-"5432"}
    local db_name=${DB_NAME:-"agentfoundry"}
    local db_user=${DB_USER:-"agentfoundry"}
    local db_password=${DB_PASSWORD:-"password"}
    
    if [ "$DRY_RUN" = "true" ]; then
        log_info "[模拟] 恢复数据库: $db_file -> $db_name"
        return 0
    fi
    
    # 检查 PostgreSQL 是否可用
    if ! command -v psql >/dev/null 2>&1; then
        log_error "psql 未安装"
        return 1
    fi
    
    # 确认数据库恢复
    if [ "$FORCE" = "false" ]; then
        echo -n "确认要恢复数据库 '$db_name'？这将覆盖现有数据 [y/N]: "
        read -r confirm
        if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
            log_info "数据库恢复已取消"
            return 0
        fi
    fi
    
    export PGPASSWORD="$db_password"
    
    # 处理压缩的 SQL 文件
    local restore_cmd
    case "$db_file" in
        *.sql.gz)
            restore_cmd="gunzip -c '$db_file' | psql -h '$db_host' -p '$db_port' -U '$db_user' -d '$db_name'"
            ;;
        *.sql)
            restore_cmd="psql -h '$db_host' -p '$db_port' -U '$db_user' -d '$db_name' < '$db_file'"
            ;;
        *)
            log_error "不支持的数据库备份格式: $db_file"
            return 1
            ;;
    esac
    
    # 执行数据库恢复
    if eval "$restore_cmd"; then
        log_success "数据库恢复完成"
    else
        log_error "数据库恢复失败"
        return 1
    fi
    
    unset PGPASSWORD
}

# 恢复文件系统
restore_files() {
    log_info "恢复文件系统..."
    
    local files_source="$RESTORE_DIR"
    
    # 如果是从完整备份中恢复，查找文件备份
    if [ "$RESTORE_TYPE" = "full" ]; then
        local found_files=$(find "$RESTORE_DIR" -name "files_*.tar*" | head -1)
        if [ -n "$found_files" ]; then
            # 提取文件备份
            local temp_dir="$RESTORE_DIR/files_temp"
            mkdir -p "$temp_dir"
            
            case "$found_files" in
                *.tar.gz)
                    tar -xzf "$found_files" -C "$temp_dir"
                    ;;
                *.tar)
                    tar -xf "$found_files" -C "$temp_dir"
                    ;;
            esac
            
            files_source="$temp_dir"
        else
            log_warning "在完整备份中未找到文件备份"
            return 0
        fi
    fi
    
    if [ "$DRY_RUN" = "true" ]; then
        log_info "[模拟] 恢复文件: $files_source -> $TARGET_DIR"
        return 0
    fi
    
    # 确认文件恢复
    if [ "$FORCE" = "false" ]; then
        echo -n "确认要恢复文件到 '$TARGET_DIR'？这可能覆盖现有文件 [y/N]: "
        read -r confirm
        if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
            log_info "文件恢复已取消"
            return 0
        fi
    fi
    
    # 恢复文件
    local restore_dirs=("data" "uploads" "logs" "configs/local")
    
    for dir in "${restore_dirs[@]}"; do
        if [ -d "$files_source/$dir" ]; then
            local target_path="$TARGET_DIR/$dir"
            mkdir -p "$(dirname "$target_path")"
            
            if cp -r "$files_source/$dir" "$target_path"; then
                log_success "恢复目录: $dir"
            else
                log_error "恢复目录失败: $dir"
                return 1
            fi
        fi
    done
    
    log_success "文件系统恢复完成"
}

# 恢复配置文件
restore_config() {
    log_info "恢复配置文件..."
    
    local config_source="$RESTORE_DIR"
    
    # 如果是从完整备份中恢复，查找配置备份
    if [ "$RESTORE_TYPE" = "full" ]; then
        local found_config=$(find "$RESTORE_DIR" -name "config_*.tar*" | head -1)
        if [ -n "$found_config" ]; then
            # 提取配置备份
            local temp_dir="$RESTORE_DIR/config_temp"
            mkdir -p "$temp_dir"
            
            case "$found_config" in
                *.tar.gz)
                    tar -xzf "$found_config" -C "$temp_dir"
                    ;;
                *.tar)
                    tar -xf "$found_config" -C "$temp_dir"
                    ;;
            esac
            
            config_source="$temp_dir"
        else
            log_warning "在完整备份中未找到配置备份"
            return 0
        fi
    fi
    
    if [ "$DRY_RUN" = "true" ]; then
        log_info "[模拟] 恢复配置: $config_source -> $TARGET_DIR"
        return 0
    fi
    
    # 确认配置恢复
    if [ "$FORCE" = "false" ]; then
        echo -n "确认要恢复配置文件到 '$TARGET_DIR'？这将覆盖现有配置 [y/N]: "
        read -r confirm
        if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
            log_info "配置恢复已取消"
            return 0
        fi
    fi
    
    # 恢复配置文件
    local config_files=(
        "policies"
        "gates"
        "telemetry"
        "runbooks"
        "docker-compose.yml"
        "Dockerfile"
        "Makefile"
        "package.json"
        "requirements.txt"
        ".gitignore"
    )
    
    for item in "${config_files[@]}"; do
        if [ -e "$config_source/$item" ]; then
            local target_path="$TARGET_DIR/$item"
            
            if [ -d "$config_source/$item" ]; then
                # 目录
                if cp -r "$config_source/$item" "$target_path"; then
                    log_success "恢复配置目录: $item"
                else
                    log_error "恢复配置目录失败: $item"
                fi
            else
                # 文件
                if cp "$config_source/$item" "$target_path"; then
                    log_success "恢复配置文件: $item"
                else
                    log_error "恢复配置文件失败: $item"
                fi
            fi
        fi
    done
    
    log_success "配置文件恢复完成"
}

# 验证恢复完整性
verify_restore() {
    if [ "$VERIFY" = "false" ]; then
        return 0
    fi
    
    log_info "验证恢复完整性..."
    
    local errors=0
    
    # 验证数据库连接
    if [ "$RESTORE_TYPE" = "full" ] || [ "$RESTORE_TYPE" = "db" ]; then
        local db_host=${DB_HOST:-"localhost"}
        local db_port=${DB_PORT:-"5432"}
        local db_name=${DB_NAME:-"agentfoundry"}
        local db_user=${DB_USER:-"agentfoundry"}
        local db_password=${DB_PASSWORD:-"password"}
        
        if [ "$DRY_RUN" = "false" ]; then
            export PGPASSWORD="$db_password"
            if psql -h "$db_host" -p "$db_port" -U "$db_user" -d "$db_name" -c "SELECT 1;" >/dev/null 2>&1; then
                log_success "数据库连接验证通过"
            else
                log_error "数据库连接验证失败"
                ((errors++))
            fi
            unset PGPASSWORD
        fi
    fi
    
    # 验证关键文件
    if [ "$RESTORE_TYPE" = "full" ] || [ "$RESTORE_TYPE" = "files" ]; then
        local key_dirs=("data" "uploads")
        for dir in "${key_dirs[@]}"; do
            if [ -d "$TARGET_DIR/$dir" ]; then
                log_success "目录验证通过: $dir"
            else
                log_warning "目录不存在: $dir"
            fi
        done
    fi
    
    # 验证配置文件
    if [ "$RESTORE_TYPE" = "full" ] || [ "$RESTORE_TYPE" = "config" ]; then
        local key_configs=("policies" "gates")
        for config in "${key_configs[@]}"; do
            if [ -d "$TARGET_DIR/$config" ]; then
                log_success "配置验证通过: $config"
            else
                log_warning "配置目录不存在: $config"
            fi
        done
    fi
    
    if [ $errors -eq 0 ]; then
        log_success "恢复完整性验证通过"
    else
        log_error "恢复完整性验证失败，发现 $errors 个错误"
        return 1
    fi
}

# 清理临时文件
cleanup_temp_files() {
    if [ "$DRY_RUN" = "true" ]; then
        log_info "[模拟] 清理临时文件: $RESTORE_DIR"
        return 0
    fi
    
    if [ -d "$RESTORE_DIR" ]; then
        rm -rf "$RESTORE_DIR"
        log_info "临时文件已清理"
    fi
    
    # 清理解密的临时文件
    if [ "$DECRYPT" = "true" ] && [ -f "$BACKUP_FILE" ] && [[ "$BACKUP_FILE" != *.gpg ]]; then
        rm -f "$BACKUP_FILE"
        log_info "解密临时文件已清理"
    fi
}

# 生成恢复报告
generate_restore_report() {
    local report_file="$TARGET_DIR/restore_report_$TIMESTAMP.txt"
    
    if [ "$DRY_RUN" = "true" ]; then
        log_info "[模拟] 生成恢复报告: $report_file"
        return 0
    fi
    
    cat > "$report_file" << EOF
AgentFoundry 恢复报告
====================

恢复时间: $(date)
备份文件: $(basename "$BACKUP_FILE")
恢复类型: $RESTORE_TYPE
目标目录: $TARGET_DIR
解密: $([ "$DECRYPT" = "true" ] && echo "是" || echo "否")
验证: $([ "$VERIFY" = "true" ] && echo "是" || echo "否")
强制覆盖: $([ "$FORCE" = "true" ] && echo "是" || echo "否")

系统信息:
- 主机名: $(hostname)
- 操作系统: $(uname -s)
- 恢复用户: $(whoami)

恢复内容:
EOF
    
    if [ "$RESTORE_TYPE" = "full" ] || [ "$RESTORE_TYPE" = "db" ]; then
        echo "- 数据库" >> "$report_file"
    fi
    
    if [ "$RESTORE_TYPE" = "full" ] || [ "$RESTORE_TYPE" = "files" ]; then
        echo "- 文件系统" >> "$report_file"
    fi
    
    if [ "$RESTORE_TYPE" = "full" ] || [ "$RESTORE_TYPE" = "config" ]; then
        echo "- 配置文件" >> "$report_file"
    fi
    
    log_success "恢复报告生成: $report_file"
}

# 主函数
main() {
    echo "🔄 AgentFoundry 恢复脚本"
    echo "========================"
    echo ""
    
    parse_args "$@"
    
    if [ "$LIST_ONLY" = "true" ]; then
        list_available_backups
        return
    fi
    
    validate_backup_file
    decrypt_backup
    setup_restore_dir
    
    # 提取备份文件（除了 SQL 文件）
    if [[ "$BACKUP_FILE" != *.sql* ]]; then
        extract_backup
    fi
    
    # 执行恢复
    case "$RESTORE_TYPE" in
        full)
            restore_database
            restore_files
            restore_config
            ;;
        db)
            restore_database
            ;;
        files)
            restore_files
            ;;
        config)
            restore_config
            ;;
    esac
    
    verify_restore
    generate_restore_report
    cleanup_temp_files
    
    if [ "$DRY_RUN" = "true" ]; then
        log_success "恢复模拟完成"
    else
        log_success "恢复完成"
    fi
}

# 错误处理
trap 'log_error "恢复过程中发生错误"; cleanup_temp_files' ERR

# 执行主函数
main "$@"