import Cocoa
import FlutterMacOS
import Foundation
import Metal

public class HardwareDetector: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "com.example.ai_assistant/hardware",
      binaryMessenger: registrar.messenger
    )
    let instance = HardwareDetector()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getDeviceEnv":
      result(getDeviceEnv())
    case "checkMetalAvailability":
      result(checkMetalAvailability())
    case "getGpuInfo":
      result(getGpuInfo())
    default:
      result(FlutterMethodNotImplemented)
    }
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
      #if os(macOS)
        if #available(macOS 10.14, *) {
          env["gpuMemoryMB"] = Int(device.recommendedMaxWorkingSetSize / 1024 / 1024)
        }
      #elseif os(iOS)
        // iOS设备使用当前已分配内存估算
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4

        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
          $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
            task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
          }
        }

        if kerr == KERN_SUCCESS {
          env["gpuMemoryMB"] = Int(info.resident_size / 1024 / 1024)
        }
      #endif

      // Metal版本
      env["metalVersion"] = "Metal \(device.supportsFamily(.common) ? "3" : "2")"
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
    gpuInfo["supportsRayTracing"] = device.supportsRaytracing
    gpuInfo["supportsMeshShaders"] = false // Metal没有mesh shaders概念

    #if os(macOS)
    if #available(macOS 10.15, *) {
      gpuInfo["maxThreadsPerThreadgroup"] = device.maxThreadsPerThreadgroup.width
      gpuInfo["maxBufferLength"] = device.maxBufferLength
    }
    #endif

    // 统一内存架构标识
    gpuInfo["unifiedMemory"] = true

    #if os(macOS)
    if #available(macOS 10.14, *) {
      gpuInfo["recommendedMaxWorkingSetSize"] = device.recommendedMaxWorkingSetSize
    }
    #endif

    return gpuInfo
  }
}
