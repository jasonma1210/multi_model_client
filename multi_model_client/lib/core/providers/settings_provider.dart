/// 设置 Provider - LLM Studio 应用设置管理模块
/// 
/// 功能：
/// - 应用设置状态管理
/// - 搜索模式配置
/// - 路径配置管理
/// - 设置持久化
/// 
/// @author JianMa
/// @version 1.0.0
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

/// 搜索模式枚举
enum SearchMode {
  tavily,
  duckduckgo,
  wikipedia,
}

/// 设置服务类
class SettingsService {
  // 下载路径
  static const String _downloadPathKey = 'download_path';
  // 知识库路径
  static const String _knowledgeBasePathKey = 'knowledge_base_path';
  // 数据库路径
  static const String _databasePathKey = 'database_path';
  // 备份路径
  static const String _backupPathKey = 'backup_path';
  // 日志路径
  static const String _logPathKey = 'log_path';
  
  // 搜索配置
  static const String _searchModeKey = 'search_mode';
  static const String _tavilyApiKeyKey = 'tavily_api_key';
  static const String _webSearchEnabledKey = 'web_search_enabled';
  
  // TTS 配置
  static const String _ttsProviderKey = 'tts_provider';
  
  // ASR 配置
  static const String _asrProviderKey = 'asr_provider';
  
  // 小米 MiMo TTS 配置
  static const String _mimoApiKeyKey = 'mimo_api_key';
  static const String _mimoVoiceKey = 'mimo_voice';
  static const String _mimoSpeedKey = 'mimo_speed';
  static const String _mimoFormatKey = 'mimo_format';

  // Ollama 配置
  static const String _ollamaBaseUrlKey = 'ollama_base_url';
  static const String _ollamaDefaultModelKey = 'ollama_default_model';
  static const String _ollamaApiKeyKey = 'ollama_api_key';

  SharedPreferences? _prefs;
  bool _isInitialized = false;
  
