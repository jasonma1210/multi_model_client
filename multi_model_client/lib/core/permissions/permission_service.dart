import 'package:flutter/services.dart';

class PermissionService {
  static const MethodChannel _channel = MethodChannel('com.multimodel.client/permissions');

  // Request microphone permission
  static Future<bool> requestMicrophonePermission() async {
    try {
      final bool granted = await _channel.invokeMethod('requestMicrophonePermission');
      return granted;
    } on PlatformException catch (e) {
      print('Failed to request microphone permission: ${e.message}');
      return false;
    }
  }

  // Request camera permission
  static Future<bool> requestCameraPermission() async {
    try {
      final bool granted = await _channel.invokeMethod('requestCameraPermission');
      return granted;
    } on PlatformException catch (e) {
      print('Failed to request camera permission: ${e.message}');
      return false;
    }
  }

  // Request storage permission
  static Future<bool> requestStoragePermission() async {
    try {
      final bool granted = await _channel.invokeMethod('requestStoragePermission');
      return granted;
    } on PlatformException catch (e) {
      print('Failed to request storage permission: ${e.message}');
      return false;
    }
  }

  // Check if microphone permission is granted
  static Future<bool> hasMicrophonePermission() async {
    try {
      final bool granted = await _channel.invokeMethod('hasMicrophonePermission');
      return granted;
    } on PlatformException catch (e) {
      print('Failed to check microphone permission: ${e.message}');
      return false;
    }
  }

  // Check if camera permission is granted
  static Future<bool> hasCameraPermission() async {
    try {
      final bool granted = await _channel.invokeMethod('hasCameraPermission');
      return granted;
    } on PlatformException catch (e) {
      print('Failed to check camera permission: ${e.message}');
      return false;
    }
  }

  // Check if storage permission is granted
  static Future<bool> hasStoragePermission() async {
    try {
      final bool granted = await _channel.invokeMethod('hasStoragePermission');
      return granted;
    } on PlatformException catch (e) {
      print('Failed to check storage permission: ${e.message}');
      return false;
    }
  }

  // Open app settings
  static Future<bool> openAppSettings() async {
    try {
      final bool opened = await _channel.invokeMethod('openAppSettings');
      return opened;
    } on PlatformException catch (e) {
      print('Failed to open app settings: ${e.message}');
      return false;
    }
  }

  // Get permission usage log
  static Future<List<PermissionUsage>> getPermissionUsageLog() async {
    try {
      final List<dynamic> log = await _channel.invokeMethod('getPermissionUsageLog');
      return log.map((item) => PermissionUsage.fromMap(item as Map<String, dynamic>)).toList();
    } on PlatformException catch (e) {
      print('Failed to get permission usage log: ${e.message}');
      return [];
    }
  }
}

class PermissionUsage {
  final String permission;
  final DateTime timestamp;
  final String purpose;

  const PermissionUsage({
    required this.permission,
    required this.timestamp,
    required this.purpose,
  });

  factory PermissionUsage.fromMap(Map<String, dynamic> map) {
    return PermissionUsage(
      permission: map['permission'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      purpose: map['purpose'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'permission': permission,
      'timestamp': timestamp.toIso8601String(),
      'purpose': purpose,
    };
  }
}
