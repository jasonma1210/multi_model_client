/// ModelScope 服务 - LLM Studio 模型下载模块
/// 
/// 功能：
/// - ModelScope 模型下载
/// - Python SDK 集成
/// - 模型缓存管理
/// - 断点续传支持
/// 
/// @author JianMa
/// @version 1.0.0
library;

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// ModelScope 模型下载服务
/// 使用 Python SDK 实现模型下载
class ModelScopeService {
  final String _pythonPath;
  final String _pythonScriptPath;
  final String? _cacheDir;

  ModelScopeService({
    String? pythonPath,
    String? pythonScriptPath,
    String? cacheDir,
  })  : _pythonPath = pythonPath ?? _getDefaultPythonPath(),
        _pythonScriptPath = pythonScriptPath ?? _getDefaultScriptPath(),
        _cacheDir = cacheDir;

  /// 获取默认 Python 路径（优先使用 anaconda）
  static String _getDefaultPythonPath() {
    // 优先使用 anaconda 的 python3
    const anacondaPython = '/opt/anaconda3/bin/python3';
    if (File(anacondaPython).existsSync()) {
      return anacondaPython;
    }
    // 回退到系统 python3
    return 'python3';
  }

  static String _getDefaultScriptPath() {
    // 获取脚本路径
    const scriptDir = '/Users/jianma/Desktop/LLM STUDIO/multi_model_client/scripts';
    return '$scriptDir/modelscope_download.py';
  }

  /// 下载 ModelScope 模型
  /// [modelId] 模型ID，格式如 'ZhipuAI/chatglm3-6b'
  /// [outputDir] 输出目录（可选）
  /// [onProgress] 进度回调
  Future<ModelScopeDownloadResult> downloadModel(
    String modelId, {
    String? outputDir,
    Function(String)? onProgress,
  }) async {
    try {
      onProgress?.call('正在准备下载...');

      final downloadArgs = <String>[];
      if (_cacheDir != null) {
        downloadArgs.addAll(['--cache_dir', _cacheDir]);
      }
      if (outputDir != null) {
        downloadArgs.addAll(['--output_dir', outputDir]);
      }

      final result = await Process.run(
        _pythonPath,
        [
          _pythonScriptPath,
          'download',
          modelId,
          ...downloadArgs,
        ],
        runInShell: true,
      );

      if (result.exitCode == 0) {
        final output = result.stdout.toString().trim();
        final jsonResult = _parseJsonOutput(output);
        
        if (jsonResult != null && jsonResult['success'] == true) {
          return ModelScopeDownloadResult(
            success: true,
            modelId: modelId,
            modelDir: jsonResult['model_dir'] ?? '',
            files: (jsonResult['files'] as List<dynamic>?)
                    ?.map((f) => ModelFile(
                          name: f['name'] ?? '',
                          size: f['size'] ?? 0,
                          path: f['path'] ?? '',
                        ))
                    .toList() ??
                [],
            downloadTime: (jsonResult['download_time'] ?? 0).toDouble(),
            totalSize: jsonResult['total_size'] ?? 0,
          );
        } else {
          return ModelScopeDownloadResult(
            success: false,
            modelId: modelId,
            error: jsonResult?['error'] ?? '下载失败',
          );
        }
      } else {
        return ModelScopeDownloadResult(
          success: false,
          modelId: modelId,
          error: result.stderr.toString(),
        );
      }
    } catch (e) {
      debugPrint('ModelScope download error: $e');
      return ModelScopeDownloadResult(
        success: false,
        modelId: modelId,
        error: e.toString(),
      );
    }
  }

  /// 获取模型信息
  Future<ModelScopeModelInfo?> getModelInfo(String modelId) async {
    try {
      final result = await Process.run(
        _pythonPath,
        [
          _pythonScriptPath,
          'info',
          modelId,
        ],
        runInShell: true,
      );

      if (result.exitCode == 0) {
        final output = result.stdout.toString().trim();
        final jsonResult = _parseJsonOutput(output);

        if (jsonResult != null && jsonResult['success'] == true) {
          return ModelScopeModelInfo(
            modelId: jsonResult['model_id'] ?? modelId,
            name: jsonResult['name'] ?? '',
            author: jsonResult['author'] ?? '',
            description: jsonResult['description'] ?? '',
            downloads: jsonResult['downloads'] ?? 0,
            likes: jsonResult['likes'] ?? 0,
            tags: (jsonResult['tags'] as List<dynamic>?)?.cast<String>() ?? [],
            license: jsonResult['license'] ?? '',
          );
        }
      }
      return null;
    } catch (e) {
      debugPrint('ModelScope getModelInfo error: $e');
      return null;
    }
  }

  /// 列出模型文件
  Future<List<String>?> listModelFiles(String modelId) async {
    try {
      final result = await Process.run(
        _pythonPath,
        [
          _pythonScriptPath,
          'list',
          modelId,
        ],
        runInShell: true,
      );

      if (result.exitCode == 0) {
        final output = result.stdout.toString().trim();
        final jsonResult = _parseJsonOutput(output);

        if (jsonResult != null && jsonResult['success'] == true) {
          return (jsonResult['files'] as List<dynamic>?)?.cast<String>() ?? [];
        }
      }
      return null;
    } catch (e) {
      debugPrint('ModelScope listModelFiles error: $e');
      return null;
    }
  }

  /// 解析 JSON 输出
  Map<String, dynamic>? _parseJsonOutput(String output) {
    try {
      // 找到第一个 { 和最后一个 } 之间的内容
      final start = output.indexOf('{');
      final end = output.lastIndexOf('}');
      
      if (start != -1 && end != -1 && end > start) {
        final jsonStr = output.substring(start, end + 1);
        return json.decode(jsonStr) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Failed to parse JSON: $e');
    }
    return null;
  }
}

/// ModelScope 下载结果
class ModelScopeDownloadResult {
  final bool success;
  final String modelId;
  final String? modelDir;
  final List<ModelFile> files;
  final double downloadTime;
  final int totalSize;
  final String? error;

  ModelScopeDownloadResult({
    required this.success,
    required this.modelId,
    this.modelDir,
    this.files = const [],
    this.downloadTime = 0,
    this.totalSize = 0,
    this.error,
  });

  String get formattedSize {
    if (totalSize < 1024) return '$totalSize B';
    if (totalSize < 1024 * 1024) return '${(totalSize / 1024).toStringAsFixed(1)} KB';
    if (totalSize < 1024 * 1024 * 1024) {
      return '${(totalSize / 1024 / 1024).toStringAsFixed(1)} MB';
    }
    return '${(totalSize / 1024 / 1024 / 1024).toStringAsFixed(2)} GB';
  }
}

/// 模型文件信息
class ModelFile {
  final String name;
  final int size;
  final String path;

  ModelFile({
    required this.name,
    required this.size,
    required this.path,
  });

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / 1024 / 1024).toStringAsFixed(1)} MB';
    }
    return '${(size / 1024 / 1024 / 1024).toStringAsFixed(2)} GB';
  }
}

/// ModelScope 模型信息
class ModelScopeModelInfo {
  final String modelId;
  final String name;
  final String author;
  final String description;
  final int downloads;
  final int likes;
  final List<String> tags;
  final String license;

  ModelScopeModelInfo({
    required this.modelId,
    required this.name,
    required this.author,
    required this.description,
    required this.downloads,
    required this.likes,
    required this.tags,
    required this.license,
  });
}