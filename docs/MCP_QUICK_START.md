# AgentFoundry MCP工具快速使用指南

## 📋 概述

本指南将帮助你快速配置和使用AgentFoundry项目中的MCP（Model Context Protocol）工具。所有智能体都已预配置了相应的MCP工具，可以直接使用。

## 🚀 快速开始

### 1. 验证配置

首先验证所有MCP配置是否正确：

```bash
# 验证所有智能体配置
python3 scripts/validate_mcp_configs.py --report

# 仅验证特定智能体
python3 scripts/validate_mcp_configs.py --agent research

# 生成配置摘要
python3 scripts/validate_mcp_configs.py --export
```

### 2. 应用配置

使用配置脚本应用MCP工具设置：

```bash
# 应用所有智能体配置
./scripts/setup_mcp_configs.sh

# 仅配置特定智能体
./scripts/setup_mcp_configs.sh --agent research

# 验证MCP服务状态
./scripts/setup_mcp_configs.sh --verify

# 查看配置状态
./scripts/setup_mcp_configs.sh --status
```

### 3. 在Trae IDE中使用

配置完成后，你可以在Trae IDE中直接使用智能体：

```
# 激活研究智能体进行市场调研
@research 帮我调研AI销售助理的市场现状

# 使用产品智能体编写用户故事
@product 为AI销售助理编写核心用户故事

# 让架构智能体设计系统架构
@architecture 设计AI销售助理的技术架构
```

## 🔧 智能体与MCP工具映射

### 核心工具类型

#### 1. sgai-mcp（智能搜索与抓取）
- **功能**: 网页内容抓取、智能搜索、数据提取
- **使用智能体**: ideation, research, feasibility, product, architecture, integration, design, implementation, qa_evaluation, growth_launch
- **主要工具**:
  - `markdownify`: 网页转Markdown
  - `smartscraper`: 智能数据提取
  - `searchscraper`: AI搜索
  - `smartcrawler_*`: 智能爬虫

#### 2. TaskManager（任务管理）
- **功能**: 项目规划、任务跟踪、工作流管理
- **使用智能体**: 所有智能体
- **主要工具**:
  - `request_planning`: 需求规划
  - `get_next_task`: 获取下一任务
  - `mark_task_done`: 标记任务完成
  - `approve_*`: 审批流程

#### 3. GitHub（代码仓库管理）
- **功能**: 代码管理、仓库操作、协作开发
- **使用智能体**: feasibility, architecture, integration, implementation, qa_evaluation, growth_launch
- **主要工具**:
  - `create_repository`: 创建仓库
  - `push_files`: 推送文件
  - `create_pull_request`: 创建PR
  - `search_repositories`: 搜索仓库

### 智能体专用配置

#### Router/Planner（路由规划器）
```json
{
  "mcp_tools": {
    "TaskManager": ["request_planning", "get_next_task", "approve_request_completion"]
  }
}
```
**用途**: 项目整体规划和任务路由

#### Research（研究分析师）
```json
{
  "mcp_tools": {
    "sgai-mcp": ["smartscraper", "searchscraper", "smartcrawler_initiate"],
    "TaskManager": ["request_planning", "mark_task_done"]
  }
}
```
**用途**: 市场调研、技术调研、竞品分析

#### Architecture（架构师）
```json
{
  "mcp_tools": {
    "GitHub": ["search_repositories", "get_file_contents"],
    "sgai-mcp": ["markdownify", "smartscraper"],
    "TaskManager": ["get_next_task", "mark_task_done"]
  }
}
```
**用途**: 技术架构设计、开源方案调研

#### Implementation（实现工程师）
```json
{
  "mcp_tools": {
    "GitHub": ["create_repository", "push_files", "create_pull_request"],
    "sgai-mcp": ["smartscraper"],
    "TaskManager": ["get_next_task", "mark_task_done"]
  }
}
```
**用途**: 代码实现、仓库管理、CI/CD

## 💡 使用技巧

### 1. 智能体协作模式

```bash
# 完整的6A工作流示例
6A: 开发一个AI销售助理MVP，预算$2000，30天交付

# 系统会自动:
# 1. Router规划整体任务
# 2. Research调研市场和技术
# 3. Product定义需求和用户故事
# 4. Architecture设计技术架构
# 5. Implementation实现核心功能
# 6. QA进行测试和验证
# 7. Growth制定发布策略
```

