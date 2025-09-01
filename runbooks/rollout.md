# 发布与回滚手册 (Rollout & Rollback Runbook)

## 📋 文档信息

- **版本**: v1.0.0
- **创建日期**: 2025-01-20
- **最后更新**: 2025-01-20
- **负责人**: AgentFoundry 发布团队
- **审核状态**: 待审核

## 🎯 发布策略概述

### 发布类型

#### 1. 蓝绿部署 (Blue-Green Deployment)

**适用场景**:
- 零停机时间要求
- 快速回滚需求
- 数据库变更较少

**优势**:
- 即时切换
- 快速回滚
- 完整测试环境

**劣势**:
- 资源消耗大
- 数据同步复杂

#### 2. 滚动部署 (Rolling Deployment)

**适用场景**:
- 资源有限
- 渐进式发布
- 服务无状态

**优势**:
- 资源利用率高
- 渐进式验证
- 风险分散

**劣势**:
- 回滚复杂
- 版本混合期

#### 3. 金丝雀部署 (Canary Deployment)

**适用场景**:
- 高风险变更
- 用户体验测试
- 性能验证

**优势**:
- 风险可控
- 真实用户反馈
- 渐进式推广

**劣势**:
- 复杂度高
- 监控要求高

#### 4. A/B测试部署

**适用场景**:
- 功能对比测试
- 用户体验优化
- 业务指标验证

**优势**:
- 数据驱动决策
- 用户分群测试
- 业务价值验证

**劣势**:
- 技术复杂
- 数据分析要求高

## 🚀 发布前准备

### 发布检查清单

#### 代码质量检查

- [ ] 代码审查完成
- [ ] 单元测试通过 (覆盖率 ≥ 80%)
- [ ] 集成测试通过
- [ ] 安全扫描通过
- [ ] 性能测试通过
- [ ] 依赖漏洞扫描通过

#### 环境准备

- [ ] 生产环境资源充足
- [ ] 数据库备份完成
- [ ] 配置文件更新
- [ ] 环境变量设置
- [ ] SSL证书有效
- [ ] DNS配置正确

#### 监控与告警

- [ ] 监控面板配置
- [ ] 告警规则设置
- [ ] 日志收集配置
- [ ] 性能基线确定
- [ ] 错误阈值设定
- [ ] 通知渠道测试

#### 回滚准备

- [ ] 回滚脚本准备
- [ ] 数据库回滚方案
- [ ] 配置回滚计划
- [ ] 回滚测试验证
- [ ] 回滚决策标准
- [ ] 回滚负责人指定

### 发布计划模板

```markdown
# 发布计划 - [版本号]

## 基本信息
- **版本**: [版本号]
- **发布日期**: [YYYY-MM-DD]
- **发布时间**: [HH:MM - HH:MM]
- **发布负责人**: [姓名]
- **技术负责人**: [姓名]
- **业务负责人**: [姓名]

## 发布内容
### 新功能
- [功能1]: [描述]
- [功能2]: [描述]

### Bug修复
- [Bug1]: [描述]
- [Bug2]: [描述]

### 性能优化
- [优化1]: [描述]
- [优化2]: [描述]

## 技术变更
### 数据库变更
- [变更1]: [SQL脚本]
- [变更2]: [SQL脚本]

### 配置变更
- [配置1]: [变更内容]
- [配置2]: [变更内容]

### 依赖更新
- [依赖1]: [版本变更]
- [依赖2]: [版本变更]

## 风险评估
### 高风险项
- [风险1]: [缓解措施]
- [风险2]: [缓解措施]

### 中风险项
- [风险1]: [监控措施]
- [风险2]: [监控措施]

## 发布步骤
1. [步骤1] - [负责人] - [预计时间]
2. [步骤2] - [负责人] - [预计时间]
3. [步骤3] - [负责人] - [预计时间]

## 验证标准
- [ ] [验证项1]
- [ ] [验证项2]
- [ ] [验证项3]

## 回滚条件
- [条件1]: [触发阈值]
- [条件2]: [触发阈值]

## 沟通计划
- **内部通知**: [时间] - [渠道]
- **用户通知**: [时间] - [渠道]
- **状态更新**: [频率] - [渠道]
```

## 🔄 发布流程

### 阶段1: 预发布验证

#### 1.1 环境检查 (T-30分钟)

```bash
#!/bin/bash
# 预发布环境检查脚本

echo "=== 预发布环境检查 ==="
echo "检查时间: $(date)"

# 检查服务状态
echo "\n1. 检查服务状态"
services=("nginx" "mysql" "redis" "app-service")
for service in "${services[@]}"; do
    if systemctl is-active --quiet $service; then
        echo "✅ $service: 运行中"
    else
        echo "❌ $service: 未运行"
        exit 1
    fi
done

# 检查磁盘空间
echo "\n2. 检查磁盘空间"
disk_usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ $disk_usage -lt 80 ]; then
    echo "✅ 磁盘使用率: ${disk_usage}%"
else
    echo "❌ 磁盘使用率过高: ${disk_usage}%"
    exit 1
fi

# 检查内存使用
echo "\n3. 检查内存使用"
mem_usage=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
if [ $mem_usage -lt 85 ]; then
    echo "✅ 内存使用率: ${mem_usage}%"
else
    echo "❌ 内存使用率过高: ${mem_usage}%"
    exit 1
fi

# 检查数据库连接
echo "\n4. 检查数据库连接"
if mysql -u[用户] -p[密码] -e "SELECT 1" >/dev/null 2>&1; then
    echo "✅ 数据库连接正常"
else
    echo "❌ 数据库连接失败"
    exit 1
fi

echo "\n✅ 所有检查通过，可以开始发布"
```

#### 1.2 数据备份 (T-20分钟)

```bash
#!/bin/bash
# 数据备份脚本

BACKUP_DIR="/backup/$(date +%Y%m%d_%H%M%S)"
mkdir -p $BACKUP_DIR

echo "=== 开始数据备份 ==="
echo "备份目录: $BACKUP_DIR"

# 数据库备份
echo "\n1. 备份数据库"
mysqldump -u[用户] -p[密码] --single-transaction --routines --triggers [数据库名] > $BACKUP_DIR/database.sql
if [ $? -eq 0 ]; then
    echo "✅ 数据库备份完成"
else
    echo "❌ 数据库备份失败"
    exit 1
fi

# 配置文件备份
echo "\n2. 备份配置文件"
tar -czf $BACKUP_DIR/configs.tar.gz /etc/nginx /etc/app-config
if [ $? -eq 0 ]; then
    echo "✅ 配置文件备份完成"
else
    echo "❌ 配置文件备份失败"
    exit 1
fi

# 应用文件备份
echo "\n3. 备份应用文件"
tar -czf $BACKUP_DIR/application.tar.gz /opt/app --exclude='*.log' --exclude='tmp/*'
if [ $? -eq 0 ]; then
    echo "✅ 应用文件备份完成"
else
    echo "❌ 应用文件备份失败"
    exit 1
fi

echo "\n✅ 所有备份完成"
echo "备份位置: $BACKUP_DIR"
```

