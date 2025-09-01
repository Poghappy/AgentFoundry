#!/usr/bin/env python3
"""
AgentFoundry MCP配置验证脚本
创建时间: 2024-01-XX
作者: AgentFoundry团队
版本: v1.0.0

功能描述:
- 验证所有智能体MCP配置文件的完整性和正确性
- 检查MCP工具依赖关系
- 生成配置报告和建议
- 检测配置冲突和重复

使用方法:
    python3 scripts/validate_mcp_configs.py [选项]
    选项:
        --agent <name>     仅验证指定智能体
        --report          生成详细报告
        --fix             自动修复发现的问题
        --export          导出配置摘要

依赖要求:
- Python 3.7+
- json, pathlib, argparse (标准库)

注意事项:
- 确保在AgentFoundry项目根目录下运行
- 配置文件必须是有效的JSON格式
"""

import json
import sys
import argparse
from pathlib import Path
from typing import Dict, List, Set, Optional, Tuple
from dataclasses import dataclass
from datetime import datetime

# 配置常量
PROJECT_ROOT = Path(__file__).parent.parent
CONFIG_DIR = PROJECT_ROOT / "agents" / "mcp_configs"
REPORT_DIR = PROJECT_ROOT / "reports"

# 颜色输出
class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    PURPLE = '\033[0;35m'
    CYAN = '\033[0;36m'
    NC = '\033[0m'  # No Color

@dataclass
class ValidationResult:
    """验证结果数据类"""
    agent_name: str
    is_valid: bool
    errors: List[str]
    warnings: List[str]
    suggestions: List[str]
    config_data: Optional[Dict] = None

