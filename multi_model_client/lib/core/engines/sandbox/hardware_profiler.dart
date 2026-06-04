/// 硬件资源评估模块
///
/// 职责：
/// - 评估设备硬件资源（RAM、VRAM、CPU、存储）
/// - 生成 HardwareProfile（硬件画像），供沙箱配置决策
/// - 内存分级策略：根据可用内存推荐上下文大小、GPU 层数等
/// - KV Cache 量化策略：F16/Q8_0/Q4_0 自动降级
///
/// @author JianMa
/// @version 1.0.0
library;

import 'package:flutter/foundation.dart';

import 'platform_detector.dart';
import '../../services/hardware_compatibility_checker.dart';

// ════════════════════════════════════════════════════════════════════════
//  数据模型
// ════════════════════════════════════════════════════════════════════════

/// KV Cache 量化类型
enum KvCacheQuant {
  /// F16 — 全精度，桌面端默认
  f16,

  /// Q8_0 — 8-bit 量化，移动端默认（省一半内存，精度损失 <0.1%）
  q8_0,

  /// Q4_0 — 4-bit 量化，低端设备（省 3/4 内存，精度损失可接受）
  q4_0,
}

/// 内存容量分级
enum MemoryTier {
  /// 极低端 (<3GB) — 老旧安卓
  ultraLow,

  /// 低端 (3-4GB) — 入门安卓
  low,

  /// 中低端 (4-6GB) — 中端安卓
  midLow,

  /// 中端 (6-8GB) — 旗舰安卓/入门 iPhone
  mid,

  /// 中高端 (8-12GB) — 旗舰手机/入门 Mac
  midHigh,

  /// 高端 (12-16GB) — 高端手机/MacBook Air
  high,

  /// 旗舰 (16-32GB) — MacBook Pro/PC
  premium,

  /// 工作站 (32-48GB) — Mac Studio/高端 PC
  workstation,

  /// 高性能工作站 (>48GB) — 服务器级
  server,
}

/// 硬件画像 — 描述设备硬件资源的完整特征
class HardwareProfile {
  /// 总内存 (MB)
  final int totalRamMB;

  /// 可用内存 (MB)
  final int availableRamMB;

  /// GPU 显存 (MB)，统一内存架构下与 RAM 共享
  final int? vramMB;

  /// CPU 核心数
  final int cpuCores;

  /// 可用存储 (GB)
  final double? availableStorageGB;

  /// 内存分级
  final MemoryTier memoryTier;

  /// 推荐的 KV Cache 量化类型
  final KvCacheQuant recommendedKvCache;

  /// 推荐的 GPU 层数
  final int recommendedGpuLayers;

  /// 推荐的上下文大小 (tokens)
  final int recommendedContextSize;

  /// 推荐的线程数
  final int recommendedThreads;

  /// 推荐的批处理大小
  ///
  /// ★ llamadart 最佳实践：SandboxConfig 使用 batchSize=0（自动），
  /// 此字段仅供外部模块参考，不再传递给 ModelParams。
  final int recommendedBatchSize;

  /// 推荐的微批次大小
  ///
  /// ★ llamadart 最佳实践：SandboxConfig 使用 microBatchSize=0（自动），
  /// 此字段仅供外部模块参考，不再传递给 ModelParams。
  final int recommendedMicroBatchSize;

  /// 是否支持 FlashAttention
  ///
  /// ★ llamadart 自动处理 FlashAttention 启用/禁用，
  /// 此字段仅供外部模块参考。
  final bool supportsFlashAttention;

  /// 内存安全阈值 (MB) — 预留 25% 系统内存
  final int memorySafetyThresholdMB;

  const HardwareProfile({
    required this.totalRamMB,
    required this.availableRamMB,
    this.vramMB,
    required this.cpuCores,
    this.availableStorageGB,
    required this.memoryTier,
    required this.recommendedKvCache,
    required this.recommendedGpuLayers,
    required this.recommendedContextSize,
    required this.recommendedThreads,
    required this.recommendedBatchSize,
    required this.recommendedMicroBatchSize,
    required this.supportsFlashAttention,
    required this.memorySafetyThresholdMB,
  });

