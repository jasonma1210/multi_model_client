#!/bin/bash
# LLM Studio macOS 开发启动脚本
# 自动将 llama.cpp 动态库嵌入 app bundle、签名后启动应用
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

# 2. 复制动态库到 app bundle（内含自动签名逻辑）
echo ""
echo "🔧 嵌入 llama.cpp 动态库 & 签名..."
bash macos/copy_frameworks.sh

# 3. 对构建产物目录的所有 dylib 进行 ad-hoc 签名
#    （flutter build macos 生成的 Frameworks 下的 ggml 系列 dylib 默认无签名）
echo ""
echo "🔐 签名 app bundle 内所有 dylib..."
APP_BUNDLE="$PROJECT_DIR/build/macos/Build/Products/Debug/multi_model_client.app"
if [ -d "${APP_BUNDLE}/Contents/Frameworks" ]; then
    SIGNED=0
    for dylib in "${APP_BUNDLE}/Contents/Frameworks"/*.dylib; do
        if [ -f "$dylib" ]; then
            codesign --force --sign - "$dylib" 2>/dev/null && SIGNED=$((SIGNED + 1)) || true
        fi
    done
    echo "🔐 ✅ 签名 ${SIGNED} 个 dylib"
fi

# 4. 启动应用
echo ""
echo "▶️ 启动应用..."
flutter run -d macos 2>&1 &
FLUTTER_PID=$!

echo ""
echo "✅ 应用已启动 (PID: $FLUTTER_PID)"
echo "   按 Ctrl+C 停止应用"

# 等待 Flutter 进程结束
wait $FLUTTER_PID
