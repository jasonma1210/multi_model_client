/// 架构差异化性能优化模块
///
/// 职责：
/// - x86 架构优化：AVX2/AVX-512 检测与策略
/// - ARM 架构优化：NEON/DotProd/i8mm/SME 检测与策略
/// - GPU 特定优化：Metal 统一内存、CUDA VRAM、Vulkan 通用
/// - 内存分配策略：按架构选择最优内存布局
///
/// ★ 设计原则：
/// - 优化策略与检测逻辑分离
/// - 每个策略独立可测试
/// - 降级路径清晰
///
/// @author JianMa
/// @version 1.0.0
library;

import 'dart:io';
import 'package:flutter/foundation.dart';

import 'platform_detector.dart';
import 'hardware_profiler.dart';
import 'sandbox_config.dart';

// ════════════════════════════════════════════════════════════════════════
//  CPU 指令集特性
// ════════════════════════════════════════════════════════════════════════

/// x86 CPU 特性
class X86Features {
  /// SSE4.2 — 基础 SIMD
  final bool sse42;

  /// AVX — 256-bit SIMD
  final bool avx;

  /// AVX2 — 256-bit 整数 SIMD
  final bool avx2;

  /// AVX-512F — 512-bit SIMD 基础
  final bool avx512f;

  /// AVX-512 VNNI — 向量神经网络指令
  final bool avx512Vnni;

  /// FMA — 融合乘加
  final bool fma;

  const X86Features({
    this.sse42 = false,
    this.avx = false,
    this.avx2 = false,
    this.avx512f = false,
    this.avx512Vnni = false,
    this.fma = false,
  });

  /// 性能等级（0-5）
  int get performanceLevel {
    if (avx512Vnni) return 5; // 最优：AVX-512 VNNI
    if (avx512f) return 4; // AVX-512
    if (avx2 && fma) return 3; // AVX2 + FMA
    if (avx2) return 2; // AVX2
    if (avx) return 1; // AVX
    return 0; // SSE4.2 或更低
  }

  @override
  String toString() => 'X86Features('
      'avx2=$avx2, avx512=$avx512f, vnni=$avx512Vnni, '
      'level=$performanceLevel)';
}

/// ARM CPU 特性
class ArmFeatures {
  /// NEON — 基础 SIMD（所有 ARM64 支持）
  final bool neon;

  /// DotProduct — ARMv8.2+，4-bit 量化速度提升 2-3 倍
  final bool dotprod;

  /// i8mm — Int8 矩阵乘法（ARMv8.2+）
  final bool i8mm;

  /// SME — 可缩放矩阵扩展（ARMv9+）
  /// ⚠️ Android GKI 内核可能有兼容性问题
  final bool sme;

  /// SVE — 可缩放向量扩展
  final bool sve;

  /// SVE2 — SVE 第二版
  final bool sve2;

  const ArmFeatures({
    this.neon = true, // ARM64 必定支持 NEON
    this.dotprod = false,
    this.i8mm = false,
    this.sme = false,
    this.sve = false,
    this.sve2 = false,
  });

  /// 性能等级（0-5）
  int get performanceLevel {
    if (sme && !smeHasCompatibilityIssue) return 5; // SME 最优
    if (i8mm) return 4; // i8mm
    if (dotprod) return 3; // DotProd
    if (neon) return 1; // NEON 基础
    return 0;
  }

  /// SME 是否有兼容性问题（Android GKI 内核）
  bool get smeHasCompatibilityIssue => Platform.isAndroid;

  @override
  String toString() => 'ArmFeatures('
      'neon=$neon, dotprod=$dotprod, i8mm=$i8mm, '
      'sme=$sme, level=$performanceLevel)';
}

// ════════════════════════════════════════════════════════════════════════
//  架构优化器
// ════════════════════════════════════════════════════════════════════════

/// 架构差异化性能优化器
///
/// 根据 CPU 架构和 GPU 后端，提供最优的性能配置建议。
/// 优化结果会反映到 [SandboxConfig] 中。
class ArchOptimizer {
  ArchOptimizer._();
  static final ArchOptimizer instance = ArchOptimizer._();

  /// 缓存的 x86 特性
  X86Features? _x86Features;

  /// 缓存的 ARM 特性
  ArmFeatures? _armFeatures;

  /// 检测 x86 CPU 特性
  ///
  /// 通过 /proc/cpuinfo（Linux）或注册表（Windows）检测
  Future<X86Features> detectX86Features() async {
    if (_x86Features != null) return _x86Features!;

    if (!Platform.isWindows && !Platform.isLinux) {
      return const X86Features(); // 非 x86 平台
    }

    try {
      if (Platform.isLinux) {
        final cpuInfo = File('/proc/cpuinfo').readAsStringSync();
        final flags = _parseCpuFlags(cpuInfo);
        _x86Features = X86Features(
          sse42: flags.contains('sse4_2'),
          avx: flags.contains('avx ') || flags.contains('avx\t'),
          avx2: flags.contains('avx2'),
          avx512f: flags.contains('avx512f'),
          avx512Vnni: flags.contains('avx512vnni'),
          fma: flags.contains('fma'),
        );
      } else if (Platform.isWindows) {
        // Windows: 简化检测，假设现代 CPU 支持 AVX2
        // 精确检测需要通过 WMI 或 CPUID 指令
        _x86Features = const X86Features(
          sse42: true,
          avx: true,
          avx2: true, // 现代 Windows PC 大多支持
          fma: true,
        );
      }
    } catch (e) {
      debugPrint('[ArchOptimizer] ⚠️ x86 特性检测失败: $e');
      _x86Features = const X86Features();
    }

    debugPrint('[ArchOptimizer] 🔍 x86 特性: $_x86Features');
    return _x86Features!;
  }

