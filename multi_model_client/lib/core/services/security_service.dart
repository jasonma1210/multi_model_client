/// 安全服务 - LLM Studio 数据安全模块
/// 
/// 功能：
/// - 数据加密/解密（AES-256）
/// - 敏感数据脱敏
/// - 安全审计日志
/// - 密钥管理
/// 
/// @author JianMa
/// @version 1.0.0
library;

import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 数据加密服务
/// 提供敏感数据的加密和解密功能
class EncryptionService {
  static const String _encryptionKeyKey = 'encryption_key';
  static const String _encryptionIvKey = 'encryption_iv';

  encrypt.Key? _key;
  encrypt.IV? _iv;
  encrypt.Encrypter? _encrypter;

  /// 初始化加密服务
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 获取或生成加密密钥
    String? keyString = prefs.getString(_encryptionKeyKey);
    String? ivString = prefs.getString(_encryptionIvKey);

    if (keyString == null || ivString == null) {
      // 生成新的密钥和 IV
      _key = encrypt.Key.fromSecureRandom(32); // 256 位密钥
      _iv = encrypt.IV.fromSecureRandom(16);    // 128 位 IV

      // 保存到安全存储
      await prefs.setString(_encryptionKeyKey, base64Encode(_key!.bytes));
      await prefs.setString(_encryptionIvKey, base64Encode(_iv!.bytes));
    } else {
      _key = encrypt.Key(base64Decode(keyString));
      _iv = encrypt.IV(base64Decode(ivString));
    }

    _encrypter = encrypt.Encrypter(encrypt.AES(_key!, mode: encrypt.AESMode.cbc));
  }

  /// 加密字符串
  String encryptString(String plainText) {
    if (_encrypter == null || _iv == null) {
      throw StateError('Encryption service not initialized');
    }
    final encrypted = _encrypter!.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }

  /// 解密字符串
  String decryptString(String encryptedText) {
    if (_encrypter == null || _iv == null) {
      throw StateError('Encryption service not initialized');
    }
    final encrypted = encrypt.Encrypted.fromBase64(encryptedText);
    return _encrypter!.decrypt(encrypted, iv: _iv);
  }

  /// 加密字节数据
  Uint8List encryptBytes(Uint8List data) {
    if (_encrypter == null || _iv == null) {
      throw StateError('Encryption service not initialized');
    }
    final encrypted = _encrypter!.encryptBytes(data, iv: _iv);
    return encrypted.bytes;
  }

  /// 解密字节数据
  Uint8List decryptBytes(Uint8List encryptedData) {
    if (_encrypter == null || _iv == null) {
      throw StateError('Encryption service not initialized');
    }
    final encrypted = encrypt.Encrypted(encryptedData);
    return Uint8List.fromList(_encrypter!.decryptBytes(encrypted, iv: _iv));
  }

  /// 生成数据哈希
  String generateHash(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// 验证数据哈希
  bool verifyHash(String data, String hash) {
    return generateHash(data) == hash;
  }

  /// 生成随机密码
  String generatePassword({int length = 16, bool includeSpecial = true}) {
    const lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const numbers = '0123456789';
    const special = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    String chars = lowercase + uppercase + numbers;
    if (includeSpecial) chars += special;

    final random = Random.secure();
    return List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// 重置加密密钥（会使得之前加密的数据无法解密）
  Future<void> resetEncryptionKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_encryptionKeyKey);
    await prefs.remove(_encryptionIvKey);
    await initialize();
  }
}

/// 安全审计服务
/// 记录安全相关事件
class SecurityAuditService {
  final List<SecurityEvent> _events = [];
  static const int _maxEvents = 1000;
  static const String _tag = 'SecurityAudit';

  /// 记录安全事件
  void logEvent(SecurityEvent event) {
    _events.insert(0, event);

    // 保持事件数量在限制内
    while (_events.length > _maxEvents) {
      _events.removeLast();
    }

    // 打印调试信息
    debugPrint('[$_tag] ${event.eventType.name}: ${event.description}');
  }

  /// 获取所有事件
  List<SecurityEvent> getEvents() => List.unmodifiable(_events);

  /// 获取指定类型的事件
  List<SecurityEvent> getEventsByType(SecurityEventType type) {
    return _events.where((e) => e.eventType == type).toList();
  }

