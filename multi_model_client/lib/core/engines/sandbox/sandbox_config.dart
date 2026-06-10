/// 沙箱配置模块
///
/// 职责：
/// - 统一沙箱初始化配置（跨平台）
/// - 整合平台画像 + 硬件画像 + 用户自定义参数
/// - 生成最终的 ModelParams（llamadart 参数）
/// - 支持运行时动态调整（热更新）
///
/// ★ 基于 llamadart 0.6.16+ 后端选择指南：
///   - preferredBackend: 让 llamadart 根据平台自动选择最优后端
///   - batchSize/microBatchSize: 默认 0（自动 = contextSize），不硬编码
///   - flashAttention: GPU 模式启用，CPU 模式禁用
///   - ModelParams.validate(): 校验参数组合合法性
///   - splitMode/mainGpu: 多 GPU 分配策略
///
/// @author JianMa
/// @version 2.0.0 (align with llamadart backend-selection guide)
library;

import 'package:llamadart/llamadart.dart';

import 'platform_detector.dart';
import 'hardware_profiler.dart';
import '../../models/model_entry.dart';

// ════════════════════════════════════════════════════════════════════════
//  沙箱配置
// ════════════════════════════════════════════════════════════════════════

/// 沙箱运行模式
enum SandboxMode {
  /// GPU 加速模式（Metal/CUDA/Vulkan）
  gpu,

  /// CPU 模式（GPU 不可用或崩溃后回退）
  cpu,

  /// 安全模式（上次崩溃后，最小化配置）
  safe,

  /// 用户自定义模式（用户手动配置所有参数）
  custom,
}

/// 沙箱初始化配置
///
/// 整合平台画像、硬件画像、用户参数，生成最终的 llamadart ModelParams。
/// 这是沙箱系统的核心配置对象，所有模块通过它获取运行参数。
class SandboxConfig {
  /// 平台画像
  final PlatformProfile platform;

  /// 硬件画像
  final HardwareProfile hardware;

  /// 运行模式
  final SandboxMode mode;

  /// 用户自定义参数（可选，覆盖自动检测值）
  final LocalModelParams? userParams;

  /// 是否强制 CPU 模式（GPU 崩溃后回退）
  final bool forceCpuMode;

  /// KV Cache 量化类型
  final KvCacheQuant kvCache;

  /// 上下文大小 (tokens)
  final int contextSize;

  /// GPU 层数
  final int gpuLayers;

  /// 线程数
  final int threads;

  /// 批处理大小（0 = 自动，默认等于 contextSize）
  final int batchSize;

  /// 微批次大小（0 = 自动，默认等于 batchSize）
  final int microBatchSize;

  /// 是否使用 mmap
  final bool useMmap;

  /// 是否使用 mlock
  final bool useMlock;

  /// GPU 后端偏好（传递给 llamadart ModelParams.preferredBackend）
  final GpuBackend preferredBackend;

  /// 模型张量分配策略（多 GPU 场景）
  final ModelSplitMode splitMode;

  /// 主 GPU 设备索引（splitMode=none 时使用）
  final int mainGpu;

  const SandboxConfig({
    required this.platform,
    required this.hardware,
    required this.mode,
    this.userParams,
    this.forceCpuMode = false,
    required this.kvCache,
    required this.contextSize,
    required this.gpuLayers,
    required this.threads,
    required this.batchSize,
    required this.microBatchSize,
    required this.useMmap,
    required this.useMlock,
    required this.preferredBackend,
    this.splitMode = ModelSplitMode.layer,
    this.mainGpu = 0,
  });

