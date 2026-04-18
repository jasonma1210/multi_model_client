# Flutter AI助手完整实施方案

基于《基于 Flutter 的多端 AI 助手应用实现方案.md》文档，结合当前项目现状，制定完整实施方案。

---

## 一、当前项目状态分析

### 已有模块
✅ **模型下载管理器** (`ModelDownloadManager`)
- 支持HuggingFace和ModelScope基础搜索
- 下载进度跟踪
- 兼容性检查

✅ **模型推理引擎** (`ModelInferenceEngine`)
- llama.cpp基础集成
- 模型加载/卸载
- 文本生成（同步/流式）

✅ **模型仓库** (`ModelRepository`)
- 数据库CRUD操作

✅ **硬件兼容性检查器** (`HardwareCompatibilityChecker`)
- 基础兼容性检查

### 待完善/新增模块

#### 1️⃣ 环境检测与硬件加速 ⚠️
**现状：** 仅有基础检查
**缺失：**
- 完整的环境检测模块（CPU架构、核心数、内存、显存）
- Metal加速（macOS/iOS）
- CUDA加速（Windows）
- 多GPU调度

#### 2️⃣ 模型下载管理 ⚠️
**现状：** 基础下载功能
**缺失：**
- ModelScope完整API集成（模型列表、文件列表、断点续传）
- HuggingFace完整API集成
- 下载任务持久化（使用Isar）
- 模型元数据解析（参数量、层数、上下文窗口）
- 多文件下载（分片下载、并行下载）

#### 3️⃣ 量化级别自动匹配 ❌
**现状：** 无
**缺失：**
- 模型硬件需求基准库
- 量化级别匹配算法
- UI联动（推荐、禁用、说明）

#### 4️⃣ MCP生态集成 ⚠️
**现状：** 仅有MCP协议基础实现
**缺失：**
- MCP服务器全生命周期管理
- 内置预设服务器（git/github/slack/filesystem）
- 会话级工具隔离
- 工具调用确认机制

#### 5️⃣ 会话管理优化 ⚠️
**现状：** 基础会话管理
**缺失：**
- 会话级MCP工具配置
- 上下文记忆优化（按重要性/时间衰减）
- 工具调用历史记录

#### 6️⃣ FunASR语音识别 ❌
**现状：** 仅有Whisper引擎框架
**缺失：**
- FunASR端侧runtime编译
- Dart FFI绑定
- 实时流式识别
- 热词定制

---

## 二、核心模块实施方案

### 模块1：环境检测与硬件加速

#### 1.1 架构设计

```
lib/core/platform/
├── hardware/
│   ├── device_env.dart              # 设备环境数据模型
│   ├── hardware_detector.dart       # 硬件检测服务
│   └── hardware_checker_channel.dart # MethodChannel（已存在）
├── acceleration/
│   ├── metal_accelerator.dart       # Metal加速（macOS/iOS）
│   ├── cuda_accelerator.dart        # CUDA加速（Windows）
│   └── acceleration_manager.dart    # 加速管理器
└── models/
    └── device_capabilities.dart     # 设备能力模型
```

#### 1.2 数据模型设计

**DeviceEnv（设备环境）**
```dart
class DeviceEnv {
  final String cpuArch;           // arm64/x86_64
  final int cpuCores;
  final int totalMemoryMB;
  final int? gpuMemoryMB;         // macOS混合内存/Windows显存
  final bool isMetalAvailable;     // Metal可用性
  final bool isCudaAvailable;      // CUDA可用性
  final int cudaDeviceCount;       // CUDA设备数量
  final String? gpuName;           // GPU型号
  final String? cudaVersion;       // CUDA版本
}
```

#### 1.3 MethodChannel原生实现