  Future<void> initialize() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
  }
  
  /// 确保已初始化
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }
  
  // ============ 存储路径设置 ============
  
  /// 获取自定义下载路径
  String? getDownloadPath() {
    if (!_isInitialized) return null;
    return _prefs?.getString(_downloadPathKey);
  }
  
  /// 设置自定义下载路径
  Future<void> setDownloadPath(String? path) async {
    await _ensureInitialized();
    if (path == null) {
      await _prefs?.remove(_downloadPathKey);
    } else {
      await _prefs?.setString(_downloadPathKey, path);
    }
  }
  
  /// 获取实际下载目录（优先使用自定义路径，否则使用默认路径）
  Future<String> getEffectiveDownloadPath() async {
    final customPath = getDownloadPath();
    if (customPath != null && customPath.isNotEmpty) {
      return customPath;
    }
    
    final appDir = await getApplicationDocumentsDirectory();
    return '${appDir.path}/models';
  }
  
  /// 获取知识库路径
  String? getKnowledgeBasePath() {
    if (!_isInitialized) return null;
    return _prefs?.getString(_knowledgeBasePathKey);
  }
  
  /// 设置知识库路径
  Future<void> setKnowledgeBasePath(String? path) async {
    await _ensureInitialized();
    if (path == null) {
      await _prefs?.remove(_knowledgeBasePathKey);
    } else {
      await _prefs?.setString(_knowledgeBasePathKey, path);
    }
  }
  
  /// 获取实际知识库目录
  Future<String> getEffectiveKnowledgeBasePath() async {
    final customPath = getKnowledgeBasePath();
    if (customPath != null && customPath.isNotEmpty) {
      return customPath;
    }
    
    final appDir = await getApplicationDocumentsDirectory();
    return '${appDir.path}/knowledge_base';
  }
  
  /// 获取数据库路径
  String? getDatabasePath() {
    if (!_isInitialized) return null;
    return _prefs?.getString(_databasePathKey);
  }
  
  /// 设置数据库路径
  Future<void> setDatabasePath(String? path) async {
    await _ensureInitialized();
    if (path == null) {
      await _prefs?.remove(_databasePathKey);
    } else {
      await _prefs?.setString(_databasePathKey, path);
    }
  }
  
  /// 获取实际数据库目录
  Future<String> getEffectiveDatabasePath() async {
    final customPath = getDatabasePath();
    if (customPath != null && customPath.isNotEmpty) {
      return customPath;
    }
    
    final appDir = await getApplicationDocumentsDirectory();
    return appDir.path;
  }
  
  /// 获取备份路径
  String? getBackupPath() {
    if (!_isInitialized) return null;
    return _prefs?.getString(_backupPathKey);
  }
  
  /// 设置备份路径
  Future<void> setBackupPath(String? path) async {
    await _ensureInitialized();
    if (path == null) {
      await _prefs?.remove(_backupPathKey);
    } else {
      await _prefs?.setString(_backupPathKey, path);
    }
  }
  
  /// 获取实际备份目录
  Future<String> getEffectiveBackupPath() async {
    final customPath = getBackupPath();
    if (customPath != null && customPath.isNotEmpty) {
      return customPath;
    }
    
    final appDir = await getApplicationDocumentsDirectory();
    return '${appDir.path}/backups';
  }
  
  /// 获取日志路径
  String? getLogPath() {
    if (!_isInitialized) return null;
    return _prefs?.getString(_logPathKey);
  }
  
  /// 设置日志路径
  Future<void> setLogPath(String? path) async {
    await _ensureInitialized();
    if (path == null) {
      await _prefs?.remove(_logPathKey);
    } else {
      await _prefs?.setString(_logPathKey, path);
    }
  }
  
  /// 获取实际日志目录
  Future<String> getEffectiveLogPath() async {
    final customPath = getLogPath();
    if (customPath != null && customPath.isNotEmpty) {
      return customPath;
    }
    
    final appDir = await getApplicationDocumentsDirectory();
    return '${appDir.path}/logs';
  }
  
  /// 获取所有存储路径配置
  Future<Map<String, String>> getAllStoragePaths() async {
    return {
      'models': await getEffectiveDownloadPath(),
      'knowledge_base': await getEffectiveKnowledgeBasePath(),
      'database': await getEffectiveDatabasePath(),
      'backups': await getEffectiveBackupPath(),
      'logs': await getEffectiveLogPath(),
    };
  }
  
  // ============ 搜索设置 ============
  
  /// 获取搜索模式
  SearchMode getSearchMode() {
    if (!_isInitialized) return SearchMode.tavily;
    final index = _prefs?.getInt(_searchModeKey) ?? 0;
    return SearchMode.values[index.clamp(0, SearchMode.values.length - 1)];
  }
  
  /// 设置搜索模式
  Future<void> setSearchMode(SearchMode mode) async {
    await _ensureInitialized();
    await _prefs?.setInt(_searchModeKey, mode.index);
  }
  
  /// 获取 Tavily API Key
  String? getTavilyApiKey() {
    if (!_isInitialized) return null;
    return _prefs?.getString(_tavilyApiKeyKey);
  }
  
  /// 设置 Tavily API Key
  Future<void> setTavilyApiKey(String? apiKey) async {
    await _ensureInitialized();
    if (apiKey == null || apiKey.isEmpty) {
      await _prefs?.remove(_tavilyApiKeyKey);
    } else {
      await _prefs?.setString(_tavilyApiKeyKey, apiKey);
    }
  }
  
  /// 获取网络搜索是否启用
  bool getWebSearchEnabled() {
    if (!_isInitialized) return false;
    return _prefs?.getBool(_webSearchEnabledKey) ?? false;
  }
  
  /// 设置网络搜索是否启用
  Future<void> setWebSearchEnabled(bool enabled) async {
    await _ensureInitialized();
    await _prefs?.setBool(_webSearchEnabledKey, enabled);
  }
  
  // ============ 小米 MiMo TTS 设置 ============
  
  /// 获取 MiMo API Key
  String? getMimoApiKey() {
    if (!_isInitialized) return null;
    return _prefs?.getString(_mimoApiKeyKey);
  }
  
  /// 设置 MiMo API Key
  Future<void> setMimoApiKey(String? apiKey) async {
    await _ensureInitialized();
    if (apiKey == null || apiKey.isEmpty) {
      await _prefs?.remove(_mimoApiKeyKey);
    } else {
      await _prefs?.setString(_mimoApiKeyKey, apiKey);
    }
  }
  
  /// 获取 MiMo 音色
  String getMimoVoice() {
    if (!_isInitialized) return 'alloy';
    return _prefs?.getString(_mimoVoiceKey) ?? 'alloy';
  }
  
  /// 设置 MiMo 音色
  Future<void> setMimoVoice(String voice) async {
    await _ensureInitialized();
    await _prefs?.setString(_mimoVoiceKey, voice);
  }
  
  /// 获取 MiMo 语速
  double getMimoSpeed() {
    if (!_isInitialized) return 1.0;
    return _prefs?.getDouble(_mimoSpeedKey) ?? 1.0;
  }
  
  /// 设置 MiMo 语速
  Future<void> setMimoSpeed(double speed) async {
    await _ensureInitialized();
    await _prefs?.setDouble(_mimoSpeedKey, speed);
  }
  
  /// 获取 MiMo 音频格式
  String getMimoFormat() {
    if (!_isInitialized) return 'mp3';
    return _prefs?.getString(_mimoFormatKey) ?? 'mp3';
  }
  
  /// 设置 MiMo 音频格式
  Future<void> setMimoFormat(String format) async {
    await _ensureInitialized();
    await _prefs?.setString(_mimoFormatKey, format);
  }
  
  /// 获取 TTS 提供商
  String getTtsProvider() {
    if (!_isInitialized) return 'sherpa';
    return _prefs?.getString(_ttsProviderKey) ?? 'sherpa';
  }
  
  /// 获取 ASR 提供商
  String getAsrProvider() {
    if (!_isInitialized) return 'sherpa';
    return _prefs?.getString(_asrProviderKey) ?? 'sherpa';
  }
  
  /// 设置 TTS 提供商
  Future<void> setTtsProvider(String provider) async {
    await _ensureInitialized();
    await _prefs?.setString(_ttsProviderKey, provider);
  }
  
  /// 设置 ASR 提供商
  Future<void> setAsrProvider(String provider) async {
    await _ensureInitialized();
    await _prefs?.setString(_asrProviderKey, provider);
  }

  // ============ Ollama 设置 ============

  /// 获取 Ollama Base URL
  String getOllamaBaseUrl() {
    if (!_isInitialized) return 'http://localhost:11434';
    return _prefs?.getString(_ollamaBaseUrlKey) ?? 'http://localhost:11434';
  }

  /// 设置 Ollama Base URL
  Future<void> setOllamaBaseUrl(String url) async {
    await _ensureInitialized();
    await _prefs?.setString(_ollamaBaseUrlKey, url);
  }

  /// 获取 Ollama 默认模型
  String getOllamaDefaultModel() {
    if (!_isInitialized) return 'llama3.2';
    return _prefs?.getString(_ollamaDefaultModelKey) ?? 'llama3.2';
  }

  /// 设置 Ollama 默认模型
  Future<void> setOllamaDefaultModel(String model) async {
    await _ensureInitialized();
    await _prefs?.setString(_ollamaDefaultModelKey, model);
  }

  /// 获取 Ollama API Key
  String getOllamaApiKey() {
    if (!_isInitialized) return '';
    return _prefs?.getString(_ollamaApiKeyKey) ?? '';
  }

  /// 设置 Ollama API Key
  Future<void> setOllamaApiKey(String apiKey) async {
    await _ensureInitialized();
    await _prefs?.setString(_ollamaApiKeyKey, apiKey);
  }
}

