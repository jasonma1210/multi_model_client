import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../platform/platform_utils.dart';

/// CPU 特性枚举（与 llama.cpp 编译选项对应）
enum CpuFeature {
  /// ARM NEON SIMD 指令集（所有 ARM64 设备都支持）
  neon,

  /// ARM DotProduct 指令集（ARMv8.2+）
  /// 4-bit 量化模型 CPU 推理速度提升 2-3 倍
  dotprod,

  /// ARM Int8 Matrix Multiply（ARMv8.2+）
  /// INT8 量化模型推理加速
  i8mm,

  /// ARM Scalable Matrix Extension（ARMv9+）
  /// ⚠️ Android GKI 内核对 SME 支持不完整，可能导致 SIGILL 崩溃
  /// 已在 MEMORY.md 中记录：Realme GT7 Pro (骁龙 8 Elite) + Android 16 崩溃问题
  sme,

  /// ARM Scalable Vector Extension（ARMv9+）
  sve,

  /// ARM Scalable Vector Extension 2
  sve2,
}

/// 芯片厂商枚举
enum ChipVendor {
  qualcomm,   // 高通骁龙
  mediatek,   // 联发科天玑
  huawei,     // 华为海思
  samsung,    // 三星 Exynos
  google,     // 谷歌 Tensor
  apple,      // 苹果（iOS）
  generic,    // 通用/未知
}

/// 加速后端优先级（从高到低）
enum AccelerationPriority {
  /// 第一优先级：高通 QNN NPU（最快最省电，但碎片化严重）
  npuQnn,

  /// 第二优先级：Vulkan GPU 加速（通用性强，性能好）
  vulkan,

  /// 第三优先级：DotProd CPU 优化（所有现代手机都支持，提升 2-3 倍）
  dotprod,

  /// 第四优先级：通用 CPU（兜底）
  generic,
}

/// CPU 特性检测结果
class CpuFeatureResult {
  final bool neon;
  final bool dotprod;
  final bool i8mm;
  final bool sme;
  final bool sve;
  final bool sve2;
  final String cpuModel;
  final String architecture;

  const CpuFeatureResult({
    required this.neon,
    required this.dotprod,
    required this.i8mm,
    required this.sme,
    required this.sve,
    required this.sve2,
    required this.cpuModel,
    required this.architecture,
  });

  /// 是否支持 DotProd（ARMv8.2+）
  bool get supportsDotProd => dotprod;

  /// 是否支持 i8mm（ARMv8.2+）
  bool get supportsI8mm => i8mm;

  /// 是否支持 SME（ARMv9+，但 Android GKI 内核可能有 bug）
  bool get supportsSme => sme;

  /// 获取推荐的 llama.cpp 库版本
  String get recommendedLibrary {
    // 优先级：SME > i8mm > dotprod > generic
    // ⚠️ SME 在某些 Android 设备上可能导致 SIGILL 崩溃
    if (sme) {
      debugPrint('[CpuFeatureDetector] ⚠️ 检测到 SME，但 Android GKI 内核可能有兼容性问题');
      // 暂时回退到 i8mm，等内核修复后再启用
      // return 'libllama_sme.so';
    }
    if (i8mm) return 'libllama_i8mm.so';
    if (dotprod) return 'libllama_dotprod.so';
    return 'libllama_generic.so';
  }

  factory CpuFeatureResult.fromMap(Map<String, dynamic> map) {
    return CpuFeatureResult(
      neon: map['neon'] as bool? ?? true,
      dotprod: map['dotprod'] as bool? ?? false,
      i8mm: map['i8mm'] as bool? ?? false,
      sme: map['sme'] as bool? ?? false,
      sve: map['sve'] as bool? ?? false,
      sve2: map['sve2'] as bool? ?? false,
      cpuModel: map['cpuModel'] as String? ?? 'Unknown',
      architecture: map['architecture'] as String? ?? 'arm64-v8a',
    );
  }

  @override
  String toString() {
    return 'CpuFeatureResult(neon: $neon, dotprod: $dotprod, i8mm: $i8mm, '
        'sme: $sme, sve: $sve, sve2: $sve2, cpuModel: $cpuModel, arch: $architecture)';
  }
}

/// 芯片厂商信息
class ChipVendorInfo {
  final ChipVendor vendor;
  final String board;
  final String hardware;
  final String model;
  final String manufacturer;
  final String? gpuArch;
  final String? npuName;

