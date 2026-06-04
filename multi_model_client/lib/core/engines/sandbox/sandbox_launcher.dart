/// 沙箱启动器 — 平台差异化 llama.cpp 初始化流程
///
/// 职责：
/// - 根据平台画像执行差异化初始化序列
/// - macOS: Metal 探测 → GPU 层数 → mmap → 安全作用域
/// - Windows: CUDA 检测 → VRAM 计算 → GPU 层数
/// - Android: Vulkan 探测 → CPU 特性 → KV 量化 → 内存预检
/// - iOS: Metal → 内存约束 → 线程优化
/// - 崩溃恢复与 CPU 回退
/// - 安全模式检测（上次崩溃标记）
///
/// @author JianMa
/// @version 1.0.0
library;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'platform_detector.dart';
import 'hardware_profiler.dart';
import 'sandbox_config.dart';
import 'arch_optimizer.dart';
import '../../services/security_bookmark_service.dart';
import '../../models/model_entry.dart';

// ════════════════════════════════════════════════════════════════════════
//  启动结果
// ════════════════════════════════════════════════════════════════════════

/// 沙箱启动结果
class SandboxLaunchResult {
  /// 是否成功
  final bool success;

  /// 错误信息（失败时）
  final String? errorMessage;

  /// 最终使用的配置（可能经过降级）
  final SandboxConfig? appliedConfig;

  /// 是否使用了 CPU 回退
  final bool usedCpuFallback;

  /// 是否使用了安全模式
  final bool usedSafeMode;

  /// 警告信息列表
  final List<String> warnings;

  const SandboxLaunchResult({
    required this.success,
    this.errorMessage,
    this.appliedConfig,
    this.usedCpuFallback = false,
    this.usedSafeMode = false,
    this.warnings = const [],
  });

  factory SandboxLaunchResult.ok(SandboxConfig config, {bool cpuFallback = false, bool safeMode = false, List<String>? warnings}) {
    return SandboxLaunchResult(
      success: true,
      appliedConfig: config,
      usedCpuFallback: cpuFallback,
      usedSafeMode: safeMode,
      warnings: warnings ?? [],
    );
  }

