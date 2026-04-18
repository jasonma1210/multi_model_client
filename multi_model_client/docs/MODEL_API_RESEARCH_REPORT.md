# 📊 Hugging Face & ModelScope API 调研报告

**日期**: 2026-04-05
**调研目的**: 了解如何搜索和下载模型，整合到项目模型管理功能

---

## ✅ 调研结果总结

### 项目已有完整实现！

经过调研发现，项目中的 `ModelDownloadManager` 已经完整实现了Hugging Face和ModelScope的API集成。

**文件位置**: `lib/core/services/model_download_manager.dart` (~600行)

---

## 📡 Hugging Face API

### 1. 搜索模型 API

**端点**: `GET https://huggingface.co/api/models`

**请求参数**:
```json
{
  "search": "查询关键词",
  "limit": 20,
  "filter": "可选过滤器"
}
```

**实现代码**:
```dart
Future<List<ModelInfo>> searchHuggingFace(
  String query, {
  int limit = 20,
  String? filter,
}) async {
  final response = await _dio.get(
    'https://huggingface.co/api/models',
    queryParameters: {
      'search': query,
      'limit': limit,
      if (filter != null) 'filter': filter,
    },
  );

  final models = (response.data as List<dynamic>)
      .map((json) => ModelInfo.fromJson(json, ModelSource.huggingFace))
      .toList();

  return models;
}
```

**响应格式**:
```json
[
  {
    "id": "model-id",
    "modelId": "author/model-name",
    "author": "作者",
    "downloads": 1000,
    "likes": 50,
    "tags": ["tag1", "tag2"],
    "license": "mit",
    "description": "模型描述"
  }
]
```

### 2. 获取模型详情 API

**端点**: `GET https://huggingface.co/api/models/{modelId}`

**实现代码**:
```dart
Future<ModelInfo?> getHuggingFaceModel(String modelId) async {
  final response = await _dio.get(
    'https://huggingface.co/api/models/$modelId',
  );

  return ModelInfo.fromJson(response.data, ModelSource.huggingFace);
}
```

### 3. 模型下载 URL

**格式**: `https://huggingface.co/{modelId}/resolve/main/model.gguf`

**示例**:
```
https://huggingface.co/meta-llama/Llama-2-7b-chat/resolve/main/model.gguf
```

### 4. 模型信息解析

**实现逻辑**:
- **参数量解析**: 从标签中提取 (7b, 13b, 70b)
- **量化检测**: 检测GGUF、GPTQ等量化格式
- **硬件需求估算**: 根据参数量计算最小内存和存储
- **特性提取**: GPU、Metal、Vulkan、NEON等

---

## 📡 ModelScope (魔搭社区) API

### 1. 搜索模型 API

**端点**: `GET https://modelscope.cn/api/v1/models`

**请求参数**:
```json
{
  "name": "查询关键词",
  "PageSize": 20,
  "filter": "可选过滤器"
}
```

**实现代码**:
```dart
Future<List<ModelInfo>> searchModelScope(
  String query, {
  int limit = 20,
  String? filter,
}) async {
  final response = await _dio.get(
    'https://modelscope.cn/api/v1/models',
    queryParameters: {
      'name': query,
      'PageSize': limit,
      if (filter != null) 'filter': filter,
    },
  );

  final data = response.data as Map<String, dynamic>;
  final models = (data['Data']?['Models'] as List<dynamic>?)
      ?.map((json) => ModelInfo.fromJson(json, ModelSource.modelScope))
      .toList() ?? [];

  return models;
}
```

**响应格式**:
```json
{
  "Data": {
    "Models": [
      {
        "id": "model-id",
        "model_id": "namespace/model-name",
        "name": "模型名称",
        "owner": "作者",
        "download_count": 1000,
        "stars": 50,
        "tags": ["tag1", "tag2"],
        "license": "apache-2.0",
        "description": "模型描述",
        "summary": "模型简介"
      }
    ]
  }
}
```

### 2. 获取模型详情 API

**端点**: `GET https://modelscope.cn/api/v1/models/{modelId}`

