import 'package:flutter/services.dart';

class EncryptionPlugin {
  static const MethodChannel _channel = MethodChannel('com.multimodel.client/encryption');

  static Future<String> encrypt(String plainText, String key) async {
    try {
      final String result = await _channel.invokeMethod('encrypt', {
        'plainText': plainText,
        'key': key,
      });
      return result;
    } on PlatformException catch (e) {
      throw EncryptionException('Failed to encrypt: ${e.message}');
    }
  }

  static Future<String> decrypt(String encryptedText, String key) async {
    try {
      final String result = await _channel.invokeMethod('decrypt', {
        'encryptedText': encryptedText,
        'key': key,
      });
      return result;
    } on PlatformException catch (e) {
      throw EncryptionException('Failed to decrypt: ${e.message}');
    }
  }

  static Future<String> generateKey() async {
    try {
      final String key = await _channel.invokeMethod('generateKey');
      return key;
    } on PlatformException catch (e) {
      throw EncryptionException('Failed to generate key: ${e.message}');
    }
  }
}

class EncryptionException implements Exception {
  final String message;
  EncryptionException(this.message);

  @override
  String toString() => 'EncryptionException: $message';
}
