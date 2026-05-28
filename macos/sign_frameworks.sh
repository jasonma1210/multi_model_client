#!/bin/bash
# sign_frameworks.sh - 对 macOS app bundle 内所有 dylib 进行 ad-hoc 签名
#
# 背景：llamadart (ggml 后端) 在运行时通过 dlopen 动态加载 libggml-*.dylib，
# macOS 沙盒要求这些 dylib 必须有代码签名，否则报：
#   EXC_BAD_ACCESS (SIGKILL - Code Signature Invalid)
#
# 用法：
#   bash macos/sign_frameworks.sh           # 签名 Debug build
#   bash macos/sign_frameworks.sh release   # 签名 Release build
#   bash macos/sign_frameworks.sh <path>    # 签名指定 app bundle 路径

set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_CONFIG="${1:-Debug}"

# 支持直接传入 app bundle 路径
if [[ "$1" == *".app" ]]; then
    APP_BUNDLE="$1"
elif [[ "$1" == "release" || "$1" == "Release" ]]; then
    APP_BUNDLE="$PROJECT_DIR/build/macos/Build/Products/Release/multi_model_client.app"
else
    APP_BUNDLE="$PROJECT_DIR/build/macos/Build/Products/Debug/multi_model_client.app"
fi

FRAMEWORKS_DIR="${APP_BUNDLE}/Contents/Frameworks"

if [ ! -d "${FRAMEWORKS_DIR}" ]; then
    echo "❌ [sign_frameworks] Frameworks 目录不存在: ${FRAMEWORKS_DIR}"
    exit 1
fi

echo "🔐 [sign_frameworks] 对 ${FRAMEWORKS_DIR} 内所有 dylib 进行 ad-hoc 签名..."

SIGNED=0
FAILED=0

for dylib in "${FRAMEWORKS_DIR}"/*.dylib; do
    if [ -f "$dylib" ]; then
        name=$(basename "$dylib")
        if codesign --force --sign - "$dylib" 2>/dev/null; then
            echo "  ✅ $name"
            SIGNED=$((SIGNED + 1))
        else
            echo "  ❌ $name (签名失败)"
            FAILED=$((FAILED + 1))
        fi
    fi
done

echo ""
echo "🔐 [sign_frameworks] 完成: ${SIGNED} 个成功, ${FAILED} 个失败"

# 验证关键库
METAL_LIB="${FRAMEWORKS_DIR}/libggml-metal.dylib"
if [ -f "${METAL_LIB}" ]; then
    if codesign --verify "${METAL_LIB}" 2>/dev/null; then
        echo "✅ libggml-metal.dylib 签名验证通过"
    else
        echo "❌ libggml-metal.dylib 签名验证失败"
        exit 1
    fi
fi

echo "✅ 所有 dylib 签名完成，可以运行应用"