### 阶段2: 应用部署

#### 2.1 蓝绿部署脚本

```bash
#!/bin/bash
# 蓝绿部署脚本

set -e

# 配置变量
APP_NAME="myapp"
BLUE_PORT=8080
GREEN_PORT=8081
NGINX_CONFIG="/etc/nginx/sites-available/$APP_NAME"
HEALTH_CHECK_URL="http://localhost"
NEW_VERSION=$1

if [ -z "$NEW_VERSION" ]; then
    echo "使用方法: $0 <版本号>"
    exit 1
fi

echo "=== 开始蓝绿部署 ==="
echo "新版本: $NEW_VERSION"

# 检查当前活跃环境
current_port=$(grep -o ":[0-9]*" $NGINX_CONFIG | head -1 | sed 's/://')
if [ "$current_port" = "$BLUE_PORT" ]; then
    active_env="blue"
    inactive_env="green"
    inactive_port=$GREEN_PORT
else
    active_env="green"
    inactive_env="blue"
    inactive_port=$BLUE_PORT
fi

echo "当前活跃环境: $active_env (端口: $current_port)"
echo "部署目标环境: $inactive_env (端口: $inactive_port)"

# 部署到非活跃环境
echo "\n1. 部署应用到 $inactive_env 环境"
docker pull $APP_NAME:$NEW_VERSION
docker stop ${APP_NAME}_${inactive_env} || true
docker rm ${APP_NAME}_${inactive_env} || true
docker run -d --name ${APP_NAME}_${inactive_env} -p $inactive_port:8080 $APP_NAME:$NEW_VERSION

# 健康检查
echo "\n2. 健康检查"
for i in {1..30}; do
    if curl -f $HEALTH_CHECK_URL:$inactive_port/health >/dev/null 2>&1; then
        echo "✅ 健康检查通过"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "❌ 健康检查失败"
        exit 1
    fi
    echo "等待应用启动... ($i/30)"
    sleep 10
done

# 切换流量
echo "\n3. 切换流量到 $inactive_env 环境"
sed -i "s/:$current_port/:$inactive_port/g" $NGINX_CONFIG
nginx -t && systemctl reload nginx

echo "\n4. 验证切换结果"
sleep 5
if curl -f $HEALTH_CHECK_URL/health >/dev/null 2>&1; then
    echo "✅ 流量切换成功"
else
    echo "❌ 流量切换失败，开始回滚"
    sed -i "s/:$inactive_port/:$current_port/g" $NGINX_CONFIG
    nginx -t && systemctl reload nginx
    exit 1
fi

# 停止旧环境
echo "\n5. 停止旧环境 $active_env"
sleep 30  # 等待连接排空
docker stop ${APP_NAME}_${active_env}

echo "\n✅ 蓝绿部署完成"
echo "新活跃环境: $inactive_env (端口: $inactive_port)"
```

#### 2.2 滚动部署脚本

```bash
#!/bin/bash
# 滚动部署脚本

set -e

APP_NAME="myapp"
NEW_VERSION=$1
INSTANCE_COUNT=3
HEALTH_CHECK_URL="http://localhost:8080/health"

if [ -z "$NEW_VERSION" ]; then
    echo "使用方法: $0 <版本号>"
    exit 1
fi

echo "=== 开始滚动部署 ==="
echo "新版本: $NEW_VERSION"
echo "实例数量: $INSTANCE_COUNT"

# 逐个更新实例
for i in $(seq 1 $INSTANCE_COUNT); do
    instance_name="${APP_NAME}_${i}"
    
    echo "\n更新实例 $i/$INSTANCE_COUNT: $instance_name"
    
    # 从负载均衡器移除实例
    echo "1. 从负载均衡器移除实例"
    # 这里需要根据实际的负载均衡器配置
    # 例如：consul-template, etcd, 或直接修改nginx配置
    
    # 等待连接排空
    echo "2. 等待连接排空"
    sleep 30
    
    # 停止旧实例
    echo "3. 停止旧实例"
    docker stop $instance_name || true
    docker rm $instance_name || true
    
    # 启动新实例
    echo "4. 启动新实例"
    port=$((8080 + i))
    docker run -d --name $instance_name -p $port:8080 $APP_NAME:$NEW_VERSION
    
    # 健康检查
    echo "5. 健康检查"
    for j in {1..30}; do
        if curl -f http://localhost:$port/health >/dev/null 2>&1; then
            echo "✅ 实例 $i 健康检查通过"
            break
        fi
        if [ $j -eq 30 ]; then
            echo "❌ 实例 $i 健康检查失败"
            exit 1
        fi
        echo "等待实例启动... ($j/30)"
        sleep 10
    done
    
    # 添加回负载均衡器
    echo "6. 添加回负载均衡器"
    # 这里需要根据实际的负载均衡器配置
    
    echo "✅ 实例 $i 更新完成"
done

echo "\n✅ 滚动部署完成"
```

#### 2.3 金丝雀部署脚本

```bash
#!/bin/bash
# 金丝雀部署脚本

set -e

APP_NAME="myapp"
NEW_VERSION=$1
CANARY_PERCENTAGE=${2:-10}  # 默认10%流量
HEALTH_CHECK_URL="http://localhost:8080/health"

if [ -z "$NEW_VERSION" ]; then
    echo "使用方法: $0 <版本号> [金丝雀百分比]"
    exit 1
fi

echo "=== 开始金丝雀部署 ==="
echo "新版本: $NEW_VERSION"
echo "金丝雀流量: $CANARY_PERCENTAGE%"

# 部署金丝雀实例
echo "\n1. 部署金丝雀实例"
docker pull $APP_NAME:$NEW_VERSION
docker run -d --name ${APP_NAME}_canary -p 8082:8080 $APP_NAME:$NEW_VERSION

# 健康检查
echo "\n2. 金丝雀实例健康检查"
for i in {1..30}; do
    if curl -f http://localhost:8082/health >/dev/null 2>&1; then
        echo "✅ 金丝雀实例健康检查通过"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "❌ 金丝雀实例健康检查失败"
        exit 1
    fi
    echo "等待金丝雀实例启动... ($i/30)"
    sleep 10
done

# 配置流量分割
echo "\n3. 配置流量分割 ($CANARY_PERCENTAGE% -> 金丝雀)"
cat > /etc/nginx/conf.d/canary.conf << EOF
upstream app_backend {
    server localhost:8080 weight=$((100-CANARY_PERCENTAGE));
    server localhost:8082 weight=$CANARY_PERCENTAGE;
}

server {
    listen 80;
    location / {
        proxy_pass http://app_backend;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

nginx -t && systemctl reload nginx

echo "\n4. 监控金丝雀指标"
echo "请监控以下指标："
echo "- 错误率: 应 < 1%"
echo "- 响应时间: 应 < 2秒"
echo "- CPU/内存使用率"
echo "- 业务指标"

echo "\n金丝雀部署完成，请监控 30 分钟后决定是否继续推广"
echo "继续推广: ./promote_canary.sh"
echo "回滚金丝雀: ./rollback_canary.sh"
```

