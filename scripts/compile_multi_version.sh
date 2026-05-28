#!/bin/bash

# ════════════════════════════════════════════════════════════════════════
#  llama.cpp 多维度动态适配编译脚本
#
#  编译多个版本以支持不同的 CPU 特性优化：
#  1. libllama_generic.so   - 通用版本（所有 ARM64 设备可用）
#  2. libllama_dotprod.so   - DotProd 优化（ARMv8.2+，提升 2-3 倍）
#  3. libllama_i8mm.so      - i8mm 优化（ARMv8.2+，INT8 量化加速）
#  4. libllama_vulkan.so    - Vulkan GPU 加速（通用 GPU）
#  5. libllama_qnn.so       - 高通 QNN NPU（需要额外的高通 SDK）
#
#  使用方法：
#    ./compile_multi_version.sh [options]
#    Options:
#      --all         编译所有版本（默认）
#      --generic    只编译通用版本
#      --dotprod    只编译 DotProd 版本
#      --i8mm       只编译 i8mm 版本
#      --vulkan     只编译 Vulkan 版本
#      --qnn        只编译 QNN 版本（需要高通 SDK）
#      --clean      清理构建目录
#
# ════════════════════════════════════════════════════════════════════════

set -e

# ════════════════════════════════════════════════════════════════════════
#  配置变量
# ════════════════════════════════════════════════════════════════════════

LLAMA_CPP_VERSION="latest"
ANDROID_NDK_ROOT="${ANDROID_NDK_HOME:-$HOME/Library/Android/sdk/ndk/28.2.13676358}"
ANDROID_PLATFORM="android-28"  # 最低支持 Android 9.0
ANDROID_ABI="arm64-v8a"
BUILD_DIR="$(dirname "$0")/build_llama/multi_version"

# ════════════════════════════════════════════════════════════════════════
#  GitHub 配置（直连访问）
# ════════════════════════════════════════════════════════════════════════
# 注意：如需使用国内镜像，可取消注释以下配置
# GITHUB_MIRROR="https://ghproxy.com"  # 测试不可用，已注释
# GITHUB_MIRROR="https://mirror.ghproxy.com"  # 测试不可用

# 设置 git 配置（直连模式）
setup_git_mirror() {
    # 直连 GitHub，不使用代理
    # 如需使用镜像，取消注释下面两行并修改镜像地址
    # git config --global url."$GITHUB_MIRROR".insteadOf "https://github.com/"
    # git config --global url."$GITHUB_MIRROR".insteadOf "git://github.com/"
    log_info "使用直连模式访问 GitHub"
}

# 输出目录
OUTPUT_DIR="android/app/src/main/jniLibs/${ANDROID_ABI}"

# ════════════════════════════════════════════════════════════════════════
#  颜色输出
# ════════════════════════════════════════════════════════════════════════

# ════════════════════════════════════════════════════════════════════════
#  颜色输出
# ════════════════════════════════════════════════════════════════════════

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# ════════════════════════════════════════════════════════════════════════
#  检查环境
# ════════════════════════════════════════════════════════════════════════

check_environment() {
    log_info "检查编译环境..."

    # 检查 NDK
    if [ ! -d "$ANDROID_NDK_ROOT" ]; then
        log_error "未找到 Android NDK，请设置 ANDROID_NDK_HOME 环境变量"
        log_info "例如: export ANDROID_NDK_HOME=/path/to/android-ndk"
        exit 1
    fi
    log_success "Android NDK: $ANDROID_NDK_ROOT"

    # 检查 CMake
    if ! command -v cmake &> /dev/null; then
        log_error "未找到 CMake，请安装 CMake 3.20+"
        exit 1
    fi
    log_success "CMake: $(cmake --version | head -n1)"

    # 检查 Ninja
    if ! command -v ninja &> /dev/null; then
        log_warn "未找到 Ninja，将使用 Make（较慢）"
        USE_NINJA=false
    else
        USE_NINJA=true
        log_success "Ninja: $(ninja --version)"
    fi

    # 创建输出目录
    mkdir -p "$OUTPUT_DIR"
    log_success "输出目录: $OUTPUT_DIR"
}

# ════════════════════════════════════════════════════════════════════════
#  下载 llama.cpp 源码（使用国内镜像）
# ════════════════════════════════════════════════════════════════════════

