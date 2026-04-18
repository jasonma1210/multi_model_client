import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // 注册硬件检查器插件
    HardwareCheckerPlugin.register(with: self.registrar(forPlugin: "HardwareCheckerPlugin")!)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
