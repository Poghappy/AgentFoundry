# AgentFoundry Trae 可复制指令包

## 📝 更新记录

- [2025-01-27] 创建Trae IDE可复制指令包，整合常用开发指令和最佳实践

## 📋 文档概述

本文档提供AgentFoundry项目中常用的Trae IDE指令包，包含项目初始化、开发流程、部署运维等各个环节的标准化指令，确保团队成员能够快速、准确地执行各种开发任务。

## 🚀 项目初始化指令

### 创建新项目结构

```bash
# 创建AgentFoundry项目基础结构
mkdir -p {agents,gates,policies,eval/{golden,redteam},runbooks,telemetry,docs/{ADRs,templates},infra,products/demo}

# 初始化Git仓库
git init
git add .
git commit -m "feat: 初始化AgentFoundry项目结构"
```

### 环境配置检查

```bash
# 检查Python环境
python3 --version
pip3 --version

# 检查Node.js环境
node --version
npm --version

# 检查Docker环境
docker --version
docker-compose --version
```

### 依赖安装

```bash
# Python依赖安装
pip3 install -r requirements.txt

# Node.js依赖安装
npm install

# 或使用yarn
yarn install
```

## 🔧 开发流程指令

### Git工作流

```bash
# 创建功能分支
git checkout -b feature/[功能名称]

# 提交代码（遵循约定式提交）
git add .
git commit -m "feat: 添加用户认证功能"
git commit -m "fix: 修复登录页面样式问题"
git commit -m "docs: 更新API文档"
git commit -m "test: 添加用户服务单元测试"
git commit -m "refactor: 重构数据库连接逻辑"

# 推送分支
git push origin feature/[功能名称]

# 合并到主分支
git checkout main
git merge feature/[功能名称]
git push origin main
```

### 代码质量检查

```bash
# Python代码格式化
black .
flake8 .
pylint **/*.py

# JavaScript/TypeScript代码检查
npm run lint
npm run format

# 运行测试
pytest tests/
npm test
```

### 文档生成

```bash
# 生成API文档
sphinx-build -b html docs/ docs/_build/

# 生成代码覆盖率报告
pytest --cov=src tests/

# 生成依赖关系图
pipdeptree --graph-output png > dependency_graph.png
```

## 🏗️ 构建和部署指令

### Docker构建

```bash
# 构建Docker镜像
docker build -t agentfoundry:latest .

# 运行容器
docker run -d -p 8080:8080 --name agentfoundry agentfoundry:latest

# 查看容器日志
docker logs -f agentfoundry

# 进入容器调试
docker exec -it agentfoundry /bin/bash
```

### Docker Compose部署

```bash
# 启动所有服务
docker-compose up -d

# 查看服务状态
docker-compose ps

# 查看服务日志
docker-compose logs -f [服务名]

# 停止所有服务
docker-compose down

# 重建并启动服务
docker-compose up --build -d
```

### Kubernetes部署

```bash
# 应用配置
kubectl apply -f k8s/

# 查看Pod状态
kubectl get pods -l app=agentfoundry

# 查看服务状态
kubectl get services

# 查看Pod日志
kubectl logs -f deployment/agentfoundry

# 端口转发（本地调试）
kubectl port-forward service/agentfoundry 8080:80
```

## 📊 监控和调试指令

### 系统监控

```bash
# 查看系统资源使用
top
htop
df -h
free -h

# 查看网络连接
netstat -tulpn
ss -tulpn

# 查看进程
ps aux | grep agentfoundry
pgrep -f agentfoundry
```

### 日志分析

```bash
# 查看应用日志
tail -f /var/log/agentfoundry/app.log

# 搜索错误日志
grep -i error /var/log/agentfoundry/app.log

# 分析访问日志
awk '{print $1}' /var/log/nginx/access.log | sort | uniq -c | sort -nr

# 实时监控日志
tail -f /var/log/agentfoundry/app.log | grep -i "error\|warning"
```

### 性能分析

```bash
# Python性能分析
python -m cProfile -o profile.stats main.py
python -c "import pstats; pstats.Stats('profile.stats').sort_stats('cumulative').print_stats(10)"

# 内存使用分析
python -m memory_profiler main.py

# 网络性能测试
curl -w "@curl-format.txt" -o /dev/null -s "http://localhost:8080/api/health"
```

## 🧪 测试指令

### 单元测试

```bash
# 运行所有测试
pytest

# 运行特定测试文件
pytest tests/test_user_service.py

# 运行特定测试函数
pytest tests/test_user_service.py::test_create_user

# 生成覆盖率报告
pytest --cov=src --cov-report=html tests/
```

### 集成测试

```bash
# 启动测试环境
docker-compose -f docker-compose.test.yml up -d

# 运行集成测试
pytest tests/integration/

# 清理测试环境
docker-compose -f docker-compose.test.yml down -v
```

### API测试

```bash
# 健康检查
curl -X GET http://localhost:8080/api/health

# 用户认证测试
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"test123"}'

# 带认证的API调用
curl -X GET http://localhost:8080/api/users \
  -H "Authorization: Bearer $TOKEN"
```

## 🔒 安全检查指令

### 依赖安全扫描

```bash
# Python依赖安全检查
safety check
pip-audit

# Node.js依赖安全检查
npm audit
npm audit fix

# Docker镜像安全扫描
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  -v $PWD:/tmp/.cache/ aquasec/trivy image agentfoundry:latest
```

### 代码安全分析

```bash
# Python代码安全检查
bandit -r src/

# 静态代码分析
sonar-scanner

# 密钥泄露检查
git-secrets --scan
truffleHog --regex --entropy=False .
```

