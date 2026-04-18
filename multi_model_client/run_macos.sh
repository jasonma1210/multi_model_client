#!/bin/bash
# LLM Studio macOS 开发启动脚本
# 自动将 llama.cpp 动态库嵌入 app bundle 后启动应用
#
# 用法: bash run_macos.sh [debug|release]

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

echo "🚀 LLM Studio macOS 开发启动脚本"
echo "================================"

# 1. 先构建 Flutter 应用
echo ""
echo "📦 构建 Flutter macOS 应用..."
flutter build macos --debug 2>&1 | tail -5

# 2. 复制动态库到 app bundle
echo ""
echo "🔧 嵌入 llama.cpp 动态库..."
bash macos/copy_frameworks.sh

# 3. 启动应用
echo ""
echo "▶️ 启动应用..."
flutter run -d macos 2>&1 &
FLUTTER_PID=$!

echo ""
echo "✅ 应用已启动 (PID: $FLUTTER_PID)"
echo "   按 Ctrl+C 停止应用"

# 等待 Flutter 进程结束
wait $FLUTTER_PID