download_llama_cpp() {
    # 设置 git 配置
    setup_git_mirror

    if [ ! -d "$BUILD_DIR/llama.cpp" ]; then
        log_info "下载 llama.cpp $LLAMA_CPP_VERSION (直连 GitHub)..."
        # 直接从 GitHub 克隆
        git clone https://github.com/ggerganov/llama.cpp.git "$BUILD_DIR/llama.cpp"
        cd "$BUILD_DIR/llama.cpp"
        git checkout "$LLAMA_CPP_VERSION"
        cd - > /dev/null
        log_success "llama.cpp 下载完成"
    else
        log_info "llama.cpp 已存在，跳过下载"
    fi
}

# ════════════════════════════════════════════════════════════════════════
#  编译通用版本（所有 ARM64 设备可用）
# ════════════════════════════════════════════════════════════════════════

compile_generic() {
    log_info "编译通用版本 libllama_generic.so..."

    local BUILD_TYPE="generic"
    local BUILD_PATH="$BUILD_DIR/build_$BUILD_TYPE"

    cd "$BUILD_DIR/llama.cpp"
    mkdir -p "$BUILD_PATH"
    cd "$BUILD_PATH"

    cmake .. \
        -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK_ROOT/build/cmake/android.toolchain.cmake" \
        -DANDROID_ABI="$ANDROID_ABI" \
        -DANDROID_PLATFORM="$ANDROID_PLATFORM" \
        -DANDROID_STL=c++_static \
        -DGGML_VULKAN=OFF \
        -DGGML_QNN=OFF \
        -DGGML_LLAMAFILE=OFF \
        -DGGML_TIZEN=OFF \
        -DCMAKE_C_FLAGS="-march=armv8-a" \
        -DCMAKE_CXX_FLAGS="-march=armv8-a" \
        -DBUILD_SHARED_LIBS=ON \
        -DCMAKE_BUILD_TYPE=Release

    if [ "$USE_NINJA" = true ]; then
        ninja -j$(sysctl -n hw.ncpu)
    else
        make -j$(sysctl -n hw.ncpu)
    fi

    cd - > /dev/null

    cp "$BUILD_PATH/libllama.so" "$OUTPUT_DIR/libllama_generic.so"
    log_success "通用版本编译完成: libllama_generic.so"
}

# ════════════════════════════════════════════════════════════════════════
#  编译 DotProd 版本（ARMv8.2+，提升 2-3 倍）
# ════════════════════════════════════════════════════════════════════════

compile_dotprod() {
    log_info "编译 DotProd 优化版本 libllama_dotprod.so..."

    local BUILD_TYPE="dotprod"
    local BUILD_PATH="$BUILD_DIR/build_$BUILD_TYPE"

    cd "$BUILD_DIR/llama.cpp"
    mkdir -p "$BUILD_PATH"
    cd "$BUILD_PATH"

    cmake .. \
        -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK_ROOT/build/cmake/android.toolchain.cmake" \
        -DANDROID_ABI="$ANDROID_ABI" \
        -DANDROID_PLATFORM="$ANDROID_PLATFORM" \
        -DANDROID_STL=c++_static \
        -DGGML_VULKAN=OFF \
        -DGGML_QNN=OFF \
        -DGGML_LLAMAFILE=OFF \
        -DGGML_TIZEN=OFF \
        -DCMAKE_C_FLAGS="-march=armv8.2-a+dotprod" \
        -DCMAKE_CXX_FLAGS="-march=armv8.2-a+dotprod" \
        -DBUILD_SHARED_LIBS=ON \
        -DCMAKE_BUILD_TYPE=Release

    if [ "$USE_NINJA" = true ]; then
        ninja -j$(sysctl -n hw.ncpu)
    else
        make -j$(sysctl -n hw.ncpu)
    fi

    cd - > /dev/null

    cp "$BUILD_PATH/libllama.so" "$OUTPUT_DIR/libllama_dotprod.so"
    log_success "DotProd 版本编译完成: libllama_dotprod.so"
}

# ════════════════════════════════════════════════════════════════════════
#  编译 i8mm 版本（ARMv8.2+，INT8 量化加速）
# ════════════════════════════════════════════════════════════════════════