### 阶段3: 发布验证

#### 3.1 自动化验证脚本

```bash
#!/bin/bash
# 发布验证脚本

set -e

APP_URL="http://localhost"
API_URL="$APP_URL/api"
HEALTH_URL="$APP_URL/health"

echo "=== 开始发布验证 ==="
echo "应用URL: $APP_URL"
echo "验证时间: $(date)"

# 1. 健康检查
echo "\n1. 健康检查"
if curl -f $HEALTH_URL >/dev/null 2>&1; then
    echo "✅ 健康检查通过"
else
    echo "❌ 健康检查失败"
    exit 1
fi

# 2. API功能测试
echo "\n2. API功能测试"

# 用户登录测试
echo "2.1 用户登录测试"
login_response=$(curl -s -X POST $API_URL/login \
    -H "Content-Type: application/json" \
    -d '{"username":"test","password":"test123"}')

if echo $login_response | grep -q "token"; then
    echo "✅ 用户登录测试通过"
    token=$(echo $login_response | jq -r '.token')
else
    echo "❌ 用户登录测试失败"
    exit 1
fi

# 数据查询测试
echo "2.2 数据查询测试"
query_response=$(curl -s -H "Authorization: Bearer $token" $API_URL/users)
if echo $query_response | grep -q "users"; then
    echo "✅ 数据查询测试通过"
else
    echo "❌ 数据查询测试失败"
    exit 1
fi

# 3. 性能测试
echo "\n3. 性能测试"
echo "3.1 响应时间测试"
response_time=$(curl -o /dev/null -s -w "%{time_total}" $APP_URL)
if (( $(echo "$response_time < 2.0" | bc -l) )); then
    echo "✅ 响应时间测试通过: ${response_time}s"
else
    echo "❌ 响应时间测试失败: ${response_time}s"
    exit 1
fi

# 4. 数据库连接测试
echo "\n4. 数据库连接测试"
db_response=$(curl -s $API_URL/db-status)
if echo $db_response | grep -q "connected"; then
    echo "✅ 数据库连接测试通过"
else
    echo "❌ 数据库连接测试失败"
    exit 1
fi

# 5. 缓存测试
echo "\n5. 缓存测试"
cache_response=$(curl -s $API_URL/cache-status)
if echo $cache_response | grep -q "connected"; then
    echo "✅ 缓存测试通过"
else
    echo "❌ 缓存测试失败"
    exit 1
fi

echo "\n✅ 所有验证测试通过"
echo "发布验证完成时间: $(date)"
```

#### 3.2 监控指标检查

```bash
#!/bin/bash
# 监控指标检查脚本

MONITORING_URL="http://prometheus:9090"
GRAFANA_URL="http://grafana:3000"
CHECK_DURATION="5m"  # 检查最近5分钟的指标

echo "=== 监控指标检查 ==="
echo "检查时间段: 最近 $CHECK_DURATION"

# 1. 错误率检查
echo "\n1. 错误率检查"
error_rate=$(curl -s "$MONITORING_URL/api/v1/query?query=rate(http_requests_total{status=~'5..'}[${CHECK_DURATION}])" | jq -r '.data.result[0].value[1]')
if (( $(echo "$error_rate < 0.01" | bc -l) )); then
    echo "✅ 错误率正常: $(echo "$error_rate * 100" | bc -l)%"
else
    echo "❌ 错误率过高: $(echo "$error_rate * 100" | bc -l)%"
    exit 1
fi

# 2. 响应时间检查
echo "\n2. 响应时间检查"
avg_response_time=$(curl -s "$MONITORING_URL/api/v1/query?query=rate(http_request_duration_seconds_sum[${CHECK_DURATION}])/rate(http_request_duration_seconds_count[${CHECK_DURATION}])" | jq -r '.data.result[0].value[1]')
if (( $(echo "$avg_response_time < 2.0" | bc -l) )); then
    echo "✅ 平均响应时间正常: ${avg_response_time}s"
else
    echo "❌ 平均响应时间过高: ${avg_response_time}s"
    exit 1
fi

# 3. CPU使用率检查
echo "\n3. CPU使用率检查"
cpu_usage=$(curl -s "$MONITORING_URL/api/v1/query?query=100-avg(rate(node_cpu_seconds_total{mode='idle'}[${CHECK_DURATION}]))*100" | jq -r '.data.result[0].value[1]')
if (( $(echo "$cpu_usage < 80" | bc -l) )); then
    echo "✅ CPU使用率正常: ${cpu_usage}%"
else
    echo "❌ CPU使用率过高: ${cpu_usage}%"
    exit 1
fi

# 4. 内存使用率检查
echo "\n4. 内存使用率检查"
mem_usage=$(curl -s "$MONITORING_URL/api/v1/query?query=(1-node_memory_MemAvailable_bytes/node_memory_MemTotal_bytes)*100" | jq -r '.data.result[0].value[1]')
if (( $(echo "$mem_usage < 85" | bc -l) )); then
    echo "✅ 内存使用率正常: ${mem_usage}%"
else
    echo "❌ 内存使用率过高: ${mem_usage}%"
    exit 1
fi

# 5. 数据库连接数检查
echo "\n5. 数据库连接数检查"
db_connections=$(curl -s "$MONITORING_URL/api/v1/query?query=mysql_global_status_threads_connected" | jq -r '.data.result[0].value[1]')
if (( $(echo "$db_connections < 100" | bc -l) )); then
    echo "✅ 数据库连接数正常: $db_connections"
else
    echo "❌ 数据库连接数过高: $db_connections"
    exit 1
fi

echo "\n✅ 所有监控指标正常"
```

## ⏪ 回滚程序

### 回滚决策标准

#### 自动回滚触发条件

- 错误率 > 5%
- 平均响应时间 > 5秒
- 健康检查失败率 > 10%
- CPU使用率 > 95%
- 内存使用率 > 95%
- 数据库连接失败

#### 手动回滚触发条件

- 业务指标异常下降
- 用户投诉激增
- 安全漏洞发现
- 数据一致性问题
- 第三方服务集成失败

### 回滚类型

#### 1. 应用回滚

**适用场景**: 应用代码问题

**回滚内容**:
- 应用版本
- 配置文件
- 静态资源

**回滚时间**: 5-10分钟

#### 2. 数据库回滚

**适用场景**: 数据库结构或数据问题