/// 设置服务 Provider (单例)
final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

/// 下载路径 Provider
final downloadPathProvider = StateNotifierProvider<DownloadPathNotifier, String?>((ref) {
  return DownloadPathNotifier(ref.watch(settingsServiceProvider));
});

class DownloadPathNotifier extends StateNotifier<String?> {
  final SettingsService _settingsService;
  
  DownloadPathNotifier(this._settingsService) : super(null) {
    _loadPath();
  }
  
  void _loadPath() {
    state = _settingsService.getDownloadPath();
  }
  
  Future<void> setPath(String? path) async {
    await _settingsService.setDownloadPath(path);
    state = path;
  }
  
  Future<String> getEffectivePath() async {
    return await _settingsService.getEffectiveDownloadPath();
  }
}

/// 知识库路径 Provider
final knowledgeBasePathProvider = StateNotifierProvider<KnowledgeBasePathNotifier, String?>((ref) {
  return KnowledgeBasePathNotifier(ref.watch(settingsServiceProvider));
});

class KnowledgeBasePathNotifier extends StateNotifier<String?> {
  final SettingsService _settingsService;
  
  KnowledgeBasePathNotifier(this._settingsService) : super(null) {
    _loadPath();
  }
  
  void _loadPath() {
    state = _settingsService.getKnowledgeBasePath();
  }
  
