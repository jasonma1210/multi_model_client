/// VoxCPM2 服务 - LLM Studio 高级语音合成模块
/// 
/// 功能：
/// - VoxCPM2 语音合成服务管理
/// - 本地 TTS 服务启动/停止
/// - 音色配置管理
/// - 高质量语音合成
/// 
/// @author JianMa
/// @version 1.0.0
library;

import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// VoxCPM2 服务管理器
class VoxCPM2ServiceManager {
  static const String _prefsKey = 'voxcpm2_settings';
  
  Process? _serverProcess;
  bool _isRunning = false;
  String _serverUrl = 'http://localhost:8080';
  final Dio _dio = Dio();
  
  // 设置
  String voice = 'default';
  double cfgValue = 2.0;
  int inferenceSteps = 10;
  
  bool get isRunning => _isRunning;
  String get serverUrl => _serverUrl;
  
  /// 初始化
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _serverUrl = prefs.getString('${_prefsKey}_server_url') ?? 'http://localhost:8080';
    voice = prefs.getString('${_prefsKey}_voice') ?? 'default';
    cfgValue = prefs.getDouble('${_prefsKey}_cfg_value') ?? 2.0;
    inferenceSteps = prefs.getInt('${_prefsKey}_inference_steps') ?? 10;
  }
  
  /// 保存设置
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_prefsKey}_server_url', _serverUrl);
    await prefs.setString('${_prefsKey}_voice', voice);
    await prefs.setDouble('${_prefsKey}_cfg_value', cfgValue);
    await prefs.setInt('${_prefsKey}_inference_steps', inferenceSteps);
  }
  
  /// 设置服务器地址
  void setServerUrl(String url) {
    _serverUrl = url;
    _saveSettings();
  }
  
  /// 设置音色
  void setVoice(String v) {
    voice = v;
    _saveSettings();
  }
  
  /// 设置 CFG 值
  void setCfgValue(double value) {
    cfgValue = value;
    _saveSettings();
  }
  
  /// 设置推理步数
  void setInferenceSteps(int steps) {
    inferenceSteps = steps;
    _saveSettings();
  }
  
  /// 检查服务是否可用
  Future<bool> checkHealth() async {
    try {
      final response = await _dio.get('$_serverUrl/health').timeout(
        const Duration(seconds: 5),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  /// 检查模型是否已加载
  Future<bool> isModelLoaded() async {
    try {
      final response = await _dio.get('$_serverUrl/model/status').timeout(
        const Duration(seconds: 5),
      );
      if (response.statusCode == 200) {
        return response.data['loaded'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  /// 启动本地服务
  Future<bool> startLocalServer() async {
    // 检查 Python 环境
    try {
      final pythonCheck = await Process.run('python3', ['--version']);
      if (pythonCheck.exitCode != 0) {
        throw Exception('Python3 未安装');
      }
    } catch (e) {
      throw Exception('请安装 Python 3.10+');
    }
    
    // 检查 voxcpm 是否安装
    try {
      final pipCheck = await Process.run('pip3', ['show', 'voxcpm']);
      if (pipCheck.exitCode != 0) {
        throw Exception('VoxCPM 未安装，请运行: pip install voxcpm');
      }
    } catch (e) {
      throw Exception('VoxCPM 未安装，请运行: pip install voxcpm');
    }
    
    // 获取服务器脚本路径
    final scriptPath = await _getServerScriptPath();
    
    // 启动服务
    try {
      _serverProcess = await Process.start(
        'python3',
        [scriptPath, '--port', '8080'],
        mode: ProcessStartMode.detached,
      );
      
      // 等待服务启动
      await Future.delayed(const Duration(seconds: 3));
      
      // 检查服务是否成功启动
      if (await checkHealth()) {
        _isRunning = true;
        return true;
      } else {
        throw Exception('服务启动失败');
      }
    } catch (e) {
      _serverProcess = null;
      rethrow;
    }
  }
  
  /// 停止本地服务
  Future<void> stopLocalServer() async {
    if (_serverProcess != null) {
      // 尝试优雅关闭
      try {
        _serverProcess!.kill(ProcessSignal.sigterm);
        await Future.delayed(const Duration(seconds: 2));
        
        // 如果进程仍然存在，强制杀死
        if (!_serverProcess!.kill(ProcessSignal.sigkill)) {
          _serverProcess = null;
          _isRunning = false;
        }
      } catch (e) {
        // 忽略错误
        _serverProcess = null;
        _isRunning = false;
      }
    }
    _isRunning = false;
  }
  
  /// 获取服务器脚本路径
  Future<String> _getServerScriptPath() async {
    final appDir = await getApplicationDocumentsDirectory();
    return '${appDir.path}/voxcpm_server.py';
  }
  
  /// 复制服务器脚本到应用目录
  Future<void> installServerScript(String sourcePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final targetPath = '${appDir.path}/voxcpm_server.py';
    
    final sourceFile = File(sourcePath);
    if (await sourceFile.exists()) {
      await sourceFile.copy(targetPath);
    }
  }
  
  /// 合成语音
  Future<List<int>> synthesize(String text) async {
    try {
      final response = await _dio.post(
        '$_serverUrl/tts',
        data: {
          'text': text,
          'voice': voice,
          'cfg_value': cfgValue,
          'inference_timesteps': inferenceSteps,
        },
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Content-Type': 'application/json'},
        ),
      );
      
      if (response.statusCode == 200) {
        return response.data as List<int>;
      } else {
        throw Exception('TTS 合成失败: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('TTS 合成错误: $e');
    }
  }
  
  /// 测试语音合成
  Future<List<int>> test() async {
    return synthesize('你好，这是 VoxCPM2 语音合成测试。');
  }
  
  /// 获取可用音色列表
  Future<List<Map<String, String>>> getVoices() async {
    try {
      final response = await _dio.post('$_serverUrl/tts/voices').timeout(
        const Duration(seconds: 10),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> voices = response.data;
        return voices.map((v) => {
          'id': v['id'] as String,
          'name': v['name'] as String,
          'prompt': v['prompt'] as String,
        }).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
  
  /// 释放资源
  void dispose() {
    stopLocalServer();
    _dio.close();
  }
}

// Riverpod Provider
final voxcpm2ServiceProvider = Provider<VoxCPM2ServiceManager>((ref) {
  final manager = VoxCPM2ServiceManager();
  manager.init();
  ref.onDispose(() => manager.dispose());
  return manager;
});

// VoxCPM2 安装状态
final voxcpm2InstalledProvider = FutureProvider<bool>((ref) async {
  final manager = ref.watch(voxcpm2ServiceProvider);
  return manager.checkHealth();
});

// VoxCPM2 服务状态
final voxcpm2RunningProvider = StateProvider<bool>((ref) => false);