**回滚内容**:
- 数据库结构
- 数据内容
- 存储过程

**回滚时间**: 10-30分钟

#### 3. 完整回滚

**适用场景**: 系统性问题

**回滚内容**:
- 应用版本
- 数据库状态
- 配置文件
- 基础设施

**回滚时间**: 15-60分钟

### 回滚脚本

#### 应用快速回滚

```bash
#!/bin/bash
# 应用快速回滚脚本

set -e

APP_NAME="myapp"
BACKUP_VERSION=$1
CURRENT_VERSION=$(docker ps --format "table {{.Image}}" | grep $APP_NAME | head -1 | cut -d':' -f2)

if [ -z "$BACKUP_VERSION" ]; then
    echo "使用方法: $0 <回滚版本号>"
    echo "当前版本: $CURRENT_VERSION"
    exit 1
fi

echo "=== 开始应用回滚 ==="
echo "当前版本: $CURRENT_VERSION"
echo "回滚版本: $BACKUP_VERSION"
echo "回滚时间: $(date)"

# 1. 验证回滚版本存在
echo "\n1. 验证回滚版本"
if docker image inspect $APP_NAME:$BACKUP_VERSION >/dev/null 2>&1; then
    echo "✅ 回滚版本镜像存在"
else
    echo "❌ 回滚版本镜像不存在，尝试拉取"
    docker pull $APP_NAME:$BACKUP_VERSION
fi

# 2. 停止当前应用
echo "\n2. 停止当前应用"
docker stop ${APP_NAME}_current || true
docker rm ${APP_NAME}_current || true

# 3. 启动回滚版本
echo "\n3. 启动回滚版本"
docker run -d --name ${APP_NAME}_current -p 8080:8080 $APP_NAME:$BACKUP_VERSION

# 4. 健康检查
echo "\n4. 健康检查"
for i in {1..30}; do
    if curl -f http://localhost:8080/health >/dev/null 2>&1; then
        echo "✅ 回滚版本健康检查通过"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "❌ 回滚版本健康检查失败"
        # 尝试恢复原版本
        docker stop ${APP_NAME}_current
        docker rm ${APP_NAME}_current
        docker run -d --name ${APP_NAME}_current -p 8080:8080 $APP_NAME:$CURRENT_VERSION
        exit 1
    fi
    echo "等待回滚版本启动... ($i/30)"
    sleep 10
done

# 5. 验证功能
echo "\n5. 验证基本功能"
if curl -f http://localhost:8080/api/status >/dev/null 2>&1; then
    echo "✅ 基本功能验证通过"
else
    echo "❌ 基本功能验证失败"
    exit 1
fi

echo "\n✅ 应用回滚完成"
echo "回滚完成时间: $(date)"
echo "当前运行版本: $BACKUP_VERSION"

# 记录回滚事件
echo "$(date): 应用从 $CURRENT_VERSION 回滚到 $BACKUP_VERSION" >> /var/log/rollback.log
```

#### 数据库回滚

```bash
#!/bin/bash
# 数据库回滚脚本

set -e

DB_NAME="myapp_db"
BACKUP_FILE=$1
DB_USER="admin"
DB_PASS="password"

if [ -z "$BACKUP_FILE" ] || [ ! -f "$BACKUP_FILE" ]; then
    echo "使用方法: $0 <备份文件路径>"
    echo "可用备份文件:"
    ls -la /backup/*.sql | tail -5
    exit 1
fi

echo "=== 开始数据库回滚 ==="
echo "数据库: $DB_NAME"
echo "备份文件: $BACKUP_FILE"
echo "回滚时间: $(date)"

# 1. 创建当前数据库备份
echo "\n1. 创建当前数据库备份"
CURRENT_BACKUP="/backup/pre_rollback_$(date +%Y%m%d_%H%M%S).sql"
mysqldump -u$DB_USER -p$DB_PASS --single-transaction --routines --triggers $DB_NAME > $CURRENT_BACKUP
echo "✅ 当前数据库已备份到: $CURRENT_BACKUP"

# 2. 停止应用服务
echo "\n2. 停止应用服务"
systemctl stop myapp-service
echo "✅ 应用服务已停止"

# 3. 验证备份文件
echo "\n3. 验证备份文件"
if mysql -u$DB_USER -p$DB_PASS -e "source $BACKUP_FILE" --dry-run 2>/dev/null; then
    echo "✅ 备份文件格式正确"
else
    echo "❌ 备份文件格式错误"
    systemctl start myapp-service
    exit 1
fi

# 4. 执行数据库回滚
echo "\n4. 执行数据库回滚"
mysql -u$DB_USER -p$DB_PASS -e "DROP DATABASE IF EXISTS ${DB_NAME}_temp;"
mysql -u$DB_USER -p$DB_PASS -e "CREATE DATABASE ${DB_NAME}_temp;"
mysql -u$DB_USER -p$DB_PASS ${DB_NAME}_temp < $BACKUP_FILE

if [ $? -eq 0 ]; then
    echo "✅ 备份数据导入临时数据库成功"
else
    echo "❌ 备份数据导入失败"
    mysql -u$DB_USER -p$DB_PASS -e "DROP DATABASE IF EXISTS ${DB_NAME}_temp;"
    systemctl start myapp-service
    exit 1
fi

# 5. 切换数据库
echo "\n5. 切换数据库"
mysql -u$DB_USER -p$DB_PASS -e "RENAME TABLE ${DB_NAME}.users TO ${DB_NAME}_old.users;"
mysql -u$DB_USER -p$DB_PASS -e "RENAME TABLE ${DB_NAME}_temp.users TO ${DB_NAME}.users;"
# 根据实际表结构添加更多表的重命名

# 6. 启动应用服务
echo "\n6. 启动应用服务"
systemctl start myapp-service

# 7. 验证服务
echo "\n7. 验证服务"
for i in {1..30}; do
    if curl -f http://localhost:8080/health >/dev/null 2>&1; then
        echo "✅ 服务验证通过"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "❌ 服务验证失败，开始恢复"
        # 恢复原数据库
        systemctl stop myapp-service
        mysql -u$DB_USER -p$DB_PASS < $CURRENT_BACKUP
        systemctl start myapp-service
        exit 1
    fi
    echo "等待服务启动... ($i/30)"
    sleep 10
done

echo "\n✅ 数据库回滚完成"
echo "回滚完成时间: $(date)"

# 记录回滚事件
echo "$(date): 数据库从 $CURRENT_BACKUP 回滚到 $BACKUP_FILE" >> /var/log/rollback.log
```

#### 蓝绿环境回滚