**实现代码**:
```dart
Future<ModelInfo?> getModelScopeModel(String modelId) async {
  final response = await _dio.get(
    'https://modelscope.cn/api/v1/models/$modelId',
  );

  final data = response.data as Map<String, dynamic>;
  return ModelInfo.fromJson(data['Data'], ModelSource.modelScope);
}
```

### 3. 模型下载 URL

**格式**: `https://modelscope.cn/models/{modelId}/resolve/master/model.gguf`

**示例**:
```
https://modelscope.cn/models/qwen/Qwen-7B-Chat/resolve/master/model.gguf
```

---

## 🔧 模型下载功能

### 下载流程

```
用户点击下载
    ↓
检查硬件兼容性
    ↓
检查存储空间
    ↓
创建下载目录
    ↓
开始下载（带进度）
    ↓
更新下载进度
    ↓
下载完成
```

### 实现代码

```dart
Future<bool> downloadModel(
  ModelInfo model, {
  Function(DownloadProgress)? onProgress,
}) async {
  // 1. 检查兼容性
  final compatibility = await checkCompatibility(model);
  if (!compatibility.isCompatible) {
    return false;
  }

  // 2. 检查存储空间
  final hasSpace = await _hardwareChecker.hasEnoughStorage(model.minStorageGB);
  if (!hasSpace) {
    return false;
  }

  // 3. 创建下载目录
  final modelDir = '$_downloadDir/${model.id.replaceAll('/', '_')}';
  final modelFile = '$modelDir/model.gguf';
  await Directory(modelDir).create(recursive: true);

  // 4. 执行下载
  await _dio.download(
    model.downloadUrl,
    modelFile,
    onReceiveProgress: (received, total) {
      final progress = DownloadProgress(
        modelId: model.id,
        totalBytes: total,
        downloadedBytes: received,
        progress: total > 0 ? received / total : 0,
        status: 'downloading',
      );
      
      if (onProgress != null) {
        onProgress(progress);
      }
    },
  );

  return true;
}
```

### 进度跟踪

```dart
class DownloadProgress {
  final String modelId;
  final int totalBytes;
  final int downloadedBytes;
  final double progress; // 0.0 - 1.0
  final String status; // downloading, completed, error
  final String? error;

  String get progressPercentage => '${(progress * 100).toStringAsFixed(1)}%';
  String get downloadedMB => '${(downloadedBytes / 1024 / 1024).toStringAsFixed(1)} MB';
  String get totalMB => '${(totalBytes / 1024 / 1024).toStringAsFixed(1)} MB';
}
```

---

## 🎯 模型信息解析

### Hugging Face 解析

**自动提取信息**:
- ✅ 模型ID和名称
- ✅ 作者
- ✅ 下载量和点赞数
- ✅ 标签
- ✅ 许可证
- ✅ 参数量（从标签推断）
- ✅ 量化信息（GGUF, GPTQ等）
- ✅ 硬件特性需求
- ✅ 最小内存需求
- ✅ 最小存储需求

**示例**:
```dart
ModelInfo.fromHuggingFace({
  "id": "meta-llama/Llama-2-7b-chat-hf",
  "modelId": "meta-llama/Llama-2-7b-chat-hf",
  "author": "meta-llama",
  "downloads": 500000,
  "likes": 2500,
  "tags": ["llama", "7b", "gguf"],
  "license": "llama2"
});

// 解析结果:
// - 参数量: 7B
// - 量化: GGUF
// - 最小内存: ~6GB
// - 最小存储: ~5GB
```

### ModelScope 解析

**自动提取信息**:
- ✅ 模型ID和名称
- ✅ 作者/所有者
- ✅ 下载量和星数
- ✅ 标签
- ✅ 许可证
- ✅ 描述和简介
- ✅ 参数量（从名称推断）
- ✅ 硬件特性需求
- ✅ 最小内存需求
- ✅ 最小存储需求

