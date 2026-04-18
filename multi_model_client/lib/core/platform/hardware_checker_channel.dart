import 'package:flutter/services.dart';

/// 硬件检查器平台通道
class HardwareCheckerPlatformChannel {
  static const MethodChannel _channel = MethodChannel('hardware_checker');

  /// 初始化平台通道
  static void initialize() {
    _channel.setMethodCallHandler((call) async {
      // 处理来自原生平台的回调（如果需要）
      switch (call.method) {
        default:
          throw MissingPluginException('Not implemented: ${call.method}');
      }
    });
  }

  /// 获取硬件信息
  static Future<Map<String, dynamic>> getHardwareInfo() async {
    try {
      final result = await _channel.invokeMethod('getHardwareInfo');
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      throw Exception('Failed to get hardware info: ${e.message}');
    }
  }

  /// 检查特定硬件特性
  static Future<bool> checkFeature(String feature) async {
    try {
      final result = await _channel.invokeMethod('checkFeature', {'feature': feature});
      return result as bool;
    } on PlatformException catch (e) {
      throw Exception('Failed to check feature: ${e.message}');
    }
  }

  /// 获取可用内存
  static Future<int> getAvailableMemory() async {
    try {
      final result = await _channel.invokeMethod('getAvailableMemory');
      return result as int;
    } on PlatformException catch (e) {
      throw Exception('Failed to get available memory: ${e.message}');
    }
  }

  /// 获取可用存储空间
  static Future<int> getAvailableStorage() async {
    try {
      final result = await _channel.invokeMethod('getAvailableStorage');
      return result as int;
    } on PlatformException catch (e) {
      throw Exception('Failed to get available storage: ${e.message}');
    }
  }

  /// 检查GPU信息
  static Future<Map<String, dynamic>> getGPUInfo() async {
    try {
      final result = await _channel.invokeMethod('getGPUInfo');
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      throw Exception('Failed to get GPU info: ${e.message}');
    }
  }
}