  /// 从平台画像 + 硬件画像自动生成配置
  ///
  /// ★ 核心方法：根据平台和硬件条件，智能选择最优配置
  factory SandboxConfig.auto({
    required PlatformProfile platform,
    required HardwareProfile hardware,
    LocalModelParams? userParams,
    bool forceCpuMode = false,
  }) {
    // ── 运行模式决策 ──
    final SandboxMode mode;
    if (forceCpuMode) {
      mode = SandboxMode.cpu;
    } else if (userParams != null) {
      mode = SandboxMode.custom;
    } else {
      mode = SandboxMode.gpu;
    }

    // ── KV Cache 策略 ──
    var kvCache = hardware.recommendedKvCache;

    // ── 上下文大小 ──
    var contextSize = userParams?.contextSize ?? hardware.recommendedContextSize;

    // ── GPU 层数 ──
    var gpuLayers = forceCpuMode
        ? 0
        : (userParams?.gpuLayers ?? hardware.recommendedGpuLayers);

    // ── 线程数 ──
    var threads = (userParams?.cpuThreads ?? 0) > 0
        ? userParams!.cpuThreads
        : hardware.recommendedThreads;

    // ── 批处理大小 ──
    // ★ llamadart 最佳实践：默认 0（自动 = contextSize）
    // 不再硬编码 512，让 llamadart 根据上下文大小自动决定
    // resolveModelContextBatchSizes() 会将 0 解析为 contextSize
    var batchSize = 0;
    var microBatchSize = 0;

    // ── mmap / mlock ──
    final useMmap = platform.supportsMmap;
    final useMlock = false;

    // ── GPU 后端偏好 ──
    // ★ 根据 llamadart 0.6.16+ 后端选择指南 + 骁龙 8 Elite 优化：
    //   Apple 平台: GpuBackend.metal（consolidated runtime）
    //   Windows/Linux: GpuBackend.auto（llamadart 自动检测 CUDA/Vulkan）
    //   Android: GpuBackend.vulkan（显式启用 Vulkan，避免默认 CPU 回退）
    //     - 骁龙 8 Elite 5 的 Adreno GPU 通过 Vulkan 可获得 3-5 倍推理加速
    //     - 纯 CPU 推理连芯片实力 1/10 都发挥不出来
    //   CPU 回退: GpuBackend.cpu
    final preferredBackend = forceCpuMode
        ? GpuBackend.cpu
        : platform.toLlamadartGpuBackend();

    // ── splitMode / mainGpu ──
    // 单 GPU 设备使用 none（避免不必要的分割开销）
    // 多 GPU 场景（服务器/工作站）使用 layer
    final splitMode = platform.isDiscreteVram
        ? ModelSplitMode.layer
        : ModelSplitMode.none;

    return SandboxConfig(
      platform: platform,
      hardware: hardware,
      mode: mode,
      userParams: userParams,
      forceCpuMode: forceCpuMode,
      kvCache: kvCache,
      contextSize: contextSize,
      gpuLayers: gpuLayers,
      threads: threads,
      batchSize: batchSize,
      microBatchSize: microBatchSize,
      useMmap: useMmap,
      useMlock: useMlock,
      preferredBackend: preferredBackend,
      splitMode: splitMode,
    );
  }

  /// 创建安全模式配置（上次崩溃后使用）
  factory SandboxConfig.safe({
    required PlatformProfile platform,
    required HardwareProfile hardware,
  }) {
    return SandboxConfig(
      platform: platform,
      hardware: hardware,
      mode: SandboxMode.safe,
      forceCpuMode: true,
      kvCache: KvCacheQuant.q4_0,
      contextSize: 2048,
      gpuLayers: 0,
      threads: (platform.cpuCores * 0.5).round().clamp(2, 4),
      batchSize: 0,
      microBatchSize: 0,
      useMmap: platform.supportsMmap,
      useMlock: false,
      preferredBackend: GpuBackend.cpu,
      splitMode: ModelSplitMode.none,
    );
  }

