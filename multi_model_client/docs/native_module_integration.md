# 原生模块集成指南

本文档说明如何集成iOS和Android原生模块。

## 加密模块 (Encryption Module)

### iOS集成

在`ios/Runner/`目录下创建以下文件：

#### EncryptionPlugin.swift
```swift
import Flutter
import UIKit
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
        result(encryptAES(plainText: plainText, key: key))
      } else {
        result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
      }
    case "decrypt":
      if let args = call.arguments as? [String: Any],
         let encryptedText = args["encryptedText"] as? String,
         let key = args["key"] as? String {
        result(decryptAES(encryptedText: encryptedText, key: key))
      } else {
        result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
      }
    case "generateKey":
      result(generateRandomKey())
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func encryptAES(plainText: String, key: String) -> String {
    // Implement AES-256 encryption
    // Use CryptoKit or CommonCrypto
    return plainText // Placeholder
  }

  private func decryptAES(encryptedText: String, key: String) -> String {
    // Implement AES-256 decryption
    return encryptedText // Placeholder
  }

  private func generateRandomKey() -> String {
    // Generate secure random key
    return UUID().uuidString
  }
}
```

### Android集成

在`android/app/src/main/kotlin/com/multimodel/client/`目录下创建：

#### EncryptionPlugin.kt
```kotlin
package com.multimodel.client.multi_model_client

import android.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.security.SecureRandom
import javax.crypto.Cipher
import javax.crypto.spec.SecretKeySpec
import android.util.Base64

class EncryptionPlugin : MethodChannel.MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "encrypt" -> {
                val plainText = call.argument<String>("plainText")
                val key = call.argument<String>("key")
                if (plainText != null && key != null) {
                    result.success(encryptAES(plainText, key))
                } else {
                    result.error("INVALID_ARGS", "Invalid arguments", null)
                }
            }
            "decrypt" -> {
                val encryptedText = call.argument<String>("encryptedText")
                val key = call.argument<String>("key")
                if (encryptedText != null && key != null) {
                    result.success(decryptAES(encryptedText, key))
                } else {
                    result.error("INVALID_ARGS", "Invalid arguments", null)
                }
            }
            "generateKey" -> {
                result.success(generateRandomKey())
            }
            else -> result.notImplemented()
        }
    }

    private fun encryptAES(plainText: String, key: String): String {
        // Implement AES-256 encryption
        return plainText // Placeholder
    }

    private fun decryptAES(encryptedText: String, key: String): String {
        // Implement AES-256 decryption
        return encryptedText // Placeholder
    }

    private fun generateRandomKey(): String {
        val random = SecureRandom()
        val bytes = ByteArray(32)
        random.nextBytes(bytes)
        return Base64.encodeToString(bytes, Base64.DEFAULT)
    }
}
```

## 权限管理模块 (Permission Module)

### iOS集成

在`ios/Runner/`目录下创建：

#### PermissionPlugin.swift
```swift
import Flutter
import UIKit
import AVFoundation
import Photos

class PermissionPlugin: NSObject, FlutterPlugin {
  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "com.multimodel.client/permissions", binaryMessenger: registrar.messenger())
    let instance = PermissionPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "requestMicrophonePermission":
      requestMicrophonePermission(result: result)
    case "requestCameraPermission":
      requestCameraPermission(result: result)
    case "requestStoragePermission":
      requestStoragePermission(result: result)
    case "hasMicrophonePermission":
      result(hasMicrophonePermission())
    case "hasCameraPermission":
      result(hasCameraPermission())
    case "hasStoragePermission":
      result(hasStoragePermission())
    case "openAppSettings":
      if let url = URL(string: UIApplication.openSettingsURLString) {
        UIApplication.shared.open(url)
        result(true)
      } else {
        result(false)
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func requestMicrophonePermission(result: @escaping FlutterResult) {
    AVAudioSession.sharedInstance().requestRecordPermission { granted in
      DispatchQueue.main.async {
        result(granted)
      }
    }
  }

  private func requestCameraPermission(result: @escaping FlutterResult) {
    AVCaptureDevice.requestAccess(for: .video) { granted in
      DispatchQueue.main.async {
        result(granted)
      }
    }
  }

  private func requestStoragePermission(result: @escaping FlutterResult) {
    PHPhotoLibrary.requestAuthorization { status in
      DispatchQueue.main.async {
        result(status == .authorized)
      }
    }
  }

  private func hasMicrophonePermission() -> Bool {
    return AVAudioSession.sharedInstance().recordPermission == .granted
  }

  private func hasCameraPermission() -> Bool {
    return AVCaptureDevice.authorizationStatus(for: .video) == .authorized
  }

  private func hasStoragePermission() -> Bool {
    return PHPhotoLibrary.authorizationStatus() == .authorized
  }
}
```