**示例**:
```dart
ModelInfo.fromModelScope({
  "id": "qwen/Qwen-7B-Chat",
  "name": "Qwen-7B-Chat",
  "owner": "qwen",
  "download_count": 100000,
  "stars": 800,
  "tags": ["chat", "chinese"],
  "description": "通义千问7B对话模型"
});

// 解析结果:
// - 参数量: 7B
// - 最小内存: ~14GB
// - 最小存储: ~7GB
```

---

## 📊 硬件兼容性检查

### 检查逻辑

```dart
Future<CompatibilityResult> checkCompatibility(ModelInfo model) async {
  return await _hardwareChecker.checkModelCompatibility(
    minRamGB: model.minRamGB,
    minStorageGB: model.minStorageGB,
    requiredFeatures: model.requiredFeatures,
  );
}
```

### 自动估算需求

**内存需求**:
- 非量化模型: `参数量 * 2` GB (FP16)
- 量化模型: `参数量 * 0.8` GB (4-5 bit)

**存储需求**:
- 非量化模型: `参数量` GB
- 量化模型: `参数量 * 0.7` GB

**示例**:
```dart
// Llama 2 7B (非量化)
minRamGB: 14 GB
minStorageGB: 7 GB

// Llama 2 7B (GGUF量化)
minRamGB: 6 GB
minStorageGB: 5 GB
```

---

## 🚀 其他功能

### 1. 取消下载

```dart
void cancelDownload(String modelId) {
  final token = _downloadTokens[modelId];
  if (token != null) {
    token.cancel('User cancelled download');
    _downloadTokens.remove(modelId);
  }
}
```

### 2. 删除已下载模型

```dart
Future<bool> deleteModel(String modelId) async {
  final modelDir = '$_downloadDir/${modelId.replaceAll('/', '_')}';
  final dir = Directory(modelDir);
  if (await dir.exists()) {
    await dir.delete(recursive: true);
    return true;
  }
  return false;
}
```

### 3. 获取下载进度

```dart
DownloadProgress? getDownloadProgress(String modelId) {
  return progressNotifier.value[modelId];
}
```

---

## 📝 使用示例

### 搜索模型

```dart
final manager = ModelDownloadManager(
  dio: dio,
  hardwareChecker: HardwareCompatibilityChecker(),
  downloadDir: '/path/to/models',
);

// 搜索Hugging Face
final hfModels = await manager.searchHuggingFace('llama 2', limit: 20);

// 搜索ModelScope
final msModels = await manager.searchModelScope('通义千问', limit: 20);
```

### 下载模型

```dart
final model = hfModels.first;

// 检查兼容性
final compatibility = await manager.checkCompatibility(model);
if (!compatibility.isCompatible) {
  print('不兼容: ${compatibility.reasons}');
  return;
}

// 开始下载
final success = await manager.downloadModel(
  model,
  onProgress: (progress) {
    print('进度: ${progress.progressPercentage}');
    print('已下载: ${progress.downloadedMB} / ${progress.totalMB}');
  },
);
```

### 监听进度

```dart
manager.progressNotifier.addListener(() {
  final progress = manager.getDownloadProgress(model.id);
  if (progress != null) {
    print('状态: ${progress.status}');
    print('进度: ${progress.progressPercentage}');
  }
});
```

---

## 🎊 调研结论

### ✅ 已有完整实现

项目中的 `ModelDownloadManager` 已经完整实现了所有需要的功能：

1. ✅ **Hugging Face API集成** - 搜索、详情、下载
2. ✅ **ModelScope API集成** - 搜索、详情、下载
3. ✅ **硬件兼容性检查** - 自动检测硬件是否支持
4. ✅ **下载进度跟踪** - 实时进度更新
5. ✅ **取消下载** - 支持中途取消
6. ✅ **模型删除** - 删除已下载模型
7. ✅ **智能估算** - 自动计算硬件需求

### 🚀 下一步

将现有功能整合到UI界面中：
1. 更新模型管理页面，使用 `ModelDownloadManager`
2. 实现搜索功能UI
3. 实现下载进度显示
4. 删除设置页面中的重复"下载模型"栏位

---

**调研完成时间**: 2026-04-05
**状态**: ✅ 完成
**结论**: 项目已有完整实现，只需整合到UI