### 2. 单独使用智能体

```bash
# 使用研究智能体进行深度调研
@research 调研以下技术栈的最佳实践：
- React + TypeScript前端
- Node.js + Express后端
- PostgreSQL数据库
- OpenAI API集成

# 使用架构智能体设计API
@architecture 设计RESTful API架构，包括：
- 用户认证和授权
- 销售线索管理
- AI对话接口
- 数据分析报表
```

### 3. 工具链组合使用

```bash
# 研究 + 产品 + 架构的组合流程
@research 调研CRM集成的主流方案
@product 基于调研结果定义CRM集成需求
@architecture 设计CRM集成的技术方案
```

## 🔍 故障排除

### 常见问题

#### 1. MCP服务连接失败
```bash
# 检查MCP服务状态
./scripts/setup_mcp_configs.sh --verify

# 重启MCP服务
trae mcp restart

# 重新应用配置
./scripts/setup_mcp_configs.sh --reset
./scripts/setup_mcp_configs.sh
```

#### 2. 智能体工具权限问题
```bash
# 检查智能体权限
trae agent permissions list

# 重新设置权限
trae agent permissions grant --agent research --tools sgai-mcp,TaskManager
```

#### 3. 配置文件格式错误
```bash
# 验证配置文件
python3 scripts/validate_mcp_configs.py --agent research

# 查看详细错误信息
python3 scripts/validate_mcp_configs.py --report
```

### 日志查看

```bash
# 查看MCP服务日志
trae mcp logs

# 查看智能体执行日志
trae agent logs --agent research

# 查看系统日志
trae system logs
```

## 📊 性能优化

### 1. 工具使用优化

- **并行执行**: 多个智能体可以并行使用不同的MCP工具
- **缓存策略**: 研究结果会自动缓存，避免重复调用
- **限流控制**: 自动控制API调用频率，避免超限

### 2. 资源管理

```bash
# 监控MCP工具使用情况
trae mcp stats

# 清理缓存
trae mcp cache clear

# 优化配置
trae mcp optimize
```

## 🔐 安全注意事项

### 1. API密钥管理

- 所有API密钥通过环境变量管理
- 不在配置文件中明文存储敏感信息
- 定期轮换API密钥

### 2. 权限控制

- 每个智能体只能访问必需的MCP工具
- 敏感操作需要额外授权
- 定期审查权限配置

### 3. 数据保护

- 调研数据自动脱敏处理
- 不持久化用户敏感信息
- 遵循GDPR等数据保护法规

## 📚 进阶使用

### 1. 自定义MCP工具

```json
{
  "mcp_tools": {
    "custom-tool": ["custom_function_1", "custom_function_2"]
  },
  "tool_configs": {
    "custom-tool": {
      "endpoint": "http://localhost:8080",
      "auth": "bearer_token"
    }
  }
}
```

### 2. 工作流自动化

```bash
# 创建自动化工作流
trae workflow create --name "ai-assistant-dev" --config workflows/ai_assistant.yaml

# 运行工作流
trae workflow run ai-assistant-dev
```

### 3. 集成外部系统

```bash
# 集成Slack通知
trae integration add slack --webhook-url $SLACK_WEBHOOK

# 集成Jira任务管理
trae integration add jira --api-key $JIRA_API_KEY
```

## 🎯 最佳实践

### 1. 配置管理

- 使用版本控制管理配置文件
- 定期备份配置
- 测试环境与生产环境分离

### 2. 监控和日志

- 启用详细日志记录
- 设置性能监控告警
- 定期分析使用统计

### 3. 团队协作

- 统一配置标准
- 共享最佳实践
- 定期培训和知识分享

## 📞 支持和帮助

### 获取帮助

```bash
# 查看帮助文档
trae help mcp

# 查看智能体帮助
trae agent help

# 查看配置脚本帮助
./scripts/setup_mcp_configs.sh --help
python3 scripts/validate_mcp_configs.py --help
```

### 社区资源

- [AgentFoundry文档](./README.md)
- [MCP协议规范](https://modelcontextprotocol.io/)
- [Trae IDE官方文档](https://trae.ai/docs)

---

**注意**: 本指南基于AgentFoundry v1.0.0版本编写，使用前请确保版本兼容性。