  Future<void> setPath(String? path) async {
    await _settingsService.setKnowledgeBasePath(path);
    state = path;
  }
  
  Future<String> getEffectivePath() async {
    return await _settingsService.getEffectiveKnowledgeBasePath();
  }
}

/// 备份路径 Provider
final backupPathProvider = StateNotifierProvider<BackupPathNotifier, String?>((ref) {
  return BackupPathNotifier(ref.watch(settingsServiceProvider));
});

class BackupPathNotifier extends StateNotifier<String?> {
  final SettingsService _settingsService;
  
  BackupPathNotifier(this._settingsService) : super(null) {
    _loadPath();
  }
  
  void _loadPath() {
    state = _settingsService.getBackupPath();
  }
  
  Future<void> setPath(String? path) async {
    await _settingsService.setBackupPath(path);
    state = path;
  }
  
  Future<String> getEffectivePath() async {
    return await _settingsService.getEffectiveBackupPath();
  }
}

/// 日志路径 Provider
final logPathProvider = StateNotifierProvider<LogPathNotifier, String?>((ref) {
  return LogPathNotifier(ref.watch(settingsServiceProvider));
});

class LogPathNotifier extends StateNotifier<String?> {
  final SettingsService _settingsService;
  
  LogPathNotifier(this._settingsService) : super(null) {
    _loadPath();
  }
  
  void _loadPath() {
    state = _settingsService.getLogPath();
  }
  
  Future<void> setPath(String? path) async {
    await _settingsService.setLogPath(path);
    state = path;
  }
  
  Future<String> getEffectivePath() async {
    return await _settingsService.getEffectiveLogPath();
  }
}

/// 搜索模式 Provider
final searchModeProvider = StateNotifierProvider<SearchModeNotifier, SearchMode>((ref) {
  return SearchModeNotifier(ref.watch(settingsServiceProvider));
});

class SearchModeNotifier extends StateNotifier<SearchMode> {
  final SettingsService _settingsService;
  
  SearchModeNotifier(this._settingsService) : super(SearchMode.tavily) {
    _loadMode();
  }
  
  void _loadMode() {
    state = _settingsService.getSearchMode();
  }
  
  Future<void> setMode(SearchMode mode) async {
    await _settingsService.setSearchMode(mode);
    state = mode;
  }
}

/// 网络搜索启用状态 Provider
final webSearchEnabledProvider = StateNotifierProvider<WebSearchEnabledNotifier, bool>((ref) {
  return WebSearchEnabledNotifier(ref.watch(settingsServiceProvider));
});

class WebSearchEnabledNotifier extends StateNotifier<bool> {
  final SettingsService _settingsService;
  
  WebSearchEnabledNotifier(this._settingsService) : super(false) {
    _loadState();
  }
  
  void _loadState() {
    state = _settingsService.getWebSearchEnabled();
  }
  
  Future<void> setEnabled(bool enabled) async {
    await _settingsService.setWebSearchEnabled(enabled);
    state = enabled;
  }
}
