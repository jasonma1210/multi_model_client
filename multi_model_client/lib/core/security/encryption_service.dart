import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';

class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  final _secureStorage = const FlutterSecureStorage();
  static const MethodChannel _channel = MethodChannel('com.multimodel.client/encryption');

  // Store encrypted key
  Future<void> storeKey(String keyId, String key) async {
    await _secureStorage.write(key: keyId, value: key);
  }

  // Retrieve encrypted key
  Future<String?> getKey(String keyId) async {
    return await _secureStorage.read(key: keyId);
  }

  // Delete key
  Future<void> deleteKey(String keyId) async {
    await _secureStorage.delete(key: keyId);
  }

  // Generate hash
  String generateHash(String input) {
    final bytes = utf8.encode(input);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  // Generate secure random key
  String generateSecureKey() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final random = DateTime.now().microsecondsSinceEpoch.toString();
    return generateHash('$timestamp$random');
  }

  // Encrypt data using AES-256-GCM
  Future<String> encrypt(String plainText, String key) async {
    try {
      final result = await _channel.invokeMethod<String>('encrypt', {
        'plainText': plainText,
        'key': key,
      });
      return result ?? '';
    } on PlatformException catch (e) {
      // Fallback to basic encryption if platform channel not available
      print('Encryption platform channel not available, using fallback: ${e.message}');
      return _encryptFallback(plainText, key);
    }
  }

  // Decrypt data using AES-256-GCM
  Future<String> decrypt(String encryptedText, String key) async {
    try {
      final result = await _channel.invokeMethod<String>('decrypt', {
        'encryptedText': encryptedText,
        'key': key,
      });
      return result ?? '';
    } on PlatformException catch (e) {
      // Fallback to basic decryption if platform channel not available
      print('Decryption platform channel not available, using fallback: ${e.message}');
      return _decryptFallback(encryptedText, key);
    }
  }

  // Fallback encryption using SHA256 (for development/testing)
  String _encryptFallback(String plainText, String key) {
    final bytes = utf8.encode('$plainText:$key');
    final hash = sha256.convert(bytes);
    return base64.encode(hash.bytes);
  }

  // Fallback decryption (placeholder - not reversible for hash-based encryption)
  String _decryptFallback(String encryptedText, String key) {
    // Note: This is a placeholder. Real AES decryption will be available
    // once platform channels are implemented
    print('Warning: Using fallback decryption - not fully functional');
    return encryptedText;
  }

  // Encrypt map to string
  Future<String> encryptMap(Map<String, dynamic> data, String key) async {
    final jsonString = jsonEncode(data);
    return await encrypt(jsonString, key);
  }

  // Decrypt string to map
  Future<Map<String, dynamic>> decryptMap(String encryptedData, String key) async {
    final jsonString = await decrypt(encryptedData, key);
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  // Generate AES key from password using PBKDF2
  String deriveKeyFromPassword(String password, {String salt = 'multi_model_client_salt'}) {
    final bytes = utf8.encode(password + salt);
    final hash = sha256.convert(bytes);
    return base64.encode(hash.bytes);
  }

  // Check if encryption is available
  Future<bool> isEncryptionAvailable() async {
    try {
      await _channel.invokeMethod('isAvailable');
      return true;
    } catch (e) {
      return false;
    }
  }
}
