# llama.cpp 编译与集成指南

本文档详细介绍如何为Flutter应用编译带硬件加速的llama.cpp动态库。

---

## 一、前置依赖

### macOS
- Xcode 14.0+
- CMake 3.20+
- Homebrew

```bash
# 安装依赖
brew install cmake git
```

### iOS
- Xcode 14.0+
- CMake 3.20+
- iOS SDK 14.0+

### Windows
- Visual Studio 2022
- CMake 3.20+
- CUDA Toolkit 11.8+ (可选，用于CUDA加速)

```powershell
# 安装CMake
winget install Kitware.CMake
```

---

## 二、获取llama.cpp源码

```bash
git clone https://github.com/ggerganov/llama.cpp
cd llama.cpp
```

---

## 三、编译动态库

### 3.1 macOS（带Metal加速）

```bash
# 编译通用二进制（支持Intel和Apple Silicon）
cmake -B build_metal \
  -DBUILD_SHARED_LIBS=ON \
  -DGGML_METAL=ON \
  -DGGML_METAL_USE_BF16=ON \
  -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLAMA_BUILD_EXAMPLES=OFF

cmake --build build_metal --config Release -j$(sysctl -n hw.ncpu)
```

**编译产物：**
- `build_metal/src/libllama.dylib` - 主推理库
- `build_metal/ggml/src/libggml.dylib` - 张量计算库
- `build_metal/ggml/src/ggml-metal/libggml-metal.dylib` - Metal后端

### 3.2 iOS（带Metal加速）

```bash
# 编译iOS静态库
cmake -B build_ios \
  -DCMAKE_SYSTEM_NAME=iOS \
  -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=14.0 \
  -DBUILD_SHARED_LIBS=OFF \
  -DGGML_METAL=ON \
  -DGGML_METAL_USE_BF16=ON \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLAMA_BUILD_EXAMPLES=OFF

cmake --build build_ios --config Release -j$(sysctl -n hw.ncpu)
```

**编译产物：**
- `build_ios/src/libllama.a`
- `build_ios/ggml/src/libggml.a`

### 3.3 Windows（带CUDA加速）

**前置条件：**
- 安装CUDA Toolkit 11.8或更高版本
- 配置CUDA环境变量

```powershell
# 检查CUDA环境
nvcc --version

# 编译Windows DLL
cmake -B build_cuda `
  -G "Visual Studio 17 2022" `
  -A x64 `
  -DBUILD_SHARED_LIBS=ON `
  -DGGML_CUDA=ON `
  -DGGML_CUDA_FORCE_MMQ=ON `
  -DCMAKE_BUILD_TYPE=Release `
  -DLLAMA_BUILD_EXAMPLES=OFF

cmake --build build_cuda --config Release
```

**编译产物：**
- `build_cuda\src\Release\llama.dll`
- `build_cuda\ggml\src\Release\ggml.dll`
- `build_cuda\ggml\src\ggml-cuda\Release\ggml-cuda.dll`

**需要的CUDA运行时DLL：**
- `cudart64_12.dll` (或 `cudart64_11.dll`)
- `cublas64_12.dll`
- `cublasLt64_12.dll`

---

## 四、集成到Flutter项目

### 4.1 macOS集成

**步骤1：复制动态库**

```bash
mkdir -p multi_model_client/macos/Frameworks
cp build_metal/src/libllama.dylib multi_model_client/macos/Frameworks/
cp build_metal/ggml/src/libggml.dylib multi_model_client/macos/Frameworks/
cp build_metal/ggml/src/ggml-metal/libggml-metal.dylib multi_model_client/macos/Frameworks/
```

**步骤2：配置Xcode项目**

编辑 `macos/Runner.xcodeproj/project.pbxproj`：

```xml
// 在Build Settings中添加
FRAMEWORK_SEARCH_PATHS = (
  "$(inherited)",
  "$(PROJECT_DIR)/Frameworks",
);