  const ChipVendorInfo({
    required this.vendor,
    required this.board,
    required this.hardware,
    required this.model,
    required this.manufacturer,
    this.gpuArch,
    this.npuName,
  });

  bool get isQualcomm => vendor == ChipVendor.qualcomm;
  bool get isMediatek => vendor == ChipVendor.mediatek;
  bool get isHuawei => vendor == ChipVendor.huawei;
  bool get isSamsung => vendor == ChipVendor.samsung;
  bool get isGoogle => vendor == ChipVendor.google;

  factory ChipVendorInfo.fromMap(Map<String, dynamic> map) {
    final vendorStr = map['vendor'] as String? ?? 'GENERIC';
    final vendor = ChipVendor.values.firstWhere(
      (v) => v.name.toUpperCase() == vendorStr.toUpperCase(),
      orElse: () => ChipVendor.generic,
    );

    return ChipVendorInfo(
      vendor: vendor,
      board: map['board'] as String? ?? '',
      hardware: map['hardware'] as String? ?? '',
      model: map['model'] as String? ?? '',
      manufacturer: map['manufacturer'] as String? ?? '',
      gpuArch: map['gpuArch'] as String?,
      npuName: map['npuName'] as String?,
    );
  }

  @override
  String toString() {
    return 'ChipVendorInfo(vendor: $vendor, model: $model, gpuArch: $gpuArch, npuName: $npuName)';
  }
}

/// NPU 可用性检测结果
class NpuAvailabilityResult {
  final ChipVendor vendor;
  final bool available;
  final String runtime;
  final String note;
  final bool nnapiAvailable;
  final String? nnapiVersion;

  const NpuAvailabilityResult({
    required this.vendor,
    required this.available,
    required this.runtime,
    required this.note,
    required this.nnapiAvailable,
    this.nnapiVersion,
  });

  factory NpuAvailabilityResult.fromMap(Map<String, dynamic> map) {
    final vendorStr = map['vendor'] as String? ?? 'GENERIC';
    final vendor = ChipVendor.values.firstWhere(
      (v) => v.name.toUpperCase() == vendorStr.toUpperCase(),
      orElse: () => ChipVendor.generic,
    );

    return NpuAvailabilityResult(
      vendor: vendor,
      available: map['available'] as bool? ?? false,
      runtime: map['runtime'] as String? ?? 'none',
      note: map['note'] as String? ?? '',
      nnapiAvailable: map['nnapiAvailable'] as bool? ?? false,
      nnapiVersion: map['nnapiVersion'] as String?,
    );
  }

  @override
  String toString() {
    return 'NpuAvailabilityResult(vendor: $vendor, available: $available, runtime: $runtime)';
  }
}

/// 硬件特性检测器（多维度动态适配核心）
///
/// 优先级策略：
/// 1. 高通 QNN NPU（最快最省电，但只能在骁龙芯片上运行）
/// 2. Vulkan GPU 加速（通用性强，性能好）
/// 3. DotProd CPU 优化（所有现代手机都支持，提升 2-3 倍）
/// 4. 通用 CPU（兜底）
class CpuFeatureDetector {
  static const MethodChannel _channel = MethodChannel('hardware_checker');

  static CpuFeatureDetector? _instance;
  static CpuFeatureDetector get instance => _instance ??= CpuFeatureDetector._();

  CpuFeatureDetector._();

  // 缓存结果
  CpuFeatureResult? _cachedFeatures;
  ChipVendorInfo? _cachedVendor;
  NpuAvailabilityResult? _cachedNpu;

  /// 获取 CPU 特性（DotProd, i8mm, SME 等）
  Future<CpuFeatureResult> getCpuFeatures() async {
    if (_cachedFeatures != null) {
      return _cachedFeatures!;
    }

    // 桌面平台返回默认特性
    if (!PlatformUtils.isAndroid || PlatformUtils.isIOS) {
      _cachedFeatures = const CpuFeatureResult(
        neon: true,
        dotprod: false,
        i8mm: false,
        sme: false,
        sve: false,
        sve2: false,
        cpuModel: 'Desktop',
        architecture: 'x86_64',
      );
      return _cachedFeatures!;
    }

    try {
      final result = await _channel.invokeMethod('getCpuFeatures');
      _cachedFeatures = CpuFeatureResult.fromMap(Map<String, dynamic>.from(result));
      debugPrint('[CpuFeatureDetector] CPU 特性: $_cachedFeatures');
      return _cachedFeatures!;
    } catch (e) {
      debugPrint('[CpuFeatureDetector] 获取 CPU 特性失败: $e');
      // 返回保守的默认值
      _cachedFeatures = const CpuFeatureResult(
        neon: true,
        dotprod: false,
        i8mm: false,
        sme: false,
        sve: false,
        sve2: false,
        cpuModel: 'Unknown',
        architecture: 'arm64-v8a',
      );
      return _cachedFeatures!;
    }
  }

