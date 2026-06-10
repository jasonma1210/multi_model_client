import 'dart:io';

import '../hardware/device_env.dart';

/// 设备加速能力
enum AccelerationType {
  cpu,    // 纯CPU推理
  metal,  // Metal加速（macOS/iOS）
  cuda,   // CUDA加速（Windows）
  opencl, // OpenCL加速（备用）
}

/// 设备能力信息
class DeviceCapabilities {
  final AccelerationType preferredAcceleration;
  final int maxContextSize;         // 最大上下文窗口
  final int recommendedBatchSize;    // 推荐批处理大小
  final bool supportsQuantization;   // 支持量化
  final List<String> supportedQuantLevels; // 支持的量化级别

  const DeviceCapabilities({
    required this.preferredAcceleration,
    required this.maxContextSize,
    required this.recommendedBatchSize,
    this.supportsQuantization = true,
    this.supportedQuantLevels = const [
      'Q2_K',
      'Q3_K_L',
      'Q4_K_M',
      'Q5_K_M',
      'Q8_0',
      'FP16',
    ],
  });

  /// 根据设备环境推断能力
  factory DeviceCapabilities.fromDeviceEnv(DeviceEnv env) {
    // 确定最佳加速类型
    AccelerationType acceleration = AccelerationType.cpu;
    if (env.isMetalAvailable) {
      acceleration = AccelerationType.metal;
    } else if (env.isCudaAvailable) {
      acceleration = AccelerationType.cuda;
    }

    // 根据内存计算最大上下文窗口
    int maxContext = 2048;
    final availableGB = env.availableMemoryMB / 1024;

    if (availableGB >= 32) {
      maxContext = 32768;
    } else if (availableGB >= 16) {
      maxContext = 16384;
    } else if (availableGB >= 8) {
      maxContext = 8192;
    } else if (availableGB >= 4) {
      maxContext = 4096;
    }

    // 推荐批处理大小
    // ★ 移动端优化：大 batch 会导致首字延迟 1 分钟！
    // 骁龙 8 Elite 等移动端 GPU 内存带宽不足，batchSize=512 会导致 Prefill 极慢
    // 移动端统一使用 128，桌面端保持 512
    int batchSize;
    if (Platform.isAndroid || Platform.isIOS) {
      batchSize = 128; // ★ 移动端固定 128，避免首字延迟
    } else if (env.supportsGpuAcceleration) {
      batchSize = env.gpuMemoryMB != null && env.gpuMemoryMB! > 8192 ? 1024 : 512;
    } else {
      batchSize = env.cpuCores >= 8 ? 512 : 256;
    }

    return DeviceCapabilities(
      preferredAcceleration: acceleration,
      maxContextSize: maxContext,
      recommendedBatchSize: batchSize,
    );
  }

  /// 是否支持指定加速类型
  bool supportsAcceleration(AccelerationType type) {
    return preferredAcceleration == type ||
           (type == AccelerationType.cpu); // CPU是兜底方案
  }

  @override
  String toString() {
    return 'DeviceCapabilities(acceleration: $preferredAcceleration, '
        'maxCtx: $maxContextSize, batchSize: $recommendedBatchSize)';
  }
}