```bash
#!/bin/bash
# 蓝绿环境回滚脚本

set -e

APP_NAME="myapp"
BLUE_PORT=8080
GREEN_PORT=8081
NGINX_CONFIG="/etc/nginx/sites-available/$APP_NAME"

echo "=== 开始蓝绿环境回滚 ==="
echo "回滚时间: $(date)"

# 1. 检查当前活跃环境
current_port=$(grep -o ":[0-9]*" $NGINX_CONFIG | head -1 | sed 's/://')
if [ "$current_port" = "$BLUE_PORT" ]; then
    active_env="blue"
    backup_env="green"
    backup_port=$GREEN_PORT
else
    active_env="green"
    backup_env="blue"
    backup_port=$BLUE_PORT
fi

echo "当前活跃环境: $active_env (端口: $current_port)"
echo "回滚目标环境: $backup_env (端口: $backup_port)"

# 2. 检查备份环境状态
echo "\n2. 检查备份环境状态"
if docker ps | grep -q ${APP_NAME}_${backup_env}; then
    echo "✅ 备份环境容器存在"
else
    echo "❌ 备份环境容器不存在，无法回滚"
    exit 1
fi

# 3. 验证备份环境健康状态
echo "\n3. 验证备份环境健康状态"
if curl -f http://localhost:$backup_port/health >/dev/null 2>&1; then
    echo "✅ 备份环境健康检查通过"
else
    echo "❌ 备份环境健康检查失败，尝试重启"
    docker restart ${APP_NAME}_${backup_env}
    
    # 等待重启完成
    for i in {1..30}; do
        if curl -f http://localhost:$backup_port/health >/dev/null 2>&1; then
            echo "✅ 备份环境重启后健康检查通过"
            break
        fi
        if [ $i -eq 30 ]; then
            echo "❌ 备份环境重启后仍然失败"
            exit 1
        fi
        echo "等待备份环境重启... ($i/30)"
        sleep 10
    done
fi

# 4. 切换流量到备份环境
echo "\n4. 切换流量到备份环境"
cp $NGINX_CONFIG ${NGINX_CONFIG}.backup
sed -i "s/:$current_port/:$backup_port/g" $NGINX_CONFIG

if nginx -t; then
    systemctl reload nginx
    echo "✅ 流量已切换到备份环境"
else
    echo "❌ Nginx配置错误，恢复原配置"
    cp ${NGINX_CONFIG}.backup $NGINX_CONFIG
    exit 1
fi

# 5. 验证回滚结果
echo "\n5. 验证回滚结果"
sleep 5
for i in {1..10}; do
    if curl -f http://localhost/health >/dev/null 2>&1; then
        echo "✅ 回滚验证通过"
        break
    fi
    if [ $i -eq 10 ]; then
        echo "❌ 回滚验证失败，恢复原环境"
        cp ${NGINX_CONFIG}.backup $NGINX_CONFIG
        nginx -t && systemctl reload nginx
        exit 1
    fi
    echo "验证回滚结果... ($i/10)"
    sleep 3
done

# 6. 停止故障环境
echo "\n6. 停止故障环境"
docker stop ${APP_NAME}_${active_env}
echo "✅ 故障环境已停止"

echo "\n✅ 蓝绿环境回滚完成"
echo "回滚完成时间: $(date)"
echo "当前活跃环境: $backup_env (端口: $backup_port)"

# 记录回滚事件
echo "$(date): 蓝绿环境从 $active_env 回滚到 $backup_env" >> /var/log/rollback.log
```

## 📊 发布监控

### 关键指标监控

#### 1. 应用性能指标

```yaml
# Prometheus 监控规则
groups:
  - name: deployment_monitoring
    rules:
      # 错误率监控
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.05
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "高错误率检测到"
          description: "错误率超过5%，当前值: {{ $value }}"
      
      # 响应时间监控
      - alert: HighResponseTime
        expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 2
        for: 3m
        labels:
          severity: warning
        annotations:
          summary: "响应时间过高"
          description: "95%响应时间超过2秒，当前值: {{ $value }}s"
      
      # 吞吐量监控
      - alert: LowThroughput
        expr: rate(http_requests_total[5m]) < 10
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "吞吐量过低"
          description: "请求吞吐量低于10 RPS，当前值: {{ $value }}"
```

#### 2. 系统资源监控

```yaml
# 系统资源监控规则
groups:
  - name: system_monitoring
    rules:
      # CPU使用率
      - alert: HighCPUUsage
        expr: 100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 3m
        labels:
          severity: warning
        annotations:
          summary: "CPU使用率过高"
          description: "CPU使用率超过80%，当前值: {{ $value }}%"
      
      # 内存使用率
      - alert: HighMemoryUsage
        expr: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 85
        for: 3m
        labels:
          severity: warning
        annotations:
          summary: "内存使用率过高"
          description: "内存使用率超过85%，当前值: {{ $value }}%"
      
      # 磁盘使用率
      - alert: HighDiskUsage
        expr: (1 - (node_filesystem_avail_bytes / node_filesystem_size_bytes)) * 100 > 90
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "磁盘使用率过高"
          description: "磁盘使用率超过90%，当前值: {{ $value }}%"
```

#### 3. 业务指标监控

```yaml
# 业务指标监控规则
groups:
  - name: business_monitoring
    rules:
      # 用户登录成功率
      - alert: LowLoginSuccessRate
        expr: rate(login_attempts_total{status="success"}[5m]) / rate(login_attempts_total[5m]) < 0.95
        for: 3m
        labels:
          severity: warning
        annotations:
          summary: "用户登录成功率过低"
          description: "登录成功率低于95%，当前值: {{ $value }}"
      
      # 订单处理成功率
      - alert: LowOrderSuccessRate
        expr: rate(orders_total{status="success"}[5m]) / rate(orders_total[5m]) < 0.98
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "订单处理成功率过低"
          description: "订单成功率低于98%，当前值: {{ $value }}"
```

### 监控面板配置

#### Grafana 发布监控面板

```json
{
  "dashboard": {
    "title": "发布监控面板",
    "panels": [
      {
        "title": "错误率趋势",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(http_requests_total{status=~'5..'}[5m])",
            "legendFormat": "错误率"
          }
        ],
        "yAxes": [
          {
            "max": 0.1,
            "min": 0
          }
        ],
        "alert": {
          "conditions": [
            {
              "query": {
                "queryType": "",
                "refId": "A"
              },
              "reducer": {
                "type": "last",
                "params": []
              },
              "evaluator": {
                "params": [0.05],
                "type": "gt"
              }
            }
          ],
          "executionErrorState": "alerting",
          "for": "2m",
          "frequency": "10s",
          "handler": 1,
          "name": "错误率告警",
          "noDataState": "no_data",
          "notifications": []
        }
      },
      {
        "title": "响应时间分布",
        "type": "heatmap",
        "targets": [
          {
            "expr": "rate(http_request_duration_seconds_bucket[5m])",
            "legendFormat": "{{le}}"
          }
        ]
      },
      {
        "title": "系统资源使用率",
        "type": "stat",
        "targets": [
          {
            "expr": "100 - (avg(rate(node_cpu_seconds_total{mode='idle'}[5m])) * 100)",
            "legendFormat": "CPU使用率"
          },
          {
            "expr": "(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100",
            "legendFormat": "内存使用率"
          }
        ]
      }
    ]
  }
}
```