  /// 总内存 (GB)
  int get totalRamGB => totalRamMB ~/ 1024;

  @override
  String toString() => 'HardwareProfile('
      'ram=${totalRamGB}GB, tier=$memoryTier, '
      'kv=$recommendedKvCache, gpu=$recommendedGpuLayers, '
      'ctx=$recommendedContextSize, threads=$recommendedThreads, '
      'batch=$recommendedBatchSize)';
}

// ════════════════════════════════════════════════════════════════════════
//  硬件评估器
// ════════════════════════════════════════════════════════════════════════

/// 硬件资源评估器
///
/// 根据 [PlatformProfile] 和实际硬件信息，生成 [HardwareProfile]。
/// 评估结果缓存，避免重复系统调用。
class HardwareProfiler {
  HardwareProfiler._();
  static final HardwareProfiler instance = HardwareProfiler._();

  /// 缓存的硬件画像
  HardwareProfile? _cachedProfile;

  /// 硬件兼容性检查器（复用现有服务）
  final HardwareCompatibilityChecker _hwChecker = HardwareCompatibilityChecker();

  /// 获取硬件画像（带缓存）
  Future<HardwareProfile> profile(PlatformProfile platform) async {
    if (_cachedProfile != null) return _cachedProfile!;

    final hwInfo = await _hwChecker.getHardwareInfo();
    final totalRamMB = hwInfo.totalRamMB;
    final availableRamMB = hwInfo.availableRamMB;

    // ── 内存分级 ──
    final memoryGB = totalRamMB ~/ 1024;
    final memoryTier = _classifyMemoryTier(memoryGB);

    // ── KV Cache 策略 ──
    final kvCache = _recommendKvCache(platform, memoryTier);

    // ── GPU 层数 ──
    final gpuLayers = _recommendGpuLayers(platform, memoryTier);

    // ── 上下文大小 ──
    final contextSize = _recommendContextSize(platform, memoryTier);

    // ── 线程数 ──
    final threads = _recommendThreads(platform);

    // ── 批处理大小 ──
    final (batchSize, microBatch) = _recommendBatchSize(contextSize, platform);

    // ── FlashAttention ──
    final flashAttn = _recommendFlashAttention(platform, memoryTier);

    // ── 内存安全阈值 ──
    final safetyMB = (availableRamMB * 0.75).toInt(); // 预留 25%

    _cachedProfile = HardwareProfile(
      totalRamMB: totalRamMB,
      availableRamMB: availableRamMB,
      vramMB: platform.isDiscreteVram ? null : null, // CUDA 显存由运行时检测
      cpuCores: platform.cpuCores,
      availableStorageGB: hwInfo.availableStorageGB.toDouble(),
      memoryTier: memoryTier,
      recommendedKvCache: kvCache,
      recommendedGpuLayers: gpuLayers,
      recommendedContextSize: contextSize,
      recommendedThreads: threads,
      recommendedBatchSize: batchSize,
      recommendedMicroBatchSize: microBatch,
      supportsFlashAttention: flashAttn,
      memorySafetyThresholdMB: safetyMB,
    );

    debugPrint('[HardwareProfiler] 📊 硬件评估完成: $_cachedProfile');
    return _cachedProfile!;
  }

  /// 强制重新评估
  Future<HardwareProfile> reprofile(PlatformProfile platform) async {
    _cachedProfile = null;
    _hwChecker.clearCache();
    return profile(platform);
  }

  // ════════════════════════════════════════════════════════════════════════
  //  分级策略
  // ════════════════════════════════════════════════════════════════════════

  /// 内存分级
  MemoryTier _classifyMemoryTier(int memoryGB) {
    if (memoryGB < 3) return MemoryTier.ultraLow;
    if (memoryGB < 4) return MemoryTier.low;
    if (memoryGB < 6) return MemoryTier.midLow;
    if (memoryGB < 8) return MemoryTier.mid;
    if (memoryGB < 12) return MemoryTier.midHigh;
    if (memoryGB < 16) return MemoryTier.high;
    if (memoryGB < 32) return MemoryTier.premium;
    if (memoryGB < 48) return MemoryTier.workstation;
    return MemoryTier.server;
  }

