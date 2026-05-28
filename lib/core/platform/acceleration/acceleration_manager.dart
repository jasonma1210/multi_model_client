import 'package:flutter/foundation.dart';
import 'package:mj_nexus/core/platform/platform_utils.dart';
import '../hardware/device_env.dart';
import '../models/device_capabilities.dart';
import 'metal_accelerator.dart';
import 'cuda_accelerator.dart';

/// 加速管理器
class AccelerationManager {
  final DeviceEnv deviceEnv;
  final DeviceCapabilities capabilities;

  MetalAccelerator? _metalAccelerator;
  CudaAccelerator? _cudaAccelerator;

  bool _isInitialized = false;

  AccelerationManager({
    required this.deviceEnv,
    required this.capabilities,
  });

  /// 是否已初始化
  bool get isInitialized => _isInitialized;

  /// 获取Metal加速器
  MetalAccelerator? get metalAccelerator => _metalAccelerator;

  /// 获取CUDA加速器
  CudaAccelerator? get cudaAccelerator => _cudaAccelerator;

  /// 初始化加速器
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('AccelerationManager already initialized');
      return;
    }

    debugPrint('Initializing AccelerationManager...');
    debugPrint('Preferred acceleration: ${capabilities.preferredAcceleration}');

    // 根据平台和能力初始化对应的加速器
    if (deviceEnv.isMetalAvailable) {
      await _initializeMetal();
    }

    if (deviceEnv.isCudaAvailable) {
      await _initializeCuda();
    }

    _isInitialized = true;

    debugPrint('AccelerationManager initialized');
    debugPrint('Metal available: ${_metalAccelerator?.isAvailable ?? false}');
    debugPrint('CUDA available: ${_cudaAccelerator?.isAvailable ?? false}');
  }

  /// 初始化Metal加速器
  Future<void> _initializeMetal() async {
    if (!PlatformUtils.isMacOS && !PlatformUtils.isIOS) {
      return;
    }

    _metalAccelerator = MetalAccelerator(deviceEnv);
    await _metalAccelerator!.initialize();
  }

  /// 初始化CUDA加速器
  Future<void> _initializeCuda() async {
    if (!PlatformUtils.isWindows) {
      return;
    }

    _cudaAccelerator = CudaAccelerator(deviceEnv);
    await _cudaAccelerator!.initialize();
  }

  /// 获取推荐的GPU层数
  int getRecommendedGpuLayers({
    required int modelTotalLayers,
    required double modelParamsGB,
    required String quantLevel,
  }) {
    if (_metalAccelerator?.isAvailable == true) {
      return _metalAccelerator!.getRecommendedGpuLayers(modelTotalLayers);
    }

    if (_cudaAccelerator?.isAvailable == true) {
      return _cudaAccelerator!.calculateOptimalGpuLayers(
        modelTotalLayers: modelTotalLayers,
        modelParamsGB: modelParamsGB,
        quantLevel: quantLevel,
      );
    }

    // CPU模式：不使用GPU层
    return 0;
  }

  /// 获取推荐的批处理大小
  int getRecommendedBatchSize() {
    if (_metalAccelerator?.isAvailable == true) {
      return _metalAccelerator!.getRecommendedBatchSize();
    }

    if (_cudaAccelerator?.isAvailable == true) {
      return _cudaAccelerator!.getRecommendedBatchSize();
    }

    // CPU模式：基于CPU核心数
    return deviceEnv.cpuCores >= 8 ? 512 : 256;
  }

  /// 获取当前加速类型
  AccelerationType get currentAccelerationType {
    if (_metalAccelerator?.isAvailable == true) {
      return AccelerationType.metal;
    }

    if (_cudaAccelerator?.isAvailable == true) {
      return AccelerationType.cuda;
    }

    return AccelerationType.cpu;
  }

  /// 是否支持GPU加速
  bool get supportsGpuAcceleration {
    return _metalAccelerator?.isAvailable == true ||
           _cudaAccelerator?.isAvailable == true;
  }

  /// 获取加速器信息
  Map<String, dynamic> getAcceleratorInfo() {
    return {
      'accelerationType': currentAccelerationType.name,
      'metal': _metalAccelerator?.getDeviceInfo(),
      'cuda': _cudaAccelerator?.getDeviceInfo(),
      'recommendedBatchSize': getRecommendedBatchSize(),
    };
  }

  /// 释放资源
  void dispose() {
    _metalAccelerator = null;
    _cudaAccelerator = null;
    _isInitialized = false;
  }
}
