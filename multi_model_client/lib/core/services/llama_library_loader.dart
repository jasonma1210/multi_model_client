import 'dart:io';
import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'hardware_feature_detector.dart';

/// llama.cpp 库版本（对应不同的 CPU 特性优化）
enum LlamaLibraryVersion {
  /// 高通 QNN NPU 版本（最快最省电）
  /// 需要系统安装 QNN 驱动，用户应用无法强制安装
  qnn('libllama_qnn.so', AccelerationPriority.npuQnn),

  /// Vulkan GPU 加速版本（通用性强）
  vulkan('libllama_vulkan.so', AccelerationPriority.vulkan),

  /// DotProd 优化版本（ARMv8.2+，提升 2-3 倍）
  dotprod('libllama_dotprod.so', AccelerationPriority.dotprod),

  /// i8mm 优化版本（ARMv8.2+，INT8 量化加速）
  i8mm('libllama_i8mm.so', AccelerationPriority.dotprod),

  /// SME 优化版本（ARMv9+，但 Android GKI 内核可能有 bug）
  /// ⚠️ 已禁用：Realme GT7 Pro (骁龙 8 Elite) + Android 16 会 SIGILL 崩溃
  // sme('libllama_sme.so', AccelerationPriority.dotprod),

  /// 通用版本（兜底，所有设备可用）
  generic('libllama.so', AccelerationPriority.generic);

  final String fileName;
  final AccelerationPriority priority;

  const LlamaLibraryVersion(this.fileName, this.priority);
}

/// 动态库加载结果
class LibraryLoadResult {
  final bool success;
  final DynamicLibrary? library;
  final LlamaLibraryVersion version;
  final String? error;
  final String? note;

  const LibraryLoadResult({
    required this.success,
    this.library,
    required this.version,
    this.error,
    this.note,
  });

  @override
  String toString() {
    return 'LibraryLoadResult(success: $success, version: ${version.fileName}, error: $error)';
  }
}

/// llama.cpp 动态库加载器
///
/// 多维度动态适配核心：
/// 1. 检测 CPU 特性（DotProd, i8mm, SME）
/// 2. 检测芯片厂商（高通、联发科、华为等）
/// 3. 检测 NPU 可用性（QNN、NeuroPilot、HiAI）
/// 4. 动态选择最优的库版本加载
class LlamaLibraryLoader {
  static LlamaLibraryLoader? _instance;
  static LlamaLibraryLoader get instance => _instance ??= LlamaLibraryLoader._();

  LlamaLibraryLoader._();

  final _featureDetector = CpuFeatureDetector.instance;

  // 缓存已加载的库
  DynamicLibrary? _loadedLibrary;
  LlamaLibraryVersion? _loadedVersion;

  /// ★★★ 核心：动态加载最优的 llama.cpp 库 ★★★
  ///
  /// 加载策略（优先级从高到低）：
  /// 1. 高通 QNN NPU（最快最省电）
  /// 2. Vulkan GPU 加速（通用性强）
  /// 3. DotProd/i8mm CPU 优化（提升 2-3 倍）
  /// 4. 通用版本（兜底）
  Future<LibraryLoadResult> loadOptimalLibrary() async {
    // 如果已经加载过，直接返回缓存
    if (_loadedLibrary != null && _loadedVersion != null) {
      debugPrint('[LlamaLibraryLoader] 使用已加载的库: ${_loadedVersion!.fileName}');
      return LibraryLoadResult(
        success: true,
        library: _loadedLibrary,
        version: _loadedVersion!,
        note: '使用缓存',
      );
    }

    // 获取硬件特性
    final features = await _featureDetector.getCpuFeatures();
    final npuResult = await _featureDetector.checkNpuAvailability();
    final vendorInfo = await _featureDetector.getChipVendor();

    debugPrint('[LlamaLibraryLoader] 硬件检测结果:');
    debugPrint('[LlamaLibraryLoader]   - CPU 特性: ${features.recommendedLibrary}');
    debugPrint('[LlamaLibraryLoader]   - 芯片厂商: ${vendorInfo.vendor}');
    debugPrint('[LlamaLibraryLoader]   - NPU 可用: ${npuResult.available} (${npuResult.runtime})');

    // 尝试加载优先级列表
    final priorityList = await _featureDetector.getAccelerationPriority();

    for (final priority in priorityList) {
      final version = _getVersionForPriority(priority, features, npuResult);
      if (version == null) continue;

      final result = await _tryLoadLibrary(version);
      if (result.success) {
        _loadedLibrary = result.library;
        _loadedVersion = version;
        debugPrint('[LlamaLibraryLoader] ✅ 成功加载: ${version.fileName}');
        return result;
      } else {
        debugPrint('[LlamaLibraryLoader] ❌ 加载失败: ${version.fileName}, 尝试下一个...');
      }
    }

    // 所有版本都失败，返回错误
    return const LibraryLoadResult(
      success: false,
      version: LlamaLibraryVersion.generic,
      error: '所有 llama.cpp 库版本加载失败',
    );
  }

  /// 根据优先级获取对应的库版本
  LlamaLibraryVersion? _getVersionForPriority(
    AccelerationPriority priority,
    CpuFeatureResult features,
    NpuAvailabilityResult npuResult,
  ) {
    switch (priority) {
      case AccelerationPriority.npuQnn:
        // 高通 QNN NPU
        if (npuResult.available && npuResult.vendor == ChipVendor.qualcomm) {
          return LlamaLibraryVersion.qnn;
        }
        return null;

      case AccelerationPriority.vulkan:
        // Vulkan 版本（通用）
        return LlamaLibraryVersion.vulkan;

      case AccelerationPriority.dotprod:
        // CPU 优化版本
        if (features.supportsI8mm) {
          return LlamaLibraryVersion.i8mm;
        }
        if (features.supportsDotProd) {
          return LlamaLibraryVersion.dotprod;
        }
        return null;

      case AccelerationPriority.generic:
        return LlamaLibraryVersion.generic;
    }
  }

