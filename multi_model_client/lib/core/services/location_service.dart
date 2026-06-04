/// 位置服务 - LLM Studio 地理位置获取模块
///
/// 功能：
/// - 获取用户当前位置（经纬度）
/// - 逆地理编码获取地址信息
/// - 权限检查和请求
/// - 位置信息格式化
///
/// @author Jianma
/// @version 1.0.0
library;

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// 位置信息数据类
class LocationInfo {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? altitude;
  final double? speed;
  final String? address;
  final String? city;
  final String? district;
  final String? province;
  final String? country;
  final DateTime timestamp;

  const LocationInfo({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.altitude,
    this.speed,
    this.address,
    this.city,
    this.district,
    this.province,
    this.country,
    required this.timestamp,
  });

  /// 转换为模型可用的格式
  Map<String, dynamic> toModelFormat() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'altitude': altitude,
      'speed': speed,
      'address': address ?? '',
      'city': city ?? '',
      'district': district ?? '',
      'province': province ?? '',
      'country': country ?? '',
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// 简化的位置描述（用于显示）
  String get shortDescription {
    if (city != null && city!.isNotEmpty) {
      return city!;
    }
    if (address != null && address!.isNotEmpty) {
      return address!;
    }
    return '$latitude, $longitude';
  }

  /// 完整的位置描述
  String get fullDescription {
    final parts = <String>[];
    if (province != null && province!.isNotEmpty) parts.add(province!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (district != null && district!.isNotEmpty) parts.add(district!);
    if (address != null && address!.isNotEmpty) parts.add(address!);
    
    if (parts.isEmpty) {
      return '$latitude, $longitude';
    }
    return parts.join('');
  }

  @override
  String toString() {
    return 'LocationInfo(lat: $latitude, lng: $longitude, address: $address)';
  }
}

/// 位置服务错误类型
enum LocationError {
  serviceDisabled,    // 位置服务未开启
  permissionDenied,   // 权限被拒绝
  permissionDeniedForever, // 权限永久拒绝
  locationDisabled,   // 设备位置未开启
  timeout,            // 获取位置超时
  unknown,            // 未知错误
}

/// 位置服务
class LocationService {
  static LocationService? _instance;
  static LocationService get instance => _instance ??= LocationService._();
  LocationService._();

  bool _isInitialized = false;
  LocationInfo? _lastLocation;
  DateTime? _lastLocationTime;
  
  /// 位置缓存有效期（5分钟）
  static const Duration cacheValidDuration = Duration(minutes: 5);

  /// 初始化位置服务
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    debugPrint('[LocationService] 初始化位置服务');
    _isInitialized = true;
  }

  /// 检查位置权限状态
  Future<LocationPermissionStatus> checkPermission() async {
    try {
      // 检查位置服务是否启用
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationPermissionStatus.serviceDisabled;
      }

      // 检查权限
      LocationPermission permission = await Geolocator.checkPermission();
      return _mapPermission(permission);
    } catch (e) {
      debugPrint('[LocationService] 检查权限失败: $e');
      return LocationPermissionStatus.denied;
    }
  }

  /// 请求位置权限
  Future<LocationPermissionStatus> requestPermission() async {
    try {
      // 先检查位置服务是否启用
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationPermissionStatus.serviceDisabled;
      }

      // 请求权限
      LocationPermission permission = await Geolocator.requestPermission();
      return _mapPermission(permission);
    } catch (e) {
      debugPrint('[LocationService] 请求权限失败: $e');
      return LocationPermissionStatus.denied;
    }
  }

  /// 映射权限状态
  LocationPermissionStatus _mapPermission(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.denied:
        return LocationPermissionStatus.denied;
      case LocationPermission.deniedForever:
        return LocationPermissionStatus.deniedForever;
      case LocationPermission.whileInUse:
        return LocationPermissionStatus.whileInUse;
      case LocationPermission.always:
        return LocationPermissionStatus.always;
      case LocationPermission.unableToDetermine:
        return LocationPermissionStatus.denied;
    }
  }

  /// 获取当前位置（带缓存）
  Future<LocationInfo?> getCurrentLocation({bool forceRefresh = false}) async {
    try {
      // 检查权限
      final permissionStatus = await checkPermission();
      if (permissionStatus != LocationPermissionStatus.whileInUse &&
          permissionStatus != LocationPermissionStatus.always) {
        debugPrint('[LocationService] 权限不足: $permissionStatus');
        return null;
      }

      // 检查缓存是否有效
      if (!forceRefresh && _lastLocation != null && _lastLocationTime != null) {
        final cacheAge = DateTime.now().difference(_lastLocationTime!);
        if (cacheAge < cacheValidDuration) {
          debugPrint('[LocationService] 使用缓存位置: $_lastLocation');
          return _lastLocation;
        }
      }

      // 获取当前位置
      debugPrint('[LocationService] 获取当前位置...');
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      // 创建位置信息
      _lastLocation = LocationInfo(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        altitude: position.altitude,
        speed: position.speed,
        timestamp: DateTime.now(),
      );
      _lastLocationTime = DateTime.now();

      debugPrint('[LocationService] 获取位置成功: $_lastLocation');
      return _lastLocation;
    } catch (e) {
      debugPrint('[LocationService] 获取位置失败: $e');
      return null;
    }
  }

  /// 打开设备位置设置
  Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (e) {
      debugPrint('[LocationService] 打开位置设置失败: $e');
      return false;
    }
  }

  /// 打开应用设置（用于权限设置）
  Future<bool> openAppSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (e) {
      debugPrint('[LocationService] 打开应用设置失败: $e');
      return false;
    }
  }

  /// 获取最后一次获取的位置
  LocationInfo? get lastLocation => _lastLocation;

  /// 检查用户消息是否需要位置信息
  bool needsLocation(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();
    
    // 位置相关关键词
    final locationKeywords = [
      '在哪里', '在哪', '我的位置', '当前位置', '现在在哪',
      '附近', '周边', '周围', '附近有什么', '周边有什么',
      '天气', '气象', '温度', '空气质量',
      '我的位置', '定位', 'GPS',
      '附近餐厅', '附近美食', '附近商店', '附近银行', '附近医院',
      '附近地铁', '附近公交', '附近停车场',
      '怎么去', '路线', '距离', '多远',
      '天气怎么样', '今天天气', '明天天气',
      '我在哪', '这是哪里', '这里是哪',
    ];

    for (final keyword in locationKeywords) {
      if (lowerMessage.contains(keyword)) {
        return true;
      }
    }
    return false;
  }

  /// 构建位置上下文信息（用于传递给模型）
  Future<String> buildLocationContext() async {
    final location = await getCurrentLocation();
    if (location == null) {
      return '';
    }

    return '''
[用户位置信息]
- 经度: ${location.latitude}
- 纬度: ${location.longitude}
- 位置: ${location.fullDescription}
- 精度: ${location.accuracy?.toStringAsFixed(0) ?? '未知'}米
- 时间: ${location.timestamp.toString()}
''';
  }
}

/// 位置权限状态
enum LocationPermissionStatus {
  /// 权限被拒绝
  denied,
  /// 权限永久拒绝
  deniedForever,
  /// 使用时允许（仅在使用应用时获取位置）
  whileInUse,
  /// 始终允许（应用在后台时也可获取位置）
  always,
  /// 位置服务未启用
  serviceDisabled,
}

/// 位置服务 Provider
final locationServiceProvider = LocationService.instance;