# AgentFoundry Makefile
# 提供便捷的项目管理命令

.PHONY: help install dev build test clean docker deploy monitor

# 默认目标
help:
	@echo "AgentFoundry - 面向投资人的端到端智能体编排设计师"
	@echo ""
	@echo "可用命令:"
	@echo "  install     - 安装项目依赖"
	@echo "  dev         - 启动开发环境"
	@echo "  build       - 构建项目"
	@echo "  test        - 运行测试"
	@echo "  test-golden - 运行黄金测试集"
	@echo "  test-redteam - 运行红队测试"
	@echo "  lint        - 代码检查"
	@echo "  format      - 代码格式化"
	@echo "  clean       - 清理临时文件"
	@echo "  docker-build - 构建Docker镜像"
	@echo "  docker-up   - 启动Docker环境"
	@echo "  docker-down - 停止Docker环境"
	@echo "  deploy-staging - 部署到测试环境"
	@echo "  deploy-prod - 部署到生产环境"
	@echo "  monitor     - 启动监控面板"
	@echo "  validate    - 验证配置文件"
	@echo "  backup      - 备份数据"
	@echo "  restore     - 恢复数据"

# 安装依赖
install:
	@echo "📦 安装项目依赖..."
	npm install
	pip install -r requirements.txt
	@echo "✅ 依赖安装完成"

# 开发环境
dev:
	@echo "🚀 启动开发环境..."
	docker-compose up -d postgres redis
	sleep 5
	npm run dev &
	python -m uvicorn src.main:app --reload --host 0.0.0.0 --port 8000

# 构建项目
build:
	@echo "🔨 构建项目..."
	npm run build
	python -m py_compile src/**/*.py
	@echo "✅ 构建完成"

# 运行测试
test:
	@echo "🧪 运行测试..."
	npm test
	pytest tests/ -v --cov=src --cov-report=html
	@echo "✅ 测试完成"

# 运行黄金测试集
test-golden:
	@echo "🏆 运行黄金测试集..."
	python scripts/run_golden_tests.py
	@echo "✅ 黄金测试完成"

# 运行红队测试
test-redteam:
	@echo "🔴 运行红队测试..."
	python scripts/run_redteam_tests.py
	@echo "✅ 红队测试完成"

# 代码检查
lint:
	@echo "🔍 代码检查..."
	npm run lint
	flake8 src/
	mypy src/
	bandit -r src/
	@echo "✅ 代码检查完成"

# 代码格式化
format:
	@echo "💅 代码格式化..."
	npm run format
	black src/
	isort src/
	@echo "✅ 代码格式化完成"

# 清理临时文件
clean:
	@echo "🧹 清理临时文件..."
	rm -rf node_modules/.cache
	rm -rf dist/
	rm -rf build/
	rm -rf .pytest_cache/
	rm -rf __pycache__/
	find . -name "*.pyc" -delete
	find . -name "__pycache__" -type d -exec rm -rf {} + || true
	@echo "✅ 清理完成"

# Docker构建
docker-build:
	@echo "🐳 构建Docker镜像..."
	docker build -t agentfoundry:latest .
	docker build -t agentfoundry:dev --target development .
	@echo "✅ Docker镜像构建完成"

# 启动Docker环境
docker-up:
	@echo "🐳 启动Docker环境..."
	docker-compose up -d
	@echo "✅ Docker环境已启动"
	@echo "📊 访问地址:"
	@echo "  - 应用: http://localhost:8000"
	@echo "  - Grafana: http://localhost:3000 (admin/admin)"
	@echo "  - Prometheus: http://localhost:9090"
	@echo "  - Flower: http://localhost:5555"
	@echo "  - Jaeger: http://localhost:16686"

# 停止Docker环境
docker-down:
	@echo "🐳 停止Docker环境..."
	docker-compose down
	@echo "✅ Docker环境已停止"

# 部署到测试环境
deploy-staging:
	@echo "🚀 部署到测试环境..."
	./scripts/deploy.sh staging
	@echo "✅ 测试环境部署完成"

# 部署到生产环境
deploy-prod:
	@echo "🚀 部署到生产环境..."
	@read -p "确认部署到生产环境? [y/N] " confirm && [ "$$confirm" = "y" ]
	./scripts/deploy.sh production
	@echo "✅ 生产环境部署完成"

# 启动监控面板
monitor:
	@echo "📊 启动监控面板..."
	docker-compose up -d prometheus grafana jaeger
	@echo "✅ 监控面板已启动"
	@echo "📊 访问地址:"
	@echo "  - Grafana: http://localhost:3000"
	@echo "  - Prometheus: http://localhost:9090"
	@echo "  - Jaeger: http://localhost:16686"

# 验证配置文件
validate:
	@echo "✅ 验证配置文件..."
	python scripts/validate_policies.py
	python scripts/validate_telemetry.py
	yamllint policies/
	jsonlint eval/
	@echo "✅ 配置验证完成"

# 备份数据
backup:
	@echo "💾 备份数据..."
	./scripts/backup.sh
	@echo "✅ 数据备份完成"

# 恢复数据
restore:
	@echo "🔄 恢复数据..."
	@read -p "输入备份文件路径: " backup_file && ./scripts/restore.sh "$$backup_file"
	@echo "✅ 数据恢复完成"

# 初始化项目
init:
	@echo "🎯 初始化AgentFoundry项目..."
	make install
	make validate
	make docker-build
	@echo "✅ 项目初始化完成"
	@echo "🚀 运行 'make dev' 启动开发环境"

# 完整测试流程
test-all:
	@echo "🧪 运行完整测试流程..."
	make lint
	make test
	make test-golden
	make test-redteam
	@echo "✅ 完整测试流程完成"

# 发布准备
release-prep:
	@echo "📦 准备发布..."
	make clean
	make install
	make test-all
	make build
	make docker-build
	@echo "✅ 发布准备完成"

# 健康检查
health:
	@echo "🏥 健康检查..."
	curl -f http://localhost:8000/health || echo "❌ 应用健康检查失败"
	curl -f http://localhost:9090/-/healthy || echo "❌ Prometheus健康检查失败"
	curl -f http://localhost:3000/api/health || echo "❌ Grafana健康检查失败"
	@echo "✅ 健康检查完成"

# 日志查看
logs:
	@echo "📋 查看应用日志..."
	docker-compose logs -f agentfoundry

# 数据库迁移
migrate:
	@echo "🗄️ 数据库迁移..."
	alembic upgrade head
	@echo "✅ 数据库迁移完成"

# 生成API文档
docs:
	@echo "📚 生成API文档..."
	mkdocs build
	@echo "✅ API文档生成完成"

# 安全扫描
security-scan:
	@echo "🔒 安全扫描..."
	bandit -r src/
	safety check
	npm audit
	@echo "✅ 安全扫描完成"

# 性能测试
perf-test:
	@echo "⚡ 性能测试..."
	./scripts/performance_test.sh
	@echo "✅ 性能测试完成"

# 清理Docker资源
docker-clean:
	@echo "🧹 清理Docker资源..."
	docker-compose down -v
	docker system prune -f
	docker volume prune -f
	@echo "✅ Docker资源清理完成"