compile_i8mm() {
    log_info "编译 i8mm 优化版本 libllama_i8mm.so..."

    local BUILD_TYPE="i8mm"
    local BUILD_PATH="$BUILD_DIR/build_$BUILD_TYPE"

    cd "$BUILD_DIR/llama.cpp"
    mkdir -p "$BUILD_PATH"
    cd "$BUILD_PATH"

    cmake .. \
        -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK_ROOT/build/cmake/android.toolchain.cmake" \
        -DANDROID_ABI="$ANDROID_ABI" \
        -DANDROID_PLATFORM="$ANDROID_PLATFORM" \
        -DANDROID_STL=c++_static \
        -DGGML_VULKAN=OFF \
        -DGGML_QNN=OFF \
        -DGGML_LLAMAFILE=OFF \
        -DGGML_TIZEN=OFF \
        -DCMAKE_C_FLAGS="-march=armv8.2-a+dotprod+i8mm" \
        -DCMAKE_CXX_FLAGS="-march=armv8.2-a+dotprod+i8mm" \
        -DBUILD_SHARED_LIBS=ON \
        -DCMAKE_BUILD_TYPE=Release

    if [ "$USE_NINJA" = true ]; then
        ninja -j$(sysctl -n hw.ncpu)
    else
        make -j$(sysctl -n hw.ncpu)
    fi

    cd - > /dev/null

    cp "$BUILD_PATH/libllama.so" "$OUTPUT_DIR/libllama_i8mm.so"
    log_success "i8mm 版本编译完成: libllama_i8mm.so"
}

# ════════════════════════════════════════════════════════════════════════
#  编译 Vulkan 版本（通用 GPU 加速）
# ════════════════════════════════════════════════════════════════════════

compile_vulkan() {
    log_info "编译 Vulkan GPU 加速版本 libllama_vulkan.so..."

    local BUILD_TYPE="vulkan"
    local BUILD_PATH="$BUILD_DIR/build_$BUILD_TYPE"

    cd "$BUILD_DIR/llama.cpp"
    mkdir -p "$BUILD_PATH"
    cd "$BUILD_PATH"

    cmake .. \
        -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK_ROOT/build/cmake/android.toolchain.cmake" \
        -DANDROID_ABI="$ANDROID_ABI" \
        -DANDROID_PLATFORM="$ANDROID_PLATFORM" \
        -DANDROID_STL=c++_static \
        -DGGML_VULKAN=ON \
        -DGGML_QNN=OFF \
        -DGGML_LLAMAFILE=OFF \
        -DGGML_TIZEN=OFF \
        -DCMAKE_C_FLAGS="-march=armv8.2-a+dotprod+i8mm" \
        -DCMAKE_CXX_FLAGS="-march=armv8.2-a+dotprod+i8mm" \
        -DBUILD_SHARED_LIBS=ON \
        -DCMAKE_BUILD_TYPE=Release

    if [ "$USE_NINJA" = true ]; then
        ninja -j$(sysctl -n hw.ncpu)
    else
        make -j$(sysctl -n hw.ncpu)
    fi

    cd - > /dev/null

    cp "$BUILD_PATH/libllama.so" "$OUTPUT_DIR/libllama_vulkan.so"
    log_success "Vulkan 版本编译完成: libllama_vulkan.so"
}

# ════════════════════════════════════════════════════════════════════════
#  编译 QNN 版本（高通 NPU，需要高通 SDK）
# ════════════════════════════════════════════════════════════════════════

compile_qnn() {
    log_info "编译高通 QNN NPU 版本 libllama_qnn.so..."

    # 检查高通 SDK
    if [ -z "$QNN_SDK_ROOT" ]; then
        log_warn "未设置 QNN_SDK_ROOT 环境变量，跳过 QNN 编译"
        log_info "如需编译 QNN 版本，请："
        log_info "  1. 下载高通 AI Stack SDK"
        log_info "  2. 设置环境变量: export QNN_SDK_ROOT=/path/to/qnn-sdk"
        log_info "  3. 重新运行此脚本"
        return 1
    fi

    local BUILD_TYPE="qnn"
    local BUILD_PATH="$BUILD_DIR/build_$BUILD_TYPE"

    cd "$BUILD_DIR/llama.cpp"
    mkdir -p "$BUILD_PATH"
    cd "$BUILD_PATH"

    cmake .. \
        -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK_ROOT/build/cmake/android.toolchain.cmake" \
        -DANDROID_ABI="$ANDROID_ABI" \
        -DANDROID_PLATFORM="$ANDROID_PLATFORM" \
        -DANDROID_STL=c++_static \
        -DGGML_VULKAN=OFF \
        -DGGML_QNN=ON \
        -DQNN_SDK_ROOT="$QNN_SDK_ROOT" \
        -DGGML_LLAMAFILE=OFF \
        -DGGML_TIZEN=OFF \
        -DCMAKE_C_FLAGS="-march=armv8.2-a+dotprod+i8mm" \
        -DCMAKE_CXX_FLAGS="-march=armv8.2-a+dotprod+i8mm" \
        -DBUILD_SHARED_LIBS=ON \
        -DCMAKE_BUILD_TYPE=Release

    if [ "$USE_NINJA" = true ]; then
        ninja -j$(sysctl -n hw.ncpu)
    else
        make -j$(sysctl -n hw.ncpu)
    fi

    cd - > /dev/null

    cp "$BUILD_PATH/libllama.so" "$OUTPUT_DIR/libllama_qnn.so"
    log_success "QNN 版本编译完成: libllama_qnn.so"
}

