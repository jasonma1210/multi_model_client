#!/bin/bash

# iOS原生库编译脚本
# 用途：编译libllama.dylib和libwhisper.dylib

set -e

echo "🚀 开始编译iOS原生库..."

# 配置变量
LLAMA_CPP_VERSION="b2861"
WHISPER_CPP_VERSION="v1.5.5"
IOS_MIN_VERSION="15.0"
ARCHS=("arm64")
BUILD_DIR="build/ios"

# 创建构建目录
mkdir -p $BUILD_DIR

# 编译llama.cpp
compile_llama() {
    echo "📦 编译llama.cpp..."

    # 下载源码
    if [ ! -d "$BUILD_DIR/llama.cpp" ]; then
        git clone https://github.com/ggerganov/llama.cpp.git $BUILD_DIR/llama.cpp
        cd $BUILD_DIR/llama.cpp
        git checkout $LLAMA_CPP_VERSION
        cd -
    fi

    cd $BUILD_DIR/llama.cpp

    # 编译arm64架构
    for ARCH in "${ARCHS[@]}"; do
        echo "🔨 编译 $ARCH 架构..."

        mkdir -p build_$ARCH
        cd build_$ARCH

        cmake .. \
            -DCMAKE_OSX_ARCHITECTURES=$ARCH \
            -DCMAKE_OSX_DEPLOYMENT_TARGET=$IOS_MIN_VERSION \
            -DCMAKE_SYSTEM_NAME=iOS \
            -DCMAKE_C_FLAGS="-target ${ARCH}-apple-ios${IOS_MIN_VERSION}" \
            -DCMAKE_CXX_FLAGS="-target ${ARCH}-apple-ios${IOS_MIN_VERSION}" \
            -DLLAMA_METAL=ON \
            -DLLAMA_METAL_EMBED_LIBRARY=ON \
            -DBUILD_SHARED_LIBS=ON \
            -DCMAKE_BUILD_TYPE=Release

        make -j$(sysctl -n hw.ncpu)

        cd ..
    done

    cd ../../..

    # 复制产物
    mkdir -p ios/libs
    cp $BUILD_DIR/llama.cpp/build_arm64/libllama.dylib ios/libs/libllama.dylib

    echo "✅ llama.cpp编译完成"
}

# 编译whisper.cpp
compile_whisper() {
    echo "📦 编译whisper.cpp..."

    # 下载源码
    if [ ! -d "$BUILD_DIR/whisper.cpp" ]; then
        git clone https://github.com/ggerganov/whisper.cpp.git $BUILD_DIR/whisper.cpp
        cd $BUILD_DIR/whisper.cpp
        git checkout $WHISPER_CPP_VERSION
        cd -
    fi

    cd $BUILD_DIR/whisper.cpp

    # 编译arm64架构
    for ARCH in "${ARCHS[@]}"; do
        echo "🔨 编译 $ARCH 架构..."

        mkdir -p build_$ARCH
        cd build_$ARCH

        cmake .. \
            -DCMAKE_OSX_ARCHITECTURES=$ARCH \
            -DCMAKE_OSX_DEPLOYMENT_TARGET=$IOS_MIN_VERSION \
            -DCMAKE_SYSTEM_NAME=iOS \
            -DCMAKE_C_FLAGS="-target ${ARCH}-apple-ios${IOS_MIN_VERSION}" \
            -DCMAKE_CXX_FLAGS="-target ${ARCH}-apple-ios${IOS_MIN_VERSION}" \
            -DWHISPER_COREML=ON \
            -DBUILD_SHARED_LIBS=ON \
            -DCMAKE_BUILD_TYPE=Release

        make -j$(sysctl -n hw.ncpu)

        cd ..
    done

    cd ../../..

    # 复制产物
    mkdir -p ios/libs
    cp $BUILD_DIR/whisper.cpp/build_arm64/libwhisper.dylib ios/libs/libwhisper.dylib

    echo "✅ whisper.cpp编译完成"
}

# 主流程
main() {
    echo "⏱️  开始时间: $(date)"

    compile_llama
    compile_whisper

    echo "✅ 所有iOS原生库编译完成！"
    echo "📁 产物位置: ios/libs/"
    ls -lh ios/libs/

    echo "⏱️  结束时间: $(date)"
}

main "$@"
