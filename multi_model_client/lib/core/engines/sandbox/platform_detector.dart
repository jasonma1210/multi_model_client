/// 平台环境自动检测模块
///
/// 职责：
/// - 检测操作系统、CPU 架构、GPU 后端
/// - 生成 PlatformProfile（平台画像），供后续模块决策
/// - 缓存检测结果，避免重复系统调用
///
/// @author JianMa
/// @version 1.0.0
library;

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:llamadart/llamadart.dart';

// ════════════════════════════════════════════════════════════════════════
//  数据模型
// ════════════════════════════════════════════════════════════════════════

/// 操作系统枚举
enum SandboxOS {
  macOS,
  windows,
  linux,
  android,
  ios,
  unknown,
}

/// CPU 架构枚举
enum CpuArch {
  /// Apple Silicon (M1/M2/M3/M4) — ARM64 + 统一内存
  arm64,

  /// x86_64 (Intel/AMD) — 传统 PC
  x86_64,

  /// ARMv7 (32-bit, 老旧 Android)
  armv7,

  /// 未知架构
  unknown,
}

/// GPU 加速后端（与 llamadart GpuBackend 对齐）
enum SandboxGpuBackend {
  /// Apple Metal (macOS/iOS) — 统一内存架构
  metal,

  /// NVIDIA CUDA (Windows/Linux) — 独立显存
  cuda,

  /// Vulkan (Android/跨平台) — 通用 GPU
  vulkan,

  /// 纯 CPU 推理
  cpu,
}

/// 平台画像 — 描述当前运行环境的完整特征
///
/// 由 [PlatformDetector] 生成，作为沙箱初始化的输入
class PlatformProfile {
  /// 操作系统
  final SandboxOS os;

  /// CPU 架构
  final CpuArch cpuArch;

  /// 首选 GPU 后端
  final SandboxGpuBackend primaryGpuBackend;

  /// 备选 GPU 后端（主后端不可用时回退）
  final SandboxGpuBackend? fallbackGpuBackend;

  /// 是否为移动端（Android/iOS）
  final bool isMobile;

  /// 是否为桌面端（macOS/Windows/Linux）
  final bool isDesktop;

  /// 是否为 Apple 平台（macOS/iOS）
  final bool isApple;

  /// 是否为统一内存架构（Apple Silicon）
  final bool isUnifiedMemory;

  /// 是否为独立显存架构（NVIDIA CUDA）
  final bool isDiscreteVram;

  /// 是否支持 mmap（iOS 沙盒下性能差）
  final bool supportsMmap;

  /// 是否支持 mlock（移动端禁止）
  final bool supportsMlock;

  /// CPU 核心数
  final int cpuCores;

  /// 设备型号（如 "MacBook Pro (M3 Max)"、"Pixel 8 Pro"）
  final String? deviceModel;

  /// 操作系统版本
  final String? osVersion;

  const PlatformProfile({
    required this.os,
    required this.cpuArch,
    required this.primaryGpuBackend,
    this.fallbackGpuBackend,
    required this.isMobile,
    required this.isDesktop,
    required this.isApple,
    required this.isUnifiedMemory,
    required this.isDiscreteVram,
    required this.supportsMmap,
    required this.supportsMlock,
    required this.cpuCores,
    this.deviceModel,
    this.osVersion,
  });

  /// 转换为 llamadart 的 GpuBackend
  ///
  /// ★ 基于 llamadart 后端选择指南：
  ///   Apple 平台: GpuBackend.metal（consolidated runtime，自动使用 Metal）
  ///   Windows/Linux: GpuBackend.auto（llamadart 自动检测 CUDA/Vulkan）
  ///   Android: GpuBackend.auto（llamadart 默认 CPU，Vulkan opt-in via pubspec.yaml）
  ///   未知: GpuBackend.auto
  GpuBackend toLlamadartGpuBackend() {
    if (isApple) return GpuBackend.metal;
    return GpuBackend.auto;
  }

  @override
  String toString() => 'PlatformProfile('
      'os=$os, arch=$cpuArch, gpu=$primaryGpuBackend, '
      'cores=$cpuCores, mobile=$isMobile, unified=$isUnifiedMemory)';
}

// ════════════════════════════════════════════════════════════════════════
//  平台检测器
// ════════════════════════════════════════════════════════════════════════

/// 平台环境自动检测器
///
/// 自动检测当前运行环境的操作系统、CPU 架构、GPU 后端等，
/// 生成 [PlatformProfile] 供沙箱初始化决策使用。
///
/// ★ 设计原则：
/// - 单例 + 缓存：检测结果在进程生命周期内不变
/// - 零依赖：不依赖 Flutter 插件或 MethodChannel
/// - 快速：所有检测均为同步操作（读取 Platform 静态属性）
class PlatformDetector {
  PlatformDetector._();
  static final PlatformDetector instance = PlatformDetector._();

  /// 缓存的平台画像
  PlatformProfile? _cachedProfile;

  /// 获取平台画像（带缓存）
  PlatformProfile detect() {
    if (_cachedProfile != null) return _cachedProfile!;
    _cachedProfile = _doDetect();
    debugPrint('[PlatformDetector] 🔍 平台检测完成: $_cachedProfile');
    return _cachedProfile!;
  }

  /// 强制重新检测（用于测试或热更新后）
  PlatformProfile redetect() {
    _cachedProfile = null;
    return detect();
  }

