abstract class IModelManager {
  Future<ModelInfo> loadModel(String modelId, {String? mmprojPath});
  Future<void> unloadModel(String modelId);
  Future<void> downloadModel(ModelDownloadConfig config);
  Future<ModelInfo> getModelInfo(String modelId);
  Future<List<ModelInfo>> getAvailableModels();
  Future<ModelCapabilities> detectCapabilities(String modelId);
  Stream<ModelLoadingState> get loadingStateStream;
}

class ModelInfo {
  final String id;
  final String name;
  final String type; // 'local', 'remote'
  final String source; // 'gguf', 'openai', 'anthropic', etc.
  final ModelCapabilities capabilities;
  final Map<String, dynamic> config;

  const ModelInfo({
    required this.id,
    required this.name,
    required this.type,
    required this.source,
    required this.capabilities,
    required this.config,
  });
}

class ModelCapabilities {
  final bool supportsVision;
  final bool supportsAudio;
  final bool supportsTools;
  final int maxContextWindow;
  final List<String> supportedLanguages;

  const ModelCapabilities({
    this.supportsVision = false,
    this.supportsAudio = false,
    this.supportsTools = false,
    required this.maxContextWindow,
    this.supportedLanguages = const ['en'],
  });
}

class ModelDownloadConfig {
  final String url;
  final String name;
  final String? savePath;
  final void Function(double progress)? onProgress;

  const ModelDownloadConfig({
    required this.url,
    required this.name,
    this.savePath,
    this.onProgress,
  });
}

class ModelLoadingState {
  final String modelId;
  final LoadingStatus status;
  final double progress;
  final String? error;
  final String? message;

  const ModelLoadingState({
    required this.modelId,
    required this.status,
    this.progress = 0.0,
    this.error,
    this.message,
  });
}

enum LoadingStatus {
  idle,
  downloading,
  loading,
  ready,
  error,
}