  /// KV Cache 量化策略
  ///
  /// - 桌面端（macOS/PC）：F16（内存充足，保留最大精度）
  /// - 移动端中高端：Q8_0（省一半内存，精度损失 <0.1%）
  /// - 移动端低端：Q4_0（省 3/4 内存，精度损失可接受）
  KvCacheQuant _recommendKvCache(PlatformProfile platform, MemoryTier tier) {
    if (platform.isDesktop) return KvCacheQuant.f16;
    // 移动端
    switch (tier) {
      case MemoryTier.ultraLow:
      case MemoryTier.low:
        return KvCacheQuant.q4_0;
      case MemoryTier.midLow:
      case MemoryTier.mid:
      case MemoryTier.midHigh:
      case MemoryTier.high:
        return KvCacheQuant.q8_0;
      default:
        return KvCacheQuant.q8_0;
    }
  }

  /// GPU 层数推荐
  int _recommendGpuLayers(PlatformProfile platform, MemoryTier tier) {
    // Apple 平台：统一内存，全量 offload
    if (platform.isApple && platform.cpuArch == CpuArch.arm64) {
      return 999; // 全量 GPU offload
    }

    // Windows/Linux CUDA：根据显存决定（运行时检测后覆盖）
    if (platform.primaryGpuBackend == SandboxGpuBackend.cuda) {
      return 999; // 默认全量，运行时根据 VRAM 调整
    }

    // Android Vulkan：根据内存分级
    if (platform.isMobile) {
      switch (tier) {
        case MemoryTier.ultraLow:
          return 8;
        case MemoryTier.low:
          return 12;
        case MemoryTier.midLow:
          return 20;
        case MemoryTier.mid:
          return 28;
        case MemoryTier.midHigh:
          return 35;
        case MemoryTier.high:
          return 60;
        default:
          return 35;
      }
    }

    // 桌面端默认全量
    return 999;
  }

  /// 上下文大小推荐
  int _recommendContextSize(PlatformProfile platform, MemoryTier tier) {
    // ★ Apple Silicon 统一内存：内存即显存，context 越大越好
    if (platform.isUnifiedMemory) {
      switch (tier) {
        case MemoryTier.high: // 12-16GB
          return 32768; // 32K
        case MemoryTier.premium: // 16-32GB
          return 65536; // 64K
        case MemoryTier.workstation: // 32-48GB
          return 131072; // 128K
        case MemoryTier.server: // >48GB
          return 131072; // 128K（llama.cpp 上限）
        default:
          return 16384; // 16K
      }
    }

    // ★ 移动端：使用 Q8 KV cache，context 可以做得更大
    if (platform.isMobile) {
      switch (tier) {
        case MemoryTier.ultraLow:
          return 2048;
        case MemoryTier.low:
          return 4096;
        case MemoryTier.midLow:
          return 4096;
        case MemoryTier.mid:
          return 6144; // 6K（8GB 设备）
        case MemoryTier.midHigh:
          return 8192; // 8K
        case MemoryTier.high:
          return 12288; // 12K
        default:
          return 8192;
      }
    }

    // ★ 桌面端 PC（x86 + CUDA/Vulkan）
    switch (tier) {
      case MemoryTier.premium:
        return 16384; // 16K（保守，VRAM 有限）
      case MemoryTier.workstation:
        return 32768;
      case MemoryTier.server:
        return 65536;
      default:
        return 8192;
    }
  }

  /// 线程数推荐
  int _recommendThreads(PlatformProfile platform) {
    final cores = platform.cpuCores;

    switch (platform.os) {
      case SandboxOS.macOS:
        // Apple Silicon: P 核数（约总核 55%）是最优解
        // M1: 4P+4E → 4 threads, M2 Pro: 6P+4E → 6 threads
        return (cores * 0.55).round().clamp(2, 12);

      case SandboxOS.windows:
      case SandboxOS.linux:
        // x86 桌面：使用物理核心数（超线程对推理收益小）
        return (cores * 0.75).round().clamp(2, 16);

      case SandboxOS.android:
        // Android: 大小核混合，0.5 系数较安全
        return (cores * 0.5).round().clamp(2, 8);

      case SandboxOS.ios:
        // iOS: 类似 Android，核心数较少
        return (cores * 0.5).round().clamp(2, 6);

      case SandboxOS.unknown:
        return 4;
    }
  }

