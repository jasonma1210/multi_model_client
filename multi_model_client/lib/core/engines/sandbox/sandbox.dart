/// 沙箱架构统一导出入口
///
/// 使用方式：
/// ```dart
/// import 'package:mj_nexus/core/engines/sandbox/sandbox.dart';
/// ```
///
/// 核心类：
/// - [LlamaCppSandbox] — 跨平台统一接口（顶层入口）
/// - [PlatformDetector] — 平台环境自动检测
/// - [HardwareProfiler] — 硬件资源评估
/// - [SandboxLauncher] — 差异化初始化流程
/// - [SandboxConfig] — 沙箱配置
/// - [ArchOptimizer] — 架构差异化性能优化
///
/// 数据模型：
/// - [PlatformProfile] — 平台画像
/// - [HardwareProfile] — 硬件画像
/// - [SandboxStatus] — 沙箱状态
/// - [SandboxLaunchResult] — 启动结果
///
/// @author JianMa
/// @version 1.0.0
library;

// 核心模块
export 'platform_detector.dart';
export 'hardware_profiler.dart';
export 'sandbox_config.dart';
export 'sandbox_launcher.dart';
export 'arch_optimizer.dart';
export 'llama_cpp_sandbox.dart';
