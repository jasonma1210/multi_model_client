#!/bin/bash
# init_agents.sh - 初始化数字员工团队

echo "开始初始化数字员工团队..."

# 创建Agent工作目录
mkdir -p .agents/{product_director,tech_lead,ui_designer_a,ui_designer_b,flutter_dev_a,flutter_dev_b,flutter_dev_c,native_dev_a,native_dev_b,fullstack_dev_a,fullstack_dev_b,algorithm_engineer,test_engineer,security_engineer}

# 为每个Agent创建工作空间
for agent in product_director tech_lead ui_designer_a ui_designer_b flutter_dev_a flutter_dev_b flutter_dev_c native_dev_a native_dev_b fullstack_dev_a fullstack_dev_b algorithm_engineer test_engineer security_engineer; do
  mkdir -p .agents/$agent/{workspace,tasks,docs,output}
  touch .agents/$agent/status.md
  echo "# $agent 工作空间" > .agents/$agent/status.md
done

# 创建全局任务跟踪文件
touch .agents/task_board.md
touch .agents/bug_tracker.md
touch .agents/meeting_notes.md

echo "数字员工团队初始化完成!"
