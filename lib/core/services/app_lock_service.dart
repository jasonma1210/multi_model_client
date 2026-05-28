/// 应用锁服务 - LLM Studio 安全模块
/// 
/// 功能：
/// - PIN 码锁屏
/// - 生物识别（Face ID / Touch ID / 指纹）
/// - 自动锁定超时
/// - 安全验证流程
/// 
/// @author JianMa
/// @version 1.0.0
library;

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 应用锁服务
/// 支持 PIN 码和生物识别（Face ID / Touch ID / 指纹）
class AppLockService {
  static const String _tag = 'AppLockService';
  static const String _pinHashKey = 'app_lock_pin_hash';
  static const String _biometricEnabledKey = 'app_lock_biometric_enabled';
  static const String _lockEnabledKey = 'app_lock_enabled';
  static const String _lockTimeoutKey = 'app_lock_timeout';

  final LocalAuthentication _localAuth = LocalAuthentication();

  /// 是否启用了应用锁
  Future<bool> isLockEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_lockEnabledKey) ?? false;
  }

  /// 是否启用了生物识别
  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }

  /// 是否支持生物识别
  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  /// 获取可用的生物识别类型
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// 设置 PIN 码
  Future<void> setPin(String pin) async {
    if (pin.length < 4 || pin.length > 6) {
      throw ArgumentError('PIN must be 4-6 digits');
    }

    // Hash the PIN for secure storage
    final bytes = utf8.encode(pin);
    final hash = sha256.convert(bytes).toString();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinHashKey, hash);
  }

  /// 验证 PIN 码
  Future<bool> verifyPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final storedHash = prefs.getString(_pinHashKey);

    if (storedHash == null) {
      return false;
    }

    final bytes = utf8.encode(pin);
    final hash = sha256.convert(bytes).toString();

    return hash == storedHash;
  }

  /// 验证生物识别
  Future<bool> verifyBiometric() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!canCheck || !isDeviceSupported) {
        return false;
      }

      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access LLM Studio',
        biometricOnly: true,
        sensitiveTransaction: true,
      );
    } catch (e) {
      debugPrint('[$_tag] 生物识别验证失败: $e');
      return false;
    }
  }

  /// 启用应用锁
  Future<void> enableLock({bool enableBiometric = false}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_lockEnabledKey, true);

    if (enableBiometric) {
      await prefs.setBool(_biometricEnabledKey, true);
    }
  }

  /// 禁用应用锁
  Future<void> disableLock() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_lockEnabledKey, false);
    await prefs.setBool(_biometricEnabledKey, false);
  }

  /// 设置锁定超时时间（秒）
  Future<void> setLockTimeout(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lockTimeoutKey, seconds);
  }

  /// 获取锁定超时时间
  Future<int> getLockTimeout() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_lockTimeoutKey) ?? 60; // 默认 60 秒
  }

  /// 清除 PIN 码
  Future<void> clearPin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pinHashKey);
  }

  /// 检查是否设置了 PIN 码
  Future<bool> hasPinSet() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pinHashKey) != null;
  }
}

/// 应用锁状态
enum AppLockState {
  unlocked,
  locked,
  lockedAwaitingBiometric,
}

/// 锁定原因
enum LockReason {
  appStart,
  backgroundReturn,
  timeout,
  manual,
}

// Riverpod Providers

// 应用锁服务 Provider
final appLockServiceProvider = Provider<AppLockService>((ref) {
  return AppLockService();
});

// 应用锁状态 Provider
final appLockStateProvider = StateProvider<AppLockState>((ref) => AppLockState.unlocked);

// 锁定原因 Provider
final lockReasonProvider = StateProvider<LockReason?>((ref) => null);

// 是否支持生物识别
final biometricAvailableProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(appLockServiceProvider);
  return await service.isBiometricAvailable();
});

// 是否启用了应用锁
final lockEnabledProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(appLockServiceProvider);
  return await service.isLockEnabled();
});