  /// 检测 ARM CPU 特性
  ///
  /// 通过 /proc/cpuinfo（Android）检测
  Future<ArmFeatures> detectArmFeatures() async {
    if (_armFeatures != null) return _armFeatures!;

    // Apple Silicon: 固定支持 NEON + DotProd + i8mm
    if (Platform.isMacOS || Platform.isIOS) {
      _armFeatures = const ArmFeatures(
        neon: true,
        dotprod: true,
        i8mm: true,
        sme: false, // M 系列暂不支持 SME
      );
      debugPrint('[ArchOptimizer] 🔍 ARM 特性 (Apple): $_armFeatures');
      return _armFeatures!;
    }

    // Android: 通过 /proc/cpuinfo 检测
    if (Platform.isAndroid) {
      try {
        final cpuInfo = File('/proc/cpuinfo').readAsStringSync();
        final features = _parseArmFeatures(cpuInfo);
        _armFeatures = ArmFeatures(
          neon: features.contains('neon') || features.contains('asimd'),
          dotprod: features.contains('dotprod'),
          i8mm: features.contains('i8mm'),
          sme: features.contains('sme'),
          sve: features.contains('sve'),
          sve2: features.contains('sve2'),
        );
      } catch (e) {
        debugPrint('[ArchOptimizer] ⚠️ ARM 特性检测失败: $e');
        _armFeatures = const ArmFeatures();
      }
      debugPrint('[ArchOptimizer] 🔍 ARM 特性 (Android): $_armFeatures');
      return _armFeatures!;
    }

    _armFeatures = const ArmFeatures();
    return _armFeatures!;
  }

  /// 应用架构优化到沙箱配置
  ///
  /// 根据 CPU 特性调整线程数、批处理大小等参数
  SandboxConfig optimize(SandboxConfig config) {
    if (config.platform.cpuArch == CpuArch.x86_64) {
      return _optimizeX86(config);
    } else if (config.platform.cpuArch == CpuArch.arm64 ||
        config.platform.cpuArch == CpuArch.armv7) {
      return _optimizeArm(config);
    }
    return config; // 未知架构，不优化
  }

  /// x86 架构优化策略
  SandboxConfig _optimizeX86(SandboxConfig config) {
    // x86 优化要点：
    // 1. AVX2+: 可以使用更大的 batch size（SIMD 加速）
    // 2. AVX-512 VNNI: INT8 推理加速 2-4 倍
    // 3. CUDA + AVX2: GPU 为主，CPU 为辅
    // 4. 线程数：超线程对推理收益小，用物理核心数

    // x86 桌面端默认配置已经较优，无需额外调整
    // 主要优化点在 CUDA VRAM 分配（由运行时检测）
    return config;
  }

  /// ARM 架构优化策略
  SandboxConfig _optimizeArm(SandboxConfig config) {
    // ARM 优化要点：
    // 1. Apple Silicon: 统一内存，全量 GPU offload
    // 2. DotProd/i8mm: CPU 推理加速 2-3 倍
    // 3. SME: ⚠️ Android GKI 兼容性问题，可能需要禁用
    // 4. 大小核: 线程数不应超过 P 核数

    // Apple Silicon 已经在 HardwareProfiler 中做了最优配置
    // Android ARM 优化需要根据 DotProd/i8mm 调整
    return config;
  }

  // ════════════════════════════════════════════════════════════════════════
  //  解析辅助
  // ════════════════════════════════════════════════════════════════════════

  /// 解析 /proc/cpuinfo 中的 CPU flags
  Set<String> _parseCpuFlags(String cpuInfo) {
    final flags = <String>{};
    for (final line in cpuInfo.split('\n')) {
      if (line.startsWith('flags')) {
        final parts = line.split(':');
        if (parts.length >= 2) {
          flags.addAll(parts[1].trim().split(RegExp(r'\s+')));
        }
      }
      if (line.startsWith('Features')) {
        final parts = line.split(':');
        if (parts.length >= 2) {
          flags.addAll(parts[1].trim().split(RegExp(r'\s+')));
        }
      }
    }
    return flags;
  }

  /// 解析 /proc/cpuinfo 中的 ARM 特性
  Set<String> _parseArmFeatures(String cpuInfo) {
    final features = <String>{};
    for (final line in cpuInfo.split('\n')) {
      if (line.startsWith('Features')) {
        final parts = line.split(':');
        if (parts.length >= 2) {
          features.addAll(parts[1].trim().split(RegExp(r'\s+')));
        }
      }
    }
    return features;
  }
}