### Android集成

在`android/app/src/main/kotlin/com/multimodel/client/`目录下创建：

#### PermissionPlugin.kt
```kotlin
package com.multimodel.client.multi_model_client

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

class PermissionPlugin(private val activity: io.flutter.embedding.android.FlutterActivity) :
    MethodChannel.MethodCallHandler, PluginRegistry.RequestPermissionsResultListener {

    companion object {
        private const val MICROPHONE_PERMISSION_CODE = 1001
        private const val CAMERA_PERMISSION_CODE = 1002
        private const val STORAGE_PERMISSION_CODE = 1003
    }

    private var pendingResult: MethodChannel.Result? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "requestMicrophonePermission" -> {
                requestPermission(Manifest.permission.RECORD_AUDIO, MICROPHONE_PERMISSION_CODE, result)
            }
            "requestCameraPermission" -> {
                requestPermission(Manifest.permission.CAMERA, CAMERA_PERMISSION_CODE, result)
            }
            "requestStoragePermission" -> {
                requestPermission(Manifest.permission.READ_EXTERNAL_STORAGE, STORAGE_PERMISSION_CODE, result)
            }
            "hasMicrophonePermission" -> {
                result.success(hasPermission(Manifest.permission.RECORD_AUDIO))
            }
            "hasCameraPermission" -> {
                result.success(hasPermission(Manifest.permission.CAMERA))
            }
            "hasStoragePermission" -> {
                result.success(hasPermission(Manifest.permission.READ_EXTERNAL_STORAGE))
            }
            "openAppSettings" -> {
                val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                intent.data = Uri.fromParts("package", activity.packageName, null)
                activity.startActivity(intent)
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    private fun requestPermission(permission: String, requestCode: Int, result: MethodChannel.Result) {
        if (hasPermission(permission)) {
            result.success(true)
        } else {
            pendingResult = result
            ActivityCompat.requestPermissions(activity, arrayOf(permission), requestCode)
        }
    }

    private fun hasPermission(permission: String): Boolean {
        return ContextCompat.checkSelfPermission(activity, permission) == PackageManager.PERMISSION_GRANTED
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray): Boolean {
        pendingResult?.success(grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED)
        pendingResult = null
        return true
    }
}
```

## 注册插件

### iOS - 在 AppDelegate.swift 中注册

```swift
import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController

    // Register plugins
    EncryptionPlugin.register(with: controller.registrar(forPlugin: "EncryptionPlugin"))
    PermissionPlugin.register(with: controller.registrar(forPlugin: "PermissionPlugin"))

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### Android - 在 MainActivity.kt 中注册

```kotlin
package com.multimodel.client.multi_model_client

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
    private lateinit var encryptionPlugin: EncryptionPlugin
    private lateinit var permissionPlugin: PermissionPlugin

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Register plugins
        encryptionPlugin = EncryptionPlugin()
        permissionPlugin = PermissionPlugin(this)

        flutterEngine.dartExecutor.binaryMessenger.let { messenger ->
            MethodChannel(messenger, "com.multimodel.client/encryption").setMethodCallHandler(encryptionPlugin)
            MethodChannel(messenger, "com.multimodel.client/permissions").setMethodCallHandler(permissionPlugin)
        }
    }
}
```

## 权限配置

### iOS - Info.plist

添加以下权限描述：

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for voice input</string>
<key>NSCameraUsageDescription</key>
<string>This app needs camera access for video input</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access for file management</string>
```

### Android - AndroidManifest.xml

添加以下权限：

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

## 测试

运行以下命令确保插件正确注册：

```bash
flutter clean
flutter pub get
flutter run
```

## 注意事项

1. 确保在发布前充分测试权限请求流程
2. 处理权限被拒绝的情况
3. 提供清晰的权限使用说明
4. 遵循平台权限最佳实践