## 📝 发布记录与报告

### 发布记录模板

```markdown
# 发布记录 - [版本号]

## 基本信息
- **版本号**: [版本号]
- **发布日期**: [YYYY-MM-DD]
- **发布时间**: [HH:MM - HH:MM]
- **发布类型**: [蓝绿/滚动/金丝雀]
- **发布负责人**: [姓名]
- **技术负责人**: [姓名]

## 发布内容
### 新功能
- [功能1]: [描述] - [开发者]
- [功能2]: [描述] - [开发者]

### Bug修复
- [Bug1]: [描述] - [修复者]
- [Bug2]: [描述] - [修复者]

### 技术改进
- [改进1]: [描述] - [实施者]
- [改进2]: [描述] - [实施者]

## 发布过程
### 时间线
| 时间 | 阶段 | 状态 | 备注 |
|------|------|------|------|
| 14:00 | 预发布检查 | ✅ 完成 | 所有检查通过 |
| 14:15 | 数据备份 | ✅ 完成 | 备份大小: 2.3GB |
| 14:30 | 应用部署 | ✅ 完成 | 蓝绿部署成功 |
| 14:45 | 发布验证 | ✅ 完成 | 所有测试通过 |
| 15:00 | 监控观察 | ✅ 完成 | 指标正常 |

### 遇到的问题
- [问题1]: [描述] - [解决方案]
- [问题2]: [描述] - [解决方案]

## 发布结果
### 成功指标
- ✅ 零停机时间发布
- ✅ 所有功能测试通过
- ✅ 性能指标正常
- ✅ 用户反馈良好

### 监控数据
- **错误率**: 0.02% (目标: <1%)
- **平均响应时间**: 1.2s (目标: <2s)
- **CPU使用率**: 45% (目标: <80%)
- **内存使用率**: 62% (目标: <85%)

## 后续行动
- [ ] 监控观察48小时
- [ ] 收集用户反馈
- [ ] 性能数据分析
- [ ] 文档更新

## 经验总结
### 做得好的地方
- [总结1]
- [总结2]

### 需要改进的地方
- [改进点1]: [具体措施]
- [改进点2]: [具体措施]

## 附件
- 发布计划文档: [链接]
- 测试报告: [链接]
- 监控截图: [链接]
- 备份文件位置: [路径]
```

### 发布报告自动生成

```bash
#!/bin/bash
# 发布报告自动生成脚本

VERSION=$1
REPORT_DIR="/reports/deployment"
REPORT_FILE="$REPORT_DIR/deployment_report_${VERSION}_$(date +%Y%m%d).md"

if [ -z "$VERSION" ]; then
    echo "使用方法: $0 <版本号>"
    exit 1
fi

mkdir -p $REPORT_DIR

echo "=== 生成发布报告 ==="
echo "版本: $VERSION"
echo "报告文件: $REPORT_FILE"

# 获取发布信息
DEPLOY_START=$(grep "开始部署" /var/log/deployment.log | tail -1 | awk '{print $1" "$2}')
DEPLOY_END=$(grep "部署完成" /var/log/deployment.log | tail -1 | awk '{print $1" "$2}')

# 获取监控数据
ERROR_RATE=$(curl -s "http://prometheus:9090/api/v1/query?query=rate(http_requests_total{status=~'5..'}[1h])" | jq -r '.data.result[0].value[1]')
AVG_RESPONSE_TIME=$(curl -s "http://prometheus:9090/api/v1/query?query=rate(http_request_duration_seconds_sum[1h])/rate(http_request_duration_seconds_count[1h])" | jq -r '.data.result[0].value[1]')
CPU_USAGE=$(curl -s "http://prometheus:9090/api/v1/query?query=100-avg(rate(node_cpu_seconds_total{mode='idle'}[1h]))*100" | jq -r '.data.result[0].value[1]')

# 生成报告
cat > $REPORT_FILE << EOF
# 发布报告 - $VERSION

## 基本信息
- **版本号**: $VERSION
- **发布日期**: $(date +%Y-%m-%d)
- **发布开始时间**: $DEPLOY_START
- **发布结束时间**: $DEPLOY_END
- **发布耗时**: $(echo "$DEPLOY_END - $DEPLOY_START" | bc) 分钟

## 发布结果
### 监控指标
- **错误率**: $(echo "$ERROR_RATE * 100" | bc -l)%
- **平均响应时间**: ${AVG_RESPONSE_TIME}s
- **CPU使用率**: ${CPU_USAGE}%

### 发布状态
$(if [ "$ERROR_RATE" \< "0.01" ]; then echo "✅ 发布成功"; else echo "❌ 发布异常"; fi)

## 详细日志
\`\`\`
$(tail -50 /var/log/deployment.log)
\`\`\`

---
报告生成时间: $(date)
EOF

echo "✅ 发布报告生成完成: $REPORT_FILE"

# 发送报告
if command -v mail >/dev/null 2>&1; then
    mail -s "发布报告 - $VERSION" team@company.com < $REPORT_FILE
    echo "✅ 报告已发送到团队邮箱"
fi
```

## 🎯 最佳实践

### 发布前准备

1. **充分测试**
   - 单元测试覆盖率 ≥ 80%
   - 集成测试覆盖主要流程
   - 性能测试验证关键指标
   - 安全测试排除已知漏洞

2. **环境一致性**
   - 开发、测试、生产环境配置一致
   - 使用容器化确保环境隔离
   - 配置管理工具统一管理

3. **监控准备**
   - 关键指标监控配置
   - 告警阈值合理设置
   - 监控面板提前准备

### 发布过程管控

1. **渐进式发布**
   - 优先选择金丝雀或蓝绿部署
   - 分阶段验证功能和性能
   - 及时收集用户反馈

2. **实时监控**
   - 发布过程全程监控
   - 关键指标实时跟踪
   - 异常情况及时响应

3. **快速回滚**
   - 回滚方案提前准备
   - 回滚脚本充分测试
   - 回滚决策标准明确

### 发布后跟踪

1. **持续观察**
   - 发布后48小时重点监控
   - 业务指标变化跟踪
   - 用户反馈收集分析

2. **问题响应**
   - 建立快速响应机制
   - 问题分类处理流程
   - 经验总结和改进

3. **文档更新**
   - 及时更新部署文档
   - 记录经验教训
   - 分享最佳实践

## 🔧 工具和脚本

### 发布工具集

#### 发布管理脚本

