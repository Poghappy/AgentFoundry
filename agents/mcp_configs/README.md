# AgentFoundry MCP工具配置总览

## 📋 配置概述

本目录包含AgentFoundry框架中所有智能体的MCP(Model Context Protocol)工具配置文件。每个智能体都根据其专业职责配置了相应的工具集，以确保高效完成各自的任务。

## 🤖 智能体工具配置清单

### 1. Router/Planner (路由规划器)
**配置文件**: `router_planner.json`
**核心工具**: TaskManager
**主要职责**: 任务分解、工作流控制、智能体协调

### 2. Ideation (创意孵化专家)
**配置文件**: `ideation.json`
**核心工具**: sgai-mcp (搜索工具), TaskManager
**主要职责**: 市场调研、机会识别、创新方案设计

### 3. Research (研究分析师)
**配置文件**: `research.json`
**核心工具**: sgai-mcp (全套搜索工具), TaskManager
**主要职责**: 证据收集、竞品分析、数据调研

### 4. Feasibility (可行性评估师)
**配置文件**: `feasibility.json`
**核心工具**: sgai-mcp, GitHub, TaskManager
**主要职责**: 技术可行性、商业可行性、风险评估

### 5. Product (产品经理)
**配置文件**: `product.json`
**核心工具**: TaskManager, sgai-mcp
**主要职责**: 需求定义、用户故事、PRD编写

### 6. Architecture (架构师)
**配置文件**: `architecture.json`
**核心工具**: GitHub, sgai-mcp, TaskManager
**主要职责**: 系统设计、技术选型、架构决策

### 7. Integration (集成策划师)
**配置文件**: `integration.json`
**核心工具**: sgai-mcp, GitHub, TaskManager
**主要职责**: 第三方集成、Build/Buy/Partner决策

### 8. Design (设计师)
**配置文件**: `design.json`
**核心工具**: sgai-mcp, TaskManager
**主要职责**: UI/UX设计、交互规范、无障碍设计

### 9. Implementation (实现工程师)
**配置文件**: `implementation.json`
**核心工具**: GitHub (完整套件), sgai-mcp, TaskManager
**主要职责**: 代码实现、CI/CD、工程实践

### 10. QA & Evaluation (质检评测师)
**配置文件**: `qa_evaluation.json`
**核心工具**: GitHub, sgai-mcp, TaskManager
**主要职责**: 测试设计、安全评估、质量保证

### 11. Growth & Launch (增长发布师)
**配置文件**: `growth_launch.json`
**核心工具**: sgai-mcp, GitHub, TaskManager
**主要职责**: MVP发布、增长策略、数据分析

## 🛠️ MCP工具分类

### sgai-mcp (智能搜索工具套件)
- **markdownify**: 网页转markdown
- **smartscraper**: AI驱动的结构化数据提取
- **searchscraper**: AI搜索和结果分析
- **smartcrawler_initiate/fetch_results**: 智能多页面爬取

### GitHub (代码仓库管理)
- **create_repository**: 创建仓库
- **create_or_update_file**: 文件管理
- **push_files**: 批量推送
- **create_branch/pull_request**: 分支和PR管理
- **search_repositories/code**: 代码搜索
- **get_file_contents**: 文件内容获取

### TaskManager (任务管理)
- **request_planning**: 请求规划
- **get_next_task**: 获取下一任务
- **mark_task_done**: 标记任务完成
- **approve_task_completion**: 任务完成审批
- **open_task_details**: 任务详情查看

## 🔧 配置使用指南

### 在Trae IDE中应用配置

1. **加载智能体配置**:
   ```bash
   # 加载特定智能体配置
   trae agent load --config agents/mcp_configs/[agent_name].json
   ```

2. **验证工具权限**:
   ```bash
   # 检查MCP工具连接状态
   trae mcp status
   ```

3. **启动智能体**:
   ```bash
   # 启动配置好的智能体
   trae agent start [agent_name]
   ```

### 配置文件结构说明

每个配置文件包含以下标准字段:

```json
{
  "agent_name": "智能体名称",
  "description": "角色描述",
  "mcp_tools": {
    "工具服务名": {
      "enabled": true/false,
      "tools": ["具体工具列表"],
      "priority": "high/medium/low",
      "description": "工具用途说明"
    }
  },
  "core_responsibilities": ["核心职责列表"],
  "input_types": ["输入类型"],
  "output_types": ["输出类型"]
}
```

## 🔒 安全和权限管理

### 工具权限分级
- **High Priority**: 核心业务工具，完全访问权限
- **Medium Priority**: 辅助工具，受限访问权限
- **Low Priority**: 可选工具，最小权限原则

### 安全最佳实践
1. **最小权限原则**: 每个智能体只配置必需的工具
2. **工具隔离**: 不同智能体的工具访问相互隔离
3. **审计日志**: 所有工具调用都有完整的审计记录
4. **权限审查**: 定期审查和更新工具权限配置

## 📊 性能优化建议

### 工具调用优化
1. **批量操作**: 优先使用批量API减少调用次数
2. **缓存策略**: 合理使用缓存避免重复调用
3. **并发控制**: 控制并发调用数量避免API限流
4. **错误重试**: 实现智能重试机制提高成功率

### 监控和告警
- **API调用量监控**: 跟踪每个工具的使用情况
- **成功率监控**: 监控工具调用的成功率
- **延迟监控**: 跟踪工具响应时间
- **成本监控**: 监控API调用成本

## 🔄 配置更新和维护

### 版本管理
- 所有配置文件使用Git进行版本控制
- 重要变更需要创建PR并经过审查
- 使用语义化版本号标记重要更新

### 定期维护任务
1. **每周**: 检查工具可用性和权限状态
2. **每月**: 审查工具使用情况和性能指标
3. **每季度**: 评估工具配置的有效性并优化

## 📞 支持和反馈

如果在使用MCP工具配置过程中遇到问题，请:

1. 查看相关智能体的配置文件
2. 检查工具权限和连接状态
3. 查看Trae IDE的日志输出
4. 联系技术支持团队

---

**最后更新**: 2024-01-XX
**维护者**: AgentFoundry团队
**版本**: v1.0.0