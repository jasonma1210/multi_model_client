import 'dart:io';
import 'package:flutter/foundation.dart';
import '../hardware/device_env.dart';

/// CUDA加速器（Windows）
class CudaAccelerator {
  final DeviceEnv deviceEnv;
  bool _isInitialized = false;
  bool _isAvailable = false;

  CudaAccelerator(this.deviceEnv);

  /// 是否可用
  bool get isAvailable => _isAvailable && deviceEnv.isCudaAvailable;

  /// 初始化
  Future<bool> initialize() async {
    if (!Platform.isWindows) {
      debugPrint('CUDA is only available on Windows');
      return false;
    }

    if (!deviceEnv.isCudaAvailable) {
      debugPrint('CUDA is not available on this device');
      return false;
    }

    try {
      // 检查CUDA设备
      _isAvailable = await _checkCudaDevice();
      _isInitialized = true;

      if (_isAvailable) {
        debugPrint('CUDA accelerator initialized successfully');
        debugPrint('GPU: ${deviceEnv.gpuName}');
        debugPrint('VRAM: ${deviceEnv.gpuMemoryMB} MB');
        debugPrint('CUDA Version: ${deviceEnv.cudaVersion}');
        debugPrint('Device Count: ${deviceEnv.cudaDeviceCount}');
      }

      return _isAvailable;
    } catch (e) {
      debugPrint('Failed to initialize CUDA: $e');
      return false;
    }
  }

  /// 检查CUDA设备
  Future<bool> _checkCudaDevice() async {
    // 在实际实现中，这里应该通过FFI调用CUDA Runtime API
    // 或者通过MethodChannel调用原生C++代码
    return deviceEnv.isCudaAvailable;
  }

  /// 计算最优GPU层数
  int calculateOptimalGpuLayers({
    required int modelTotalLayers,
    required double modelParamsGB,
    required String quantLevel,
  }) {
    if (!isAvailable) return 0;

    final gpuMemoryMB = deviceEnv.gpuMemoryMB ?? 0;
    if (gpuMemoryMB == 0) return 0;

    // 量化系数映射
    final Map<String, double> quantCoefficient = {
      'Q2_K': 0.25,
      'Q3_K_L': 0.3,
      'Q4_K_M': 0.4,
      'Q5_K_M': 0.5,
      'Q8_0': 0.8,
      'FP16': 1.0,
    };

    // 计算每层所需显存
    final coef = quantCoefficient[quantLevel] ?? 0.4;
    final layerMemMB = (modelParamsGB / modelTotalLayers) * 1024 * coef;

    // 预留20%显存作为缓冲
    final availableMemMB = (gpuMemoryMB * 0.8).toInt();
    final maxLayers = (availableMemMB / layerMemMB).floor();

    return maxLayers.clamp(0, modelTotalLayers);
  }

  /// 获取推荐的批处理大小
  int getRecommendedBatchSize() {
    if (!isAvailable) return 512;

    final gpuMemGB = (deviceEnv.gpuMemoryMB ?? 0) / 1024;

    if (gpuMemGB >= 24) {
      return 1024;
    } else if (gpuMemGB >= 12) {
      return 512;
    } else if (gpuMemGB >= 8) {
      return 256;
    } else {
      return 128;
    }
  }

  /// 获取CUDA设备信息
  Map<String, dynamic> getDeviceInfo() {
    return {
      'available': isAvailable,
      'gpuName': deviceEnv.gpuName,
      'vram': deviceEnv.gpuMemoryMB,
      'cudaVersion': deviceEnv.cudaVersion,
      'deviceCount': deviceEnv.cudaDeviceCount,
      'recommendedBatchSize': getRecommendedBatchSize(),
    };
  }

  /// 检查多GPU配置
  bool hasMultiGpu() {
    return deviceEnv.cudaDeviceCount > 1;
  }

  /// 获取推荐的GPU ID（用于多GPU场景）
  int getRecommendedGpuId() {
    // 默认使用第一个GPU
    // 在多GPU场景下，可以选择显存最大的GPU
    return 0;
  }
}
