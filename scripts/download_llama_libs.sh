#!/bin/bash

# llama.cpp 库自动下载脚本
# 使用方法: ./download_llama_libs.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
OUTPUT_DIR="$PROJECT_ROOT/libs"
TEMP_DIR="/tmp/llama_cpp_download"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== llama.cpp 库下载脚本 ===${NC}"

# 检测架构
ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
    FILENAME="llama-b8833-bin-macos-arm64.tar.gz"
    echo "检测到 Apple Silicon (M1/M2/M3/M4)"
elif [ "$ARCH" = "x86_64" ]; then
    FILENAME="llama-b8833-bin-macos-x64.tar.gz"
    echo "检测到 Intel Mac"
else
    echo -e "${RED}不支持的架构: $ARCH${NC}"
    exit 1
fi

# 创建输出目录
mkdir -p "$OUTPUT_DIR"

# 创建临时目录
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"

# 下载
echo -e "${YELLOW}下载 llama.cpp...${NC}"
URL="https://github.com/ggml-org/llama.cpp/releases/download/b8833/$FILENAME"
curl -L -o "$FILENAME" "$URL"

# 解压
echo -e "${YELLOW}解压...${NC}"
tar -xzf "$FILENAME"

# 复制可执行文件
echo -e "${YELLOW}复制文件到 libs 目录...${NC}"
SOURCE_DIR=$(ls -d llama-b8833-bin-macos-*)
cp "$SOURCE_DIR"/* "$OUTPUT_DIR"/

# 清理
rm -rf "$TEMP_DIR"

echo -e "${GREEN}=== 下载完成 ===${NC}"
echo "文件已放置到: $OUTPUT_DIR"
ls -la "$OUTPUT_DIR"