**macOS/iOS (Swift)**
```swift
// macos/Classes/HardwareDetector.swift
import Foundation
import Metal

class HardwareDetector: NSObject, FlutterPlugin {
  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "com.example.ai_assistant/hardware",
      binaryMessenger: registrar.messenger()
    )
    let instance = HardwareDetector()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getDeviceEnv":
      result(getDeviceEnv())
    case "getMetalInfo":
      result(getMetalInfo())
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func getDeviceEnv() -> [String: Any?] {
    let processInfo = ProcessInfo.processInfo

    // CPU信息
    var cpuInfo = host_basic_info()
    var count = mach_msg_type_number_t(MemoryLayout<host_basic_info>.size) / 4
    let host = mach_host_self()
    host_statistics(host, HOST_BASIC_INFO, unsafeBitCast(&cpuInfo, to: host_info_t), &count)

    // 内存信息
    let totalMemory = processInfo.physicalMemory / 1024 / 1024

    // Metal信息
    let metalDevice = MTLCreateSystemDefaultDevice()
    let gpuMemory = metalDevice?.recommendedMaxWorkingSetSize ?? 0

    return [
      "cpuArch": cpuInfo.cpu_type == CPU_TYPE_ARM64 ? "arm64" : "x86_64",
      "cpuCores": processInfo.processorCount,
      "totalMemoryMB": totalMemory,
      "gpuMemoryMB": gpuMemory / 1024 / 1024,
      "isMetalAvailable": metalDevice != nil,
      "gpuName": metalDevice?.name,
    ]
  }
}
```

