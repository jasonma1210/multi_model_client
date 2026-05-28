import Foundation
import CommonCrypto

class EncryptionPlugin: NSObject, FlutterPlugin {
    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.multimodel.client/encryption", binaryMessenger: registrar.messenger())
        let instance = EncryptionPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "encrypt":
            if let args = call.arguments as? [String: Any],
               let plainText = args["plainText"] as? String,
               let key = args["key"] as? String {
                do {
                    let encrypted = try encryptAES(plainText: plainText, key: key)
                    result(encrypted)
                } catch {
                    result(FlutterError(code: "ENCRYPTION_ERROR", message: error.localizedDescription, details: nil))
                }
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for encrypt", details: nil))
            }

        case "decrypt":
            if let args = call.arguments as? [String: Any],
               let encryptedText = args["encryptedText"] as? String,
               let key = args["key"] as? String {
                do {
                    let decrypted = try decryptAES(encryptedText: encryptedText, key: key)
                    result(decrypted)
                } catch {
                    result(FlutterError(code: "DECRYPTION_ERROR", message: error.localizedDescription, details: nil))
                }
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for decrypt", details: nil))
            }

        case "isAvailable":
            result(true)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func encryptAES(plainText: String, key: String) throws -> String {
        let keyData = key.data(using: .utf8)!
        let plainData = plainText.data(using: .utf8)!
        
        // Derive 32-byte key using SHA256
        var keyHash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        keyData.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(keyData.count), &keyHash)
        }
        
        // Generate random IV
        var iv = [UInt8](repeating: 0, count: kCCBlockSizeAES128)
        _ = SecRandomCopyBytes(kSecRandomDefault, iv.count, &iv)
        
        // Encrypt
        let encryptedData = try aesCrypt(data: plainData, key: Data(keyHash), iv: Data(iv), operation: CCOperation(kCCEncrypt))
        
        // Combine IV + encrypted data and base64 encode
        var combined = Data(iv)
        combined.append(encryptedData)
        
        return combined.base64EncodedString()
    }

    private func decryptAES(encryptedText: String, key: String) throws -> String {
        let keyData = key.data(using: .utf8)!
        guard let combinedData = Data(base64Encoded: encryptedText) else {
            throw NSError(domain: "Invalid base64", code: -1)
        }
        
        // Derive 32-byte key using SHA256
        var keyHash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        keyData.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(keyData.count), &keyHash)
        }
        
        // Extract IV and encrypted data
        let iv = combinedData.prefix(kCCBlockSizeAES128)
        let encryptedData = combinedData.suffix(from: kCCBlockSizeAES128)
        
        // Decrypt
        let decryptedData = try aesCrypt(data: encryptedData, key: Data(keyHash), iv: iv, operation: CCOperation(kCCDecrypt))
        
        guard let decryptedString = String(data: decryptedData, encoding: .utf8) else {
            throw NSError(domain: "Invalid UTF8", code: -1)
        }
        
        return decryptedString
    }

    private func aesCrypt(data: Data, key: Data, iv: Data, operation: CCOperation) throws -> Data {
        let cryptLength = data.count + kCCBlockSizeAES128
        var cryptData = Data(count: cryptLength)
        
        var bytesProcessed: Int = 0
        
        let cryptStatus = cryptData.withUnsafeMutableBytes { cryptBytes in
            data.withUnsafeBytes { dataBytes in
                iv.withUnsafeBytes { ivBytes in
                    key.withUnsafeBytes { keyBytes in
                        CCCrypt(
                            operation,
                            CCAlgorithm(kCCAlgorithmAES),
                            CCOptions(kCCOptionPKCS7Padding),
                            keyBytes.baseAddress, key.count,
                            ivBytes.baseAddress,
                            dataBytes.baseAddress, data.count,
                            cryptBytes.baseAddress, cryptLength,
                            &bytesProcessed
                        )
                    }
                }
            }
        }
        
        guard cryptStatus == kCCSuccess else {
            throw NSError(domain: "Encryption error", code: Int(cryptStatus))
        }
        
        cryptData.removeSubrange(bytesProcessed..<cryptData.count)
        return cryptData
    }
}