## 📦 数据库操作指令

### 数据库迁移

```bash
# 创建迁移文件
alembic revision --autogenerate -m "添加用户表"

# 执行迁移
alembic upgrade head

# 回滚迁移
alembic downgrade -1

# 查看迁移历史
alembic history
```

### 数据库备份恢复

```bash
# PostgreSQL备份
pg_dump -h localhost -U username -d database_name > backup.sql

# PostgreSQL恢复
psql -h localhost -U username -d database_name < backup.sql

# MySQL备份
mysqldump -h localhost -u username -p database_name > backup.sql

# MySQL恢复
mysql -h localhost -u username -p database_name < backup.sql
```

## 🔄 CI/CD指令

### GitHub Actions

```yaml
# .github/workflows/ci.yml 基础模板
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Set up Python
      uses: actions/setup-python@v3
      with:
        python-version: '3.9'
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements.txt
    - name: Run tests
      run: |
        pytest --cov=src tests/
```

### 部署脚本

```bash
# 蓝绿部署脚本
#!/bin/bash
set -e

# 构建新版本
docker build -t agentfoundry:$BUILD_NUMBER .

# 部署到绿色环境
docker-compose -f docker-compose.green.yml up -d

# 健康检查
for i in {1..30}; do
  if curl -f http://green.agentfoundry.com/health; then
    echo "Green environment is healthy"
    break
  fi
  sleep 10
done

# 切换流量
# 更新负载均衡器配置

# 停止蓝色环境
docker-compose -f docker-compose.blue.yml down
```

## 🛠️ 故障排查指令

### 常见问题诊断

```bash
# 检查端口占用
lsof -i :8080
netstat -tulpn | grep :8080

# 检查磁盘空间
df -h
du -sh /var/log/*

# 检查内存使用
free -h
ps aux --sort=-%mem | head

# 检查CPU使用
top -o %CPU
ps aux --sort=-%cpu | head
```

### 服务重启

```bash
# 重启应用服务
sudo systemctl restart agentfoundry
sudo systemctl status agentfoundry

# 重启Docker容器
docker restart agentfoundry

# 重启Docker Compose服务
docker-compose restart agentfoundry
```

### 日志收集

```bash
# 收集系统信息
uname -a > system_info.txt
df -h >> system_info.txt
free -h >> system_info.txt
ps aux >> system_info.txt

# 收集应用日志
tar -czf logs_$(date +%Y%m%d_%H%M%S).tar.gz /var/log/agentfoundry/

# 收集Docker日志
docker logs agentfoundry > docker_logs.txt 2>&1
```

## 📋 快速参考

### 常用端口

- **应用服务**: 8080
- **数据库**: 5432 (PostgreSQL), 3306 (MySQL)
- **Redis**: 6379
- **监控**: 9090 (Prometheus), 3000 (Grafana)
- **日志**: 5601 (Kibana)

### 环境变量

```bash
# 设置开发环境
export ENVIRONMENT=development
export DEBUG=true
export LOG_LEVEL=debug

# 设置生产环境
export ENVIRONMENT=production
export DEBUG=false
export LOG_LEVEL=info
```

### 常用别名

```bash
# 添加到 ~/.bashrc 或 ~/.zshrc
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'

# Docker别名
alias dps='docker ps'
alias dimg='docker images'
alias dlog='docker logs -f'
alias dexec='docker exec -it'

# Git别名
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'
```

## 🔧 Trae IDE 特定指令

### 项目配置

```bash
# 初始化Trae项目配置
trae init

# 配置代码格式化
trae config set formatter.python black
trae config set formatter.javascript prettier

# 配置代码检查
trae config set linter.python flake8
trae config set linter.javascript eslint
```

### 代码生成

```bash
# 生成API端点
trae generate api --name user --methods get,post,put,delete

# 生成数据模型
trae generate model --name User --fields name:str,email:str,age:int

# 生成测试文件
trae generate test --target src/user_service.py
```

### 智能重构

```bash
# 重命名变量/函数
trae refactor rename --old-name old_function --new-name new_function

# 提取函数
trae refactor extract-function --start-line 10 --end-line 20 --name extracted_function

# 优化导入
trae refactor optimize-imports --file src/main.py
```

## 📚 学习资源

### 官方文档

- [AgentFoundry 官方文档](https://docs.agentfoundry.com)
- [Trae IDE 用户指南](https://docs.trae.ai)
- [Docker 官方文档](https://docs.docker.com)
- [Kubernetes 官方文档](https://kubernetes.io/docs)

### 最佳实践

- [十二要素应用](https://12factor.net/zh_cn/)
- [Google SRE 手册](https://sre.google/sre-book/table-of-contents/)
- [Clean Code 原则](https://clean-code-developer.com/)
- [API 设计指南](https://github.com/microsoft/api-guidelines)

---

## 📝 使用说明

1. **复制指令**: 直接复制所需指令到终端执行
2. **参数替换**: 将 `[参数名]` 替换为实际值
3. **环境适配**: 根据实际环境调整路径和配置
4. **权限检查**: 确保有足够权限执行相关操作
5. **备份重要**: 执行危险操作前先备份重要数据

## ⚠️ 注意事项

- 生产环境操作需要额外谨慎
- 定期更新依赖和工具版本
- 遵循公司安全政策和规范
- 重要操作需要代码审查
- 保持文档和指令的及时更新

---

**维护者**: AgentFoundry Team  
**最后更新**: 2025-01-27  
**版本**: v1.0.0