```bash
#!/bin/bash
# 发布管理主脚本

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_NAME="myapp"
VERSION=$1
DEPLOY_TYPE=${2:-"blue-green"}  # blue-green, rolling, canary

if [ -z "$VERSION" ]; then
    echo "使用方法: $0 <版本号> [部署类型]"
    echo "部署类型: blue-green, rolling, canary"
    exit 1
fi

echo "=== 发布管理系统 ==="
echo "应用: $APP_NAME"
echo "版本: $VERSION"
echo "部署类型: $DEPLOY_TYPE"
echo "开始时间: $(date)"

# 记录发布开始
echo "$(date): 开始发布 $APP_NAME $VERSION ($DEPLOY_TYPE)" >> /var/log/deployment.log

# 执行预发布检查
echo "\n1. 执行预发布检查"
if ! $SCRIPT_DIR/pre_deploy_check.sh; then
    echo "❌ 预发布检查失败"
    exit 1
fi

# 执行数据备份
echo "\n2. 执行数据备份"
if ! $SCRIPT_DIR/backup_data.sh; then
    echo "❌ 数据备份失败"
    exit 1
fi

# 根据部署类型执行相应脚本
echo "\n3. 执行应用部署"
case $DEPLOY_TYPE in
    "blue-green")
        if ! $SCRIPT_DIR/blue_green_deploy.sh $VERSION; then
            echo "❌ 蓝绿部署失败"
            exit 1
        fi
        ;;
    "rolling")
        if ! $SCRIPT_DIR/rolling_deploy.sh $VERSION; then
            echo "❌ 滚动部署失败"
            exit 1
        fi
        ;;
    "canary")
        if ! $SCRIPT_DIR/canary_deploy.sh $VERSION; then
            echo "❌ 金丝雀部署失败"
            exit 1
        fi
        ;;
    *)
        echo "❌ 不支持的部署类型: $DEPLOY_TYPE"
        exit 1
        ;;
esac

# 执行发布验证
echo "\n4. 执行发布验证"
if ! $SCRIPT_DIR/post_deploy_verify.sh; then
    echo "❌ 发布验证失败，开始回滚"
    $SCRIPT_DIR/rollback.sh
    exit 1
fi

# 生成发布报告
echo "\n5. 生成发布报告"
$SCRIPT_DIR/generate_report.sh $VERSION

# 记录发布完成
echo "$(date): 完成发布 $APP_NAME $VERSION" >> /var/log/deployment.log

echo "\n✅ 发布完成"
echo "结束时间: $(date)"
```

#### 回滚管理脚本

```bash
#!/bin/bash
# 回滚管理主脚本

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_NAME="myapp"
ROLLBACK_TYPE=${1:-"app"}  # app, database, full
BACKUP_VERSION=$2

echo "=== 回滚管理系统 ==="
echo "应用: $APP_NAME"
echo "回滚类型: $ROLLBACK_TYPE"
echo "开始时间: $(date)"

# 记录回滚开始
echo "$(date): 开始回滚 $APP_NAME ($ROLLBACK_TYPE)" >> /var/log/rollback.log

# 根据回滚类型执行相应脚本
case $ROLLBACK_TYPE in
    "app")
        if [ -z "$BACKUP_VERSION" ]; then
            echo "应用回滚需要指定版本号"
            echo "使用方法: $0 app <版本号>"
            exit 1
        fi
        if ! $SCRIPT_DIR/app_rollback.sh $BACKUP_VERSION; then
            echo "❌ 应用回滚失败"
            exit 1
        fi
        ;;
    "database")
        if [ -z "$BACKUP_VERSION" ]; then
            echo "数据库回滚需要指定备份文件"
            echo "使用方法: $0 database <备份文件路径>"
            exit 1
        fi
        if ! $SCRIPT_DIR/database_rollback.sh $BACKUP_VERSION; then
            echo "❌ 数据库回滚失败"
            exit 1
        fi
        ;;
    "full")
        if ! $SCRIPT_DIR/full_rollback.sh; then
            echo "❌ 完整回滚失败"
            exit 1
        fi
        ;;
    *)
        echo "❌ 不支持的回滚类型: $ROLLBACK_TYPE"
        echo "支持的类型: app, database, full"
        exit 1
        ;;
esac

# 验证回滚结果
echo "\n验证回滚结果"
if ! $SCRIPT_DIR/post_rollback_verify.sh; then
    echo "❌ 回滚验证失败"
    exit 1
fi

# 记录回滚完成
echo "$(date): 完成回滚 $APP_NAME" >> /var/log/rollback.log

echo "\n✅ 回滚完成"
echo "结束时间: $(date)"
```

### 监控脚本

#### 实时监控脚本

```bash
#!/bin/bash
# 实时监控脚本

MONITOR_DURATION=${1:-300}  # 默认监控5分钟
CHECK_INTERVAL=10  # 每10秒检查一次
APP_URL="http://localhost:8080"
PROMETHEUS_URL="http://localhost:9090"

echo "=== 实时监控 ==="
echo "监控时长: ${MONITOR_DURATION}秒"
echo "检查间隔: ${CHECK_INTERVAL}秒"
echo "开始时间: $(date)"

# 创建监控日志文件
MONITOR_LOG="/var/log/monitor_$(date +%Y%m%d_%H%M%S).log"
touch $MONITOR_LOG

# 监控函数
monitor_metrics() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # 健康检查
    if curl -f $APP_URL/health >/dev/null 2>&1; then
        health_status="✅ 正常"
    else
        health_status="❌ 异常"
    fi
    
    # 获取错误率
    error_rate=$(curl -s "$PROMETHEUS_URL/api/v1/query?query=rate(http_requests_total{status=~'5..'}[1m])" | jq -r '.data.result[0].value[1]' 2>/dev/null || echo "0")
    
    # 获取响应时间
    response_time=$(curl -s "$PROMETHEUS_URL/api/v1/query?query=rate(http_request_duration_seconds_sum[1m])/rate(http_request_duration_seconds_count[1m])" | jq -r '.data.result[0].value[1]' 2>/dev/null || echo "0")
    
    # 获取CPU使用率
    cpu_usage=$(curl -s "$PROMETHEUS_URL/api/v1/query?query=100-avg(rate(node_cpu_seconds_total{mode='idle'}[1m]))*100" | jq -r '.data.result[0].value[1]' 2>/dev/null || echo "0")
    
    # 输出监控结果
    printf "%-20s | %-10s | %-10s | %-10s | %-10s\n" \
        "$timestamp" \
        "$health_status" \
        "$(printf '%.4f' $error_rate)" \
        "$(printf '%.2f' $response_time)s" \
        "$(printf '%.1f' $cpu_usage)%"
    
    # 记录到日志文件
    echo "$timestamp,health:$health_status,error_rate:$error_rate,response_time:$response_time,cpu_usage:$cpu_usage" >> $MONITOR_LOG
    
    # 检查告警条件
    if (( $(echo "$error_rate > 0.05" | bc -l) )); then
        echo "🚨 告警: 错误率过高 ($error_rate)"
        echo "$(date): 错误率告警 - $error_rate" >> /var/log/alerts.log
    fi
    
    if (( $(echo "$response_time > 2.0" | bc -l) )); then
        echo "🚨 告警: 响应时间过高 (${response_time}s)"
        echo "$(date): 响应时间告警 - ${response_time}s" >> /var/log/alerts.log
    fi
    
    if (( $(echo "$cpu_usage > 80" | bc -l) )); then
        echo "🚨 告警: CPU使用率过高 (${cpu_usage}%)"
        echo "$(date): CPU使用率告警 - ${cpu_usage}%" >> /var/log/alerts.log
    fi
}

# 输出表头
printf "%-20s | %-10s | %-10s | %-10s | %-10s\n" \
    "时间" "健康状态" "错误率" "响应时间" "CPU使用率"
printf "%-20s-+-%-10s-+-%-10s-+-%-10s-+-%-10s\n" \
    "--------------------" "----------" "----------" "----------" "----------"

# 开始监控循环
end_time=$(($(date +%s) + MONITOR_DURATION))
while [ $(date +%s) -lt $end_time ]; do
    monitor_metrics
    sleep $CHECK_INTERVAL
done

echo "\n监控完成，日志文件: $MONITOR_LOG"
```

