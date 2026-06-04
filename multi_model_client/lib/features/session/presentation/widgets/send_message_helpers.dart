// 会话发送消息时的辅助方法 - 位置服务、多模态处理、文件处理
// 从 session_detail_page.dart 拆分

import 'package:flutter/foundation.dart';

import '../../../../core/services/location_service.dart';

/// 位置服务处理辅助类
class LocationHandler {
  final LocationService locationService;
  final Future<bool?> Function() showPermissionDialog;
  final Future<void> Function() showSettingsDialog;
  final Future<void> Function() showServiceDisabledDialog;

  LocationHandler({
    required this.locationService,
    required this.showPermissionDialog,
    required this.showSettingsDialog,
    required this.showServiceDisabledDialog,
  });

  /// 检查并获取位置上下文
  ///
  /// 返回位置上下文字符串，若不需要或获取失败则返回 null
  Future<String?> handleLocationForMessage(String text) async {
    if (!locationService.needsLocation(text)) {
      return null;
    }

    debugPrint('[位置服务] 用户消息需要位置信息: $text');

    final permissionStatus = await locationService.checkPermission();

    if (permissionStatus == LocationPermissionStatus.denied) {
      final shouldRequest = await showPermissionDialog();
      if (shouldRequest == true) {
        final newStatus = await locationService.requestPermission();
        if (newStatus == LocationPermissionStatus.whileInUse ||
            newStatus == LocationPermissionStatus.always) {
          return _tryBuildLocationContext();
        } else if (newStatus == LocationPermissionStatus.deniedForever) {
          await showSettingsDialog();
        }
      }
    } else if (permissionStatus == LocationPermissionStatus.whileInUse ||
        permissionStatus == LocationPermissionStatus.always) {
      return _tryBuildLocationContext();
    } else if (permissionStatus == LocationPermissionStatus.serviceDisabled) {
      await showServiceDisabledDialog();
    }

    return null;
  }

  Future<String?> _tryBuildLocationContext() async {
    final location = await locationService.getCurrentLocation();
    if (location != null) {
      final context = await locationService.buildLocationContext();
      debugPrint('[位置服务] 已获取位置: ${location.shortDescription}');
      return context;
    }
    return null;
  }
}

/// 上下文压缩辅助类
class ContextCompressor {
  final double contextUsageRatio;
  final bool isCompressing;
  final Future<void> Function() onCompress;
  final Future<void> Function() onUpdateUsage;
  final void Function(bool isCompressing) onStateChange;
  final void Function() onShowSnackBar;

  ContextCompressor({
    required this.contextUsageRatio,
    required this.isCompressing,
    required this.onCompress,
    required this.onUpdateUsage,
    required this.onStateChange,
    required this.onShowSnackBar,
  });

  /// 自动压缩上下文（使用率 ≥ 90% 时触发）
  Future<bool> autoCompressIfNeeded() async {
    if (contextUsageRatio < 0.9 || isCompressing) {
      return false;
    }

    debugPrint(
        '[SessionDetail] 上下文使用率 ${(contextUsageRatio * 100).toInt()}% ≥ 90%，自动压缩...');
    onStateChange(true);
    try {
      await onCompress();
      await Future.delayed(const Duration(milliseconds: 300));
      await onUpdateUsage();
      onShowSnackBar();
    } catch (e) {
      debugPrint('[SessionDetail] 自动压缩失败: $e');
    } finally {
      onStateChange(false);
    }
    return true;
  }
}
