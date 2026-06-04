import 'package:flutter/foundation.dart';
import 'package:mj_nexus/core/platform/platform_utils.dart';
import '../hardware/device_env.dart';

/// Metal加速器（macOS/iOS）
class MetalAccelerator {
  final DeviceEnv deviceEnv;
  bool _isAvailable = false;

  MetalAccelerator(this.deviceEnv);

  /// 是否可用
  bool get isAvailable => _isAvailable && deviceEnv.isMetalAvailable;

  /// 初始化
  Future<bool> initialize() async {
    if (!PlatformUtils.isMacOS && !PlatformUtils.isIOS) {
      debugPrint('Metal is only available on macOS and iOS');
      return false;
    }

    if (!deviceEnv.isMetalAvailable) {
      debugPrint('Metal is not available on this device');
      return false;
    }

    try {
      // 检查Metal设备
      _isAvailable = await _checkMetalDevice();

      if (_isAvailable) {
        debugPrint('Metal accelerator initialized successfully');
        debugPrint('GPU: ${deviceEnv.gpuName}');
        debugPrint('Unified Memory: ${deviceEnv.gpuMemoryMB} MB');
      }

      return _isAvailable;
    } catch (e) {
      debugPrint('Failed to initialize Metal: $e');
      return false;
    }
  }

  /// 检查Metal设备
  Future<bool> _checkMetalDevice() async {
    // 在实际实现中，这里应该通过FFI调用Metal API
    // 或者通过MethodChannel调用原生Swift代码
    return deviceEnv.isMetalAvailable;
  }

  /// 获取推荐的GPU层数
  int getRecommendedGpuLayers(int modelTotalLayers) {
    if (!isAvailable) return 0;

    // Metal统一内存架构：建议全量offload
    // 因为不需要在CPU和GPU之间拷贝数据
    return modelTotalLayers;
  }

  /// 获取推荐的批处理大小
  int getRecommendedBatchSize() {
    if (!isAvailable) return 512;

    final gpuMemGB = (deviceEnv.gpuMemoryMB ?? 0) / 1024;

    if (gpuMemGB >= 16) {
      return 1024;
    } else if (gpuMemGB >= 8) {
      return 512;
    } else {
      return 256;
    }
  }

  /// 获取Metal设备信息
  Map<String, dynamic> getDeviceInfo() {
    return {
      'available': isAvailable,
      'gpuName': deviceEnv.gpuName,
      'unifiedMemory': deviceEnv.gpuMemoryMB,
      'recommendedBatchSize': getRecommendedBatchSize(),
    };
  }
}
