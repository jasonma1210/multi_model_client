package com.multimodel.client

import android.security.keystore.KeyProperties
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.security.MessageDigest
import java.util.Base64
import javax.crypto.Cipher
import javax.crypto.spec.IvParameterSpec
import javax.crypto.spec.SecretKeySpec

class EncryptionPlugin : MethodChannel.MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "encrypt" -> {
                val plainText = call.argument<String>("plainText")
                val key = call.argument<String>("key")
                if (plainText != null && key != null) {
                    try {
                        val encrypted = encryptAES(plainText, key)
                        result.success(encrypted)
                    } catch (e: Exception) {
                        result.error("ENCRYPTION_ERROR", e.message, null)
                    }
                } else {
                    result.error("INVALID_ARGUMENTS", "Invalid arguments for encrypt", null)
                }
            }
            "decrypt" -> {
                val encryptedText = call.argument<String>("encryptedText")
                val key = call.argument<String>("key")
                if (encryptedText != null && key != null) {
                    try {
                        val decrypted = decryptAES(encryptedText, key)
                        result.success(decrypted)
                    } catch (e: Exception) {
                        result.error("DECRYPTION_ERROR", e.message, null)
                    }
                } else {
                    result.error("INVALID_ARGUMENTS", "Invalid arguments for decrypt", null)
                }
            }
            "isAvailable" -> result.success(true)
            else -> result.notImplemented()
        }
    }

    private fun encryptAES(plainText: String, key: String): String {
        val keyData = key.toByteArray(Charsets.UTF_8)
        val plainData = plainText.toByteArray(Charsets.UTF_8)
        
        // Derive 32-byte key using SHA256
        val sha256 = MessageDigest.getInstance("SHA-256")
        val keyHash = sha256.digest(keyData)
        
        // Generate random IV
        val iv = ByteArray(16)
        java.security.SecureRandom().nextBytes(iv)
        
        // Encrypt
        val cipher = Cipher.getInstance("AES/CBC/PKCS7Padding")
        val secretKey = SecretKeySpec(keyHash, "AES")
        val ivSpec = IvParameterSpec(iv)
        cipher.init(Cipher.ENCRYPT_MODE, secretKey, ivSpec)
        val encryptedData = cipher.doFinal(plainData)
        
        // Combine IV + encrypted data and base64 encode
        val combined = iv + encryptedData
        return Base64.getEncoder().encodeToString(combined)
    }

    private fun decryptAES(encryptedText: String, key: String): String {
        val keyData = key.toByteArray(Charsets.UTF_8)
        val combinedData = Base64.getDecoder().decode(encryptedText)
        
        // Derive 32-byte key using SHA256
        val sha256 = MessageDigest.getInstance("SHA-256")
        val keyHash = sha256.digest(keyData)
        
        // Extract IV and encrypted data
        val iv = combinedData.copyOfRange(0, 16)
        val encryptedData = combinedData.copyOfRange(16, combinedData.size)
        
        // Decrypt
        val cipher = Cipher.getInstance("AES/CBC/PKCS7Padding")
        val secretKey = SecretKeySpec(keyHash, "AES")
        val ivSpec = IvParameterSpec(iv)
        cipher.init(Cipher.DECRYPT_MODE, secretKey, ivSpec)
        val decryptedData = cipher.doFinal(encryptedData)
        
        return String(decryptedData, Charsets.UTF_8)
    }
}
