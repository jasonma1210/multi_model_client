import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mj_nexus/core/platform/platform_utils.dart';
import 'device_env.dart';
import '../models/device_capabilities.dart';

/// 硬件检测服务
class HardwareDetector {
  static const MethodChannel _channel = MethodChannel('com.example.ai_assistant/hardware');
  static const String _tag = 'HardwareDetector';

  /// 获取设备环境信息
  Future<DeviceEnv> getDeviceEnv() async {
    try {
      if (PlatformUtils.isMacOS || PlatformUtils.isIOS || PlatformUtils.isWindows || PlatformUtils.isAndroid) {
        final Map<dynamic, dynamic> result = await _channel.invokeMethod('getDeviceEnv');
        return DeviceEnv.fromJson(Map<String, dynamic>.from(result));
      } else {
        // Linux等其他平台
        return _getLinuxDeviceEnv();
      }
    } catch (e) {
      debugPrint('[$_tag] 获取设备环境失败: $e');
      // 返回默认值
      return DeviceEnv(
        cpuArch: 'unknown',
        cpuCores: 1,
        totalMemoryMB: 4096,
      );
    }
  }

  /// 获取设备能力
  Future<DeviceCapabilities> getDeviceCapabilities() async {
    final env = await getDeviceEnv();
    return DeviceCapabilities.fromDeviceEnv(env);
  }

  /// 检查Metal可用性（macOS/iOS）
  Future<bool> checkMetalAvailability() async {
    if (!PlatformUtils.isMacOS && !PlatformUtils.isIOS) {
      return false;
    }

    try {
      final bool isAvailable = await _channel.invokeMethod('checkMetalAvailability');
      return isAvailable;
    } catch (e) {
      debugPrint('[$_tag] 检查 Metal 可用性失败: $e');
      return false;
    }
  }

  /// 检查CUDA可用性（Windows）
  Future<bool> checkCudaAvailability() async {
    if (!PlatformUtils.isWindows) {
      return false;
    }

    try {
      final bool isAvailable = await _channel.invokeMethod('checkCudaAvailability');
      return isAvailable;
    } catch (e) {
      debugPrint('[$_tag] 检查 CUDA 可用性失败: $e');
      return false;
    }
  }

  /// 获取GPU信息
  Future<Map<String, dynamic>> getGpuInfo() async {
    try {
      if (PlatformUtils.isMacOS || PlatformUtils.isIOS || PlatformUtils.isWindows) {
        final Map<dynamic, dynamic> result = await _channel.invokeMethod('getGpuInfo');
        return Map<String, dynamic>.from(result);
      }
      return {};
    } catch (e) {
      debugPrint('[$_tag] 获取 GPU 信息失败: $e');
      return {};
    }
  }

  /// Android设备环境
  DeviceEnv _getAndroidDeviceEnv() {
    // Android使用Platform类获取基础信息
    final cores = Platform.numberOfProcessors;

    // 简化版：无法直接获取内存大小，使用估算
    // 实际应用中应该通过MethodChannel调用原生API获取准确信息
    return DeviceEnv(
      cpuArch: _getAndroidArch(),
      cpuCores: cores,
      totalMemoryMB: 4096, // 默认4GB
      isMetalAvailable: false,
      isCudaAvailable: false,
    );
  }

  /// Linux设备环境
  DeviceEnv _getLinuxDeviceEnv() {
    final cores = Platform.numberOfProcessors;

    return DeviceEnv(
      cpuArch: _getLinuxArch(),
      cpuCores: cores,
      totalMemoryMB: 8192, // 默认8GB
      isMetalAvailable: false,
      isCudaAvailable: false, // 可通过nvidia-smi检测
    );
  }

  /// 获取Android CPU架构
  String _getAndroidArch() {
    // dart:io无法直接获取Android ABI，需要通过MethodChannel
    // 这里返回默认值
    return 'arm64';
  }

  /// 获取Linux CPU架构
  String _getLinuxArch() {
    // 从环境变量或uname获取
    return Platform.version.contains('x86_64') ? 'x86_64' : 'arm64';
  }

  /// 检查设备是否满足模型要求
  Future<bool> checkModelRequirements({
    required int minRamMB,
    required int minStorageMB,
    List<String>? requiredFeatures,
  }) async {
    final env = await getDeviceEnv();

    // 检查内存
    if (env.totalMemoryMB < minRamMB) {
      return false;
    }

    // 检查特性要求
    if (requiredFeatures != null) {
      for (final feature in requiredFeatures) {
        switch (feature.toLowerCase()) {
          case 'metal':
            if (!env.isMetalAvailable) return false;
            break;
          case 'cuda':
            if (!env.isCudaAvailable) return false;
            break;
          case 'gpu':
            if (!env.supportsGpuAcceleration) return false;
            break;
        }
      }
    }

    return true;
  }
}