  /// 批处理大小推荐
  ///
  /// 返回 (batchSize, microBatchSize)
  (int, int) _recommendBatchSize(int contextSize, PlatformProfile platform) {
    // CPU 模式用更大批（CPU 上下文切换成本高）
    if (platform.primaryGpuBackend == SandboxGpuBackend.cpu) {
      return (2048, 1024);
    }

    // 长上下文用 2048，短上下文用 1024 节省内存
    if (contextSize >= 8192) {
      return (2048, 512);
    } else if (contextSize >= 4096) {
      return (2048, 1024);
    } else {
      return (1024, 512);
    }
  }

  /// FlashAttention 推荐
  bool _recommendFlashAttention(PlatformProfile platform, MemoryTier tier) {
    // ★ auto 模式：让 llamadart 自动检测
    // 旧 Metal 设备（Intel Mac）可能不支持，llamadart 会自动降级
    // 移动端低端设备也可能不支持
    return true; // 使用 auto，由 llamadart 决定
  }

  // ════════════════════════════════════════════════════════════════════════
  //  运行时内存预检
  // ════════════════════════════════════════════════════════════════════════

  /// 预估模型加载所需内存 (MB)
  ///
  /// [modelSizeMB] — 模型文件大小 (MB)
  /// [contextSize] — 上下文大小 (tokens)
  /// [kvCache] — KV Cache 量化类型
  static int estimateRequiredMemory({
    required int modelSizeMB,
    required int contextSize,
    required KvCacheQuant kvCache,
  }) {
    // KV Cache 每 1K context 的内存占用 (MB)
    // 经验值（7B 模型, layer=32, n_head_kv=8, head_dim=128）：
    //   F16: ~50MB/1K, Q8_0: ~25MB/1K, Q4_0: ~13MB/1K
    final kvMBPer1K = switch (kvCache) {
      KvCacheQuant.f16 => 50,
      KvCacheQuant.q8_0 => 25,
      KvCacheQuant.q4_0 => 13,
    };

    final kvCacheMB = (contextSize * kvMBPer1K) ~/ 1024;
    const runtimeOverheadMB = 256; // 运行时开销

    return modelSizeMB + kvCacheMB + runtimeOverheadMB;
  }

  /// 检查模型是否可以加载到当前设备
  ///
  /// 返回 null 表示可以加载，否则返回错误信息
  String? checkModelFeasibility({
    required HardwareProfile hw,
    required int modelSizeMB,
    required int contextSize,
    required KvCacheQuant kvCache,
  }) {
    final requiredMB = estimateRequiredMemory(
      modelSizeMB: modelSizeMB,
      contextSize: contextSize,
      kvCache: kvCache,
    );

    if (requiredMB > hw.memorySafetyThresholdMB) {
      // 尝试降级 KV Cache
      if (kvCache == KvCacheQuant.f16) {
        final q8Required = estimateRequiredMemory(
          modelSizeMB: modelSizeMB,
          contextSize: contextSize,
          kvCache: KvCacheQuant.q8_0,
        );
        if (q8Required <= hw.memorySafetyThresholdMB) {
          return '内存不足（F16 KV），建议切换到 Q8 KV Cache 可节省 50% KV 内存';
        }
      }
      if (kvCache != KvCacheQuant.q4_0) {
        final q4Required = estimateRequiredMemory(
          modelSizeMB: modelSizeMB,
          contextSize: contextSize,
          kvCache: KvCacheQuant.q4_0,
        );
        if (q4Required <= hw.memorySafetyThresholdMB) {
          return '内存不足，建议切换到 Q4 KV Cache 或降低上下文大小';
        }
      }
      return '内存不足：需要 ${requiredMB}MB，可用 ${hw.memorySafetyThresholdMB}MB。'
          '请选择更小的模型或关闭其他应用';
    }

    return null; // 可以加载
  }
}
