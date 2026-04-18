package com.multimodel.client.multi_model_client

import android.app.ActivityManager
import android.content.Context
import android.os.Build
import android.os.StatFs
import android.provider.Settings
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File

class HardwareCheckerPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "com.example.ai_assistant/hardware")
        channel.setMethodCallHandler(this)
        context = binding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getDeviceEnv" -> {
                result.success(getDeviceEnv())
            }
            "getHardwareInfo" -> {
                result.success(getHardwareInfo())
            }
            "checkMetalAvailability" -> {
                // Android 不支持 Metal
                result.success(false)
            }
            "checkCudaAvailability" -> {
                // Android 不支持 CUDA
                result.success(false)
            }
            "checkFeature" -> {
                val feature = call.argument<String>("feature")
                if (feature != null) {
                    result.success(checkFeature(feature))
                } else {
                    result.error("INVALID_ARGUMENTS", "Feature argument missing", null)
                }
            }
            "getAvailableMemory" -> {
                result.success(getAvailableMemory())
            }
            "getAvailableStorage" -> {
                result.success(getAvailableStorage())
            }
            "getGpuInfo", "getGPUInfo" -> {
                result.success(getGPUInfo())
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    /// 获取设备环境信息（与 Dart 端 DeviceEnv 兼容）
    private fun getDeviceEnv(): Map<String, Any?> {
        val env = mutableMapOf<String, Any?>()

        // CPU架构
        env["cpuArch"] = Build.SUPPORTED_ABIS.firstOrNull() ?: "arm64"

        // CPU核心数
        env["cpuCores"] = Runtime.getRuntime().availableProcessors()

        // 总内存（MB）
        val memoryInfo = getMemoryInfo()
        env["totalMemoryMB"] = memoryInfo.totalMB

        // GPU信息
        try {
            val renderer = android.opengl.GLES20.glGetString(android.opengl.GLES20.GL_RENDERER)
            env["gpuName"] = renderer ?: "Unknown GPU"
            env["gpuMemoryMB"] = (memoryInfo.totalMB / 3) // 估算 GPU 可用内存
        } catch (e: Exception) {
            env["gpuName"] = "Unknown GPU"
            env["gpuMemoryMB"] = 0
        }

        // Metal/CUDA 可用性（Android 不支持）
        env["isMetalAvailable"] = false
        env["isCudaAvailable"] = false
        env["cudaDeviceCount"] = 0

        return env
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    // 获取硬件信息
    private fun getHardwareInfo(): Map<String, Any> {
        val info = mutableMapOf<String, Any>()

        // 设备名称
        info["deviceName"] = "${Build.MANUFACTURER} ${Build.MODEL}"

        // 系统版本
        info["osVersion"] = "Android ${Build.VERSION.RELEASE}"

        // CPU架构
        info["cpuArchitecture"] = Build.SUPPORTED_ABIS.firstOrNull() ?: "arm64-v8a"

        // CPU核心数
        info["cpuCores"] = Runtime.getRuntime().availableProcessors()

        // 内存信息
        val memoryInfo = getMemoryInfo()
        info["totalRamMB"] = memoryInfo.totalMB
        info["availableRamMB"] = memoryInfo.availableMB

        // 存储空间
        val storageInfo = getStorageInfo()
        info["totalStorageGB"] = storageInfo.totalGB
        info["availableStorageGB"] = storageInfo.availableGB

        // 支持的硬件特性
        val features = mutableListOf<String>()

        // 检查GPU支持
        if (checkGPUFeatures()) {
            features.add("gpu")
        }

        // 检查Vulkan支持
        if (checkVulkanSupport()) {
            features.add("vulkan")
        }

        // 检查NEON支持
        if (checkNeonSupport()) {
            features.add("neon")
        }

        // 检查NNAPI支持
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            features.add("nnapi")
        }

        info["supportedFeatures"] = features

        // GPU信息
        val gpuInfo = getGPUInfo()
        info.putAll(gpuInfo)

        return info
    }

    // 检查特定硬件特性
    private fun checkFeature(feature: String): Boolean {
        return when (feature.lowercase()) {
            "gpu" -> checkGPUFeatures()
            "vulkan" -> checkVulkanSupport()
            "neon" -> checkNeonSupport()
            "nnapi" -> Build.VERSION.SDK_INT >= Build.VERSION_CODES.P
            else -> false
        }
    }

    // 获取内存信息
    private fun getMemoryInfo(): MemoryInfo {
        val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val memInfo = ActivityManager.MemoryInfo()
        activityManager.getMemoryInfo(memInfo)

        val totalMB = memInfo.totalMem / 1024 / 1024
        val availableMB = memInfo.availMem / 1024 / 1024

        return MemoryInfo(totalMB.toInt(), availableMB.toInt())
    }

    // 获取可用内存
    private fun getAvailableMemory(): Int {
        val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val memInfo = ActivityManager.MemoryInfo()
        activityManager.getMemoryInfo(memInfo)
        return (memInfo.availMem / 1024 / 1024).toInt()
    }

    // 获取存储信息
    private fun getStorageInfo(): StorageInfo {
        val path = File(context.filesDir.absolutePath)
        val stat = StatFs(path.path)

        val totalGB = stat.totalBytes / 1024 / 1024 / 1024
        val availableGB = stat.availableBytes / 1024 / 1024 / 1024

        return StorageInfo(totalGB.toInt(), availableGB.toInt())
    }

    // 获取可用存储
    private fun getAvailableStorage(): Int {
        val path = File(context.filesDir.absolutePath)
        val stat = StatFs(path.path)
        return (stat.availableBytes / 1024 / 1024 / 1024).toInt()
    }

    // 检查GPU特性
    private fun checkGPUFeatures(): Boolean {
        // Android设备通常都有GPU
        return true
    }

    // 检查Vulkan支持
    private fun checkVulkanSupport(): Boolean {
        return try {
            val lib = System.loadLibrary("vulkan")
            true
        } catch (e: UnsatisfiedLinkError) {
            false
        }
    }

    // 检查NEON支持
    private fun checkNeonSupport(): Boolean {
        // ARM设备通常都支持NEON
        return Build.SUPPORTED_ABIS.any { it.startsWith("arm") }
    }

    // 获取GPU信息
    private fun getGPUInfo(): Map<String, Any> {
        val info = mutableMapOf<String, Any>()

        try {
            // 获取GPU渲染器信息
            val renderer = android.opengl.GLES20.glGetString(android.opengl.GLES20.GL_RENDERER)
            val vendor = android.opengl.GLES20.glGetString(android.opengl.GLES20.GL_VENDOR)
            val version = android.opengl.GLES20.glGetString(android.opengl.GLES20.GL_VERSION)

            info["gpuName"] = renderer ?: "Unknown GPU"
            info["gpuVendor"] = vendor ?: "Unknown Vendor"
            info["gpuVersion"] = version ?: "Unknown Version"

            // 估算GPU内存（Android设备通常共享系统内存）
            val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            val memInfo = ActivityManager.MemoryInfo()
            activityManager.getMemoryInfo(memInfo)

            // 估算GPU可用的内存（通常为系统内存的一部分）
            val estimatedGPUMemoryMB = (memInfo.totalMem / 1024 / 1024 / 3).toInt()
            info["gpuMemoryMB"] = estimatedGPUMemoryMB

        } catch (e: Exception) {
            info["gpuName"] = "Unknown GPU"
            info["gpuMemoryMB"] = 0
        }

        return info
    }

    // 数据类
    private data class MemoryInfo(val totalMB: Int, val availableMB: Int)
    private data class StorageInfo(val totalGB: Int, val availableGB: Int)
}