  /// 获取芯片厂商信息
  Future<ChipVendorInfo> getChipVendor() async {
    if (_cachedVendor != null) {
      return _cachedVendor!;
    }

    if (!PlatformUtils.isAndroid) {
      _cachedVendor = const ChipVendorInfo(
        vendor: ChipVendor.generic,
        board: '',
        hardware: '',
        model: 'Desktop',
        manufacturer: '',
      );
      return _cachedVendor!;
    }

    try {
      final result = await _channel.invokeMethod('getChipVendor');
      _cachedVendor = ChipVendorInfo.fromMap(Map<String, dynamic>.from(result));
      debugPrint('[CpuFeatureDetector] 芯片厂商: $_cachedVendor');
      return _cachedVendor!;
    } catch (e) {
      debugPrint('[CpuFeatureDetector] 获取芯片厂商失败: $e');
      _cachedVendor = const ChipVendorInfo(
        vendor: ChipVendor.generic,
        board: '',
        hardware: '',
        model: 'Unknown',
        manufacturer: '',
      );
      return _cachedVendor!;
    }
  }

  /// 检测 NPU 可用性
  Future<NpuAvailabilityResult> checkNpuAvailability() async {
    if (_cachedNpu != null) {
      return _cachedNpu!;
    }

    if (!PlatformUtils.isAndroid) {
      _cachedNpu = const NpuAvailabilityResult(
        vendor: ChipVendor.generic,
        available: false,
        runtime: 'none',
        note: '非 Android 平台',
        nnapiAvailable: false,
      );
      return _cachedNpu!;
    }

    try {
      final result = await _channel.invokeMethod('checkNpuAvailability');
      _cachedNpu = NpuAvailabilityResult.fromMap(Map<String, dynamic>.from(result));
      debugPrint('[CpuFeatureDetector] NPU 可用性: $_cachedNpu');
      return _cachedNpu!;
    } catch (e) {
      debugPrint('[CpuFeatureDetector] 检测 NPU 可用性失败: $e');
      _cachedNpu = const NpuAvailabilityResult(
        vendor: ChipVendor.generic,
        available: false,
        runtime: 'none',
        note: '检测失败',
        nnapiAvailable: false,
      );
      return _cachedNpu!;
    }
  }

  /// ★★★ 核心：获取最优的 llama.cpp 库加载策略 ★★★
  ///
  /// 返回优先级列表，从高到低尝试加载
  Future<List<AccelerationPriority>> getAccelerationPriority() async {
    final priorities = <AccelerationPriority>[];

    // 1. 检测 NPU（高通 QNN）
    final npuResult = await checkNpuAvailability();
    if (npuResult.available && npuResult.vendor == ChipVendor.qualcomm) {
      priorities.add(AccelerationPriority.npuQnn);
      debugPrint('[CpuFeatureDetector] ✅ 检测到高通 QNN NPU，将优先尝试 NPU 加速');
    }

    // 2. Vulkan GPU（所有 Android 设备）
    // 注意：Vulkan 检测在 LocalFFIEngine 中通过实际加载测试
    priorities.add(AccelerationPriority.vulkan);

    // 3. CPU 指令集优化
    final features = await getCpuFeatures();
    if (features.supportsDotProd || features.supportsI8mm) {
      priorities.add(AccelerationPriority.dotprod);
      debugPrint('[CpuFeatureDetector] ✅ 检测到 DotProd/i8mm 支持');
    }

    // 4. 兜底
    priorities.add(AccelerationPriority.generic);

    return priorities;
  }