# ════════════════════════════════════════════════════════════════════════
#  清理构建目录
# ════════════════════════════════════════════════════════════════════════

clean_build() {
    log_info "清理构建目录..."
    rm -rf "$BUILD_DIR"
    log_success "构建目录已清理"
}

# ════════════════════════════════════════════════════════════════════════
#  显示帮助
# ════════════════════════════════════════════════════════════════════════

show_help() {
    echo "llama.cpp 多维度动态适配编译脚本"
    echo ""
    echo "用法: $0 [options]"
    echo ""
    echo "选项:"
    echo "  --all       编译所有版本（默认）"
    echo "  --generic   只编译通用版本"
    echo "  --dotprod   只编译 DotProd 版本"
    echo "  --i8mm      只编译 i8mm 版本"
    echo "  --vulkan    只编译 Vulkan 版本"
    echo "  --qnn       只编译 QNN 版本（需要高通 SDK）"
    echo "  --clean     清理构建目录"
    echo "  --help      显示帮助"
    echo ""
    echo "环境变量:"
    echo "  ANDROID_NDK_HOME  Android NDK 路径"
    echo "  QNN_SDK_ROOT      高通 QNN SDK 路径（仅 QNN 版本需要）"
}

# ════════════════════════════════════════════════════════════════════════
#  主流程
# ════════════════════════════════════════════════════════════════════════

main() {
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║  llama.cpp 多维度动态适配编译脚本                              ║"
    echo "║  版本: $LLAMA_CPP_VERSION                                           ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""

    # 解析参数
    local COMPILE_ALL=true
    local COMPILE_GENERIC=false
    local COMPILE_DOTPROD=false
    local COMPILE_I8MM=false
    local COMPILE_VULKAN=false
    local COMPILE_QNN=false
    local CLEAN=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            --all)
                COMPILE_ALL=true
                shift
                ;;
            --generic)
                COMPILE_ALL=false
                COMPILE_GENERIC=true
                shift
                ;;
            --dotprod)
                COMPILE_ALL=false
                COMPILE_DOTPROD=true
                shift
                ;;
            --i8mm)
                COMPILE_ALL=false
                COMPILE_I8MM=true
                shift
                ;;
            --vulkan)
                COMPILE_ALL=false
                COMPILE_VULKAN=true
                shift
                ;;
            --qnn)
                COMPILE_ALL=false
                COMPILE_QNN=true
                shift
                ;;
            --clean)
                CLEAN=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                log_error "未知参数: $1"
                show_help
                exit 1
                ;;
        esac
    done

    # 清理模式
    if [ "$CLEAN" = true ]; then
        clean_build
        exit 0
    fi

    # 检查环境
    check_environment

    # 下载源码
    download_llama_cpp

    echo ""
    echo "⏱️  开始编译: $(date)"
    echo ""

    # 编译选中的版本
    if [ "$COMPILE_ALL" = true ]; then
        compile_generic
        compile_dotprod
        compile_i8mm
        compile_vulkan
        compile_qnn || true  # QNN 可能失败，继续其他版本
    else
        [ "$COMPILE_GENERIC" = true ] && compile_generic
        [ "$COMPILE_DOTPROD" = true ] && compile_dotprod
        [ "$COMPILE_I8MM" = true ] && compile_i8mm
        [ "$COMPILE_VULKAN" = true ] && compile_vulkan
        [ "$COMPILE_QNN" = true ] && compile_qnn
    fi

    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║  编译完成！                                                    ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "📁 输出目录: $OUTPUT_DIR"
    echo ""
    echo "📦 编译产物:"
    ls -lh "$OUTPUT_DIR"/*.so 2>/dev/null || echo "  (无 .so 文件)"
    echo ""
    echo "⏱️  结束时间: $(date)"
}

main "$@"