#!/bin/bash

# AgentFoundry 项目初始化脚本
# 创建时间: 2025-01-27
# 作者: AgentFoundry Team
# 版本: v1.0.0

# 功能描述:
# - 检查系统环境
# - 安装必要依赖
# - 初始化配置文件
# - 设置开发环境

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

# 检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 检查系统环境
check_system() {
    log_info "检查系统环境..."
    
    # 检查操作系统
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        log_info "检测到 macOS 系统"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        log_info "检测到 Linux 系统"
    else
        log_error "不支持的操作系统: $OSTYPE"
        exit 1
    fi
    
    # 检查必要工具
    local required_tools=("git" "curl" "docker" "docker-compose")
    local missing_tools=()
    
    for tool in "${required_tools[@]}"; do
        if ! command_exists "$tool"; then
            missing_tools+=("$tool")
        fi
    done
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        log_error "缺少必要工具: ${missing_tools[*]}"
        log_info "请安装缺少的工具后重新运行此脚本"
        exit 1
    fi
    
    log_success "系统环境检查通过"
}

# 检查并安装 Node.js
check_nodejs() {
    log_info "检查 Node.js..."
    
    if command_exists "node"; then
        local node_version=$(node --version | cut -d'v' -f2)
        local required_version="16.0.0"
        
        if [ "$(printf '%s\n' "$required_version" "$node_version" | sort -V | head -n1)" = "$required_version" ]; then
            log_success "Node.js 版本满足要求: v$node_version"
        else
            log_warning "Node.js 版本过低: v$node_version，建议升级到 v$required_version 或更高"
        fi
    else
        log_warning "未检测到 Node.js"
        if [[ "$OS" == "macos" ]]; then
            log_info "建议使用 Homebrew 安装: brew install node"
        else
            log_info "建议使用 NodeSource 安装: https://nodejs.org/"
        fi
    fi
}

# 检查并安装 Python
check_python() {
    log_info "检查 Python..."
    
    if command_exists "python3"; then
        local python_version=$(python3 --version | cut -d' ' -f2)
        local required_version="3.8.0"
        
        if [ "$(printf '%s\n' "$required_version" "$python_version" | sort -V | head -n1)" = "$required_version" ]; then
            log_success "Python 版本满足要求: $python_version"
        else
            log_warning "Python 版本过低: $python_version，建议升级到 $required_version 或更高"
        fi
    else
        log_error "未检测到 Python 3"
        exit 1
    fi
    
    # 检查 pip
    if ! command_exists "pip3"; then
        log_error "未检测到 pip3"
        exit 1
    fi
}

# 创建虚拟环境
setup_venv() {
    log_info "设置 Python 虚拟环境..."
    
    cd "$PROJECT_ROOT"
    
    if [ ! -d "venv" ]; then
        python3 -m venv venv
        log_success "虚拟环境创建成功"
    else
        log_info "虚拟环境已存在"
    fi
    
    # 激活虚拟环境
    source venv/bin/activate
    
    # 升级 pip
    pip install --upgrade pip
    
    log_success "虚拟环境设置完成"
}

# 安装依赖
install_dependencies() {
    log_info "安装项目依赖..."
    
    cd "$PROJECT_ROOT"
    
    # 安装 Python 依赖
    if [ -f "requirements.txt" ]; then
        log_info "安装 Python 依赖..."
        pip install -r requirements.txt
        log_success "Python 依赖安装完成"
    fi
    
    # 安装 Node.js 依赖
    if [ -f "package.json" ] && command_exists "npm"; then
        log_info "安装 Node.js 依赖..."
        npm install
        log_success "Node.js 依赖安装完成"
    fi
}

# 初始化配置文件
init_config() {
    log_info "初始化配置文件..."
    
    cd "$PROJECT_ROOT"
    
    # 创建环境变量文件
    if [ ! -f ".env" ]; then
        cat > .env << EOF
# AgentFoundry 环境配置

# 应用配置
APP_NAME=AgentFoundry
APP_VERSION=1.0.0
ENVIRONMENT=development
DEBUG=true

# 服务器配置
HOST=0.0.0.0
PORT=8000

# 数据库配置
DATABASE_URL=postgresql://agentfoundry:password@localhost:5432/agentfoundry
REDIS_URL=redis://localhost:6379/0

# API 密钥 (请替换为实际值)
OPENAI_API_KEY=your_openai_api_key_here
ANTHROPIC_API_KEY=your_anthropic_api_key_here

# 监控配置
PROMETHEUS_PORT=9090
GRAFANA_PORT=3000
JAEGER_PORT=16686

# 安全配置
SECRET_KEY=your_secret_key_here
JWT_SECRET=your_jwt_secret_here

# 日志配置
LOG_LEVEL=INFO
LOG_FORMAT=json

# 邮件配置
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your_email@gmail.com
SMTP_PASSWORD=your_app_password

# 文件存储
UPLOAD_DIR=./uploads
MAX_FILE_SIZE=10485760

# 缓存配置
CACHE_TTL=3600
CACHE_MAX_SIZE=1000
EOF
        log_success "环境配置文件 .env 创建成功"
        log_warning "请编辑 .env 文件，填入正确的 API 密钥和配置信息"
    else
        log_info "环境配置文件已存在"
    fi
    
    # 创建本地配置目录
    mkdir -p configs/local
    
    # 创建日志目录
    mkdir -p logs
    
    # 创建上传目录
    mkdir -p uploads
    
    # 创建数据目录
    mkdir -p data
    
    log_success "配置文件初始化完成"
}

