#!/bin/bash
# build_llama_cpp.sh - 编译 llama.cpp 库（macOS 版本，支持 Metal 加速）
# 使用方法: ./build_llama_cpp.sh [--clean]

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== llama.cpp macOS 编译脚本 (Metal 加速) ===${NC}"
echo ""

# 解析参数
CLEAN=false
if [[ "$1" == "--clean" ]]; then
    CLEAN=true
    echo -e "${YELLOW}清理模式已启用${NC}"
fi

# 项目根目录
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_DIR/build/llama_cpp"
SRC_DIR="$BUILD_DIR/llama.cpp"

# 创建目录
mkdir -p "$BUILD_DIR"

# 检查是否需要克隆 llama.cpp
if [ ! -d "$SRC_DIR" ]; then
    echo -e "${GREEN}正在克隆 llama.cpp 仓库...${NC}"
    git clone --depth 1 https://github.com/ggml-org/llama.cpp.git "$SRC_DIR"
else
    echo -e "${GREEN}llama.cpp 已存在，跳过克隆${NC}"
fi

# 清理旧构建
if [ "$CLEAN" = true ] && [ -d "$SRC_DIR/build" ]; then
    echo -e "${YELLOW}清理旧构建...${NC}"
    rm -rf "$SRC_DIR/build"
fi

# 创建构建目录
mkdir -p "$SRC_DIR/build"
cd "$SRC_DIR/build"

# 配置 CMake（Metal 加速）
echo -e "${GREEN}配置 CMake（Metal 加速）...${NC}"

# 检测芯片类型
if [[ $(uname -m) == 'arm64' ]]; then
    echo "检测到 Apple Silicon (ARM64)"
    CMAKE_ARGS="-DLLAMA_METAL=ON -DLLAMA_METAL_EMBED_LIBRARY=ON -DCMAKE_BUILD_TYPE=Release"
else
    echo "检测到 Intel Mac"
    CMAKE_ARGS="-DLLAMA_METAL=OFF -DCMAKE_BUILD_TYPE=Release"
fi

cmake .. \
    -DCMAKE_OSX_ARCHITECTURES="$(uname -m)" \
    -DCMAKE_INSTALL_PREFIX="$BUILD_DIR/install" \
    -DLLAMA_BUILD_TESTS=OFF \
    -DLLAMA_BUILD_EXAMPLES=OFF \
    $CMAKE_ARGS

# 编译
echo -e "${GREEN}编译 llama.cpp...${NC}"
cmake --build . --config Release -j$(sysctl -n hw.ncpu)

# 安装
echo -e "${GREEN}安装库文件...${NC}"
cmake --install .

# 复制到项目 lib 目录
LIB_DIR="$PROJECT_DIR/lib"
mkdir -p "$LIB_DIR"

if [[ $(uname -m) == 'arm64' ]]; then
    cp "$BUILD_DIR/install/lib/libllama.dylib" "$LIB_DIR/" 2>/dev/null || true
    cp "$BUILD_DIR/install/lib/libllama_metallib.dylib" "$LIB_DIR/" 2>/dev/null || true
fi

# 复制 CPU 版本
cp "$BUILD_DIR/install/lib/libllama.dylib" "$LIB_DIR/libllama_cpu.dylib" 2>/dev/null || true

echo ""
echo -e "${GREEN}=== 编译完成！ ===${NC}"
echo ""
echo "库文件位置: $BUILD_DIR/install/lib/"
echo "项目 lib 目录: $LIB_DIR/"
echo ""
echo "Apple Silicon 建议使用 Metal 版本，Intel Mac 使用 CPU 版本"
echo ""

# 列出生成的文件
if [ -d "$BUILD_DIR/install/lib" ]; then
    echo "生成的库文件:"
    ls -lh "$BUILD_DIR/install/lib/" | grep -E "\.dylib|\.a" || echo "未找到库文件"
fi
