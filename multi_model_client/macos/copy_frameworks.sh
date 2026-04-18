#!/bin/bash
# 将 llama.cpp 动态库复制到 macOS app bundle 的 Frameworks 目录
# 此脚本由 Xcode Build Phase 自动调用，也可手动运行
#
# Xcode 环境变量:
#   PROJECT_DIR - 项目目录 (macos/)
#   CONFIGURATION - Debug/Release
#   BUILT_PRODUCTS_DIR - 构建产物目录
#   PRODUCT_NAME - 产品名称
#
# 手动运行: bash macos/copy_frameworks.sh

set -e

echo "🔧 [Copy Frameworks] 复制 llama.cpp 动态库..."

# 确定项目根目录
if [ -n "$PROJECT_DIR" ]; then
    # 从 Xcode Build Phase 调用
    MACOS_DIR="$PROJECT_DIR"
    PROJECT_DIR="$(cd "$PROJECT_DIR/.." && pwd)"
else
    # 手动运行
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    MACOS_DIR="$SCRIPT_DIR"
    PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
fi

# Frameworks 源目录 (macos/Frameworks/)
FRAMEWORKS_SRC="$MACOS_DIR/Frameworks"

if [ ! -d "${FRAMEWORKS_SRC}" ]; then
    echo "⚠️ [Copy Frameworks] 源目录不存在: ${FRAMEWORKS_SRC}"
    exit 0
fi

# 确定构建配置和 app bundle 路径
if [ -n "$BUILT_PRODUCTS_DIR" ] && [ -n "$PRODUCT_NAME" ]; then
    # 从 Xcode Build Phase 调用
    APP_BUNDLE="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app"
else
    # 手动运行
    CONFIG="${CONFIGURATION:-Debug}"
    APP_BUNDLE="$PROJECT_DIR/build/macos/Build/Products/$CONFIG/multi_model_client.app"
fi

if [ ! -d "${APP_BUNDLE}" ]; then
    echo "⚠️ [Copy Frameworks] App bundle 不存在: ${APP_BUNDLE}"
    exit 0
fi

# 创建 Frameworks 目录
FRAMEWORKS_DST="${APP_BUNDLE}/Contents/Frameworks"
mkdir -p "${FRAMEWORKS_DST}"

# 复制所有 .dylib 文件
COPIED=0
for dylib in "${FRAMEWORKS_SRC}"/*.dylib; do
    if [ -f "$dylib" ]; then
        FILENAME=$(basename "$dylib")
        DEST_FILE="${FRAMEWORKS_DST}/${FILENAME}"
        
        # 检查目标是否已存在
        if [ -f "${DEST_FILE}" ]; then
            continue
        fi
        
        cp -f "$dylib" "${FRAMEWORKS_DST}/"
        COPIED=$((COPIED + 1))
    fi
done

# 修复 RPATH
EXECUTABLE="${APP_BUNDLE}/Contents/MacOS/multi_model_client"
if [ -f "${EXECUTABLE}" ]; then
    CURRENT_RPATHS=$(otool -l "${EXECUTABLE}" 2>/dev/null | grep -A2 LC_RPATH | grep path | grep "@executable_path/../Frameworks" || true)
    if [ -z "${CURRENT_RPATHS}" ]; then
        install_name_tool -add_rpath "@executable_path/../Frameworks" "${EXECUTABLE}" 2>/dev/null || true
    fi
fi

if [ $COPIED -gt 0 ]; then
    echo "🔧 [Copy Frameworks] ✅ 已复制 ${COPIED} 个动态库"
else
    echo "🔧 [Copy Frameworks] ℹ️ 无新文件需要复制"
fi