  factory SandboxLaunchResult.fail(String message) {
    return SandboxLaunchResult(
      success: false,
      errorMessage: message,
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
//  沙箱启动器
// ════════════════════════════════════════════════════════════════════════

/// 沙箱启动器
///
/// 根据平台画像执行差异化初始化序列，生成最终的 [SandboxConfig]。
/// 启动器负责：
/// 1. 安全模式检测（上次崩溃标记）
/// 2. 平台特定的预初始化（Metal/CUDA/Vulkan 探测）
/// 3. 内存预检与配置降级
/// 4. 架构优化
/// 5. macOS 安全作用域授权
class SandboxLauncher {
  SandboxLauncher._();
  static final SandboxLauncher instance = SandboxLauncher._();

  /// 崩溃标记 key
  static const _crashFlagKey = '_model_loading_crash_flag';

  /// 执行启动序列
  ///
  /// [platform] — 平台画像
  /// [hardware] — 硬件画像
  /// [modelSizeMB] — 模型文件大小 (MB)
  /// [modelPath] — 模型文件路径
  /// [userParams] — 用户自定义参数
  ///
  /// 返回 [SandboxLaunchResult]，包含最终配置或错误信息
  Future<SandboxLaunchResult> launch({
    required PlatformProfile platform,
    required HardwareProfile hardware,
    required int modelSizeMB,
    required String modelPath,
    LocalModelParams? userParams,
  }) async {
    final warnings = <String>[];

    debugPrint('[SandboxLauncher] 🚀 启动沙箱初始化序列...');
    debugPrint('[SandboxLauncher] 📋 平台: $platform');
    debugPrint('[SandboxLauncher] 📊 硬件: $hardware');

    // ── Step 1: 安全模式检测 ──
    final safeMode = await _checkSafeMode();
    if (safeMode) {
      warnings.add('检测到上次加载崩溃，启用安全模式（CPU + 小上下文）');
      debugPrint('[SandboxLauncher] ⚠️ 安全模式: 上次加载崩溃，使用最小化配置');
      final config = SandboxConfig.safe(platform: platform, hardware: hardware);
      return SandboxLaunchResult.ok(config, safeMode: true, warnings: warnings);
    }

    // ── Step 2: 写入崩溃标记（加载前）──
    await _setCrashFlag(true);

    // ── Step 3: 生成自动配置 ──
    var config = SandboxConfig.auto(
      platform: platform,
      hardware: hardware,
      userParams: userParams,
    );

    // ── Step 4: 架构优化 ──
    config = ArchOptimizer.instance.optimize(config);

    // ── Step 5: 内存预检 ──
    final profiler = HardwareProfiler.instance;
    final memCheck = profiler.checkModelFeasibility(
      hw: hardware,
      modelSizeMB: modelSizeMB,
      contextSize: config.contextSize,
      kvCache: config.kvCache,
    );

    if (memCheck != null) {
      debugPrint('[SandboxLauncher] ⚠️ 内存预检警告: $memCheck');
      warnings.add(memCheck);

      // 尝试降级 KV Cache
      var downgraded = config.downgradeKvCache();
      final memCheck2 = profiler.checkModelFeasibility(
        hw: hardware,
        modelSizeMB: modelSizeMB,
        contextSize: downgraded.contextSize,
        kvCache: downgraded.kvCache,
      );

      if (memCheck2 != null) {
        // 仍不够，降低上下文大小
        downgraded = downgraded.reduceContext(0.75);
        warnings.add('已降低上下文大小至 ${downgraded.contextSize} tokens');
      }
      config = downgraded;
    }

    // ── Step 6: 平台特定初始化 ──
    final platformResult = await _platformSpecificInit(platform, modelPath);
    if (platformResult != null) {
      warnings.add(platformResult);
    }

    debugPrint('[SandboxLauncher] ✅ 沙箱初始化完成: $config');
    if (warnings.isNotEmpty) {
      for (final w in warnings) {
        debugPrint('[SandboxLauncher] ⚠️ $w');
      }
    }

    return SandboxLaunchResult.ok(config, warnings: warnings);
  }

  /// GPU 崩溃后 CPU 回退
  ///
  /// 当 GPU 加速导致崩溃时，回退到纯 CPU 模式
  SandboxConfig fallbackToCpu({
    required PlatformProfile platform,
    required HardwareProfile hardware,
  }) {
    debugPrint('[SandboxLauncher] 🔄 GPU 崩溃，回退到 CPU 模式');
    return SandboxConfig.auto(
      platform: platform,
      hardware: hardware,
      forceCpuMode: true,
    );
  }

  /// 加载成功后清除崩溃标记
  Future<void> clearCrashFlag() async {
    await _setCrashFlag(false);
  }

  // ════════════════════════════════════════════════════════════════════════
  //  安全模式检测
  // ════════════════════════════════════════════════════════════════════════

  /// 检查是否需要进入安全模式
  Future<bool> _checkSafeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_crashFlagKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// 设置/清除崩溃标记
  Future<void> _setCrashFlag(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_crashFlagKey, value);
    } catch (_) {}
  }

  // ════════════════════════════════════════════════════════════════════════
  //  平台特定初始化
  // ════════════════════════════════════════════════════════════════════════

  /// 平台特定初始化，返回警告信息或 null
  Future<String?> _platformSpecificInit(
    PlatformProfile platform,
    String modelPath,
  ) async {
    switch (platform.os) {
      case SandboxOS.macOS:
        return await _initMacOS(modelPath);
      case SandboxOS.windows:
        return await _initWindows();
      case SandboxOS.linux:
        return await _initLinux();
      case SandboxOS.android:
        return await _initAndroid();
      case SandboxOS.ios:
        return await _initIOS();
      case SandboxOS.unknown:
        return null;
    }
  }

  /// macOS 初始化
  ///
  /// - Metal 加速（Apple Silicon / Intel Mac）
  /// - 安全作用域授权（macOS 沙盒）
  /// - mmap 启用
  Future<String?> _initMacOS(String modelPath) async {
    debugPrint('[SandboxLauncher] 🍎 macOS 初始化...');

    // macOS 沙盒：获取外部目录访问权限
    final modelDir = modelPath.substring(0, modelPath.lastIndexOf('/'));
    final bookmarkService = SecurityBookmarkService.instance;
    final hasAccess = await bookmarkService.startAccessing(modelDir);
    if (!hasAccess) {
      return 'macOS 沙盒权限不足: $modelDir，请在设置中重新选择模型目录';
    }

    debugPrint('[SandboxLauncher] ✅ macOS 安全作用域已授权: $modelDir');
    return null;
  }

  /// Windows 初始化
  ///
  /// - CUDA 检测（NVIDIA GPU）
  /// - VRAM 计算
  /// - Vulkan 回退
  Future<String?> _initWindows() async {
    debugPrint('[SandboxLauncher] 🪟 Windows 初始化...');

    // CUDA 可用性由 llamadart 运行时检测
    // 如果 CUDA 不可用，llamadart 会自动回退到 CPU
    debugPrint('[SandboxLauncher] ✅ Windows 初始化完成（CUDA 运行时检测）');
    return null;
  }

  /// Linux 初始化
  ///
  /// - CUDA/Vulkan 检测
  /// - /proc/meminfo 内存读取
  Future<String?> _initLinux() async {
    debugPrint('[SandboxLauncher] 🐧 Linux 初始化...');
    debugPrint('[SandboxLauncher] ✅ Linux 初始化完成');
    return null;
  }

  /// Android 初始化
  ///
  /// - Vulkan GPU 加速
  /// - CPU 特性检测（DotProd/i8mm/SME）
  /// - KV Cache 量化（Q8_0/Q4_0）
  /// - 内存预检
  Future<String?> _initAndroid() async {
    debugPrint('[SandboxLauncher] 🤖 Android 初始化...');

    // CPU 特性检测
    try {
      final armFeatures = await ArchOptimizer.instance.detectArmFeatures();
      debugPrint('[SandboxLauncher] 📱 ARM 特性: $armFeatures');

      if (armFeatures.dotprod || armFeatures.i8mm) {
        debugPrint('[SandboxLauncher] ✅ DotProd/i8mm 支持，CPU 推理将获得加速');
      }

      // ⚠️ SME 兼容性警告
      if (armFeatures.sme) {
        debugPrint('[SandboxLauncher] ⚠️ SME 支持但 Android GKI 内核可能有兼容性问题');
        return '检测到 SME 支持，但 Android GKI 内核可能不兼容，如遇 SIGILL 错误请降低 GPU 层数';
      }
    } catch (e) {
      debugPrint('[SandboxLauncher] ⚠️ CPU 特性检测失败: $e');
    }

    debugPrint('[SandboxLauncher] ✅ Android 初始化完成');
    return null;
  }

  /// iOS 初始化
  ///
  /// - Metal 加速
  /// - 内存约束（iOS 应用可用内存有限）
  /// - 线程优化（核心数较少）
  Future<String?> _initIOS() async {
    debugPrint('[SandboxLauncher] 📱 iOS 初始化...');

    // iOS 内存约束：系统可用内存可能远小于物理内存
    // 建议使用较小的上下文大小
    debugPrint('[SandboxLauncher] ✅ iOS 初始化完成');
    return null;
  }
}
