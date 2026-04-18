import UIKit
import Flutter
import AVFoundation
import CoreML
import Metal

@objc class HardwareCheckerPlugin: NSObject, FlutterPlugin {
    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.example.ai_assistant/hardware", binaryMessenger: registrar.messenger())
        let instance = HardwareCheckerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getDeviceEnv":
            result(getDeviceEnv())
        case "checkMetalAvailability":
            result(checkMetalSupport())
        case "getHardwareInfo":
            result(getHardwareInfo())
        case "checkFeature":
            if let args = call.arguments as? [String: Any],
               let feature = args["feature"] as? String {
                result(checkFeature(feature: feature))
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Feature argument missing", details: nil))
            }
        case "getAvailableMemory":
            result(getAvailableMemory())
        case "getAvailableStorage":
            result(getAvailableStorage())
        case "getGpuInfo", "getGPUInfo":
            result(getGPUInfo())
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    /// 获取设备环境信息（与 Dart 端 DeviceEnv 兼容）
    private func getDeviceEnv() -> [String: Any?] {
        var env: [String: Any?] = [:]

        // CPU架构
        #if arch(arm64)
        env["cpuArch"] = "arm64"
        #else
        env["cpuArch"] = "x86_64"
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
            // iOS 设备使用统一内存，GPU 可用内存约为系统内存的一半
            env["gpuMemoryMB"] = Int(totalMemory / 1024 / 1024 / 2)
        }

        // CUDA 信息（iOS 不支持）
        env["isCudaAvailable"] = false
        env["cudaDeviceCount"] = 0

        return env
    }

    // 获取硬件信息
    private func getHardwareInfo() -> [String: Any] {
        var info: [String: Any] = [:]

        // 设备名称
        info["deviceName"] = UIDevice.current.name

        // 系统版本
        info["osVersion"] = UIDevice.current.systemVersion

        // CPU架构
        #if arch(arm64)
        info["cpuArchitecture"] = "arm64"
        #else
        info["cpuArchitecture"] = "x86_64"
        #endif

        // CPU核心数
        info["cpuCores"] = ProcessInfo.processInfo.processorCount

        // 内存信息
        let totalMemory = ProcessInfo.processInfo.physicalMemory
        info["totalRamMB"] = totalMemory / 1024 / 1024

        // 可用内存（估算）
        let freeMemory = getFreeMemory()
        info["availableRamMB"] = freeMemory / 1024 / 1024

        // 存储空间
        let storageInfo = getStorageInfo()
        info["totalStorageGB"] = storageInfo.total
        info["availableStorageGB"] = storageInfo.available

        // 支持的硬件特性
        var features: [String] = []

        // 检查Metal支持
        if checkMetalSupport() {
            features.append("metal")
        }

        // 检查NEON支持（ARM设备都支持）
        #if arch(arm64)
        features.append("neon")
        #endif

        // 检查CoreML支持
        if #available(iOS 12.0, *) {
            features.append("coreml")
        }

        info["supportedFeatures"] = features

        // GPU信息
        let gpuInfo = getGPUInfo()
        if let gpuName = gpuInfo["name"] as? String {
            info["gpuName"] = gpuName
        }
        if let gpuMemory = gpuInfo["memoryMB"] as? Int {
            info["gpuMemoryMB"] = gpuMemory
        }

        return info
    }

    // 检查特定硬件特性
    private func checkFeature(feature: String) -> Bool {
        switch feature.lowercased() {
        case "gpu":
            return checkMetalSupport()
        case "metal":
            return checkMetalSupport()
        case "neon":
            #if arch(arm64)
            return true
            #else
            return false
            #endif
        case "coreml":
            if #available(iOS 12.0, *) {
                return true
            }
            return false
        default:
            return false
        }
    }

    // 获取可用内存
    private func getAvailableMemory() -> UInt64 {
        var pageStats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)

        let result = withUnsafeMutablePointer(to: &pageStats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }

        if result == KERN_SUCCESS {
            let pageSize = UInt64(vm_kernel_page_size)
            let freePages = UInt64(pageStats.free_count)
            return freePages * pageSize
        }

        return 0
    }

    // 获取存储信息
    private func getStorageInfo() -> (total: Int, available: Int) {
        let fileURL = URL(fileURLWithPath: NSHomeDirectory())
        var totalSpace: Int64 = 0
        var availableSpace: Int64 = 0

        do {
            let values = try fileURL.resourceValues(forKeys: [
                .volumeTotalCapacityKey,
                .volumeAvailableCapacityKey
            ])

            totalSpace = values.volumeTotalCapacity ?? 0
            availableSpace = values.volumeAvailableCapacity ?? 0
        } catch {
            print("Error getting storage info: \(error)")
        }

        return (
            total: Int(totalSpace / 1024 / 1024 / 1024),
            available: Int(availableSpace / 1024 / 1024 / 1024)
        )
    }

    // 检查Metal支持
    private func checkMetalSupport() -> Bool {
        let device = MTLCreateSystemDefaultDevice()
        return device != nil
    }

    // 获取GPU信息
    private func getGPUInfo() -> [String: Any] {
        var gpuInfo: [String: Any] = [:]

        guard let device = MTLCreateSystemDefaultDevice() else {
            return gpuInfo
        }

        gpuInfo["name"] = device.name

        // 估算GPU内存（iOS设备通常共享系统内存）
        // 根据设备型号估算
        let totalMemory = ProcessInfo.processInfo.physicalMemory

        // iOS设备GPU通常可以使用系统内存的一部分
        let estimatedGPUMemory = totalMemory / 2 // 保守估计

        gpuInfo["memoryMB"] = Int(estimatedGPUMemory / 1024 / 1024)

        return gpuInfo
    }
}