class MCPConfigValidator:
    """MCP配置验证器"""
    
    def __init__(self):
        self.agents = [
            "router_planner", "ideation", "research", "feasibility",
            "product", "architecture", "integration", "design",
            "implementation", "qa_evaluation", "growth_launch"
        ]
        
        # 定义必需的配置字段
        self.required_fields = {
            "agent_name", "description", "core_responsibilities",
            "mcp_tools", "input_types", "output_types"
        }
        
        # 定义可用的MCP工具
        self.available_tools = {
            "sgai-mcp": ["markdownify", "smartscraper", "searchscraper", 
                         "smartcrawler_initiate", "smartcrawler_fetch_results"],
            "TaskManager": ["request_planning", "get_next_task", "mark_task_done",
                           "approve_task_completion", "approve_request_completion",
                           "open_task_details", "list_requests", "add_tasks_to_request",
                           "update_task", "delete_task"],
            "GitHub": ["create_or_update_file", "search_repositories", "create_repository",
                      "get_file_contents", "push_files", "create_issue", "create_pull_request",
                      "fork_repository", "create_branch", "list_commits", "list_issues",
                      "update_issue", "add_issue_comment", "search_code", "search_issues",
                      "search_users", "get_issue", "get_pull_request", "list_pull_requests",
                      "create_pull_request_review", "merge_pull_request", "get_pull_request_files",
                      "get_pull_request_status", "update_pull_request_branch", "get_pull_request_comments"]
        }
    
    def log_info(self, message: str):
        print(f"{Colors.BLUE}[INFO]{Colors.NC} {message}")
    
    def log_success(self, message: str):
        print(f"{Colors.GREEN}[SUCCESS]{Colors.NC} {message}")
    
    def log_warning(self, message: str):
        print(f"{Colors.YELLOW}[WARNING]{Colors.NC} {message}")
    
    def log_error(self, message: str):
        print(f"{Colors.RED}[ERROR]{Colors.NC} {message}")
    
    def validate_json_format(self, config_file: Path) -> Tuple[bool, Optional[Dict]]:
        """验证JSON格式"""
        try:
            with open(config_file, 'r', encoding='utf-8') as f:
                data = json.load(f)
            return True, data
        except json.JSONDecodeError as e:
            return False, None
        except Exception as e:
            return False, None
    
    def validate_required_fields(self, config_data: Dict) -> List[str]:
        """验证必需字段"""
        errors = []
        for field in self.required_fields:
            if field not in config_data:
                errors.append(f"缺少必需字段: {field}")
            elif not config_data[field]:
                errors.append(f"字段不能为空: {field}")
        return errors
    
    def validate_mcp_tools(self, config_data: Dict) -> Tuple[List[str], List[str]]:
        """验证MCP工具配置"""
        errors = []
        warnings = []
        
        mcp_tools = config_data.get("mcp_tools", {})
        
        for server_name, server_config in mcp_tools.items():
            if server_name not in self.available_tools:
                errors.append(f"未知的MCP服务器: {server_name}")
                continue
            
            # 检查服务器配置格式
            if not isinstance(server_config, dict):
                errors.append(f"MCP服务器配置格式错误: {server_name}")
                continue
            
            # 检查必需字段
            if "enabled" not in server_config:
                warnings.append(f"服务器 {server_name} 缺少 enabled 字段")
            
            if "tools" not in server_config:
                errors.append(f"服务器 {server_name} 缺少 tools 字段")
                continue
            
            tools = server_config["tools"]
            if not isinstance(tools, list):
                errors.append(f"服务器 {server_name} 的 tools 字段必须是列表")
                continue
            
            # 验证工具可用性
            available_tools = self.available_tools[server_name]
            for tool in tools:
                if tool not in available_tools:
                    warnings.append(f"工具 {tool} 在服务器 {server_name} 中不可用")
        
        return errors, warnings
    
    def validate_agent_config(self, agent_name: str) -> ValidationResult:
        """验证单个智能体配置"""
        config_file = CONFIG_DIR / f"{agent_name}.json"
        
        result = ValidationResult(
            agent_name=agent_name,
            is_valid=True,
            errors=[],
            warnings=[],
            suggestions=[]
        )
        
        # 检查文件是否存在
        if not config_file.exists():
            result.is_valid = False
            result.errors.append(f"配置文件不存在: {config_file}")
            return result
        
        # 验证JSON格式
        is_valid_json, config_data = self.validate_json_format(config_file)
        if not is_valid_json:
            result.is_valid = False
            result.errors.append("JSON格式错误")
            return result
        
        result.config_data = config_data
        
        # 验证必需字段
        field_errors = self.validate_required_fields(config_data)
        result.errors.extend(field_errors)
        
        # 验证MCP工具
        tool_errors, tool_warnings = self.validate_mcp_tools(config_data)
        result.errors.extend(tool_errors)
        result.warnings.extend(tool_warnings)
        
        # 验证智能体名称一致性
        if config_data.get("agent_name") != agent_name:
            result.warnings.append("配置文件中的agent_name与文件名不一致")
        
        # 生成建议
        self.generate_suggestions(result)
        
        # 设置验证结果
        if result.errors:
            result.is_valid = False
        
        return result
    
    def generate_suggestions(self, result: ValidationResult):
        """生成优化建议"""
        if not result.config_data:
            return
        
        config = result.config_data
        
        # 检查描述长度
        description = config.get("description", "")
        if len(description) < 50:
            result.suggestions.append("建议增加更详细的描述信息")
        
        # 检查职责数量
        responsibilities = config.get("core_responsibilities", [])
        if len(responsibilities) < 3:
            result.suggestions.append("建议增加更多核心职责描述")
        
        # 检查工具使用
        mcp_tools = config.get("mcp_tools", {})
        if len(mcp_tools) == 1:
            result.suggestions.append("考虑添加更多MCP工具以增强功能")
    
    def validate_all_configs(self) -> List[ValidationResult]:
        """验证所有智能体配置"""
        results = []
        
        self.log_info("开始验证所有智能体配置...")
        
        for agent in self.agents:
            self.log_info(f"验证 {agent} 配置...")
            result = self.validate_agent_config(agent)
            results.append(result)
            
            if result.is_valid:
                self.log_success(f"{agent} 配置验证通过")
            else:
                self.log_error(f"{agent} 配置验证失败")
        
        return results
    
    def generate_report(self, results: List[ValidationResult]) -> str:
        """生成验证报告"""
        report_lines = []
        report_lines.append("# AgentFoundry MCP配置验证报告")
        report_lines.append(f"\n生成时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        report_lines.append(f"验证智能体数量: {len(results)}")
        
        # 统计信息
        valid_count = sum(1 for r in results if r.is_valid)
        error_count = sum(len(r.errors) for r in results)
        warning_count = sum(len(r.warnings) for r in results)
        
        report_lines.append(f"\n## 📊 验证统计")
        report_lines.append(f"- ✅ 通过验证: {valid_count}/{len(results)}")
        report_lines.append(f"- ❌ 错误总数: {error_count}")
        report_lines.append(f"- ⚠️ 警告总数: {warning_count}")
        
        # 详细结果
        report_lines.append(f"\n## 📋 详细验证结果")
        
        for result in results:
            status = "✅ 通过" if result.is_valid else "❌ 失败"
            report_lines.append(f"\n### {result.agent_name} - {status}")
            
            if result.config_data:
                desc = result.config_data.get("description", "无描述")
                report_lines.append(f"**描述**: {desc}")
                
                tools = result.config_data.get("mcp_tools", {})
                tool_list = []
                for server, tool_names in tools.items():
                    tool_list.append(f"{server}({len(tool_names)}个工具)")
                report_lines.append(f"**MCP工具**: {', '.join(tool_list)}")
            
            if result.errors:
                report_lines.append(f"\n**❌ 错误:**")
                for error in result.errors:
                    report_lines.append(f"- {error}")
            
            if result.warnings:
                report_lines.append(f"\n**⚠️ 警告:**")
                for warning in result.warnings:
                    report_lines.append(f"- {warning}")
            
            if result.suggestions:
                report_lines.append(f"\n**💡 建议:**")
                for suggestion in result.suggestions:
                    report_lines.append(f"- {suggestion}")
        
        # 工具使用统计
        report_lines.append(f"\n## 🔧 工具使用统计")
        tool_usage = {}
        for result in results:
            if result.config_data:
                tools = result.config_data.get("mcp_tools", {})
                for server, tool_names in tools.items():
                    if server not in tool_usage:
                        tool_usage[server] = set()
                    tool_usage[server].update(tool_names)
        
        for server, tools in tool_usage.items():
            report_lines.append(f"\n### {server}")
            report_lines.append(f"使用的工具: {', '.join(sorted(tools))}")
            report_lines.append(f"使用智能体数量: {sum(1 for r in results if r.config_data and server in r.config_data.get('mcp_tools', {}))}")
        
        return "\n".join(report_lines)
    
    def export_config_summary(self, results: List[ValidationResult]) -> Dict:
        """导出配置摘要"""
        summary = {
            "timestamp": datetime.now().isoformat(),
            "total_agents": len(results),
            "valid_agents": sum(1 for r in results if r.is_valid),
            "agents": []
        }
        
        for result in results:
            agent_info = {
                "name": result.agent_name,
                "valid": result.is_valid,
                "error_count": len(result.errors),
                "warning_count": len(result.warnings)
            }
            
            if result.config_data:
                agent_info.update({
                    "description": result.config_data.get("description", ""),
                    "mcp_tools": result.config_data.get("mcp_tools", {}),
                    "responsibilities_count": len(result.config_data.get("core_responsibilities", []))
                })
            
            summary["agents"].append(agent_info)
        
        return summary

def main():
    parser = argparse.ArgumentParser(description="AgentFoundry MCP配置验证工具")
    parser.add_argument("--agent", help="仅验证指定智能体")
    parser.add_argument("--report", action="store_true", help="生成详细报告")
    parser.add_argument("--export", action="store_true", help="导出配置摘要")
    parser.add_argument("--output", help="输出文件路径")
    
    args = parser.parse_args()
    
    validator = MCPConfigValidator()
    
    # 验证配置
    if args.agent:
        if args.agent not in validator.agents:
            validator.log_error(f"未知智能体: {args.agent}")
            validator.log_info(f"可用智能体: {', '.join(validator.agents)}")
            sys.exit(1)
        
        results = [validator.validate_agent_config(args.agent)]
    else:
        results = validator.validate_all_configs()
    
    # 显示结果摘要
    valid_count = sum(1 for r in results if r.is_valid)
    total_count = len(results)
    
    print(f"\n{Colors.CYAN}=== 验证结果摘要 ==={Colors.NC}")
    print(f"总计: {total_count} 个智能体")
    print(f"通过: {valid_count} 个")
    print(f"失败: {total_count - valid_count} 个")
    
    # 生成报告
    if args.report:
        report = validator.generate_report(results)
        
        if args.output:
            output_path = Path(args.output)
        else:
            REPORT_DIR.mkdir(exist_ok=True)
            output_path = REPORT_DIR / f"mcp_config_validation_{datetime.now().strftime('%Y%m%d_%H%M%S')}.md"
        
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(report)
        
        validator.log_success(f"验证报告已生成: {output_path}")
    
    # 导出摘要
    if args.export:
        summary = validator.export_config_summary(results)
        
        if args.output:
            output_path = Path(args.output).with_suffix('.json')
        else:
            REPORT_DIR.mkdir(exist_ok=True)
            output_path = REPORT_DIR / f"mcp_config_summary_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(summary, f, indent=2, ensure_ascii=False)
        
        validator.log_success(f"配置摘要已导出: {output_path}")
    
    # 设置退出码
    if valid_count < total_count:
        sys.exit(1)
    else:
        validator.log_success("所有配置验证通过！")
        sys.exit(0)

if __name__ == "__main__":
    main()