  /// 尝试加载指定版本的库
  Future<LibraryLoadResult> _tryLoadLibrary(LlamaLibraryVersion version) async {
    try {
      // 1. 首先尝试从应用 bundle 加载（静态打包）
      final bundlePath = await _getBundleLibraryPath(version);
      if (bundlePath != null && await File(bundlePath).exists()) {
        debugPrint('[LlamaLibraryLoader] 从 bundle 加载: $bundlePath');
        final library = DynamicLibrary.open(bundlePath);
        return LibraryLoadResult(
          success: true,
          library: library,
          version: version,
          note: '从应用 bundle 加载',
        );
      }

      // 2. 尝试从 libs 目录加载（Flutter 插件方式）
      final libsPath = await _getLibsDirectoryPath(version);
      if (libsPath != null && await File(libsPath).exists()) {
        debugPrint('[LlamaLibraryLoader] 从 libs 加载: $libsPath');
        final library = DynamicLibrary.open(libsPath);
        return LibraryLoadResult(
          success: true,
          library: library,
          version: version,
          note: '从 libs 目录加载',
        );
      }

      // 3. 尝试系统路径（作为最后的回退）
      final systemPath = _getSystemLibraryPath(version);
      try {
        debugPrint('[LlamaLibraryLoader] 尝试系统路径: $systemPath');
        final library = DynamicLibrary.open(systemPath);
        return LibraryLoadResult(
          success: true,
          library: library,
          version: version,
          note: '从系统路径加载',
        );
      } catch (e) {
        // 系统路径也失败
        return LibraryLoadResult(
          success: false,
          version: version,
          error: '库文件不存在: $bundlePath, $libsPath, $systemPath',
        );
      }
    } catch (e, stack) {
      debugPrint('[LlamaLibraryLoader] 加载异常: $e');
      debugPrint('[LlamaLibraryLoader] 堆栈: $stack');
      return LibraryLoadResult(
        success: false,
        version: version,
        error: '加载异常: $e',
      );
    }
  }

  /// 获取应用 bundle 中的库路径
  Future<String?> _getBundleLibraryPath(LlamaLibraryVersion version) async {
    if (!Platform.isAndroid) return null;

    try {
      // Android 应用 bundle 路径
      final appDir = await getApplicationDocumentsDirectory();
      // bundle 中的库通常在 app/libs 或 app/lib 中
      // 但 Flutter 打包时会把 .so 放在 lib/ 目录下
      final libDir = Directory('${appDir.path}/../lib');
      if (await libDir.exists()) {
        final libPath = '${libDir.path}/${version.fileName}';
        if (await File(libPath).exists()) {
          return libPath;
        }
      }
    } catch (e) {
      debugPrint('[LlamaLibraryLoader] 获取 bundle 路径失败: $e');
    }
    return null;
  }

  /// 获取 libs 目录路径（Flutter 插件方式）
  Future<String?> _getLibsDirectoryPath(LlamaLibraryVersion version) async {
    if (!Platform.isAndroid) return null;

    try {
      // Flutter 插件的 .so 文件通常放在 app/libs/ 目录下
      final appDir = await getApplicationDocumentsDirectory();
      final libsDir = Directory('${appDir.path}/../libs');
      if (await libsDir.exists()) {
        final libPath = '${libsDir.path}/${version.fileName}';
        if (await File(libPath).exists()) {
          return libPath;
        }
      }
    } catch (e) {
      debugPrint('[LlamaLibraryLoader] 获取 libs 路径失败: $e');
    }
    return null;
  }

  /// 获取系统库路径
  String _getSystemLibraryPath(LlamaLibraryVersion version) {
    if (Platform.isAndroid) {
      return '/vendor/lib64/${version.fileName}';
    } else if (Platform.isLinux) {
      return '/usr/lib/${version.fileName}';
    }
    return version.fileName;
  }

  /// 预加载所有可能的库版本（用于快速切换）
  Future<Map<LlamaLibraryVersion, LibraryLoadResult>> preloadAllLibraries() async {
    final results = <LlamaLibraryVersion, LibraryLoadResult>{};

    // 预加载所有版本
    for (final version in LlamaLibraryVersion.values) {
      final result = await _tryLoadLibrary(version);
      results[version] = result;
      debugPrint('[LlamaLibraryLoader] 预加载 ${version.fileName}: ${result.success}');
    }

    return results;
  }

  /// 获取当前已加载的库信息
  LibraryLoadResult? get currentLibrary {
    if (_loadedLibrary == null || _loadedVersion == null) {
      return null;
    }
    return LibraryLoadResult(
      success: true,
      library: _loadedLibrary,
      version: _loadedVersion!,
    );
  }

  /// 卸载当前库
  void unload() {
    _loadedLibrary = null;
    _loadedVersion = null;
    debugPrint('[LlamaLibraryLoader] 库已卸载');
  }

  /// 获取所有可用的库版本
  Future<List<LlamaLibraryVersion>> getAvailableVersions() async {
    final available = <LlamaLibraryVersion>[];

    for (final version in LlamaLibraryVersion.values) {
      final bundlePath = await _getBundleLibraryPath(version);
      final libsPath = await _getLibsDirectoryPath(version);

      if ((bundlePath != null && await File(bundlePath).exists()) ||
          (libsPath != null && await File(libsPath).exists())) {
        available.add(version);
      }
    }

    return available;
  }
}