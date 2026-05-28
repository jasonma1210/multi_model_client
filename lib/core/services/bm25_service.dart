/// BM25 排序服务 - LLM Studio 全文检索模块
/// 
/// 功能：
/// - BM25 排序算法实现
/// - 文档相关性评分
/// - 全文检索支持
/// - 中文分词集成
/// 
/// @author JianMa
/// @version 1.0.0
library;

import 'dart:math';
import 'chinese_segmenter_service.dart';

/// BM25 排序算法服务
/// BM25 (Best Matching 25) 是一种用于信息检索的排名函数
/// 用于评估文档与查询之间的相关性
class BM25Service {
  /// 文档集合
  final List<BM25Document> documents;
  
  /// 文档平均长度
  late final double _avgDocLength;
  
  /// 逆文档频率表
  late final Map<String, double> _idfCache;
  
  /// 词频表（文档ID -> 词 -> 频率）
  late final Map<int, Map<String, int>> _termFrequencyCache;
  
  /// BM25 参数
  final double k1; // 词频饱和参数（通常 1.2-2.0）
  final double b;  // 文档长度归一化参数（通常 0.75）

  BM25Service({
    required this.documents,
    this.k1 = 1.5,
    this.b = 0.75,
  }) {
    _precompute();
  }

  /// 预计算文档统计信息
  void _precompute() {
    if (documents.isEmpty) {
      _avgDocLength = 0;
      _idfCache = {};
      _termFrequencyCache = {};
      return;
    }

    // 计算平均文档长度
    int totalLength = 0;
    _termFrequencyCache = {};
    
    for (final doc in documents) {
      final words = ChineseSegmenterService.segment(doc.content);
      totalLength += words.length;
      
      // 计算词频
      final tf = <String, int>{};
      for (final word in words) {
        tf[word] = (tf[word] ?? 0) + 1;
      }
      _termFrequencyCache[doc.id] = tf;
    }
    
    _avgDocLength = totalLength / documents.length;

    // 计算 IDF
    _computeIDF();
  }

  /// 计算逆文档频率 (IDF)
  void _computeIDF() {
    _idfCache = {};
    final N = documents.length;
    
    if (N == 0) return;

    // 统计每个词出现在多少个文档中
    final docFreq = <String, int>{};
    for (final tf in _termFrequencyCache.values) {
      for (final word in tf.keys) {
        docFreq[word] = (docFreq[word] ?? 0) + 1;
      }
    }

    // 计算 IDF（使用 Okapi BM25 公式的 IDF）
    for (final entry in docFreq.entries) {
      final df = entry.value;
      // IDF = log((N - df + 0.5) / (df + 0.5) + 1)
      _idfCache[entry.key] = log((N - df + 0.5) / (df + 0.5) + 1);
    }
  }

  /// 计算单个文档对查询的 BM25 分数
  double score(String query) {
    if (documents.isEmpty) return 0;
    
    final queryWords = ChineseSegmenterService.extractKeywords(query);
    if (queryWords.isEmpty) return 0;

    double totalScore = 0;
    
    for (final doc in documents) {
      final docScore = _documentScore(doc, queryWords);
      totalScore += docScore;
    }
    
    return totalScore;
  }

  /// 计算单个文档对查询词的 BM25 分数
  double _documentScore(BM25Document doc, List<String> queryWords) {
    final tf = _termFrequencyCache[doc.id] ?? {};
    final docLength = doc.content.length;
    
    double score = 0;
    
    for (final word in queryWords) {
      // 词频
      final termFreq = tf[word] ?? 0;
      
      // IDF
      final idf = _idfCache[word] ?? 0;
      
      // BM25 公式
      // score = IDF * (tf * (k1 + 1)) / (tf + k1 * (1 - b + b * docLength / avgDocLength))
      final numerator = termFreq * (k1 + 1);
      final denominator = termFreq + k1 * (1 - b + b * docLength / _avgDocLength);
      
      if (denominator > 0) {
        score += idf * numerator / denominator;
      }
    }
    
    return score;
  }

  /// 获取排序后的文档列表（按 BM25 分数降序）
  List<BM25Document> getRankedDocuments(String query) {
    return getRankedDocumentsWithScores(query).map((s) => s.doc).toList();
  }

  /// 获取排序后的文档列表（按 BM25 分数降序），同时返回分数
  List<ScoredDocument> getRankedDocumentsWithScores(String query) {
    if (documents.isEmpty) return [];
    
    final queryWords = ChineseSegmenterService.extractKeywords(query);
    if (queryWords.isEmpty) {
      return documents.map((doc) => ScoredDocument(doc: doc, score: 0)).toList();
    }

    // 计算每个文档的分数
    final scoredDocs = <ScoredDocument>[];
    
    for (final doc in documents) {
      final tf = _termFrequencyCache[doc.id] ?? {};
      final docLength = doc.content.length;
      
      double score = 0;
      for (final word in queryWords) {
        final termFreq = tf[word] ?? 0;
        final idf = _idfCache[word] ?? 0;
        
        final numerator = termFreq * (k1 + 1);
        final denominator = termFreq + k1 * (1 - b + b * docLength / _avgDocLength);
        
        if (denominator > 0) {
          score += idf * numerator / denominator;
        }
      }
      
      scoredDocs.add(ScoredDocument(doc: doc, score: score));
    }
    
    // 按分数降序排序
    scoredDocs.sort((a, b) => b.score.compareTo(a.score));
    
    return scoredDocs;
  }

  /// 获取单个文档对查询的 BM25 分数
  double getDocumentScore(String content, String query) {
    if (documents.isEmpty) return 0;
    
    final queryWords = ChineseSegmenterService.extractKeywords(query);
    if (queryWords.isEmpty) return 0;

    // 计算这个词频
    final tf = <String, int>{};
    final words = ChineseSegmenterService.extractKeywords(content);
    for (final word in words) {
      tf[word] = (tf[word] ?? 0) + 1;
    }
    
    final docLength = content.length;
    
    double score = 0;
    for (final word in queryWords) {
      final termFreq = tf[word] ?? 0;
      final idf = _idfCache[word] ?? 0;
      
      final numerator = termFreq * (k1 + 1);
      final denominator = termFreq + k1 * (1 - b + b * docLength / _avgDocLength);
      
      if (denominator > 0) {
        score += idf * numerator / denominator;
      }
    }
    
    return score;
  }

  /// 重新计算（当文档集合变化时）
  void refresh() {
    _precompute();
  }
}

/// BM25 文档
class BM25Document {
  final int id;
  final String content;
  final String? title;
  final Map<String, dynamic>? metadata;

  BM25Document({
    required this.id,
    required this.content,
    this.title,
    this.metadata,
  });
}

/// 带分数的文档
/// 文档评分结果
class ScoredDocument {
  final BM25Document doc;
  final double score;

  ScoredDocument({required this.doc, required this.score});
}