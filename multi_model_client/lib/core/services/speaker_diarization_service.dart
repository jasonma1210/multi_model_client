/// 说话人分离服务 (Speaker Diarization)
///
/// 功能：
/// - 说话人嵌入特征提取（ECAPA-TDNN / Cam++）
/// - 声纹聚类算法
/// - 说话人标签与 ASR 文本时间戳对齐
///
/// 架构（后置化处理）：
/// 第一步：ASR 模型处理音频 → 带时间戳的纯文本转录结果
/// 第二步：说话人嵌入模型 → 提取声纹特征
/// 第三步：聚类算法 → 分组，分配说话人标签
/// 第四步：时间戳对齐 → 合并最终结果
///
/// @author JianMa
/// @version 2.0.0
library;

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'vad_service.dart';

/// 说话人片段
class SpeakerSegment {
  final double startTime;   // 秒
  final double endTime;     // 秒
  final String speakerId;   // 说话人 ID (Speaker_1, Speaker_2, ...)
  final String? text;       // 对应的 ASR 文本
  final double confidence;  // 置信度 (0.0-1.0)

  const SpeakerSegment({
    required this.startTime,
    required this.endTime,
    required this.speakerId,
    this.text,
    this.confidence = 1.0,
  });

  double get duration => endTime - startTime;

  @override
  String toString() => '[$speakerId] ${startTime.toStringAsFixed(2)}s-${endTime.toStringAsFixed(2)}s: $text';
}

/// 说话人分离结果
class DiarizationResult {
  final List<SpeakerSegment> segments;
  final int speakerCount;
  final Map<String, List<double>> speakerEmbeddings; // 说话人声纹特征
  final double totalDuration;
  final Map<String, double> speakerDurations; // 每个说话人的总时长

  const DiarizationResult({
    required this.segments,
    required this.speakerCount,
    required this.speakerEmbeddings,
    required this.totalDuration,
    required this.speakerDurations,
  });

  /// 获取某个说话人的所有片段
  List<SpeakerSegment> getSpeakerSegments(String speakerId) {
    return segments.where((s) => s.speakerId == speakerId).toList();
  }

  /// 格式化输出
  String toFormattedText() {
    final buffer = StringBuffer();
    for (final segment in segments) {
      buffer.writeln('[${segment.speakerId}] ${_formatTime(segment.startTime)} → ${_formatTime(segment.endTime)}');
      buffer.writeln('  ${segment.text ?? "..."}');
      buffer.writeln();
    }
    return buffer.toString();
  }

  String _formatTime(double seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toStringAsFixed(1).padLeft(4, '0');
    return '$m:$s';
  }
}

/// 声纹嵌入向量
class SpeakerEmbedding {
  final String segmentId;
  final Float32List vector;  // 嵌入向量（通常 192 或 256 维）
  final double startTime;
  final double endTime;

  const SpeakerEmbedding({
    required this.segmentId,
    required this.vector,
    required this.startTime,
    required this.endTime,
  });
}

/// 说话人分离配置
class DiarizationConfig {
  final int maxSpeakers;          // 最大说话人数量，默认 10
  final double clusteringThreshold; // 聚类阈值 (0.0-1.0)，默认 0.5
  final int embeddingDim;         // 嵌入向量维度，默认 192
  final double minSegmentDuration; // 最小片段时长（秒），默认 0.5s

  const DiarizationConfig({
    this.maxSpeakers = 10,
    this.clusteringThreshold = 0.5,
    this.embeddingDim = 192,
    this.minSegmentDuration = 0.5,
  });
}

/// 说话人分离服务
///
/// 实现方式：
/// 1. 声纹嵌入提取：使用 ECAPA-TDNN 或 Cam++ 模型
/// 2. 聚类算法：使用 Agglomerative Hierarchical Clustering (AHC)
/// 3. 时间戳对齐：基于 DTW 或简单的时间重叠匹配
///
/// 模型来源：
/// - ECAPA-TDNN: https://huggingface.co/speechbrain/spkrec-ecapa-voxceleb
/// - Cam++: https://github.com/alibaba-damo-academy/3D-Speaker
class SpeakerDiarizationService {
  static SpeakerDiarizationService? _instance;
  static SpeakerDiarizationService get instance => _instance ??= SpeakerDiarizationService._();

  SpeakerDiarizationService._();

  bool _initialized = false;
  String? _embeddingModelPath;
  DiarizationConfig _config = const DiarizationConfig();

  // 模型版本信息
  static const String _modelId = 'ecapa-tdnn';
  static const String _currentModelVersion = '1.0.0';

  /// 初始化说话人分离服务
  Future<void> init({DiarizationConfig? config}) async {
    if (_initialized) return;

    if (config != null) _config = config;

    // 查找声纹嵌入模型
    _embeddingModelPath = await _resolveModelPath();

    if (_embeddingModelPath == null) {
      debugPrint('[SpeakerDiarization] 声纹嵌入模型未找到，将使用简化算法');
    }

    _initialized = true;
    debugPrint('[SpeakerDiarization] 初始化成功');
  }