  /// 获取推荐加载的库文件名
  Future<String> getRecommendedLibraryName() async {
    final features = await getCpuFeatures();
    final npuResult = await checkNpuAvailability();

    // 优先级：NPU QNN > Vulkan > DotProd > Generic
    if (npuResult.available && npuResult.vendor == ChipVendor.qualcomm) {
      return 'libllama_qnn.so';
    }

    // Vulkan 版本（通用）
    // return 'libllama_vulkan.so';

    // CPU 优化版本
    return features.recommendedLibrary;
  }

  /// 清除缓存（用于测试或重新检测）
  void clearCache() {
    _cachedFeatures = null;
    _cachedVendor = null;
    _cachedNpu = null;
    _cachedBigCoreInfo = null;
    debugPrint('[CpuFeatureDetector] 缓存已清除');
  }

  // ════════════════════════════════════════════════════════════════════════
  //  新增：大核信息检测（骁龙 8 Elite 优化核心）
  // ════════════════════════════════════════════════════════════════════════

  BigCoreInfo? _cachedBigCoreInfo;

  /// 获取 CPU 大核信息
  ///
  /// ★ Android big.LITTLE 架构优化核心：
  ///   - EAS（能量感知调度）会把推理任务分配给小核，导致性能极差
  ///   - 必须显式设置线程数 = 大核数，避免"裸奔"在小核上
  ///   - 骁龙 8 Elite 5: 2×超大核(P) + 4×大核(M) + 2×小核(E) = 8 核
  Future<BigCoreInfo> getBigCoreInfo() async {
    if (_cachedBigCoreInfo != null) return _cachedBigCoreInfo!;

    if (!PlatformUtils.isAndroid) {
      // 非 Android 平台：所有核心都可用
      _cachedBigCoreInfo = BigCoreInfo(
        totalCores: Platform.numberOfProcessors,
        bigCoreCount: Platform.numberOfProcessors,
        littleCoreCount: 0,
        recommendedThreads: Platform.numberOfProcessors,
      );
      return _cachedBigCoreInfo!;
    }

    try {
      final result = await _channel.invokeMethod('getBigCoreInfo');
      final map = Map<String, dynamic>.from(result);
      _cachedBigCoreInfo = BigCoreInfo.fromMap(map);
      debugPrint('[CpuFeatureDetector] 大核信息: $_cachedBigCoreInfo');
      return _cachedBigCoreInfo!;
    } catch (e) {
      debugPrint('[CpuFeatureDetector] 获取大核信息失败: $e');
      // 回退：使用经验值
      final totalCores = Platform.numberOfProcessors;
      _cachedBigCoreInfo = BigCoreInfo(
        totalCores: totalCores,
        bigCoreCount: (totalCores * 0.75).round(),
        littleCoreCount: totalCores - (totalCores * 0.75).round(),
        recommendedThreads: (totalCores * 0.75).round().clamp(2, 10),
      );
      return _cachedBigCoreInfo!;
    }
  }
}

// ════════════════════════════════════════════════════════════════════════
//  大核信息数据模型
// ════════════════════════════════════════════════════════════════════════

/// CPU 大核信息（Android big.LITTLE 架构优化）
///
/// ★ 骁龙 8 Elite 5 核心: 2×超大核(P) + 4×大核(M) + 2×小核(E) = 8 核
/// 推理线程数应 = 大核数（跳过小核），避免 EAS 调度到小核
class BigCoreInfo {
  /// 总 CPU 核心数
  final int totalCores;

  /// 大核数（包括超大核）
  final int bigCoreCount;

  /// 小核数
  final int littleCoreCount;

  /// 推荐的推理线程数 = 大核数（clamp 2-10）
  final int recommendedThreads;

  const BigCoreInfo({
    required this.totalCores,
    required this.bigCoreCount,
    required this.littleCoreCount,
    required this.recommendedThreads,
  });

  factory BigCoreInfo.fromMap(Map<String, dynamic> map) {
    return BigCoreInfo(
      totalCores: map['totalCores'] as int? ?? Platform.numberOfProcessors,
      bigCoreCount: map['bigCoreCount'] as int? ?? (Platform.numberOfProcessors * 0.75).round(),
      littleCoreCount: map['littleCoreCount'] as int? ?? 0,
      recommendedThreads: map['recommendedThreads'] as int? ?? (Platform.numberOfProcessors * 0.75).round().clamp(2, 10),
    );
  }

  @override
  String toString() {
    return 'BigCoreInfo(total: $totalCores, big: $bigCoreCount, '
        'little: $littleCoreCount, recommendedThreads: $recommendedThreads)';
  }
}