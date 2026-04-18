import Cocoa
import FlutterMacOS
import Metal

@main
class AppDelegate: FlutterAppDelegate {
  private var hardwareChannel: FlutterMethodChannel?

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  override func applicationDidFinishLaunching(_ aNotification: Notification) {
    let controller : FlutterViewController = mainFlutterWindow?.contentViewController as! FlutterViewController

    // 注册硬件检测通道
    hardwareChannel = FlutterMethodChannel(
      name: "com.example.ai_assistant/hardware",
      binaryMessenger: controller.engine.binaryMessenger
    )

    hardwareChannel?.setMethodCallHandler { [weak self] (call, result) in
      switch call.method {
      case "getDeviceEnv":
        result(self?.getDeviceEnv())
      case "checkMetalAvailability":
        result(self?.checkMetalAvailability() ?? false)
      case "getGpuInfo":
        result(self?.getGpuInfo())
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    super.applicationDidFinishLaunching(aNotification)
  }

  /// 获取设备环境信息
  private func getDeviceEnv() -> [String: Any?] {
    var env: [String: Any?] = [:]

    // CPU架构
    #if arch(arm64)
      env["cpuArch"] = "arm64"
    #elseif arch(x86_64)
      env["cpuArch"] = "x86_64"
    #else
      env["cpuArch"] = "unknown"
    #endif

    // CPU核心数
    env["cpuCores"] = ProcessInfo.processInfo.processorCount

    // 总内存（MB）
    let totalMemory = ProcessInfo.processInfo.physicalMemory
    env["totalMemoryMB"] = Int(totalMemory / 1024 / 1024)

    // Metal信息
    let metalDevice = MTLCreateSystemDefaultDevice()
    env["isMetalAvailable"] = metalDevice != nil

    if let device = metalDevice {
      env["gpuName"] = device.name

      // 获取推荐的最大工作集大小（统一内存）
      if #available(macOS 10.14, *) {
        env["gpuMemoryMB"] = Int(device.recommendedMaxWorkingSetSize / 1024 / 1024)
      }

      // Metal版本
      env["metalVersion"] = "Metal 2"
    }

    return env
  }

  /// 检查Metal可用性
  private func checkMetalAvailability() -> Bool {
    return MTLCreateSystemDefaultDevice() != nil
  }

  /// 获取GPU详细信息
  private func getGpuInfo() -> [String: Any?] {
    var gpuInfo: [String: Any?] = [:]

    guard let device = MTLCreateSystemDefaultDevice() else {
      gpuInfo["available"] = false
      return gpuInfo
    }

    gpuInfo["available"] = true
    gpuInfo["name"] = device.name
    gpuInfo["vendor"] = "Apple"

    // 设备特性
    if #available(macOS 11.0, *) {
      gpuInfo["supportsRayTracing"] = device.supportsRaytracing
    } else {
      gpuInfo["supportsRayTracing"] = false
    }

    if #available(macOS 10.15, *) {
      gpuInfo["maxThreadsPerThreadgroup"] = device.maxThreadsPerThreadgroup.width
      gpuInfo["maxBufferLength"] = device.maxBufferLength
    }

    // 统一内存架构标识
    gpuInfo["unifiedMemory"] = true

    if #available(macOS 10.14, *) {
      gpuInfo["recommendedMaxWorkingSetSize"] = device.recommendedMaxWorkingSetSize
    }

    return gpuInfo
  }
}