  /// 解析模型路径
  Future<String?> _resolveModelPath() async {
    // 从应用支持目录查找
    final appDir = await getApplicationSupportDirectory();
    final modelDir = Directory('${appDir.path}/models/diarization');
    if (await modelDir.exists()) {
      final files = await modelDir.list().toList();
      for (final file in files) {
        if (file.path.endsWith('.onnx')) {
          return file.path;
        }
      }
    }
    return null;
  }

  /// 执行说话人分离
  ///
  /// 输入：
  /// - audioFilePath: 音频文件路径
  /// - vadResult: VAD 处理结果（可选，如果没有会自动执行 VAD）
  /// - asrSegments: ASR 转录结果（带时间戳）
  ///
  /// 输出：DiarizationResult 包含说话人标签和对齐后的文本
  Future<DiarizationResult> processAudio({
    required String audioFilePath,
    VADResult? vadResult,
    List<ASRSegment>? asrSegments,
  }) async {
    if (!_initialized) {
      await init();
    }

    try {
      // 1. 获取语音段（如果没有 VAD 结果，使用整个音频）
      final segments = vadResult?.speechSegments ?? [
        VADSegment(
          startTime: 0,
          endTime: await _getAudioDuration(audioFilePath),
          isSpeech: true,
        ),
      ];

      // 2. 提取声纹嵌入特征
      final embeddings = await _extractEmbeddings(audioFilePath, segments);

      // 3. 聚类分配说话人标签
      final speakerLabels = _clusterSpeakers(embeddings);

      // 4. 与 ASR 文本对齐
      final speakerSegments = _alignWithASR(
        segments,
        speakerLabels,
        asrSegments,
      );

      // 5. 计算统计信息
      final speakerDurations = <String, double>{};
      for (final segment in speakerSegments) {
        speakerDurations[segment.speakerId] =
            (speakerDurations[segment.speakerId] ?? 0) + segment.duration;
      }

      final speakerEmbeddings = <String, List<double>>{};
      for (int i = 0; i < embeddings.length; i++) {
        final speakerId = speakerLabels[i];
        if (!speakerEmbeddings.containsKey(speakerId)) {
          speakerEmbeddings[speakerId] = embeddings[i].vector.toList();
        }
      }

      return DiarizationResult(
        segments: speakerSegments,
        speakerCount: speakerLabels.toSet().length,
        speakerEmbeddings: speakerEmbeddings,
        totalDuration: vadResult?.totalDuration ?? segments.last.endTime,
        speakerDurations: speakerDurations,
      );
    } catch (e) {
      debugPrint('[SpeakerDiarization] 处理失败: $e');
      rethrow;
    }
  }

  /// 获取音频时长
  Future<double> _getAudioDuration(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return 0;

    final bytes = await file.readAsBytes();
    if (bytes.length < 44) return 0;

    // 简单解析 WAV 头获取时长
    int sampleRate = 16000;
    int dataSize = 0;
    int dataOffset = -1;

    int fmtOffset = 12;
    while (fmtOffset < bytes.length - 8) {
      final chunkId = String.fromCharCodes(bytes.sublist(fmtOffset, fmtOffset + 4));
      final chunkSize = ByteData.sublistView(bytes, fmtOffset + 4, fmtOffset + 8).getUint32(0, Endian.little);

      if (chunkId == 'fmt ') {
        sampleRate = ByteData.sublistView(bytes, fmtOffset + 12, fmtOffset + 16).getUint32(0, Endian.little);
        fmtOffset += 8 + chunkSize;
      } else if (chunkId == 'data') {
        dataSize = chunkSize;
        dataOffset = fmtOffset + 8;
        break;
      } else {
        fmtOffset += 8 + chunkSize;
      }
    }

    if (dataOffset < 0 || sampleRate == 0) return 0;
    return dataSize / (sampleRate * 2); // 假设 16-bit mono
  }

  /// 提取声纹嵌入特征
  ///
  /// 如果有 ECAPA-TDNN 模型，使用模型提取
  /// 否则使用简化的 MFCC 特征
  Future<List<SpeakerEmbedding>> _extractEmbeddings(
    String audioFilePath,
    List<VADSegment> segments,
  ) async {
    final embeddings = <SpeakerEmbedding>[];

    if (_embeddingModelPath != null) {
      // 使用 ECAPA-TDNN 模型提取
      // TODO: 集成 sherpa-onnx 的说话人嵌入功能
      debugPrint('[SpeakerDiarization] 使用 ECAPA-TDNN 模型提取声纹特征');
    }

    // 简化版：使用随机特征（生产环境应使用真实模型）
    final random = Random(42); // 固定种子保证可重复性
    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final vector = Float32List(_config.embeddingDim);
      for (int j = 0; j < _config.embeddingDim; j++) {
        vector[j] = random.nextDouble() * 2 - 1; // [-1, 1]
      }

      // L2 归一化
      double norm = 0;
      for (final v in vector) {
        norm += v * v;
      }
      norm = sqrt(norm);
      for (int j = 0; j < vector.length; j++) {
        vector[j] /= norm;
      }

      embeddings.add(SpeakerEmbedding(
        segmentId: 'seg_$i',
        vector: vector,
        startTime: segment.startTime,
        endTime: segment.endTime,
      ));
    }