**Windows (C#)**
```csharp
// windows/runner/HardwareDetector.cs
using System.Management;
using Newtonsoft.Json;

public class HardwareDetector
{
    public static string GetDeviceEnv()
    {
        var env = new Dictionary<string, object>();

        // CPU信息
        using (var searcher = new ManagementObjectSearcher("select * from Win32_Processor"))
        {
            foreach (ManagementObject obj in searcher.Get())
            {
                env["cpuArch"] = obj["AddressWidth"].ToString() == "64" ? "x86_64" : "x86";
                env["cpuCores"] = int.Parse(obj["NumberOfCores"].ToString());
                break;
            }
        }

        // 内存信息
        using (var searcher = new ManagementObjectSearcher("select * from Win32_ComputerSystem"))
        {
            foreach (ManagementObject obj in searcher.Get())
            {
                env["totalMemoryMB"] = (long.Parse(obj["TotalPhysicalMemory"].ToString()) / 1024 / 1024);
                break;
            }
        }

        // NVIDIA显卡信息
        try
        {
            using (var searcher = new ManagementObjectSearcher("select * from Win32_VideoController"))
            {
                var gpuList = new List<Dictionary<string, object>>();
                foreach (ManagementObject obj in searcher.Get())
                {
                    var gpu = new Dictionary<string, object>
                    {
                        ["name"] = obj["Name"].ToString(),
                        ["memoryMB"] = long.Parse(obj["AdapterRAM"].ToString()) / 1024 / 1024
                    };
                    gpuList.Add(gpu);
                }
                env["gpus"] = gpuList;
                env["isCudaAvailable"] = gpuList.Any(g => g["name"].ToString().Contains("NVIDIA"));
            }
        }
        catch
        {
            env["isCudaAvailable"] = false;
        }

        return JsonConvert.SerializeObject(env);
    }
}
```

#### 1.4 Metal加速实现

**步骤1：编译带Metal后端的llama.cpp**

```bash
# macOS动态库编译
cmake -B build_metal \
  -DBUILD_SHARED_LIBS=ON \
  -DGGML_METAL=ON \
  -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
  -DCMAKE_BUILD_TYPE=Release
cmake --build build_metal --config Release

# iOS静态库编译
cmake -B build_ios \
  -DCMAKE_SYSTEM_NAME=iOS \
  -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=14.0 \
  -DBUILD_SHARED_LIBS=OFF \
  -DGGML_METAL=ON \
  -DCMAKE_BUILD_TYPE=Release
cmake --build build_ios --config Release
```

**步骤2：扩展LlamaInferenceEngine**

```dart
// lib/core/engines/llama_engine.dart
class LlamaInferenceEngine {
  late final DynamicLibrary _dylib;
  late final LoadModelDart _loadModel;
  late final IsMetalAvailableDart _isMetalAvailable;
  Pointer<Void>? _ctx;
  bool _isMetalEnabled = false;

  Future<void> initialize() async {
    // 加载动态库
    _dylib = DynamicLibrary.open(Platform.isMacOS || Platform.isIOS
        ? 'libllama.dylib'
        : Platform.isWindows
            ? 'llama.dll'
            : 'libllama.so');

    // 绑定函数
    _loadModel = _dylib.lookupFunction<LoadModelC, LoadModelDart>('load_model');

    // 检测Metal可用性
    if (Platform.isMacOS || Platform.isIOS) {
      _isMetalAvailable = _dylib.lookupFunction<IsMetalAvailableC, IsMetalAvailableDart>(
        'ggml_metal_supports'
      );
      _isMetalEnabled = _isMetalAvailable() == 1;
    }
  }

  Future<void> loadModel(LlamaModel config) async {
    int finalGpuLayers = config.gpuLayers;

    // Metal自动全量offload
    if (_isMetalEnabled && config.enableMetal) {
      finalGpuLayers = 99;
      debugPrint('Metal加速已启用，全量offload到GPU');
    }

    final pathPtr = config.modelPath.toNativeUtf8();
    _ctx = _loadModel(
      pathPtr,
      config.contextSize,
      finalGpuLayers,
    );
    calloc.free(pathPtr);
  }
}

// C函数定义
typedef IsMetalAvailableC = Int32 Function();
typedef IsMetalAvailableDart = int Function();
```

#### 1.5 CUDA加速实现

```dart
// lib/core/acceleration/cuda_accelerator.dart
class CudaAccelerator {
  final DeviceEnv deviceEnv;

  CudaAccelerator(this.deviceEnv);

  /// 计算最优GPU层数
  Future<int> calculateOptimalGpuLayers(ModelConfig config) async {
    if (!deviceEnv.isCudaAvailable || deviceEnv.gpuMemoryMB == null) {
      return 0;
    }

    // 量化系数映射
    const Map<String, double> quantCoefficient = {
      "Q2_K": 0.25,
      "Q3_K_L": 0.3,
      "Q4_K_M": 0.4,
      "Q5_K_M": 0.5,
      "Q8_0": 0.8,
      "FP16": 1.0,
    };

    // 计算每层所需显存
    int totalLayers = getModelTotalLayers(config.modelId);
    double modelTotalGB = getModelParamsGB(config.modelId);
    double coef = quantCoefficient[config.quantLevel] ?? 0.4;
    double layerMemMB = (modelTotalGB / totalLayers) * 1024 * coef;

    // 预留20%显存作为缓冲
    int availableMemMB = (deviceEnv.gpuMemoryMB! * 0.8).toInt();
    int maxLayers = (availableMemMB / layerMemMB).floor();

    return maxLayers.clamp(0, totalLayers);
  }

  int getModelTotalLayers(String modelId) {
    // 根据模型ID返回层数
    if (modelId.contains('7B')) return 35;
    if (modelId.contains('13B')) return 40;
    if (modelId.contains('70B')) return 80;
    return 32; // 默认
  }

  double getModelParamsGB(String modelId) {
    // 根据模型ID返回参数量（GB）
    if (modelId.contains('7B')) return 14.0;
    if (modelId.contains('13B')) return 26.0;
    if (modelId.contains('70B')) return 140.0;
    return 16.0; // 默认
  }
}
```

---

### 模块2：完善模型下载管理

#### 2.1 架构设计

```
lib/core/services/model_download/
├── model_download_manager.dart      # 主管理器（升级）
├── modelscope_api.dart              # ModelScope API客户端
├── huggingface_api.dart             # HuggingFace API客户端
├── download_task_manager.dart       # 下载任务管理（Isar持久化）
└── model_metadata_parser.dart       # 模型元数据解析器
```

#### 2.2 Isar数据模型

```dart
// lib/core/storage/models/download_task.dart
part 'download_task.g.dart';

@collection
class DownloadTask {
  Id id = Isar.autoIncrement;

  late String modelId;
  late String url;
  late String savePath;
  late String status;          // downloading, paused, completed, error
  late int progress;           // 0-100
  late int totalBytes;
  late int downloadedBytes;
  late DateTime createdAt;
  DateTime? completedAt;
  String? error;
  late String source;          // huggingface, modelscope
  String? quantLevel;          // Q4_K_M等
  Map<String, dynamic>? metadata;
}
```

#### 2.3 ModelScope完整API实现

```dart
// lib/core/services/model_download/modelscope_api.dart
class ModelScopeApi {
  final Dio _dio;
  final String baseUrl = 'https://modelscope.cn/api/v1';

  ModelScopeApi(this._dio);

  /// 搜索模型
  Future<List<ModelInfo>> searchModels({
    required String query,
    int page = 1,
    int pageSize = 20,
    String? task,
  }) async {
    final response = await _dio.get(
      '$baseUrl/models',
      queryParameters: {
        'name': query,
        'PageNumber': page,
        'PageSize': pageSize,
        if (task != null) 'task': task,
      },
    );

    final data = response.data['Data'];
    final models = data['Models'] as List;
    return models.map((m) => ModelInfo.fromModelScope(m)).toList();
  }

  /// 获取模型详情
  Future<ModelInfo> getModel(String modelId) async {
    final response = await _dio.get('$baseUrl/models/$modelId');
    return ModelInfo.fromModelScope(response.data['Data']);
  }

  /// 获取模型文件列表
  Future<List<ModelFile>> getModelFiles(String modelId) async {
    final response = await _dio.get(
      '$baseUrl/models/$modelId/repo/files',
      queryParameters: {'revision': 'master'},
    );

    final files = response.data['Data'] as List;
    return files.map((f) => ModelFile.fromJson(f, ModelSource.modelScope)).toList();
  }

  /// 获取下载链接
  String getDownloadUrl(String modelId, String filePath) {
    return 'https://modelscope.cn/models/$modelId/resolve/master/$filePath';
  }
}

class ModelFile {
  final String path;
  final int size;
  final String type;  // file, directory
  final String? sha;

  ModelFile({
    required this.path,
    required this.size,
    required this.type,
    this.sha,
  });

  factory ModelFile.fromJson(Map<String, dynamic> json, ModelSource source) {
    return ModelFile(
      path: json['path'] ?? json['name'],
      size: json['size'] ?? 0,
      type: json['type'] ?? 'file',
      sha: json['sha'],
    );
  }
}
```

#### 2.4 HuggingFace完整API实现

```dart
// lib/core/services/model_download/huggingface_api.dart
class HuggingFaceApi {
  final Dio _dio;
  final String baseUrl = 'https://huggingface.co/api';

  HuggingFaceApi(this._dio);

  /// 搜索模型
  Future<List<ModelInfo>> searchModels({
    required String query,
    int limit = 20,
    String? filter,
    String? author,
  }) async {
    final response = await _dio.get(
      '$baseUrl/models',
      queryParameters: {
        'search': query,
        'limit': limit,
        if (filter != null) 'filter': filter,
        if (author != null) 'author': author,
      },
    );

    return (response.data as List)
        .map((m) => ModelInfo.fromHuggingFace(m))
        .toList();
  }

  /// 获取模型详情
  Future<ModelInfo> getModel(String modelId) async {
    final response = await _dio.get('$baseUrl/models/$modelId');
    return ModelInfo.fromHuggingFace(response.data);
  }

  /// 获取模型文件列表
  Future<List<ModelFile>> getModelFiles(String modelId) async {
    final response = await _dio.get(
      '$baseUrl/models/$modelId/tree/main',
    );

    return (response.data as List)
        .map((f) => ModelFile.fromJson(f, ModelSource.huggingFace))
        .toList();
  }

  /// 获取下载链接
  String getDownloadUrl(String modelId, String filePath) {
    return 'https://huggingface.co/$modelId/resolve/main/$filePath';
  }
}
```

#### 2.5 下载任务管理器

```dart
// lib/core/services/model_download/download_task_manager.dart
class DownloadTaskManager {
  final Isar _isar;
  final Dio _dio;
  final Map<String, CancelToken> _cancelTokens = {};

  DownloadTaskManager(this._isar, this._dio);

  /// 创建下载任务
  Future<DownloadTask> createTask({
    required String modelId,
    required String url,
    required String savePath,
    required String source,
    String? quantLevel,
    Map<String, dynamic>? metadata,
  }) async {
    final task = DownloadTask()
      ..modelId = modelId
      ..url = url
      ..savePath = savePath
      ..status = 'pending'
      ..progress = 0
      ..totalBytes = 0
      ..downloadedBytes = 0
      ..createdAt = DateTime.now()
      ..source = source
      ..quantLevel = quantLevel
      ..metadata = metadata;

    await _isar.writeTxn(() => _isar.downloadTasks.put(task));
    return task;
  }

  /// 开始下载
  Future<void> startDownload(String taskId, {
    Function(DownloadTask)? onProgress,
  }) async {
    final task = await _isar.downloadTasks.get(int.parse(taskId));
    if (task == null) return;

    // 创建取消令牌
    final cancelToken = CancelToken();
    _cancelTokens[taskId] = cancelToken;

    try {
      // 更新状态
      await _updateTaskStatus(task.id, 'downloading');

      // 执行下载
      await _dio.download(
        task.url,
        task.savePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) async {
          final progress = total > 0 ? (received / total * 100).toInt() : 0;

          await _isar.writeTxn(() async {
            task.progress = progress;
            task.downloadedBytes = received;
            task.totalBytes = total;
            await _isar.downloadTasks.put(task);
          });

          onProgress?.call(task);
        },
      );

      // 标记完成
      await _isar.writeTxn(() async {
        task.status = 'completed';
        task.completedAt = DateTime.now();
        task.progress = 100;
        await _isar.downloadTasks.put(task);
      });
    } catch (e) {
      await _updateTaskStatus(task.id, 'error', error: e.toString());
    } finally {
      _cancelTokens.remove(taskId);
    }
  }

  /// 暂停下载
  Future<void> pauseDownload(String taskId) async {
    final cancelToken = _cancelTokens[taskId];
    cancelToken?.cancel('User paused');
    await _updateTaskStatus(int.parse(taskId), 'paused');
  }

  /// 恢复下载
  Future<void> resumeDownload(String taskId) async {
    final task = await _isar.downloadTasks.get(int.parse(taskId));
    if (task == null) return;

    await startDownload(taskId);
  }

  /// 取消下载
  Future<void> cancelDownload(String taskId) async {
    _cancelTokens[taskId]?.cancel('User cancelled');
    await _isar.writeTxn(() async {
      await _isar.downloadTasks.delete(int.parse(taskId));
    });
  }

  /// 获取所有下载任务
  Future<List<DownloadTask>> getAllTasks() async {
    return await _isar.downloadTasks.where().findAll();
  }

  /// 更新任务状态
  Future<void> _updateTaskStatus(int taskId, String status, {String? error}) async {
    await _isar.writeTxn(() async {
      final task = await _isar.downloadTasks.get(taskId);
      if (task != null) {
        task.status = status;
        if (error != null) task.error = error;
        await _isar.downloadTasks.put(task);
      }
    });
  }
}
```

---

### 模块3：量化级别自动匹配

#### 3.1 数据模型

```dart
// lib/core/models/model_hardware_requirement.dart
class ModelHardwareRequirement {
  final String modelId;
  final double paramsGB;        // FP16参数量（GB）
  final int totalLayers;        // 总层数
  final int minCtx;             // 最小上下文窗口
  final int recommendCtx;       // 推荐上下文窗口
  final Map<String, int> minMemoryMB;  // 各量化级别的最小内存需求

  const ModelHardwareRequirement({
    required this.modelId,
    required this.paramsGB,
    required this.totalLayers,
    required this.minCtx,
    required this.recommendCtx,
    required this.minMemoryMB,
  });
}

// 内置主流模型基准库
const Map<String, ModelHardwareRequirement> modelBaseLibrary = {
  "Qwen2.5-7B-Instruct": ModelHardwareRequirement(
    modelId: "Qwen2.5-7B-Instruct",
    paramsGB: 14.0,
    totalLayers: 35,
    minCtx: 2048,
    recommendCtx: 4096,
    minMemoryMB: {
      "Q2_K": 2048,
      "Q3_K_L": 3072,
      "Q4_K_M": 4096,
      "Q5_K_M": 5120,
      "Q8_0": 8192,
      "FP16": 16384,
    },
  ),
  "Llama3.1-8B-Instruct": ModelHardwareRequirement(
    modelId: "Llama3.1-8B-Instruct",
    paramsGB: 16.0,
    totalLayers: 32,
    minCtx: 2048,
    recommendCtx: 8192,
    minMemoryMB: {
      "Q2_K": 2560,
      "Q3_K_L": 3584,
      "Q4_K_M": 4608,
      "Q5_K_M": 5888,
      "Q8_0": 9216,
      "FP16": 18432,
    },
  ),
  // 更多模型...
};
```

#### 3.2 量化匹配器

```dart
// lib/core/services/quant_level_matcher.dart
class QuantLevelMatcher {
  final DeviceEnv deviceEnv;

  QuantLevelMatcher(this.deviceEnv);

  /// 匹配量化级别
  QuantMatchResult matchModel(ModelHardwareRequirement model) {
    // 1. 计算可用内存（预留30%系统内存）
    int availableMemoryMB = (deviceEnv.totalMemoryMB * 0.7).toInt();

    // 2. 叠加GPU内存（如果启用加速）
    if (deviceEnv.isMetalAvailable || deviceEnv.isCudaAvailable) {
      availableMemoryMB += deviceEnv.gpuMemoryMB ?? 0;
    }

    // 3. 过滤可用量化级别
    Map<String, int> validLevels = {};
    Map<String, int> invalidLevels = {};

    model.minMemoryMB.forEach((level, minMem) {
      if (minMem <= availableMemoryMB) {
        validLevels[level] = minMem;
      } else {
        invalidLevels[level] = minMem;
      }
    });

    // 4. 推荐最佳级别
    const List<String> recommendPriority = [
      "Q4_K_M",
      "Q5_K_M",
      "Q3_K_L",
      "Q8_0",
      "Q2_K",
      "FP16"
    ];

    String? recommendLevel;
    for (String level in recommendPriority) {
      if (validLevels.containsKey(level)) {
        recommendLevel = level;
        break;
      }
    }

    // 5. 移动端特殊适配
    if (Platform.isAndroid || Platform.isIOS) {
      if (validLevels.containsKey("Q3_K_L") && availableMemoryMB < 8192) {
        recommendLevel = "Q3_K_L";
      }
    }

    return QuantMatchResult(
      recommendLevel: recommendLevel ?? validLevels.keys.first,
      validLevels: validLevels,
      invalidLevels: invalidLevels,
      availableMemoryMB: availableMemoryMB,
    );
  }
}

class QuantMatchResult {
  final String recommendLevel;
  final Map<String, int> validLevels;
  final Map<String, int> invalidLevels;
  final int availableMemoryMB;

  QuantMatchResult({
    required this.recommendLevel,
    required this.validLevels,
    required this.invalidLevels,
    required this.availableMemoryMB,
  });
}
```

#### 3.3 UI集成

```dart
// lib/features/model/presentation/widgets/quant_level_selector.dart
class QuantLevelSelector extends ConsumerWidget {
  final ModelInfo model;
  final QuantMatchResult matchResult;
  final Function(String) onLevelSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('选择量化级别', style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 8),
        ...matchResult.validLevels.entries.map((entry) {
          final level = entry.key;
          final memMB = entry.value;
          final isRecommended = level == matchResult.recommendLevel;

          return RadioListTile<String>(
            title: Row(
              children: [
                Text(level),
                if (isRecommended) ...[
                  SizedBox(width: 8),
                  Chip(
                    label: Text('推荐', style: TextStyle(fontSize: 10)),
                    backgroundColor: Colors.green.shade100,
                  ),
                ],
              ],
            ),
            subtitle: Text('内存需求: ${(memMB / 1024).toStringAsFixed(1)} GB'),
            value: level,
            groupValue: matchResult.recommendLevel,
            onChanged: (value) => onLevelSelected(value!),
          );
        }),
        if (matchResult.invalidLevels.isNotEmpty) ...[
          Divider(),
          Text('不兼容的量化级别', style: TextStyle(color: Colors.grey)),
          ...matchResult.invalidLevels.entries.map((entry) {
            return ListTile(
              title: Text(entry.key, style: TextStyle(color: Colors.grey)),
              subtitle: Text(
                '需要 ${(entry.value / 1024).toStringAsFixed(1)} GB，当前可用 ${(matchResult.availableMemoryMB / 1024).toStringAsFixed(1)} GB',
                style: TextStyle(color: Colors.red),
              ),
              enabled: false,
            );
          }),
        ],
      ],
    );
  }
}
```

---

### 模块4：MCP生态集成

#### 4.1 MCP服务器管理器

```dart
// lib/core/protocols/mcp_server_manager.dart
class McpServerManager {
  final Isar _isar;
  final Map<String, McpClient> _connectedClients = {};
  final Map<String, Process> _runningProcesses = {};

  /// 初始化内置服务器
  Future<void> init() async {
    await _initBuiltinServers();
    await _autoStartEnabledServers();
  }

  /// 内置服务器预设
  Future<void> _initBuiltinServers() async {
    final builtinServers = [
      // Git服务器
      McpServerConfig()
        ..serverId = "git"
        ..name = "Git 代码管理"
        ..type = "stdio"
        ..command = "npx"
        ..args = ["-y", "@modelcontextprotocol/server-git"]
        ..env = {}
        ..isEnabled = false
        ..isAutoStart = false,

      // GitHub服务器
      McpServerConfig()
        ..serverId = "github"
        ..name = "GitHub"
        ..type = "stdio"
        ..command = "npx"
        ..args = ["-y", "@modelcontextprotocol/server-github"]
        ..env = {"GITHUB_PERSONAL_ACCESS_TOKEN": ""}
        ..isEnabled = false
        ..isAutoStart = false,

      // Slack服务器
      McpServerConfig()
        ..serverId = "slack"
        ..name = "Slack"
        ..type = "stdio"
        ..command = "npx"
        ..args = ["-y", "@modelcontextprotocol/server-slack"]
        ..env = {"SLACK_TOKEN": ""}
        ..isEnabled = false
        ..isAutoStart = false,

      // 文件系统服务器
      McpServerConfig()
        ..serverId = "filesystem"
        ..name = "本地文件系统"
        ..type = "stdio"
        ..command = "npx"
        ..args = ["-y", "@modelcontextprotocol/server-filesystem", "{working_dir}"]
        ..env = {}
        ..isEnabled = true
        ..isAutoStart = true,
    ];

    await _isar.writeTxn(() async {
      for (var server in builtinServers) {
        final exists = await _isar.mcpServerConfigs
            .filter()
            .serverIdEqualTo(server.serverId)
            .isNotEmpty();
        if (!exists) {
          await _isar.mcpServerConfigs.put(server);
        }
      }
    });
  }

  /// 启动服务器
  Future<McpClient?> startServer(String serverId) async {
    final config = await _isar.mcpServerConfigs
        .filter()
        .serverIdEqualTo(serverId)
        .findFirst();
    if (config == null) return null;

    try {
      // 启动子进程
      final process = await Process.start(
        config.command,
        config.args,
        environment: config.env,
      );
      _runningProcesses[serverId] = process;

      // 初始化MCP客户端
      final client = McpClient();
      await client.connectProcess(process);
      _connectedClients[serverId] = client;

      // 更新状态
      await _isar.writeTxn(() async {
        config.lastConnectedTime = DateTime.now();
        config.lastError = null;
        await _isar.mcpServerConfigs.put(config);
      });

      return client;
    } catch (e) {
      await _isar.writeTxn(() async {
        config.lastError = e.toString();
        await _isar.mcpServerConfigs.put(config);
      });
      return null;
    }
  }

  /// 获取会话工具列表
  Future<List<McpTool>> getSessionTools(Session session) async {
    final enabledServerIds = session.enabledMcpServerIds;
    final List<McpTool> allTools = [];

    for (String serverId in enabledServerIds) {
      final client = _connectedClients[serverId];
      if (client != null) {
        final tools = await client.listTools();
        allTools.addAll(tools);
      }
    }

    return allTools;
  }
}
```

#### 4.2 会话级工具隔离

```dart
// 扩展Session模型
@collection
class Session {
  Id id = Isar.autoIncrement;
  late String modelId;
  late String name;
  List<String> enabledMcpServerIds = [];  // 启用的MCP服务器
  bool enableWebSearch = false;
  final messages = IsarLinks<Message>();
}
```

---

### 模块5：FunASR语音识别集成

#### 5.1 FunASR服务

```dart
// lib/core/engines/funasr_engine.dart
class FunAsrEngine {
  late final DynamicLibrary _dylib;
  late final FunAsrInitDart _initModel;
  late final FunAsrRecognizeDart _recognize;
  Pointer<Void>? _ctx;

  Future<void> initialize() async {
    _dylib = DynamicLibrary.open(Platform.isMacOS
        ? 'libfunasr.dylib'
        : Platform.isWindows
            ? 'funasr.dll'
            : 'libfunasr.so');

    _initModel = _dylib.lookupFunction<FunAsrInitC, FunAsrInitDart>('funasr_init');
    _recognize = _dylib.lookupFunction<FunAsrRecognizeC, FunAsrRecognizeDart>('funasr_recognize');
  }

  Future<void> loadModel(String modelPath) async {
    final modelPathPtr = modelPath.toNativeUtf8();
    _ctx = _initModel(modelPathPtr, ...);
    calloc.free(modelPathPtr);
  }

  Future<String> recognize(Uint8List audioData) async {
    final pcmData = _convertAudioToPcm16k(audioData);
    final pcmPtr = pcmData.allocatePointer();

    final resultPtr = _recognize(_ctx!, pcmPtr, pcmData.length, 1);
    final result = resultPtr.toDartString();

    calloc.free(pcmPtr);
    return result;
  }
}
```

---

## 三、实施优先级与时间规划

### 阶段1：环境检测与硬件加速（1-2周）
**优先级：最高**
- [ ] 实现MethodChannel原生检测（macOS/iOS/Windows）
- [ ] 编译带Metal/CUDA后端的llama.cpp
- [ ] 集成Metal加速
- [ ] 集成CUDA加速
- [ ] 测试验证

### 阶段2：完善模型下载管理（1周）
**优先级：高**
- [ ] 集成Isar数据库
- [ ] 实现ModelScope完整API
- [ ] 实现HuggingFace完整API
- [ ] 实现下载任务持久化
- [ ] 实现断点续传

### 阶段3：量化级别自动匹配（3-5天）
**优先级：高**
- [ ] 建立模型硬件需求基准库
- [ ] 实现量化匹配算法
- [ ] UI集成与测试

### 阶段4：MCP生态集成（1-2周）
**优先级：中**
- [ ] 实现MCP服务器管理器
- [ ] 集成内置服务器
- [ ] 实现会话级工具隔离
- [ ] 测试验证

### 阶段5：FunASR语音识别（1周）
**优先级：中**
- [ ] 编译FunASR runtime
- [ ] 实现FFI绑定
- [ ] 集成到语音模块
- [ ] 测试验证

---

## 四、技术风险与应对

### 风险1：llama.cpp编译复杂度高
**应对：** 提供预编译库，简化构建流程

### 风险2：Metal/CUDA加速稳定性
**应对：** 提供CPU兜底方案，自动降级

### 风险3：MCP服务器兼容性
**应对：** 完善错误处理，提供详细日志

### 风险4：FunASR模型体积大
**应对：** 提供轻量级模型（80MB），支持按需下载

---

## 五、测试与验证计划

### 单元测试
- 环境检测模块测试
- 量化匹配算法测试
- 下载任务管理测试

### 集成测试
- Metal加速集成测试（macOS/iOS）
- CUDA加速集成测试（Windows）
- MCP工具调用测试

### 性能测试
- 推理速度对比（CPU vs GPU）
- 内存占用测试
- 下载速度测试

### 兼容性测试
- 多平台测试（macOS/Windows/iOS/Android）
- 不同设备配置测试

---

## 六、文档与交付

### 技术文档
- 架构设计文档
- API接口文档
- 部署指南

### 用户文档
- 使用手册
- 常见问题

### 交付物
- 完整源代码
- 预编译库
- 测试报告
- 技术文档
