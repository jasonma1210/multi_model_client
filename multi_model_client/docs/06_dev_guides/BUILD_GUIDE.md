# 编译构建指南

**文档版本：** 1.0
**创建日期：** 2026-04-09
**项目：** Multi-Model Client

---

## 1. 环境要求

### 1.1 通用要求

| 工具 | 最低版本 | 说明 |
|:---|:---:|:---|
| Flutter SDK | 3.x | 跨平台框架 |
| Dart | 3.x | 编程语言 |
| Git | 2.x | 版本控制 |

### 1.2 平台特定要求

| 平台 | 额外要求 |
|:---|:---|
| **macOS** | Xcode 15+, Xcode Command Line Tools |
| **iOS** | Xcode 15+, Apple Developer账号（真机部署） |
| **Android** | Android Studio 2022+, Android SDK 21+ |
| **Windows** | Visual Studio 2022+, Windows SDK 10+ |

---

## 2. 获取代码

```bash
# 克隆仓库
git clone <repository-url>
cd multi_model_client

# 获取依赖
flutter pub get
```

---

## 3. 平台构建

### 3.1 macOS 构建

```bash
# 构建macOS应用
flutter build macos

# 或者使用release模式
flutter build macos --release
```

**产物位置：** `build/macos/Build/Products/Release/`

### 3.2 iOS 构建

```bash
# 构建iOS模拟器版本
flutter build ios --simulator --no-codesign

# 构建iOS真机版本（需要签名）
flutter build ios --release
```

**产物位置：** `build/ios/iphoneos/`

### 3.3 Android 构建

```bash
# 构建Debug APK
flutter build apk --debug

# 构建Release APK
flutter build apk --release

# 构建AAB（Android App Bundle）
flutter build appbundle --release
```

**产物位置：** `build/app/outputs/flutter-apk/`

### 3.4 Windows 构建

```bash
# 构建Windows应用
flutter build windows --release
```

**产物位置：** `build/windows/x64/runner/Release/`

---

## 4. 原生库编译

### 4.1 llama.cpp 编译

本项目需要编译 llama.cpp 原生库以支持本地模型推理。

#### macOS

```bash
# 进入脚本目录
cd scripts

# 编译macOS版本
chmod +x build_llama_macos.sh
./build_llama_macos.sh
```

**输出：** `macos/Frameworks/libllama.dylib`

#### iOS

```bash
# 进入脚本目录
cd scripts

# 编译iOS版本
chmod +x compile_ios.sh
./compile_ios.sh
```

**输出：** `ios/Frameworks/libllama.dylib`

#### Android

需要使用 NDK 进行交叉编译，详见 `docs/NATIVE_COMPILATION_GUIDE.md`

### 4.2 Whisper 编译（可选）

如需使用本地语音识别，需要编译 whisper.cpp：

```bash
# 参考 scripts/ 目录下的编译脚本
```

---

## 5. 常见问题

### 5.1 Flutter 相关

| 问题 | 解决方案 |
|:---|:---|
| Flutter not found | 添加Flutter到PATH环境变量 |
| pod install failed | 运行 `cd ios && pod install --repo-update` |
| build_runner timeout | 增加超时时间或运行 `dart run build_runner build --delete-conflicting-outputs` |

### 5.2 iOS 相关

| 问题 | 解决方案 |
|:---|:---|
| Xcode license not accepted | 运行 `sudo xcodebuild -license` |
| Code signing failed | 检查Apple Developer证书配置 |
| Simulator not found | 运行 `xcrun simctl list devices` |

### 5.3 Android 相关

| 问题 | 解决方案 |
|:---|:---|
| ANDROID_HOME not set | 设置 `ANDROID_HOME` 环境变量 |
| NDK not found | 通过Android Studio安装NDK |
| Build tools not found | 通过SDK Manager安装 |

### 5.4 原生库相关

| 问题 | 解决方案 |
|:---|:---|
| libllama not found | 确保原生库已编译并复制到正确位置 |
| Metal not available | 检查设备是否支持Metal |
| CUDA not available | 安装NVIDIA驱动和CUDA Toolkit |

---

## 6. 性能优化

### 6.1 iOS 性能

- 使用 Metal 加速：确保在支持的设备上运行
- 量化模型：使用 Q4_K_M 或更低的量化级别
- 内存优化：减少上下文窗口大小

### 6.2 Android 性能

- 使用 NNAPI 加速（如果支持）
- 选择合适的量化级别
- 关闭不必要的功能以节省内存

### 6.3 桌面端性能

- CUDA 加速（Windows）：安装 NVIDIA 驱动
- Metal 加速（macOS）：默认启用
- 多线程：调整 `n_threads` 参数

---

## 7. 调试模式

### 7.1 启用调试日志

在 `lib/main.dart` 中设置：

```dart
void main() {
  // 启用调试模式
  Logger.level = Level.debug;
  
  runApp(const MyApp());
}
```

### 7.2 热重载

```bash
# 运行热重载
flutter run

# 指定设备
flutter run -d "iPhone 15 Pro"
flutter run -d emulator-5554
```

---

## 8. 发布检查清单

- [ ] 所有测试通过
- [ ] 代码静态分析无错误
- [ ] 构建产物生成成功
- [ ] 应用图标已设置
- [ ] 版本号已更新
- [ ] CHANGELOG已更新

---

## 9. 相关文档

- [macOS构建指南](MACOS_BUILD_GUIDE.md)
- [iOS编译指南](IOS_COMPILATION_GUIDE.md)
- [Android编译指南](ANDROID_COMPILATION_GUIDE.md)
- [原生库编译指南](NATIVE_COMPILATION_GUIDE.md)