## 📞 应急响应

### 应急联系人

```yaml
# 应急联系人配置
contacts:
  primary:
    - name: "技术负责人"
      phone: "+86-138-0000-0000"
      email: "tech-lead@company.com"
      role: "技术决策"
    
    - name: "运维负责人"
      phone: "+86-139-0000-0000"
      email: "ops-lead@company.com"
      role: "系统运维"
  
  secondary:
    - name: "产品负责人"
      phone: "+86-137-0000-0000"
      email: "product-lead@company.com"
      role: "业务决策"
    
    - name: "安全负责人"
      phone: "+86-136-0000-0000"
      email: "security-lead@company.com"
      role: "安全响应"

escalation:
  level1: "5分钟内响应"
  level2: "15分钟内响应"
  level3: "30分钟内响应"

notification_channels:
  - type: "phone"
    priority: "critical"
  - type: "email"
    priority: "warning"
  - type: "slack"
    channel: "#alerts"
    priority: "info"
```

### 应急响应流程

#### 1. 问题发现

- **自动监控告警**: 系统自动检测异常并发送告警
- **用户反馈**: 用户报告问题或异常
- **主动发现**: 运维人员主动发现问题

#### 2. 问题评估

```bash
#!/bin/bash
# 问题评估脚本

ISSUE_TYPE=$1  # critical, major, minor
ISSUE_DESC="$2"

echo "=== 问题评估 ==="
echo "问题类型: $ISSUE_TYPE"
echo "问题描述: $ISSUE_DESC"
echo "发现时间: $(date)"

# 根据问题类型确定响应级别
case $ISSUE_TYPE in
    "critical")
        echo "🚨 严重问题 - 立即响应"
        RESPONSE_TIME=5
        ESCALATION_LEVEL="level1"
        ;;
    "major")
        echo "⚠️ 重要问题 - 快速响应"
        RESPONSE_TIME=15
        ESCALATION_LEVEL="level2"
        ;;
    "minor")
        echo "ℹ️ 一般问题 - 正常响应"
        RESPONSE_TIME=30
        ESCALATION_LEVEL="level3"
        ;;
    *)
        echo "❌ 未知问题类型"
        exit 1
        ;;
esac

echo "响应时间要求: ${RESPONSE_TIME}分钟"
echo "升级级别: $ESCALATION_LEVEL"

# 发送通知
echo "发送应急通知..."
# 这里集成实际的通知系统

# 记录问题
echo "$(date): $ISSUE_TYPE - $ISSUE_DESC" >> /var/log/incidents.log
```

#### 3. 应急处理

```bash
#!/bin/bash
# 应急处理脚本

ACTION=$1  # rollback, restart, scale, isolate
TARGET=$2

echo "=== 应急处理 ==="
echo "处理动作: $ACTION"
echo "处理目标: $TARGET"
echo "处理时间: $(date)"

case $ACTION in
    "rollback")
        echo "执行应急回滚"
        ./rollback.sh app $TARGET
        ;;
    "restart")
        echo "重启服务"
        systemctl restart $TARGET
        ;;
    "scale")
        echo "扩容服务"
        docker service scale $TARGET=$(($(docker service ls --filter name=$TARGET --format "{{.Replicas}}" | cut -d'/' -f1) * 2))
        ;;
    "isolate")
        echo "隔离故障节点"
        # 从负载均衡器移除节点
        ;;
    *)
        echo "❌ 未知处理动作"
        exit 1
        ;;
esac

echo "应急处理完成"
```

## 📚 附录

### 常用命令速查

#### Docker 相关

```bash
# 查看容器状态
docker ps -a

# 查看容器日志
docker logs -f <container_name>

# 进入容器
docker exec -it <container_name> /bin/bash

# 重启容器
docker restart <container_name>

# 查看镜像
docker images

# 清理未使用的镜像
docker image prune -f
```

#### 系统监控

```bash
# 查看系统负载
top
htop

# 查看内存使用
free -h

# 查看磁盘使用
df -h

# 查看网络连接
netstat -tulpn
ss -tulpn

# 查看进程
ps aux | grep <process_name>
```

#### 日志查看

```bash
# 查看系统日志
journalctl -f

# 查看特定服务日志
journalctl -u <service_name> -f

# 查看应用日志
tail -f /var/log/app.log

# 搜索日志
grep "ERROR" /var/log/app.log
```

### 故障排查清单

#### 应用无法访问

- [ ] 检查应用进程是否运行
- [ ] 检查端口是否监听
- [ ] 检查防火墙设置
- [ ] 检查负载均衡器配置
- [ ] 检查DNS解析
- [ ] 检查SSL证书

#### 应用响应缓慢

- [ ] 检查CPU使用率
- [ ] 检查内存使用率
- [ ] 检查磁盘I/O
- [ ] 检查网络延迟
- [ ] 检查数据库连接
- [ ] 检查缓存状态

#### 数据库问题

- [ ] 检查数据库服务状态
- [ ] 检查连接数
- [ ] 检查慢查询
- [ ] 检查锁等待
- [ ] 检查磁盘空间
- [ ] 检查备份状态

### 版本历史

| 版本 | 日期 | 修改内容 | 修改人 |
|------|------|----------|--------|
| v1.0.0 | 2025-01-20 | 初始版本 | AgentFoundry |

---

**文档维护**: 本文档应定期更新，确保与实际部署流程保持一致。

**反馈渠道**: 如有问题或建议，请联系运维团队。

**最后更新**: 2025-01-20