# 验证配置
validate_config() {
    log_info "验证配置文件..."
    
    cd "$PROJECT_ROOT"
    
    # 验证 YAML 文件
    if command_exists "yamllint"; then
        find policies/ -name "*.yaml" -o -name "*.yml" | xargs yamllint
        log_success "YAML 文件验证通过"
    else
        log_warning "yamllint 未安装，跳过 YAML 验证"
    fi
    
    # 验证 JSON 文件
    if command_exists "jq"; then
        find . -name "*.json" -not -path "./node_modules/*" | while read -r file; do
            if ! jq empty "$file" 2>/dev/null; then
                log_error "JSON 文件格式错误: $file"
                exit 1
            fi
        done
        log_success "JSON 文件验证通过"
    else
        log_warning "jq 未安装，跳过 JSON 验证"
    fi
}

# 设置 Git hooks
setup_git_hooks() {
    log_info "设置 Git hooks..."
    
    cd "$PROJECT_ROOT"
    
    if [ -d ".git" ]; then
        # 创建 pre-commit hook
        cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
# AgentFoundry pre-commit hook

echo "运行 pre-commit 检查..."

# 运行代码检查
make lint

# 运行测试
make test

echo "pre-commit 检查完成"
EOF
        chmod +x .git/hooks/pre-commit
        
        log_success "Git hooks 设置完成"
    else
        log_warning "不是 Git 仓库，跳过 Git hooks 设置"
    fi
}

# 启动开发服务
start_dev_services() {
    log_info "启动开发服务..."
    
    cd "$PROJECT_ROOT"
    
    # 启动 Docker 服务
    if command_exists "docker-compose"; then
        log_info "启动数据库和缓存服务..."
        docker-compose up -d postgres redis
        
        # 等待服务启动
        sleep 10
        
        log_success "开发服务启动完成"
    else
        log_warning "docker-compose 未安装，请手动启动数据库服务"
    fi
}

# 运行初始化测试
run_init_tests() {
    log_info "运行初始化测试..."
    
    cd "$PROJECT_ROOT"
    
    # 运行基础测试
    if [ -f "tests/test_init.py" ]; then
        python -m pytest tests/test_init.py -v
        log_success "初始化测试通过"
    else
        log_warning "初始化测试文件不存在，跳过测试"
    fi
}

# 显示后续步骤
show_next_steps() {
    log_success "AgentFoundry 初始化完成！"
    echo ""
    echo "📋 后续步骤:"
    echo "1. 编辑 .env 文件，配置 API 密钥和数据库连接"
    echo "2. 运行 'make dev' 启动开发环境"
    echo "3. 访问 http://localhost:8000 查看应用"
    echo "4. 访问 http://localhost:3000 查看监控面板 (admin/admin)"
    echo ""
    echo "📚 有用的命令:"
    echo "  make help          - 查看所有可用命令"
    echo "  make test          - 运行测试"
    echo "  make docker-up     - 启动完整 Docker 环境"
    echo "  make monitor       - 启动监控服务"
    echo ""
    echo "📖 文档:"
    echo "  README.md          - 项目说明"
    echo "  docs/              - 详细文档"
    echo "  gates/             - 阶段关卡说明"
    echo ""
    echo "🎯 开始使用 AgentFoundry 构建您的智能体项目！"
}

# 主函数
main() {
    echo "🚀 AgentFoundry 项目初始化"
    echo "=============================="
    echo ""
    
    check_system
    check_nodejs
    check_python
    setup_venv
    install_dependencies
    init_config
    validate_config
    setup_git_hooks
    start_dev_services
    run_init_tests
    
    echo ""
    show_next_steps
}

# 错误处理
trap 'log_error "初始化过程中发生错误，请检查上面的错误信息"' ERR

# 执行主函数
main "$@"