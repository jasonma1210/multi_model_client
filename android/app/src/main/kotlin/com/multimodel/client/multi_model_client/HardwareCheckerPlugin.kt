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
import kotlin.math.roundToInt

class HardwareCheckerPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        // ★ 修复：Channel 名必须与 Dart 端一致
        // Dart 端（hardware_compatibility_checker.dart / hardware_checker_channel.dart）使用 'hardware_checker'
        channel = MethodChannel(binding.binaryMessenger, "hardware_checker")
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
            // ===== 新增：CPU 特性检测 =====
            "getCpuFeatures" -> {
                result.success(getCpuFeatures())
            }
            "getChipVendor" -> {
                result.success(getChipVendor())
            }
            "checkNpuAvailability" -> {
                result.success(checkNpuAvailability())
            }
            // ===== 新增：大核信息检测（骁龙 8 Elite 优化）=====
            "getBigCoreInfo" -> {
                result.success(getBigCoreInfo())
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

    // 获取内存信息（优先使用 /proc/meminfo，更可靠）
    private fun getMemoryInfo(): MemoryInfo {
        // 方法1: 读取 /proc/meminfo（最可靠，适用于所有 Android 设备）
        try {
            val procMemInfo = readProcMemInfo()
            if (procMemInfo != null) {
                return procMemInfo
            }
        } catch (e: Exception) {
            // 降级到 ActivityManager
        }

        // 方法2: 使用 ActivityManager（降级方案）
        val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val memInfo = ActivityManager.MemoryInfo()
        activityManager.getMemoryInfo(memInfo)

        val totalMB = (memInfo.totalMem / 1024L / 1024L).toInt()
        val availableMB = (memInfo.availMem / 1024L / 1024L).toInt()

        return MemoryInfo(totalMB, availableMB)
    }

    // 从 /proc/meminfo 读取内存信息
    private fun readProcMemInfo(): MemoryInfo? {
        return try {
            val file = File("/proc/meminfo")
            if (!file.exists()) return null

            var totalKB = 0L
            var availableKB = 0L

            file.readLines().forEach { line ->
                when {
                    line.startsWith("MemTotal:") -> {
                        totalKB = line.split("\\s+".toRegex())[1].toLongOrNull() ?: 0L
                    }
                    line.startsWith("MemAvailable:") -> {
                        availableKB = line.split("\\s+".toRegex())[1].toLongOrNull() ?: 0L
                    }
                }
            }

            if (totalKB > 0) {
                val totalMB = (totalKB / 1024).toInt()
                val availableMB = (availableKB / 1024).toInt()
                MemoryInfo(totalMB, availableMB)
            } else {
                null
            }
        } catch (e: Exception) {
            null
        }
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
    // ★ 骁龙 8 Elite 5 优化：Vulkan 是 Android GPU 加速的关键
    // 纯 CPU 推理连芯片实力 1/10 都发挥不出来
    private fun checkVulkanSupport(): Boolean {
        // 方法1：尝试加载 libvulkan.so（最可靠）
        try {
            System.loadLibrary("vulkan")
            return true
        } catch (e: UnsatisfiedLinkError) {
            // 方法2：检查 /system/lib64 下是否有 Vulkan 库
            val vulkanLib = File("/system/lib64/libvulkan.so")
            if (vulkanLib.exists()) return true

            // 方法3：检查 /vendor/lib64（某些设备把驱动放在 vendor 分区）
            val vendorVulkan = File("/vendor/lib64/libvulkan.so")
            if (vendorVulkan.exists()) return true
        }
        return false
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

    // ════════════════════════════════════════════════════════════════════════
    //  新增：CPU 特性检测 + 芯片厂商识别 + NPU 检测（多维度动态适配核心）
    // ════════════════════════════════════════════════════════════════════════

    /// 获取 CPU 特性（DotProd, i8mm, SME 等）
    private fun getCpuFeatures(): Map<String, Any> {
        val features = mutableMapOf<String, Any>()

        // 读取 /proc/cpuinfo 获取 CPU 特性
        try {
            val cpuInfoFile = File("/proc/cpuinfo")
            if (cpuInfoFile.exists()) {
                val cpuInfo = cpuInfoFile.readText()

                // 检测 ARM 特性标志
                val hasNeon = cpuInfo.contains("neon") || cpuInfo.contains("asimd")
                val hasDotProd = cpuInfo.contains("dotprod")
                val hasI8mm = cpuInfo.contains("i8mm")
                val hasSme = cpuInfo.contains("sme")
                val hasSve = cpuInfo.contains("sve")
                val hasSve2 = cpuInfo.contains("sve2")

                features["neon"] = hasNeon
                features["dotprod"] = hasDotProd
                features["i8mm"] = hasI8mm
                features["sme"] = hasSme
                features["sve"] = hasSve
                features["sve2"] = hasSve2

                // 提取 CPU 型号
                val cpuModel = Regex("model name\\s*:\\s*(.+)").find(cpuInfo)?.groupValues?.get(1)
                    ?: Regex("Hardware\\s*:\\s*(.+)").find(cpuInfo)?.groupValues?.get(1)
                    ?: "Unknown"
                features["cpuModel"] = cpuModel.trim()
            } else {
                // 默认值
                features["neon"] = true
                features["dotprod"] = false
                features["i8mm"] = false
                features["sme"] = false
                features["sve"] = false
                features["sve2"] = false
                features["cpuModel"] = "Unknown"
            }
        } catch (e: Exception) {
            features["neon"] = true
            features["dotprod"] = false
            features["i8mm"] = false
            features["sme"] = false
            features["sve"] = false
            features["sve2"] = false
            features["cpuModel"] = "Unknown"
            features["error"] = (e.message ?: "Unknown error")
        }

        // 架构信息
        features["architecture"] = Build.SUPPORTED_ABIS.firstOrNull() ?: "arm64-v8a"

        return features
    }

    /// 获取芯片厂商（高通、联发科、华为等）
    private fun getChipVendor(): Map<String, Any> {
        val vendorInfo = mutableMapOf<String, Any>()

        val board = Build.BOARD.lowercase()
        val hardware = Build.HARDWARE.lowercase()
        val manufacturer = Build.MANUFACTURER.lowercase()

        // 厂商识别逻辑
        val vendor = when {
            // 高通
            board.contains("qcom") || hardware.contains("qcom") ||
            hardware.contains("sc8280") || hardware.contains("sm8") -> "QUALCOMM"

            // 联发科
            board.contains("mt") || hardware.contains("mt") ||
            hardware.contains("dimensity") -> "MEDIATEK"

            // 华为海思
            board.contains("hi") || hardware.contains("kirin") ||
            hardware.contains("hi36") || manufacturer.contains("huawei") -> "HUAWEI"

            // 三星
            board.contains("exynos") || hardware.contains("exynos") ||
            hardware.contains("s5e") -> "SAMSUNG"

            // 谷歌 Tensor
            board.contains("tensor") || hardware.contains("tensor") ||
            hardware.contains("gs101") -> "GOOGLE"

            // 苹果（虽然 Android 不太可能）
            board.contains("apple") -> "APPLE"

            else -> "GENERIC"
        }

        vendorInfo["vendor"] = vendor
        vendorInfo["board"] = Build.BOARD
        vendorInfo["hardware"] = Build.HARDWARE
        vendorInfo["model"] = Build.MODEL
        vendorInfo["manufacturer"] = Build.MANUFACTURER

        // 高通特定信息
        if (vendor == "QUALCOMM") {
            vendorInfo["gpuArch"] = getAdrenoArch()
            vendorInfo["npuName"] = getQualcommNpuName()
        }

        return vendorInfo
    }

    /// 获取高通 Adreno GPU 架构版本
    private fun getAdrenoArch(): String {
        val renderer = try {
            android.opengl.GLES20.glGetString(android.opengl.GLES20.GL_RENDERER)
        } catch (e: Exception) { null }

        return when {
            renderer?.contains("Adreno 7") == true -> "Adreno7xx"  // 骁龙 8 Elite
            renderer?.contains("Adreno 6") == true -> "Adreno6xx"  // 骁龙 8 Gen 3/2
            renderer?.contains("Adreno 5") == true -> "Adreno5xx"  // 骁龙 888/870
            renderer?.contains("Adreno 4") == true -> "Adreno4xx"  // 骁龙 765G 等
            renderer?.contains("Adreno 3") == true -> "Adreno3xx"  // 较老
            else -> "Unknown"
        }
    }

    /// 获取高通 NPU 名称
    private fun getQualcommNpuName(): String {
        // 高通 NPU 命名规则
        val hardware = Build.HARDWARE.lowercase()
        return when {
            hardware.contains("sm8750") -> "Hexagon 780"  // 骁龙 8 Elite
            hardware.contains("sm8650") -> "Hexagon 770"  // 骁龙 8 Gen 3
            hardware.contains("sm8550") -> "Hexagon 760"  // 骁龙 8 Gen 2
            hardware.contains("sm8475") -> "Hexagon 750"  // 骁龙 8+ Gen 1
            hardware.contains("sm8450") -> "Hexagon 730"  // 骁龙 8 Gen 1
            else -> "Hexagon (Unknown)"
        }
    }

    /// 检测 NPU 可用性（高通 QNN / 联发科 NeuroPilot / 华为 HiAI）
    private fun checkNpuAvailability(): Map<String, Any> {
        val npuInfo = mutableMapOf<String, Any>()

        val vendorInfo = getChipVendor()
        val vendor = vendorInfo["vendor"] as? String ?: "GENERIC"

        npuInfo["vendor"] = vendor
        npuInfo["available"] = false
        npuInfo["runtime"] = "none"
        npuInfo["note"] = ""

        when (vendor) {
            "QUALCOMM" -> {
                // 高通：检测 QNN (Qualcomm AI Stack) 运行时
                // 注意：需要系统内置 QNN 驱动，用户应用无法强制安装
                val hasQnn = checkQnnRuntime()
                npuInfo["available"] = hasQnn
                npuInfo["runtime"] = if (hasQnn) "QNN_HTP" else "none"
                npuInfo["note"] = if (hasQnn) "高通 QNN 运行时可用，推理速度极快" else "系统未安装 QNN 驱动，使用 GPU/CPU 回退"
            }
            "MEDIATEK" -> {
                // 联发科：检测 NeuroPilot 运行时
                val hasNeuroPilot = checkNeuroPilotRuntime()
                npuInfo["available"] = hasNeuroPilot
                npuInfo["runtime"] = if (hasNeuroPilot) "NeuroPilot" else "none"
                npuInfo["note"] = if (hasNeuroPilot) "联发科 NeuroPilot 可用" else "系统未安装 NeuroPilot 驱动"
            }
            "HUAWEI" -> {
                // 华为：检测 HiAI/CANN 运行时
                val hasHiAi = checkHiAiRuntime()
                npuInfo["available"] = hasHiAi
                npuInfo["runtime"] = if (hasHiAi) "HiAI" else "none"
                npuInfo["note"] = if (hasHiAi) "华为 HiAI NPU 可用" else "系统未安装 HiAI 驱动"
            }
            else -> {
                npuInfo["note"] = "当前芯片厂商不支持 NPU 加速"
            }
        }

        // 额外信息：检查 NNAPI（Android 标准 API）
        npuInfo["nnapiAvailable"] = Build.VERSION.SDK_INT >= Build.VERSION_CODES.P
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            // 使用反射获取 NNAPI 版本
            try {
                val neuralNetworksClass = Class.forName("android.hardware.neuralnetworks.NeuralNetworks")
                val getVersionMethod = neuralNetworksClass.getMethod("getVersion")
                npuInfo["nnapiVersion"] = getVersionMethod.invoke(null) as? String ?: "Unknown"
            } catch (e: Exception) {
                npuInfo["nnapiVersion"] = "Reflection failed: ${e.message}"
            }
        }

        return npuInfo
    }

    /// 检测高通 QNN 运行时是否可用
    private fun checkQnnRuntime(): Boolean {
        // 方法1：尝试加载 QNN 库
        return try {
            System.loadLibrary("QnnHtp")
            true
        } catch (e: UnsatisfiedLinkError) {
            // 方法2：检查 /vendor/lib64 下是否有 QNN 驱动
            try {
                val vendorLib = File("/vendor/lib64/libQnnHtp.so")
                vendorLib.exists()
            } catch (e2: Exception) {
                false
            }
        }
    }

    /// 检测联发科 NeuroPilot 运行时
    private fun checkNeuroPilotRuntime(): Boolean {
        return try {
            val neuroPilotLib = File("/vendor/lib64/libneuron.so")
            neuroPilotLib.exists()
        } catch (e: Exception) {
            false
        }
    }

    /// 检测华为 HiAI 运行时
    private fun checkHiAiRuntime(): Boolean {
        return try {
            val hiAiLib = File("/vendor/lib64/libhiai.so")
            hiAiLib.exists()
        } catch (e: Exception) {
            false
        }
    }

    // ════════════════════════════════════════════════════════════════════════
    //  新增：大核信息检测（骁龙 8 Elite 优化核心）
    // ════════════════════════════════════════════════════════════════════════

    /// 获取 CPU 大核信息
    /// ★ Android big.LITTLE 架构优化核心：
    ///   - EAS（能量感知调度）会把推理任务分配给小核，导致性能极差
    ///   - 必须显式设置线程数 = 大核数，避免"裸奔"在小核上
    ///   - 骁龙 8 Elite 5: 2×超大核(P) + 4×大核(M) + 2×小核(E) = 8 核
    private fun getBigCoreInfo(): Map<String, Any> {
        val info = mutableMapOf<String, Any>()
        val totalCores = Runtime.getRuntime().availableProcessors()
        info["totalCores"] = totalCores

        // 尝试从 /sys/devices/system/cpu/ 读取每个核心的最大频率
        // 大核频率通常 > 小核频率
        var bigCoreCount = 0
        var maxFreq = 0L
        val coreFreqs = mutableListOf<Int>()

        for (i in 0 until totalCores) {
            val freqFile = File("/sys/devices/system/cpu/cpu$i/cpufreq/cpuinfo_max_freq")
            val freq = if (freqFile.exists()) {
                try {
                    freqFile.readText().trim().toIntOrNull() ?: 0
                } catch (e: Exception) {
                    0
                }
            } else {
                0
            }
            coreFreqs.add(freq)
            if (freq > maxFreq) maxFreq = freq.toLong()
        }

        // 大核 = 频率 >= 最大频率 70% 的核心
        // 骁龙 8 Elite: 超大核 ~4.47GHz, 大核 ~3.53GHz, 小核 ~2.47GHz
        // 70% 阈值: 4470 * 0.7 = 3129，大核和小核都能区分
        val bigCoreThreshold = (maxFreq * 0.7).toInt()
        for (freq in coreFreqs) {
            if (freq >= bigCoreThreshold && freq > 0) {
                bigCoreCount++
            }
        }

        // 如果无法检测频率，使用经验值
        if (bigCoreCount == 0) {
            bigCoreCount = (totalCores * 0.75).roundToInt()
        }

        info["bigCoreCount"] = bigCoreCount
        info["littleCoreCount"] = totalCores - bigCoreCount
        info["recommendedThreads"] = bigCoreCount.coerceIn(2, 10)
        info["maxFreqKHz"] = maxFreq
        info["coreFreqs"] = coreFreqs

        return info
    }
}
