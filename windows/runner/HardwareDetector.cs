using System;
using System.Collections.Generic;
using System.Management;
using System.Runtime.InteropServices;
using System.Text.Json;

namespace multi_model_client
{
    public class HardwareDetector
    {
        private static readonly JsonSerializerOptions JsonOptions = new JsonSerializerOptions
        {
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
            WriteIndented = false
        };

        public static string GetDeviceEnv()
        {
            var env = new Dictionary<string, object>();

            try
            {
                // CPU架构
                env["cpuArch"] = IntPtr.Size == 8 ? "x86_64" : "x86";

                // CPU核心数
                env["cpuCores"] = Environment.ProcessorCount;

                // 总内存（MB）
                using (var searcher = new ManagementObjectSearcher("select * from Win32_ComputerSystem"))
                {
                    foreach (ManagementObject obj in searcher.Get())
                    {
                        long totalMemory = Convert.ToInt64(obj["TotalPhysicalMemory"]);
                        env["totalMemoryMB"] = totalMemory / 1024 / 1024;
                        break;
                    }
                }

                // GPU信息
                var gpuList = new List<Dictionary<string, object>>();
                bool hasNvidiaGpu = false;

                using (var searcher = new ManagementObjectSearcher("select * from Win32_VideoController"))
                {
                    foreach (ManagementObject obj in searcher.Get())
                    {
                        var gpu = new Dictionary<string, object>
                        {
                            ["name"] = obj["Name"]?.ToString() ?? "Unknown",
                            ["driverVersion"] = obj["DriverVersion"]?.ToString() ?? "",
                            ["videoProcessor"] = obj["VideoProcessor"]?.ToString() ?? ""
                        };

                        // 显存
                        try
                        {
                            long adapterRAM = Convert.ToInt64(obj["AdapterRAM"]);
                            gpu["memoryMB"] = adapterRAM / 1024 / 1024;
                        }
                        catch
                        {
                            gpu["memoryMB"] = 0;
                        }

                        // 检测是否为NVIDIA显卡
                        string gpuName = obj["Name"]?.ToString()?.ToLower() ?? "";
                        if (gpuName.Contains("nvidia") || gpuName.Contains("geforce") || gpuName.Contains("rtx") || gpuName.Contains("gtx"))
                        {
                            hasNvidiaGpu = true;
                            gpu["vendor"] = "NVIDIA";

                            // 设置为主要GPU信息
                            env["gpuName"] = obj["Name"];
                            env["gpuMemoryMB"] = gpu["memoryMB"];
                        }

                        gpuList.Add(gpu);
                    }
                }

                env["gpus"] = gpuList;

                // CUDA检测
                bool cudaAvailable = hasNvidiaGpu && CheckCudaRuntime();
                env["isCudaAvailable"] = cudaAvailable;

                if (cudaAvailable)
                {
                    var cudaInfo = GetCudaInfo();
                    env["cudaVersion"] = cudaInfo.Version;
                    env["cudaDeviceCount"] = cudaInfo.DeviceCount;
                }
                else
                {
                    env["cudaDeviceCount"] = 0;
                }

                // Metal/CUDA 可用性标志
                env["isMetalAvailable"] = false; // Windows 不支持 Metal
            }
            catch (Exception ex)
            {
                env["error"] = ex.Message;
            }

            return JsonSerializer.Serialize(env, JsonOptions);
        }

        public static bool CheckCudaAvailability()
        {
            return CheckCudaRuntime();
        }

        public static string GetGpuInfo()
        {
            var gpuInfo = new Dictionary<string, object>();

            try
            {
                var gpuList = new List<Dictionary<string, object>>();

                using (var searcher = new ManagementObjectSearcher("select * from Win32_VideoController"))
                {
                    foreach (ManagementObject obj in searcher.Get())
                    {
                        var gpu = new Dictionary<string, object>
                        {
                            ["name"] = obj["Name"]?.ToString() ?? "Unknown",
                            ["driverVersion"] = obj["DriverVersion"]?.ToString() ?? "",
                            ["videoProcessor"] = obj["VideoProcessor"]?.ToString() ?? ""
                        };

                        try
                        {
                            long adapterRAM = Convert.ToInt64(obj["AdapterRAM"]);
                            gpu["memoryMB"] = adapterRAM / 1024 / 1024;
                        }
                        catch
                        {
                            gpu["memoryMB"] = 0;
                        }

                        gpuList.Add(gpu);
                    }
                }

                gpuInfo["gpus"] = gpuList;
                gpuInfo["available"] = gpuList.Count > 0;
            }
            catch (Exception ex)
            {
                gpuInfo["error"] = ex.Message;
            }

            return JsonSerializer.Serialize(gpuInfo, JsonOptions);
        }

        private static bool CheckCudaRuntime()
        {
            try
            {
                // 尝试加载CUDA运行时DLL
                // CUDA 12.x
                var handle = LoadLibrary("cudart64_12.dll");
                if (handle != IntPtr.Zero)
                {
                    FreeLibrary(handle);
                    return true;
                }

                // CUDA 11.x
                handle = LoadLibrary("cudart64_11.dll");
                if (handle != IntPtr.Zero)
                {
                    FreeLibrary(handle);
                    return true;
                }

                // 尝试通用名称
                handle = LoadLibrary("cudart64_110.dll");
                if (handle != IntPtr.Zero)
                {
                    FreeLibrary(handle);
                    return true;
                }

                handle = LoadLibrary("cudart64_120.dll");
                if (handle != IntPtr.Zero)
                {
                    FreeLibrary(handle);
                    return true;
                }

                return false;
            }
            catch
            {
                return false;
            }
        }

        private static (string Version, int DeviceCount) GetCudaInfo()
        {
            try
            {
                // 实际应用中应该通过CUDA Runtime API获取版本
                // 这里使用环境变量作为简化方案
                string cudaPath = Environment.GetEnvironmentVariable("CUDA_PATH");
                string cudaVersion = "Unknown";

                if (!string.IsNullOrEmpty(cudaPath))
                {
                    // 从路径提取版本号
                    string[] parts = cudaPath.Split('\\');
                    foreach (string part in parts)
                    {
                        if (part.StartsWith("v"))
                        {
                            cudaVersion = part.Substring(1);
                            break;
                        }
                    }
                }

                // GPU数量（简化版：通过WMI统计NVIDIA显卡数量）
                int deviceCount = 0;
                using (var searcher = new ManagementObjectSearcher("select * from Win32_VideoController"))
                {
                    foreach (ManagementObject obj in searcher.Get())
                    {
                        string name = obj["Name"]?.ToString()?.ToLower() ?? "";
                        if (name.Contains("nvidia") || name.Contains("geforce") || name.Contains("rtx") || name.Contains("gtx"))
                        {
                            deviceCount++;
                        }
                    }
                }

                return (cudaVersion, deviceCount);
            }
            catch
            {
                return ("Unknown", 0);
            }
        }

        [DllImport("kernel32.dll")]
        private static extern IntPtr LoadLibrary(string dllToLoad);

        [DllImport("kernel32.dll")]
        private static extern bool FreeLibrary(IntPtr hModule);
    }
}