  /// 核心检测逻辑
  PlatformProfile _doDetect() {
    // ── 1. 操作系统 ──
    final SandboxOS os;
    if (Platform.isMacOS) {
      os = SandboxOS.macOS;
    } else if (Platform.isWindows) {
      os = SandboxOS.windows;
    } else if (Platform.isLinux) {
      os = SandboxOS.linux;
    } else if (Platform.isAndroid) {
      os = SandboxOS.android;
    } else if (Platform.isIOS) {
      os = SandboxOS.ios;
    } else {
      os = SandboxOS.unknown;
    }

    // ── 2. CPU 架构 ──
    final CpuArch cpuArch = _detectCpuArch();

    // ── 3. GPU 后端 ──
    final (SandboxGpuBackend primary, SandboxGpuBackend? fallback) =
        _detectGpuBackend(os, cpuArch);

    // ── 4. 平台特征 ──
    final isMobile = os == SandboxOS.android || os == SandboxOS.ios;
    final isDesktop = os == SandboxOS.macOS ||
        os == SandboxOS.windows ||
        os == SandboxOS.linux;
    final isApple = os == SandboxOS.macOS || os == SandboxOS.ios;

    // Apple Silicon = 统一内存架构（CPU/GPU 共享内存）
    final isUnifiedMemory = isApple && cpuArch == CpuArch.arm64;
    // CUDA = 独立显存架构
    final isDiscreteVram = primary == SandboxGpuBackend.cuda;

    // ── 5. 平台特性 ──
    final supportsMmap = os != SandboxOS.ios; // iOS 沙盒下 mmap 性能差
    final supportsMlock = isDesktop && !isMobile; // 移动端禁止 mlock

    return PlatformProfile(
      os: os,
      cpuArch: cpuArch,
      primaryGpuBackend: primary,
      fallbackGpuBackend: fallback,
      isMobile: isMobile,
      isDesktop: isDesktop,
      isApple: isApple,
      isUnifiedMemory: isUnifiedMemory,
      isDiscreteVram: isDiscreteVram,
      supportsMmap: supportsMmap,
      supportsMlock: supportsMlock,
      cpuCores: Platform.numberOfProcessors,
      osVersion: _getOsVersion(),
    );
  }

  /// 检测 CPU 架构
  CpuArch _detectCpuArch() {
    // Dart 的 Platform 没有直接的架构 API，通过路径和平台推断
    if (Platform.isMacOS || Platform.isIOS) {
      // Apple Silicon 检测：通过 sysctl 或路径推断
      // macOS: /usr/bin/sysctl -n hw.optional.arm64
      // 简化：macOS 2020+ 的 Apple Silicon 设备都是 arm64
      // iOS: 所有现代 iOS 设备都是 arm64
      return CpuArch.arm64;
    }

    if (Platform.isAndroid) {
      // Android: 通过 /proc/cpuinfo 或 Build.SUPPORTED_ABIS 推断
      // 现代安卓设备（arm64-v8a）都是 ARM64
      // 老旧设备（armeabi-v7a）是 ARMv7
      try {
        final cpuInfo = File('/proc/cpuinfo').readAsStringSync();
        if (cpuInfo.contains('ARMv7') || cpuInfo.contains('armv7')) {
          return CpuArch.armv7;
        }
      } catch (_) {}
      return CpuArch.arm64; // 默认 ARM64
    }

    if (Platform.isWindows || Platform.isLinux) {
      // Windows/Linux: 通过环境变量推断
      final procArch = Platform.environment['PROCESSOR_ARCHITECTURE'] ?? '';
      final hostType = Platform.environment['HOSTTYPE'] ?? '';
      if (procArch.contains('AMD64') ||
          procArch.contains('x86') ||
          hostType.contains('x86_64')) {
        return CpuArch.x86_64;
      }
      if (hostType.contains('aarch64') || hostType.contains('arm64')) {
        return CpuArch.arm64;
      }
      // 默认 x86_64（PC 主流架构）
      return CpuArch.x86_64;
    }

    return CpuArch.unknown;
  }

  /// 检测 GPU 后端
  ///
  /// 返回 (首选后端, 备选后端)
  (SandboxGpuBackend, SandboxGpuBackend?) _detectGpuBackend(
    SandboxOS os,
    CpuArch cpuArch,
  ) {
    switch (os) {
      case SandboxOS.macOS:
        // macOS: Metal (Apple Silicon/Intel Mac 均支持)
        // Intel Mac 无 Metal GPU 时回退 CPU
        return (SandboxGpuBackend.metal, SandboxGpuBackend.cpu);

      case SandboxOS.ios:
        // iOS: Metal（所有现代 iOS 设备）
        return (SandboxGpuBackend.metal, SandboxGpuBackend.cpu);

      case SandboxOS.windows:
        // Windows: CUDA 优先（NVIDIA GPU），Vulkan 回退
        // ★ 注意：实际 CUDA 可用性需要运行时检测
        return (SandboxGpuBackend.cuda, SandboxGpuBackend.vulkan);

      case SandboxOS.linux:
        // Linux: CUDA 优先（服务器/工作站），Vulkan 回退
        return (SandboxGpuBackend.cuda, SandboxGpuBackend.vulkan);

      case SandboxOS.android:
        // Android: Vulkan 优先（通用 GPU），CPU 回退
        // ★ NPU (QNN) 通过 CpuFeatureDetector 单独检测
        return (SandboxGpuBackend.vulkan, SandboxGpuBackend.cpu);

      case SandboxOS.unknown:
        return (SandboxGpuBackend.cpu, null);
    }
  }

  /// 获取操作系统版本字符串
  String? _getOsVersion() {
    try {
      if (Platform.isMacOS || Platform.isIOS) {
        // macOS/iOS: 通过 sw_vers 或 uname 获取
        // 简化：使用 Platform 操作系统版本
        return Platform.operatingSystemVersion;
      }
      return Platform.operatingSystemVersion;
    } catch (_) {
      return null;
    }
  }
}
