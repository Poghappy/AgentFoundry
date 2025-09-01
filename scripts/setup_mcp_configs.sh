#!/bin/bash

# AgentFoundry MCP工具配置应用脚本
# 创建时间: 2024-01-XX
# 作者: AgentFoundry团队
# 版本: v1.0.0

# 功能描述:
# - 批量应用所有智能体的MCP工具配置
# - 验证MCP服务连接状态
# - 设置智能体权限和工具访问

# 使用方法:
#     bash scripts/setup_mcp_configs.sh [选项]
#     选项:
#       --agent <name>  仅配置指定智能体
#       --verify        仅验证配置状态
#       --reset         重置所有配置

# 设置错误处理
set -euo pipefail

# 脚本目录和项目根目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_DIR="$PROJECT_ROOT/agents/mcp_configs"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# 智能体列表
AGENTS=(
    "router_planner"
    "ideation"
    "research"
    "feasibility"
    "product"
    "architecture"
    "integration"
    "design"
    "implementation"
    "qa_evaluation"
    "growth_launch"
)

# 检查Trae IDE环境
check_trae_environment() {
    log_info "检查Trae IDE环境..."
    
    if ! command -v trae &> /dev/null; then
        log_error "Trae IDE未安装或不在PATH中"
        exit 1
    fi
    
    log_success "Trae IDE环境检查通过"
}

# 验证MCP服务状态
verify_mcp_services() {
    log_info "验证MCP服务连接状态..."
    
    # 检查sgai-mcp服务
    if trae mcp status | grep -q "sgai-mcp.*connected"; then
        log_success "sgai-mcp服务连接正常"
    else
        log_warning "sgai-mcp服务连接异常，请检查配置"
    fi
    
    # 检查TaskManager服务
    if trae mcp status | grep -q "TaskManager.*connected"; then
        log_success "TaskManager服务连接正常"
    else
        log_warning "TaskManager服务连接异常，请检查配置"
    fi
    
    # 检查GitHub服务
    if trae mcp status | grep -q "GitHub.*connected"; then
        log_success "GitHub服务连接正常"
    else
        log_warning "GitHub服务连接异常，请检查配置"
    fi
}

# 应用单个智能体配置
apply_agent_config() {
    local agent_name="$1"
    local config_file="$CONFIG_DIR/${agent_name}.json"
    
    if [[ ! -f "$config_file" ]]; then
        log_error "配置文件不存在: $config_file"
        return 1
    fi
    
    log_info "应用 $agent_name 智能体配置..."
    
    # 验证JSON格式
    if ! jq empty "$config_file" 2>/dev/null; then
        log_error "配置文件JSON格式错误: $config_file"
        return 1
    fi
    
    # 应用配置到Trae IDE
    if trae agent config load --file "$config_file" --agent "$agent_name"; then
        log_success "$agent_name 配置应用成功"
    else
        log_error "$agent_name 配置应用失败"
        return 1
    fi
}

# 批量应用所有智能体配置
apply_all_configs() {
    log_info "开始批量应用智能体MCP配置..."
    
    local success_count=0
    local total_count=${#AGENTS[@]}
    
    for agent in "${AGENTS[@]}"; do
        if apply_agent_config "$agent"; then
            ((success_count++))
        fi
    done
    
    log_info "配置应用完成: $success_count/$total_count 成功"
    
    if [[ $success_count -eq $total_count ]]; then
        log_success "所有智能体配置应用成功！"
    else
        log_warning "部分智能体配置应用失败，请检查日志"
    fi
}

# 重置所有配置
reset_all_configs() {
    log_info "重置所有智能体配置..."
    
    for agent in "${AGENTS[@]}"; do
        log_info "重置 $agent 配置..."
        trae agent config reset --agent "$agent" || log_warning "$agent 重置失败"
    done
    
    log_success "配置重置完成"
}

# 显示配置状态
show_config_status() {
    log_info "智能体配置状态:"
    echo
    
    for agent in "${AGENTS[@]}"; do
        local config_file="$CONFIG_DIR/${agent}.json"
        if [[ -f "$config_file" ]]; then
            local agent_desc=$(jq -r '.description' "$config_file")
            local tool_count=$(jq -r '.mcp_tools | length' "$config_file")
            printf "  %-20s | %-40s | %s个工具\n" "$agent" "$agent_desc" "$tool_count"
        else
            printf "  %-20s | %-40s | 配置缺失\n" "$agent" "未知"
        fi
    done
    echo
}

# 显示帮助信息
show_help() {
    cat << EOF
AgentFoundry MCP工具配置应用脚本

用法:
    $0 [选项]

选项:
    --agent <name>     仅配置指定智能体
    --verify          仅验证MCP服务和配置状态
    --reset           重置所有智能体配置
    --status          显示当前配置状态
    --help            显示此帮助信息

可用智能体:
$(printf '    %s\n' "${AGENTS[@]}")

示例:
    $0                           # 应用所有智能体配置
    $0 --agent research          # 仅配置research智能体
    $0 --verify                  # 验证服务状态
    $0 --reset                   # 重置所有配置

EOF
}

# 主函数
main() {
    local agent_name=""
    local verify_only=false
    local reset_configs=false
    local show_status=false
    
    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            --agent)
                agent_name="$2"
                shift 2
                ;;
            --verify)
                verify_only=true
                shift
                ;;
            --reset)
                reset_configs=true
                shift
                ;;
            --status)
                show_status=true
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                log_error "未知选项: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # 检查环境
    check_trae_environment
    
    # 根据参数执行相应操作
    if [[ "$show_status" == true ]]; then
        show_config_status
        exit 0
    fi
    
    if [[ "$verify_only" == true ]]; then
        verify_mcp_services
        show_config_status
        exit 0
    fi
    
    if [[ "$reset_configs" == true ]]; then
        reset_all_configs
        exit 0
    fi
    
    # 验证MCP服务
    verify_mcp_services
    
    # 应用配置
    if [[ -n "$agent_name" ]]; then
        # 验证智能体名称
        if [[ ! " ${AGENTS[*]} " =~ " ${agent_name} " ]]; then
            log_error "未知智能体: $agent_name"
            log_info "可用智能体: ${AGENTS[*]}"
            exit 1
        fi
        apply_agent_config "$agent_name"
    else
        apply_all_configs
    fi
    
    log_success "MCP工具配置设置完成！"
    log_info "你现在可以使用配置好的智能体了"
}

# 执行主函数
main "$@"