#!/bin/bash

# Android原生库编译脚本
# 用途：编译libllama.so和libwhisper.so

set -e

echo "🚀 开始编译Android原生库..."

# 配置变量
LLAMA_CPP_VERSION="b2861"
WHISPER_CPP_VERSION="v1.5.5"
ANDROID_NDK_ROOT="${ANDROID_NDK_HOME:-/usr/local/share/android-ndk}"
ANDROID_PLATFORM="android-29"
ANDROID_ABI="arm64-v8a"
BUILD_DIR="build/android"

# 检查NDK
if [ ! -d "$ANDROID_NDK_ROOT" ]; then
    echo "❌ 错误：未找到Android NDK，请设置ANDROID_NDK_HOME环境变量"
    exit 1
fi

echo "📍 Android NDK路径: $ANDROID_NDK_ROOT"

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

    # 设置NDK工具链
    export ANDROID_NDK=$ANDROID_NDK_ROOT
    export TOOLCHAIN=$ANDROID_NDK/build/cmake/android.toolchain.cmake

    mkdir -p build_$ANDROID_ABI
    cd build_$ANDROID_ABI

    cmake .. \
        -DCMAKE_TOOLCHAIN_FILE=$TOOLCHAIN \
        -DANDROID_ABI=$ANDROID_ABI \
        -DANDROID_PLATFORM=$ANDROID_PLATFORM \
        -DANDROID_STL=c++_static \
        -DLLAMA_VULKAN=ON \
        -DBUILD_SHARED_LIBS=ON \
        -DCMAKE_BUILD_TYPE=Release

    make -j$(sysctl -n hw.ncpu)

    cd ../../..

    # 复制产物
    mkdir -p android/app/src/main/jniLibs/$ANDROID_ABI
    cp $BUILD_DIR/llama.cpp/build_$ANDROID_ABI/libllama.so android/app/src/main/jniLibs/$ANDROID_ABI/libllama.so

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

    # 设置NDK工具链
    export ANDROID_NDK=$ANDROID_NDK_ROOT
    export TOOLCHAIN=$ANDROID_NDK/build/cmake/android.toolchain.cmake

    mkdir -p build_$ANDROID_ABI
    cd build_$ANDROID_ABI

    cmake .. \
        -DCMAKE_TOOLCHAIN_FILE=$TOOLCHAIN \
        -DANDROID_ABI=$ANDROID_ABI \
        -DANDROID_PLATFORM=$ANDROID_PLATFORM \
        -DANDROID_STL=c++_static \
        -DWHISPER_NNAPI=ON \
        -DBUILD_SHARED_LIBS=ON \
        -DCMAKE_BUILD_TYPE=Release

    make -j$(sysctl -n hw.ncpu)

    cd ../../..

    # 复制产物
    mkdir -p android/app/src/main/jniLibs/$ANDROID_ABI
    cp $BUILD_DIR/whisper.cpp/build_$ANDROID_ABI/libwhisper.so android/app/src/main/jniLibs/$ANDROID_ABI/libwhisper.so

    echo "✅ whisper.cpp编译完成"
}

# 主流程
main() {
    echo "⏱️  开始时间: $(date)"

    compile_llama
    compile_whisper

    echo "✅ 所有Android原生库编译完成！"
    echo "📁 产物位置: android/app/src/main/jniLibs/$ANDROID_ABI/"
    ls -lh android/app/src/main/jniLibs/$ANDROID_ABI/

    echo "⏱️  结束时间: $(date)"
}

main "$@"