  /// 获取最近的事件
  List<SecurityEvent> getRecentEvents({int limit = 50}) {
    return _events.take(limit).toList();
  }

  /// 获取时间范围内的事件
  List<SecurityEvent> getEventsInRange(DateTime start, DateTime end) {
    return _events.where((e) => 
      e.timestamp.isAfter(start) && e.timestamp.isBefore(end)
    ).toList();
  }

  /// 清空所有事件
  void clearEvents() {
    _events.clear();
  }

  /// 获取安全统计
  SecurityStats getStats() {
    return SecurityStats(
      totalEvents: _events.length,
      failedLogins: _events.where((e) => e.eventType == SecurityEventType.loginFailed).length,
      successfulLogins: _events.where((e) => e.eventType == SecurityEventType.loginSuccess).length,
      passwordChanges: _events.where((e) => e.eventType == SecurityEventType.passwordChanged).length,
      sensitiveDataAccess: _events.where((e) => e.eventType == SecurityEventType.sensitiveDataAccessed).length,
      failedAttempts: _events.where((e) => e.eventType == SecurityEventType.authFailed).length,
    );
  }
}

/// 安全事件类型
enum SecurityEventType {
  loginSuccess,
  loginFailed,
  logout,
  passwordChanged,
  pinChanged,
  biometricEnabled,
  biometricDisabled,
  sensitiveDataAccessed,
  dataExported,
  dataImported,
  authFailed,
  suspiciousActivity,
  systemError,
}

/// 安全事件
class SecurityEvent {
  final SecurityEventType eventType;
  final String description;
  final DateTime timestamp;
  final String? userId;
  final String? ipAddress;
  final Map<String, dynamic>? metadata;

  SecurityEvent({
    required this.eventType,
    required this.description,
    DateTime? timestamp,
    this.userId,
    this.ipAddress,
    this.metadata,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// 安全统计
class SecurityStats {
  final int totalEvents;
  final int failedLogins;
  final int successfulLogins;
  final int passwordChanges;
  final int sensitiveDataAccess;
  final int failedAttempts;

  SecurityStats({
    required this.totalEvents,
    required this.failedLogins,
    required this.successfulLogins,
    required this.passwordChanges,
    required this.sensitiveDataAccess,
    required this.failedAttempts,
  });
}

/// 数据脱敏服务
class DataMaskingService {
  /// 脱敏手机号
  static String maskPhoneNumber(String phone) {
    if (phone.length < 7) return phone;
    return '${phone.substring(0, 3)}****${phone.substring(phone.length - 4)}';
  }

  /// 脱敏邮箱
  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    
    final username = parts[0];
    if (username.length <= 2) {
      return '**@${parts[1]}';
    }
    
    return '${username.substring(0, 2)}***@${parts[1]}';
  }

  /// 脱敏身份证号
  static String maskIdCard(String idCard) {
    if (idCard.length < 8) return idCard;
    return '${idCard.substring(0, 4)}**********${idCard.substring(idCard.length - 4)}';
  }

  /// 脱敏银行卡号
  static String maskBankCard(String bankCard) {
    if (bankCard.length < 8) return bankCard;
    return '${bankCard.substring(0, 4)} **** **** ${bankCard.substring(bankCard.length - 4)}';
  }

  /// 脱敏地址
  static String maskAddress(String address) {
    if (address.length <= 6) return address;
    return '${address.substring(0, 3)}***${address.substring(address.length - 3)}';
  }

  /// 脱敏 API Key
  static String maskApiKey(String apiKey) {
    if (apiKey.length <= 8) return '****';
    return '${apiKey.substring(0, 4)}****${apiKey.substring(apiKey.length - 4)}';
  }
}

// Riverpod Providers

// 加密服务 Provider
final encryptionServiceProvider = Provider<EncryptionService>((ref) {
  return EncryptionService();
});

// 安全审计服务 Provider
final securityAuditServiceProvider = Provider<SecurityAuditService>((ref) {
  return SecurityAuditService();
});

// 安全统计 Provider
final securityStatsProvider = Provider<SecurityStats>((ref) {
  final auditService = ref.watch(securityAuditServiceProvider);
  return auditService.getStats();
});

// 安全事件列表 Provider
final securityEventsProvider = Provider<List<SecurityEvent>>((ref) {
  final auditService = ref.watch(securityAuditServiceProvider);
  return auditService.getRecentEvents();
});