// 在Build Phases > Embed Libraries中添加
libllama.dylib
libggml.dylib
libggml-metal.dylib
```

**步骤3：更新CMakeLists.txt**

编辑 `macos/Runner/CMakeLists.txt`：

```cmake
# 添加动态库路径
set(CMAKE_INSTALL_RPATH "@executable_path/../Frameworks")

# 安装动态库
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/Frameworks/
        DESTINATION "${INSTALL_BUNDLE_DATA_DIR}/Frameworks"
        FILES_MATCHING PATTERN "*.dylib")
```

### 4.2 iOS集成

**步骤1：创建Framework**

```bash
# 创建XCFramework
xcodebuild -create-xcframework \
  -library build_ios/src/libllama.a \
  -library build_ios/ggml/src/libggml.a \
  -output llama.xcframework
```

**步骤2：添加到Xcode项目**

1. 将 `llama.xcframework` 拖入 `ios/Runner.xcodeproj`
2. 在 "Frameworks, Libraries, and Embedded Content" 中添加
3. 设置为 "Do Not Embed"（因为是静态库）

**步骤3：链接系统框架**

在 `ios/Runner.xcodeproj` 的 "Link Binary With Libraries" 中添加：
- `Metal.framework`
- `MetalKit.framework`
- `Accelerate.framework`

### 4.3 Windows集成

**步骤1：复制DLL文件**

```powershell
mkdir multi_model_client\windows\runner\bin

# 复制编译产物
copy build_cuda\src\Release\llama.dll windows\runner\bin\
copy build_cuda\ggml\src\Release\ggml.dll windows\runner\bin\
copy build_cuda\ggml\src\ggml-cuda\Release\ggml-cuda.dll windows\runner\bin\

# 复制CUDA运行时（从CUDA安装目录）
copy "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.0\bin\cudart64_12.dll" windows\runner\bin\
copy "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.0\bin\cublas64_12.dll" windows\runner\bin\
copy "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.0\bin\cublasLt64_12.dll" windows\runner\bin\
```

**步骤2：配置CMakeLists.txt**

编辑 `windows/runner/CMakeLists.txt`：

```cmake
# 安装DLL到输出目录
install(FILES
  "${CMAKE_CURRENT_SOURCE_DIR}/bin/llama.dll"
  "${CMAKE_CURRENT_SOURCE_DIR}/bin/ggml.dll"
  "${CMAKE_CURRENT_SOURCE_DIR}/bin/ggml-cuda.dll"
  "${CMAKE_CURRENT_SOURCE_DIR}/bin/cudart64_12.dll"
  "${CMAKE_CURRENT_SOURCE_DIR}/bin/cublas64_12.dll"
  "${CMAKE_CURRENT_SOURCE_DIR}/bin/cublasLt64_12.dll"
  DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
  COMPONENT Runtime
)
```

---

## 五、验证集成

### 5.1 macOS验证

```dart
// lib/core/engines/llama_engine.dart
Future<void> initialize() async {
  final libPath = '@executable_path/../Frameworks/libllama.dylib';
  _bindings = LlamaCppBindings(DynamicLibrary.open(libPath));
  print('llama.cpp loaded successfully on macOS');
}
```

### 5.2 iOS验证

```dart
Future<void> initialize() async {
  final libPath = '@executable_path/Frameworks/libllama.dylib';
  _bindings = LlamaCppBindings(DynamicLibrary.open(libPath));
  print('llama.cpp loaded successfully on iOS');
}
```

### 5.3 Windows验证

```dart
Future<void> initialize() async {
  final libPath = '${Directory.current.path}\\llama.dll';
  _bindings = LlamaCppBindings(DynamicLibrary.open(libPath));
  print('llama.cpp loaded successfully on Windows');
}
```

---

## 六、常见问题

### Q1: macOS找不到动态库

**解决方案：** 检查 `@executable_path` 和 `@rpath` 设置

```bash
# 查看动态库依赖
otool -L libllama.dylib