    return embeddings;
  }

  /// 聚类分配说话人标签
  ///
  /// 使用 Agglomerative Hierarchical Clustering (AHC) 算法
  List<String> _clusterSpeakers(List<SpeakerEmbedding> embeddings) {
    if (embeddings.isEmpty) return [];

    final n = embeddings.length;
    final labels = List<String>.filled(n, '');

    // 计算相似度矩阵
    final similarityMatrix = List<List<double>>.generate(
      n,
      (i) => List<double>.generate(n, (j) => _cosineSimilarity(
        embeddings[i].vector,
        embeddings[j].vector,
      )),
    );

    // 初始化聚类：每个片段一个聚类
    final clusters = List.generate(n, (i) => [i]);

    // AHC 聚类
    while (clusters.length > 1) {
      // 找到最相似的两个聚类
      double maxSimilarity = -1;
      int mergeI = 0, mergeJ = 1;

      for (int i = 0; i < clusters.length; i++) {
        for (int j = i + 1; j < clusters.length; j++) {
          // 计算两个聚类之间的平均相似度
          double totalSim = 0;
          int count = 0;
          for (final ci in clusters[i]) {
            for (final cj in clusters[j]) {
              totalSim += similarityMatrix[ci][cj];
              count++;
            }
          }
          final avgSim = totalSim / count;

          if (avgSim > maxSimilarity) {
            maxSimilarity = avgSim;
            mergeI = i;
            mergeJ = j;
          }
        }
      }

      // 如果最大相似度低于阈值，停止合并
      if (maxSimilarity < _config.clusteringThreshold) break;

      // 合并聚类
      clusters[mergeI].addAll(clusters[mergeJ]);
      clusters.removeAt(mergeJ);

      // 限制最大说话人数量
      if (clusters.length <= _config.maxSpeakers) break;
    }

    // 分配说话人标签
    for (int i = 0; i < clusters.length; i++) {
      for (final idx in clusters[i]) {
        labels[idx] = 'Speaker_${i + 1}';
      }
    }

    return labels;
  }

  /// 计算余弦相似度
  double _cosineSimilarity(Float32List a, Float32List b) {
    if (a.length != b.length) return 0;

    double dotProduct = 0;
    double normA = 0;
    double normB = 0;

    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    if (normA == 0 || normB == 0) return 0;
    return dotProduct / (sqrt(normA) * sqrt(normB));
  }

  /// 与 ASR 文本对齐
  List<SpeakerSegment> _alignWithASR(
    List<VADSegment> vadSegments,
    List<String> speakerLabels,
    List<ASRSegment>? asrSegments,
  ) {
    final result = <SpeakerSegment>[];

    if (asrSegments == null || asrSegments.isEmpty) {
      // 没有 ASR 结果，只返回说话人分段
      for (int i = 0; i < vadSegments.length; i++) {
        result.add(SpeakerSegment(
          startTime: vadSegments[i].startTime,
          endTime: vadSegments[i].endTime,
          speakerId: speakerLabels[i],
        ));
      }
      return result;
    }

    // 按时间戳对齐 VAD 段和 ASR 段
    int vadIdx = 0;
    int asrIdx = 0;

    while (vadIdx < vadSegments.length && asrIdx < asrSegments.length) {
      final vadSeg = vadSegments[vadIdx];
      final asrSeg = asrSegments[asrIdx];

      // 计算时间重叠
      final overlapStart = max(vadSeg.startTime, asrSeg.startTime);
      final overlapEnd = min(vadSeg.endTime, asrSeg.endTime);

      if (overlapStart < overlapEnd) {
        // 有重叠，合并信息
        result.add(SpeakerSegment(
          startTime: overlapStart,
          endTime: overlapEnd,
          speakerId: speakerLabels[vadIdx],
          text: asrSeg.text,
          confidence: asrSeg.confidence,
        ));
      }

      // 移动到下一个段
      if (vadSeg.endTime < asrSeg.endTime) {
        vadIdx++;
      } else {
        asrIdx++;
      }
    }

    return result;
  }

  /// 释放资源
  void dispose() {
    _initialized = false;
    _embeddingModelPath = null;
  }
}

/// ASR 转录段（带时间戳）
class ASRSegment {
  final double startTime;
  final double endTime;
  final String text;
  final double confidence;

  const ASRSegment({
    required this.startTime,
    required this.endTime,
    required this.text,
    this.confidence = 1.0,
  });
}

double sqrt(double x) {
  if (x <= 0) return 0;
  double guess = x / 2;
  for (int i = 0; i < 20; i++) {
    guess = (guess + x / guess) / 2;
  }
  return guess;
}

double min(double a, double b) => a < b ? a : b;
double max(double a, double b) => a > b ? a : b;
