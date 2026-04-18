/// llama.cpp 库加载器 - 简化版
///
/// 工业级标准实现：
/// - App 打包时，各平台编译好的 llama.cpp 动态库已嵌入安装包
/// - 运行时只需找到库路径并设置 Llama.libraryPath
/// - .gguf 模型文件通过模型下载功能动态获取
///
/// 查找优先级：
/// 1. app bundle Frameworks 目录（macOS 生产环境）
/// 2. 项目 libs 目录（开发环境）
/// 3. 系统路径（homebrew / usr/local）
///
/// @author JianMa
/// @version 3.0.0
library;

import 'dart:io';

import 'package:flutter/foundation.dart';

/// llama.cpp 库加载器单例
///
/// 职责单一：找到动态库 → 设置 Llama.libraryPath → 完成
/// 不再负责沙盒复制、版本更新等，由上层 LlamaParent/Isolate 处理推理
class LlamaLibraryLoader {
  static final LlamaLibraryLoader _instance = LlamaLibraryLoader._();
  static LlamaLibraryLoader get instance => _instance;

  LlamaLibraryLoader._();

  /// 缓存找到的库路径
  String? _cachedLibraryPath;

  /// 是否已初始化
  bool _initialized = false;

  /// 获取库文件名（按平台）
  static String get libraryName {
    if (Platform.isMacOS || Platform.isIOS) {
      return 'libllama.dylib';
    } else if (Platform.isWindows) {
      return 'libllama.dll';
    } else {
      return 'libllama.so';
    }
  }

  /// 初始化加载器
  ///
  /// 仅查找库路径并缓存，不复制文件
  Future<void> init() async {
    if (_initialized) return;

    debugPrint('[LlamaLibraryLoader] 初始化...');

    try {
      final libraryPath = await _findLibraryPath();
      if (libraryPath != null) {
        _cachedLibraryPath = libraryPath;
        debugPrint('[LlamaLibraryLoader] ✅ 找到库: $libraryPath');
      } else {
        debugPrint('[LlamaLibraryLoader] ❌ 未找到 llama.cpp 库文件');
        debugPrint('[LlamaLibraryLoader] 提示：请确保 macos/Frameworks/ 目录包含 libraryName');
      }
    } catch (e) {
      debugPrint('[LlamaLibraryLoader] 初始化失败: $e');
    }

    _initialized = true;
  }

  /// 查找库文件路径
  ///
  /// 按优先级搜索，找到即返回
  Future<String?> _findLibraryPath() async {
    debugPrint('[LlamaLibraryLoader] 搜索库文件: $libraryName');

    // 1. app bundle Frameworks 目录（macOS 沙盒内可访问）
    final bundlePath = _getBundleFrameworksPath();
    if (bundlePath != null) {
      final path = '$bundlePath/$libraryName';
      debugPrint('[LlamaLibraryLoader] 检查 bundle: $path');
      if (File(path).existsSync()) {
        debugPrint('[LlamaLibraryLoader] ✅ 在 bundle 中找到');
        return path;
      }
    }

    // 2. 项目 libs 目录（开发环境）
    final projectLibsPath = _getProjectLibsPath();
    final projectPath = '$projectLibsPath/$libraryName';
    debugPrint('[LlamaLibraryLoader] 检查 libs: $projectPath');
    if (File(projectPath).existsSync()) {
      debugPrint('[LlamaLibraryLoader] ✅ 在 libs 中找到');
      return projectPath;
    }

    // 3. macOS Frameworks 源目录（macos/Frameworks/，构建前）
    final macosFrameworksPath = _getMacOSFrameworksPath();
    if (macosFrameworksPath != null) {
      final path = '$macosFrameworksPath/$libraryName';
      debugPrint('[LlamaLibraryLoader] 检查 macos/Frameworks: $path');
      if (File(path).existsSync()) {
        debugPrint('[LlamaLibraryLoader] ✅ 在 macos/Frameworks 中找到');
        return path;
      }
    }

    // 4. 系统常见路径
    final homeDir = Platform.environment['HOME'] ?? '';
    final commonPaths = [
      '$homeDir/llama.cpp/build/src/$libraryName',
      '/usr/local/lib/$libraryName',
      '/opt/homebrew/lib/$libraryName',
    ];

    for (final path in commonPaths) {
      debugPrint('[LlamaLibraryLoader] 检查系统路径: $path');
      if (File(path).existsSync()) {
        debugPrint('[LlamaLibraryLoader] ✅ 在系统路径中找到');
        return path;
      }
    }

    debugPrint('[LlamaLibraryLoader] ❌ 所有路径都未找到库文件');
    return null;
  }

  /// 获取 app bundle 中 Frameworks 目录的路径
  String? _getBundleFrameworksPath() {
    try {
      final executablePath = Platform.resolvedExecutable;
      // macOS: /path/to/app.app/Contents/MacOS/executable
      // Frameworks: /path/to/app.app/Contents/Frameworks/
      final executableDir = File(executablePath).parent.path;
      final frameworksPath = '$executableDir/../Frameworks';

      final dir = Directory(frameworksPath);
      if (dir.existsSync()) {
        return frameworksPath;
      }
    } catch (e) {
      debugPrint('[LlamaLibraryLoader] 获取 bundle Frameworks 路径失败: $e');
    }
    return null;
  }

  /// 获取项目 libs 目录路径（开发时使用）
  String _getProjectLibsPath() {
    final executablePath = Platform.resolvedExecutable;
    if (executablePath.contains('.app/')) {
      // Debug 构建: /path/to/build/macos/Build/Products/Debug/app.app/Contents/MacOS/app
      final executableDir = File(executablePath).parent.path;
      return '$executableDir/../../../../libs';
    }
    return '/Users/jianma/Desktop/LLM STUDIO/multi_model_client/libs';
  }

  /// 获取 macos/Frameworks 目录路径
  String? _getMacOSFrameworksPath() {
    try {
      final executablePath = Platform.resolvedExecutable;
      if (executablePath.contains('.app/')) {
        final executableDir = File(executablePath).parent.path;
        // macos/Frameworks/ 相对于构建产物目录
        return '$executableDir/../../../../macos/Frameworks';
      }
      // 非 app bundle（如测试），直接用项目路径
      return '/Users/jianma/Desktop/LLM STUDIO/multi_model_client/macos/Frameworks';
    } catch (e) {
      return null;
    }
  }

  /// 获取库文件路径
  ///
  /// 如果尚未初始化，会自动初始化
  Future<String?> getLibraryPath() async {
    if (_cachedLibraryPath != null && File(_cachedLibraryPath!).existsSync()) {
      return _cachedLibraryPath;
    }

    if (!_initialized) {
      await init();
    }

    return _cachedLibraryPath;
  }

  /// 检查库是否可用
  Future<bool> isLibraryAvailable() async {
    final path = await getLibraryPath();
    return path != null && File(path).existsSync();
  }

  /// 清除缓存（用于重新检测）
  void clearCache() {
    _cachedLibraryPath = null;
    _initialized = false;
  }

  /// 重新加载库文件（热更新后调用）
  ///
  /// 清除缓存并重新查找库路径
  Future<String?> reload() async {
    debugPrint('[LlamaLibraryLoader] 重新加载库文件...');
    clearCache();
    return await getLibraryPath();
  }
}
