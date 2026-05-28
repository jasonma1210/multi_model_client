#!/bin/bash
# llama.cpp 库文件同步脚本
# 
# 用途：将新下载/编译的 llama.cpp 动态库同步到 macos/Frameworks 目录
# 使用：bash scripts/sync_llama_libs.sh [源目录]
#
# 示例：
#   bash scripts/sync_llama_libs.sh ~/Downloads/llama.cpp/build
#   bash scripts/sync_llama_libs.sh /path/to/your/llama.cpp/build

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TARGET_DIR="$PROJECT_ROOT/macos/Frameworks"

# 核心动态库列表（必须同步）
CORE_LIBS=(
    "libllama.dylib"
    "libllama-common.dylib"
)

# 可选依赖库（如果存在则同步）
OPTIONAL_LIBS=(
    "libggml.dylib"
    "libggml-base.dylib"
    "libggml-metal.dylib"
    "libggml-cpu.dylib"
    "libggml-blas.dylib"
    "libggml-rpc.dylib"
)

# 帮助信息
show_help() {
    echo "用法: $0 [源目录]"
    echo ""
    echo "将源目录中的 llama.cpp 动态库同步到 macos/Frameworks"
    echo ""
    echo "参数:"
    echo "  源目录    llama.cpp 构建目录（包含 .dylib 文件）"
    echo ""
    echo "示例:"
    echo "  $0 ~/Downloads/llama.cpp/build"
    echo "  $0 /usr/local/Cellar/llama.cpp/1.0/lib"
    echo ""
    echo "如果不指定源目录，将使用项目内的 libs/ 目录"
}

# 检查文件是否存在
check_and_copy() {
    local src="$1"
    local dst="$2"
    local filename=$(basename "$src")
    
    if [ -f "$src" ]; then
        # 复制文件
        cp "$src" "$dst"
        
        # 修复 dylib 路径（确保 @rpath 正确）
        if [[ "$dst" == *.dylib ]]; then
            # 设置 dylib 的 install name
            install_name_tool -id "@rpath/$filename" "$dst" 2>/dev/null || true
        fi
        
        echo -e "${GREEN}✓${NC} $filename"
    else
        echo -e "${YELLOW}⚠${NC} $filename (源文件不存在，跳过)"
    fi
}

# 主逻辑
main() {
    local source_dir=""
    
    # 解析参数
    if [ $# -eq 0 ]; then
        # 默认使用项目内的 libs 目录
        source_dir="$PROJECT_ROOT/libs"
        echo -e "${YELLOW}未指定源目录，使用默认: $source_dir${NC}"
    elif [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
        show_help
        exit 0
    else
        source_dir="$1"
    fi
    
    # 验证源目录
    if [ ! -d "$source_dir" ]; then
        echo -e "${RED}错误: 源目录不存在: $source_dir${NC}"
        exit 1
    fi
    
    echo ""
    echo "========================================"
    echo "  llama.cpp 库文件同步"
    echo "========================================"
    echo "源目录: $source_dir"
    echo "目标目录: $TARGET_DIR"
    echo ""
    
    # 确保目标目录存在
    mkdir -p "$TARGET_DIR"
    
    echo "正在同步核心库..."
    for lib in "${CORE_LIBS[@]}"; do
        src_path="$source_dir/$lib"
        check_and_copy "$src_path" "$TARGET_DIR/$lib"
    done
    
    echo ""
    echo "正在同步可选依赖库..."
    for lib in "${OPTIONAL_LIBS[@]}"; do
        src_path="$source_dir/$lib"
        check_and_copy "$src_path" "$TARGET_DIR/$lib"
    done
    
    echo ""
    echo "========================================"
    echo -e "${GREEN}同步完成！${NC}"
    echo "========================================"
    echo ""
    echo "已同步的库文件:"
    ls -lh "$TARGET_DIR"/*.dylib 2>/dev/null | awk '{print "  " $9 " (" $5 ")"}'
    echo ""
    echo "下一步："
    echo "  1. 在 Xcode 中重新构建项目"
    echo "  2. 或者运行: flutter build macos"
}

main "$@"