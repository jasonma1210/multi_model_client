#!/usr/bin/env python3
"""
批量为所有非首页页面添加 PopScope 包裹。
规则: canPop=true (允许右滑返回上一页，不退出 app)
"""

import os
import re

BASE = "/Users/jianma/Desktop/LLM STUDIO/multi_model_client/lib/features"

# 需要修复的文件及其 Scaffold return 行
FILES = {
    "model/presentation/pages/model_load_page.dart": 128,
    "model/presentation/pages/model_market_page.dart": 211,
    "model/presentation/pages/downloads_page.dart": None,  # 稍后手动查找
    "settings/presentation/pages/knowledge_base_detail_page.dart": 290,
    "settings/presentation/pages/knowledge_base_management_page.dart": None,
    "settings/presentation/pages/log_detail_page.dart": None,
    "settings/presentation/pages/log_list_page.dart": None,
    "settings/presentation/pages/manual_page.dart": None,
    "settings/presentation/pages/memory_settings_page.dart": 134,
    "settings/presentation/pages/model_management_page.dart": None,
    "settings/presentation/pages/network_diagnostics_page.dart": None,
    "settings/presentation/pages/plugin_management_page.dart": None,
    "settings/presentation/pages/storage_paths_page.dart": None,
    "settings/presentation/pages/voice_settings_page.dart": 177,
    "prompt/presentation/pages/prompt_editor_page.dart": 62,
    "prompt/presentation/pages/prompt_templates_page.dart": None,
    "skill/presentation/pages/skill_detail_page.dart": None,
    "skill/presentation/pages/skill_editor_page.dart": 74,
    "skill/presentation/pages/skill_market_page.dart": None,
    "mcp/presentation/pages/mcp_config_page.dart": 70,
    "mcp/presentation/pages/mcp_servers_page.dart": None,
}

# Scaffold return 匹配正则
SCAFFOLD_RETURN_RE = re.compile(r'^(\s*return )Scaffold\(')

POPSCOPE_WRAPPER = """    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        // 右滑返回上一页，与返回按钮行为一致
      },
      child: Scaffold("""

def find_scaffold_line(content):
    """从文件内容中找到 Scaffold return 语句的行号（从1开始）"""
    lines = content.split('\n')
    for i, line in enumerate(lines):
        if SCAFFOLD_RETURN_RE.match(line):
            return i + 1  # 1-indexed
    return None

def add_popscope_to_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # 已经有了 PopScope
    if 'PopScope' in content:
        print(f"SKIP (已有 PopScope): {filepath}")
        return False

    # 找 Scaffold return
    scaffold_line = find_scaffold_line(content)
    if scaffold_line is None:
        print(f"WARN (未找到 Scaffold return): {filepath}")
        return False

    lines = content.split('\n')
    # 找到该行
    line = lines[scaffold_line - 1]
    indent = len(line) - len(line.lstrip())
    indent_str = ' ' * indent

    # 构建包裹
    new_wrapper = f"{indent_str}return PopScope(\n{indent_str}  canPop: true,\n{indent_str}  onPopInvokedWithResult: (didPop, result) {{\n{indent_str}    // 右滑返回上一页，与返回按钮行为一致\n{indent_str}  }},\n{indent_str}  child: Scaffold("

    # 替换
    lines[scaffold_line - 1] = new_wrapper

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))

    print(f"PATCHED ({scaffold_line}): {filepath}")
    return True


def main():
    for rel_path in FILES:
        filepath = os.path.join(BASE, rel_path)
        if not os.path.exists(filepath):
            print(f"NOT FOUND: {filepath}")
            continue
        add_popscope_to_file(filepath)

if __name__ == '__main__':
    main()
