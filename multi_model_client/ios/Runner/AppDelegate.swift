import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // 硬件检查器插件 - 暂时禁用（需要手动添加到 Xcode 项目）
    // HardwareCheckerPlugin.register(with: self.registrar(forPlugin: "HardwareCheckerPlugin")!)

    // background_downloader 需要在 AppDelegate 中设置通知处理
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }

    // 注册分享通道
    let controller = window?.rootViewController as! FlutterViewController
    let shareChannel = FlutterMethodChannel(
      name: "com.multimodel.client/share",
      binaryMessenger: controller.binaryMessenger
    )

    shareChannel.setMethodCallHandler { [weak self] (call, result) in
      switch call.method {
      case "getSharedText":
        // 从 UserDefaults 读取分享内容
        let userDefaults = UserDefaults(suiteName: "group.com.multimodel.client")
        let sharedContent = userDefaults?.string(forKey: "sharedContent")
        result(sharedContent)
      case "getSharedUrl":
        let userDefaults = UserDefaults(suiteName: "group.com.multimodel.client")
        result(userDefaults?.string(forKey: "sharedContent"))
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // 处理 URL Scheme
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    // 处理 llmstudio:// 或 mjnexus:// URL
    if url.scheme == "llmstudio" || url.scheme == "mjnexus" {
      // 通过 MethodChannel 通知 Flutter
      if let controller = window?.rootViewController as? FlutterViewController {
        let channel = FlutterMethodChannel(
          name: "com.multimodel.client/deeplink",
          binaryMessenger: controller.binaryMessenger
        )
        channel.invokeMethod("onDeepLink", arguments: url.absoluteString)
      }
      return true
    }
    return super.application(app, open: url, options: options)
  }
}
