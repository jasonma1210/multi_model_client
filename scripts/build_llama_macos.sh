#!/bin/bash

# llama.cpp 自动化编译脚本 for macOS and iOS
# 使用方法: ./build_llama_macos.sh [platform]
# platform: macos (默认) 或 ios

set -e  # 遇到错误立即退出

PLATFORM=${1:-macos}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_ROOT/build_llama"
OUTPUT_DIR="$PROJECT_ROOT/native_libs"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== llama.cpp 编译脚本 ===${NC}"
echo "平台: $PLATFORM"
echo "项目根目录: $PROJECT_ROOT"
echo "构建目录: $BUILD_DIR"
echo "输出目录: $OUTPUT_DIR"

# 检查依赖
check_dependencies() {
    echo -e "${YELLOW}检查依赖...${NC}"

    # 检查CMake
    if ! command -v cmake &> /dev/null; then
        echo -e "${RED}错误: CMake未安装${NC}"
        echo "请运行: brew install cmake"
        exit 1
    fi

    # 检查Git
    if ! command -v git &> /dev/null; then
        echo -e "${RED}错误: Git未安装${NC}"
        exit 1
    fi

    # 检查Xcode (仅macOS/iOS)
    if [[ "$PLATFORM" == "macos" ]] || [[ "$PLATFORM" == "ios" ]]; then
        if ! command -v xcodebuild &> /dev/null; then
            echo -e "${RED}错误: Xcode未安装${NC}"
            exit 1
        fi
    fi

    echo -e "${GREEN}所有依赖已满足${NC}"
}

# 克隆llama.cpp仓库
clone_repo() {
    if [ -d "$BUILD_DIR/llama.cpp" ]; then
        echo -e "${YELLOW}llama.cpp已存在，跳过克隆${NC}"
        return
    fi

    echo -e "${YELLOW}克隆llama.cpp仓库...${NC}"
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"
    git clone https://github.com/ggerganov/llama.cpp.git
    cd llama.cpp

    # 记录版本
    git rev-parse HEAD > "$BUILD_DIR/LLAMA_VERSION.txt"
    echo -e "${GREEN}克隆完成${NC}"
}

# 编译macOS版本
build_macos() {
    echo -e "${YELLOW}开始编译macOS版本（带Metal支持）...${NC}"

    cd "$BUILD_DIR/llama.cpp"

    # 创建构建目录
    BUILD_PATH="$BUILD_DIR/build_macos"
    mkdir -p "$BUILD_PATH"

    # CMake配置
    cmake -B "$BUILD_PATH" \
        -DBUILD_SHARED_LIBS=ON \
        -DGGML_METAL=ON \
        -DGGML_METAL_USE_BF16=ON \
        -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
        -DCMAKE_BUILD_TYPE=Release \
        -DLLAMA_BUILD_EXAMPLES=OFF

    # 编译
    cmake --build "$BUILD_PATH" --config Release -j$(sysctl -n hw.ncpu)

    echo -e "${GREEN}macOS编译完成${NC}"
}

# 编译iOS版本
build_ios() {
    echo -e "${YELLOW}开始编译iOS版本（带Metal支持）...${NC}"

    cd "$BUILD_DIR/llama.cpp"

    # 创建构建目录
    BUILD_PATH="$BUILD_DIR/build_ios"
    mkdir -p "$BUILD_PATH"

    # CMake配置
    cmake -B "$BUILD_PATH" \
        -DCMAKE_SYSTEM_NAME=iOS \
        -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
        -DCMAKE_OSX_DEPLOYMENT_TARGET=14.0 \
        -DBUILD_SHARED_LIBS=OFF \
        -DGGML_METAL=ON \
        -DGGML_METAL_USE_BF16=ON \
        -DCMAKE_BUILD_TYPE=Release \
        -DLLAMA_BUILD_EXAMPLES=OFF

    # 编译
    cmake --build "$BUILD_PATH" --config Release -j$(sysctl -n hw.ncpu)

    echo -e "${GREEN}iOS编译完成${NC}"
}

# 复制编译产物
copy_artifacts() {
    echo -e "${YELLOW}复制编译产物...${NC}"

    mkdir -p "$OUTPUT_DIR"

    if [[ "$PLATFORM" == "macos" ]]; then
        # macOS动态库
        mkdir -p "$OUTPUT_DIR/macos"

        cp "$BUILD_DIR/build_macos/src/libllama.dylib" "$OUTPUT_DIR/macos/"
        cp "$BUILD_DIR/build_macos/ggml/src/libggml.dylib" "$OUTPUT_DIR/macos/"
        cp "$BUILD_DIR/build_macos/ggml/src/ggml-metal/libggml-metal.dylib" "$OUTPUT_DIR/macos/" 2>/dev/null || true

        echo -e "${GREEN}macOS动态库已复制到: $OUTPUT_DIR/macos/${NC}"

    elif [[ "$PLATFORM" == "ios" ]]; then
        # iOS静态库
        mkdir -p "$OUTPUT_DIR/ios"

        cp "$BUILD_DIR/build_ios/src/libllama.a" "$OUTPUT_DIR/ios/"
        cp "$BUILD_DIR/build_ios/ggml/src/libggml.a" "$OUTPUT_DIR/ios/"

        echo -e "${GREEN}iOS静态库已复制到: $OUTPUT_DIR/ios/${NC}"
    fi
}

# 集成到Flutter项目
integrate_to_flutter() {
    echo -e "${YELLOW}集成到Flutter项目...${NC}"

    if [[ "$PLATFORM" == "macos" ]]; then
        FRAMEWORKS_DIR="$PROJECT_ROOT/macos/Frameworks"
        mkdir -p "$FRAMEWORKS_DIR"

        cp "$OUTPUT_DIR/macos/"*.dylib "$FRAMEWORKS_DIR/"

        echo -e "${GREEN}macOS动态库已集成到: $FRAMEWORKS_DIR${NC}"

    elif [[ "$PLATFORM" == "ios" ]]; then
        # 创建XCFramework
        echo -e "${YELLOW}创建XCFramework...${NC}"

        XCFRAMEWORK_PATH="$PROJECT_ROOT/ios/llama.xcframework"

        xcodebuild -create-xcframework \
            -library "$OUTPUT_DIR/ios/libllama.a" \
            -library "$OUTPUT_DIR/ios/libggml.a" \
            -output "$XCFRAMEWORK_PATH"

        echo -e "${GREEN}iOS XCFramework已创建: $XCFRAMEWORK_PATH${NC}"
    fi
}

# 主流程
main() {
    check_dependencies
    clone_repo

    if [[ "$PLATFORM" == "macos" ]]; then
        build_macos
    elif [[ "$PLATFORM" == "ios" ]]; then
        build_ios
    else
        echo -e "${RED}错误: 未知平台 '$PLATFORM'${NC}"
        echo "支持的平台: macos, ios"
        exit 1
    fi

    copy_artifacts
    integrate_to_flutter

    echo -e "${GREEN}=== 编译完成 ===${NC}"
    echo "版本信息: $(cat $BUILD_DIR/LLAMA_VERSION.txt)"
    echo "编译产物位置: $OUTPUT_DIR"
}

# 执行主流程
main
