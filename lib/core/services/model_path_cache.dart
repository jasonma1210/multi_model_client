/// 模型路径缓存服务 - 性能优化
/// 
/// 避免每次加载模型时递归扫描整个模型目录，
/// 首次扫描后缓存文件名到完整路径的映射。
/// 
/// @author JianMa
/// @version 1.0.0
library;

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 模型路径缓存单例
class ModelPathCache {
  static final ModelPathCache _instance = ModelPathCache._();
  static ModelPathCache get instance => _instance;

  ModelPathCache._();

  /// 文件名 -> 完整路径的缓存映射
  final Map<String, String> _pathIndex = {};

  /// mmproj 文件名 -> 完整路径的缓存映射
  final Map<String, String> _mmprojPathIndex = {};

  /// 是否已初始化
  bool _initialized = false;

  /// 缓存的模型目录列表
  List<String>? _cachedModelDirs;

  /// 查找模型文件（带缓存）
  Future<String?> findModel(String fileName) async {
    if (!_initialized) {
      await buildIndex();
    }
    return _pathIndex[fileName];
  }

  /// 查找 mmproj 文件（带缓存）
  Future<String?> findMmproj(String mmprojFileName) async {
    if (!_initialized) {
      await buildIndex();
    }
    return _mmprojPathIndex[mmprojFileName];
  }

  /// 构建索引（首次调用时执行）
  Future<void> buildIndex() async {
    if (_initialized) return;

    debugPrint('[ModelPathCache] 开始构建模型路径索引...');
    final stopwatch = Stopwatch()..start();

    try {
      final dirs = await getModelDirectories();
      
      for (final dirPath in dirs) {
        final dir = Directory(dirPath);
        if (!await dir.exists()) continue;

        await for (final entity in dir.list(recursive: true)) {
          if (entity is File) {
            final fileName = entity.path.split('/').last;
            
            if (fileName.endsWith('.gguf')) {
              // 主模型文件
              _pathIndex[fileName] = entity.path;
            } else if (fileName.endsWith('-mmproj.gguf') || 
                       fileName.contains('mmproj')) {
              // mmproj 投影仪文件
              _mmprojPathIndex[fileName] = entity.path;
            }
          }
        }
      }

      _initialized = true;
      stopwatch.stop();
      debugPrint('[ModelPathCache] 索引构建完成: ${_pathIndex.length}个模型, '
          '${_mmprojPathIndex.length}个mmproj, '
          '耗时${stopwatch.elapsedMilliseconds}ms');
    } catch (e) {
      debugPrint('[ModelPathCache] 索引构建失败: $e');
      // 失败时不设置 _initialized，下次会重试
    }
  }

  /// 使缓存失效（模型下载/删除后调用）
  void invalidate() {
    _initialized = false;
    _pathIndex.clear();
    _mmprojPathIndex.clear();
    _cachedModelDirs = null;
    debugPrint('[ModelPathCache] 缓存已失效');
  }

  /// 添加新模型到缓存
  void addModel(String fileName, String fullPath) {
    _pathIndex[fileName] = fullPath;
    debugPrint('[ModelPathCache] 添加模型缓存: $fileName -> $fullPath');
  }

  /// 添加 mmproj 到缓存
  void addMmproj(String fileName, String fullPath) {
    _mmprojPathIndex[fileName] = fullPath;
    debugPrint('[ModelPathCache] 添加mmproj缓存: $fileName -> $fullPath');
  }

  /// 移除模型缓存
  void removeModel(String fileName) {
    _pathIndex.remove(fileName);
    debugPrint('[ModelPathCache] 移除模型缓存: $fileName');
  }

  /// 获取所有模型目录（带缓存）
  Future<List<String>> getModelDirectories() async {
    if (_cachedModelDirs != null) {
      return _cachedModelDirs!;
    }

    final dirs = <String>[];

    try {
      // 1. 应用文档目录
      final appDir = await getApplicationDocumentsDirectory();
      dirs.add('${appDir.path}/models');

      // 2. 自定义下载路径（用户在设置中配置的模型下载目录）
      try {
        final prefs = await SharedPreferences.getInstance();
        final customPath = prefs.getString('download_path');
        if (customPath != null && customPath.isNotEmpty) {
          final customDir = Directory(customPath);
          if (await customDir.exists() && !dirs.contains(customPath)) {
            dirs.add(customPath);
            debugPrint('[ModelPathCache] 添加自定义模型目录: $customPath');
          }
        }
      } catch (_) {}

      // 3. Android 外部存储
      if (Platform.isAndroid) {
        try {
          final extDir = await getExternalStorageDirectory();
          if (extDir != null) {
            dirs.add('${extDir.path}/models');
          }
        } catch (_) {}
      }

      // 4. 下载目录
      final downloadDir = await getDownloadsDirectory();
      if (downloadDir != null) {
        dirs.add('${downloadDir.path}/LLMStudio/models');
      }

      _cachedModelDirs = dirs;
    } catch (e) {
      debugPrint('[ModelPathCache] 获取目录失败: $e');
    }

    return dirs;
  }

  /// 获取缓存统计信息
  Map<String, dynamic> getStats() {
    return {
      'initialized': _initialized,
      'modelCount': _pathIndex.length,
      'mmprojCount': _mmprojPathIndex.length,
      'directories': _cachedModelDirs?.length ?? 0,
    };
  }
}