  /// 降级 KV Cache（运行时内存不足时调用）
  SandboxConfig downgradeKvCache() {
    final newKv = switch (kvCache) {
      KvCacheQuant.f16 => KvCacheQuant.q8_0,
      KvCacheQuant.q8_0 => KvCacheQuant.q4_0,
      KvCacheQuant.q4_0 => KvCacheQuant.q4_0,
    };
    return SandboxConfig(
      platform: platform,
      hardware: hardware,
      mode: mode,
      userParams: userParams,
      forceCpuMode: forceCpuMode,
      kvCache: newKv,
      contextSize: contextSize,
      gpuLayers: gpuLayers,
      threads: threads,
      batchSize: batchSize,
      microBatchSize: microBatchSize,
      useMmap: useMmap,
      useMlock: useMlock,
      preferredBackend: preferredBackend,
      splitMode: splitMode,
      mainGpu: mainGpu,
    );
  }

  /// 降低上下文大小（运行时内存不足时调用）
  SandboxConfig reduceContext(double factor) {
    final newCtx = (contextSize * factor).round().clamp(512, 131072);
    return SandboxConfig(
      platform: platform,
      hardware: hardware,
      mode: mode,
      userParams: userParams,
      forceCpuMode: forceCpuMode,
      kvCache: kvCache,
      contextSize: newCtx,
      gpuLayers: gpuLayers,
      threads: threads,
      batchSize: batchSize,
      microBatchSize: microBatchSize,
      useMmap: useMmap,
      useMlock: useMlock,
      preferredBackend: preferredBackend,
      splitMode: splitMode,
      mainGpu: mainGpu,
    );
  }

  /// 转换为 llamadart 的 ModelParams
  ///
  /// ★ 基于 llamadart 0.6.16+ 后端选择指南：
  /// - preferredBackend: 传递平台检测的 GPU 后端偏好
  /// - flashAttention: GPU 模式启用，CPU 模式禁用
  /// - batchSize/microBatchSize: 0 = 自动（由 resolveModelContextBatchSizes 解析）
  /// - validate(): 校验参数组合合法性
  ModelParams toModelParams() {
    // ── KvCacheQuant → KvCacheType 映射 ──
    final cacheTypeK = switch (kvCache) {
      KvCacheQuant.f16 => KvCacheType.f16,
      KvCacheQuant.q8_0 => KvCacheType.q8_0,
      KvCacheQuant.q4_0 => KvCacheType.q4_0,
    };
    final cacheTypeV = cacheTypeK; // K/V 使用相同量化

    // ── FlashAttention 策略 ──
    // ★ 后端选择指南推荐：
    //   GPU 模式：FlashAttention.enabled（性能优化 + 支持 Q8/Q4 KV Cache）
    //   CPU 模式：FlashAttention.disabled（CPU 模式下可能不稳定）
    //   安全模式：FlashAttention.disabled
    //   非F16 KV Cache 必须启用 FlashAttention（llamadart validate 会检查）
    final flashAttention = (forceCpuMode || mode == SandboxMode.cpu || mode == SandboxMode.safe)
        ? FlashAttention.disabled
        : FlashAttention.enabled;

    final params = ModelParams(
      contextSize: contextSize,
      gpuLayers: gpuLayers,
      preferredBackend: preferredBackend,
      splitMode: splitMode,
      mainGpu: mainGpu,
      numberOfThreads: threads,
      numberOfThreadsBatch: threads,
      batchSize: batchSize,
      microBatchSize: microBatchSize,
      useMmap: useMmap,
      useMlock: useMlock,
      flashAttention: flashAttention,
      cacheTypeK: cacheTypeK,
      cacheTypeV: cacheTypeV,
    );

    // ★ 校验参数组合合法性（非 F16 KV + disabled flash 会抛 ArgumentError）
    params.validate();

    return params;
  }

  @override
  String toString() => 'SandboxConfig('
      'mode=$mode, gpu=$gpuLayers, ctx=$contextSize, '
      'threads=$threads, batch=$batchSize, kv=$kvCache, '
      'mmap=$useMmap, backend=$preferredBackend, split=$splitMode)';
}