# 修改install_name
install_name_tool -change @rpath/libggml.dylib @executable_path/../Frameworks/libggml.dylib libllama.dylib
```

### Q2: Windows缺少CUDA DLL

**解决方案：**
1. 确保安装了CUDA Toolkit
2. 将CUDA DLL复制到应用目录
3. 或在应用启动时检查CUDA可用性，自动降级到CPU模式

### Q3: iOS编译报错 "Undefined symbols"

**解决方案：**
1. 确保链接了Metal和Accelerate框架
2. 检查静态库架构是否匹配（arm64 vs x86_64）
3. 清理Xcode构建缓存

### Q4: Metal加速无效

**解决方案：**
1. 检查设备是否支持Metal
2. 确认Metal framework已正确链接
3. 查看控制台日志，确认Metal设备创建成功

---

## 七、性能优化建议

### 7.1 Metal优化

- 启用BF16量化：`-DGGML_METAL_USE_BF16=ON`
- 全量offload到GPU（统一内存架构）
- 调整批处理大小以适应GPU带宽

### 7.2 CUDA优化

- 根据显存自动计算GPU层数
- 启用MMQ优化：`-DGGML_CUDA_FORCE_MMQ=ON`
- 多GPU场景使用负载均衡策略

### 7.3 通用优化

- 使用合适的量化级别（Q4_K_M推荐）
- 调整线程数匹配CPU核心数
- 预分配上下文窗口内存

---

## 八、编译选项说明

### 关键编译选项

| 选项 | 说明 | 默认值 |
|------|------|--------|
| `BUILD_SHARED_LIBS` | 编译动态库 | ON |
| `GGML_METAL` | 启用Metal加速 | OFF |
| `GGML_CUDA` | 启用CUDA加速 | OFF |
| `GGML_METAL_USE_BF16` | Metal使用BF16 | OFF |
| `GGML_CUDA_FORCE_MMQ` | CUDA强制MMQ | OFF |
| `LLAMA_BUILD_EXAMPLES` | 编译示例程序 | ON |
| `CMAKE_BUILD_TYPE` | 构建类型 | Release |

### 性能相关选项

- `GGML_METAL_NDEBUG`: 禁用Metal调试，提升性能
- `GGML_CUDA_DMMV_F16`: CUDA半精度优化
- `LLAMA_FAST`: 启用所有性能优化

---

## 九、持续集成

### GitHub Actions示例

```yaml
name: Build llama.cpp

on: [push, pull_request]

jobs:
  build-macos:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build
        run: |
          cmake -B build -DBUILD_SHARED_LIBS=ON -DGGML_METAL=ON
          cmake --build build --config Release
      - uses: actions/upload-artifact@v3
        with:
          name: llama-macos
          path: build/src/libllama.dylib

  build-windows:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build
        run: |
          cmake -B build -G "Visual Studio 17 2022" -DGGML_CUDA=ON
          cmake --build build --config Release
      - uses: actions/upload-artifact@v3
        with:
          name: llama-windows
          path: build/src/Release/llama.dll
```

---

## 十、更新与维护

### 定期更新

```bash
# 更新llama.cpp源码
cd llama.cpp
git pull origin master

# 重新编译
cmake --build build_metal --config Release --clean-first
```

### 版本管理

建议在项目中记录llama.cpp的commit hash：

```bash
git rev-parse HEAD > LLAMA_VERSION.txt
```

---

## 参考资源

- [llama.cpp官方仓库](https://github.com/ggerganov/llama.cpp)
- [Metal Performance Shaders指南](https://developer.apple.com/metal/)
- [CUDA C++编程指南](https://docs.nvidia.com/cuda/cuda-c-programming-guide/)
- [Flutter FFI文档](https://dart.dev/guides/libraries/c-interop)
