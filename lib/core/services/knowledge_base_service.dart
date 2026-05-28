/// 知识库服务 - LLM Studio RAG 知识库管理模块
/// 
/// 功能：
/// - 知识库 CRUD 操作
/// - 文档解析与分块
/// - FTS5 全文检索 + BM25 重排序
/// - 健康检查与诊断
/// 
/// @author JianMa
/// @version 1.1.0
library;

import 'dart:io';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import '../storage/database.dart';
import 'file_parser_service.dart';
import 'chinese_segmenter_service.dart';
import 'bm25_service.dart';

/// 知识库服务 - 管理知识库的 CRUD 和全文检索
class KnowledgeBaseService {
  final AppDatabase _db;
  
  /// FTS 表是否已创建的缓存
  final Set<String> _ftsTablesCreated = {};

  KnowledgeBaseService(this._db);

  /// 获取所有知识库（实时计算文档数量）
  Future<List<KnowledgeBase>> getAllKnowledgeBases() async {
    final kbs = await _db.select(_db.knowledgeBases).get();
    
    // 实时计算每个知识库的文档数量
    final updatedKbs = <KnowledgeBase>[];
    for (final kb in kbs) {
      final docCount = await (_db.select(_db.documents)
        ..where((t) => t.knowledgeBaseId.equals(kb.id))).get();
      
      if (docCount.length != kb.documentCount) {
        // 更新文档数量
        await (_db.update(_db.knowledgeBases)
          ..where((t) => t.id.equals(kb.id))).write(
          KnowledgeBasesCompanion(
            documentCount: Value(docCount.length),
            updatedAt: Value(DateTime.now()),
          ),
        );
        
        // 重新获取更新后的数据
        final updated = await (_db.select(_db.knowledgeBases)
          ..where((t) => t.id.equals(kb.id))).getSingleOrNull();
        if (updated != null) {
          updatedKbs.add(updated);
          continue;
        }
      }
      updatedKbs.add(kb);
    }
    
    return updatedKbs;
  }

  /// 获取知识库详情（实时计算文档数量）
  Future<KnowledgeBase?> getKnowledgeBase(String id) async {
    final kb = await (_db.select(_db.knowledgeBases)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (kb == null) return null;
    
    // 实时计算文档数量
    final docCount = await (_db.select(_db.documents)
      ..where((t) => t.knowledgeBaseId.equals(id))).get();
    
    if (docCount.length != kb.documentCount) {
      // 更新文档数量
      await (_db.update(_db.knowledgeBases)
        ..where((t) => t.id.equals(id))).write(
        KnowledgeBasesCompanion(
          documentCount: Value(docCount.length),
          updatedAt: Value(DateTime.now()),
        ),
      );
      
      // 重新获取更新后的数据
      return await (_db.select(_db.knowledgeBases)..where((t) => t.id.equals(id))).getSingleOrNull();
    }
    
    return kb;
  }

  /// 创建知识库
  Future<KnowledgeBase> createKnowledgeBase({
    required String name,
    String? description,
  }) async {
    final now = DateTime.now();
    final id = 'kb_${now.millisecondsSinceEpoch}';
    
    final kb = KnowledgeBasesCompanion.insert(
      id: id,
      name: name,
      description: Value(description),
      documentCount: const Value(0),
      createdAt: now,
      updatedAt: now,
    );
    
    await _db.into(_db.knowledgeBases).insert(kb);
    
    // 创建 FTS5 虚拟表用于全文检索
    try {
      await _createFtsTable(id);
      _ftsTablesCreated.add(id);
      debugPrint('[KnowledgeBaseService] FTS 表创建成功: $id');
    } catch (e) {
      debugPrint('[KnowledgeBaseService] FTS 表创建失败: $e');
      // 不阻止知识库创建，后续可以修复
    }
    
    return (await getKnowledgeBase(id))!;
  }

  /// 更新知识库
  Future<void> updateKnowledgeBase({
    required String id,
    String? name,
    String? description,
  }) async {
    final query = _db.update(_db.knowledgeBases)..where((t) => t.id.equals(id));
    await query.write(
      KnowledgeBasesCompanion(
        name: name != null ? Value(name) : const Value.absent(),
        description: description != null ? Value(description) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// 删除知识库（同时删除文档和分块）
  Future<void> deleteKnowledgeBase(String id) async {
    // 删除 FTS 表
    await _dropFtsTable(id);
    
    // 删除所有分块
    final chunksQuery = _db.delete(_db.documentChunks)
      ..where((t) => t.knowledgeBaseId.equals(id));
    await chunksQuery.go();
    
    // 删除所有文档
    final docsQuery = _db.delete(_db.documents)
      ..where((t) => t.knowledgeBaseId.equals(id));
    await docsQuery.go();
    
    // 删除知识库
    final kbQuery = _db.delete(_db.knowledgeBases)
      ..where((t) => t.id.equals(id));
    await kbQuery.go();
  }

  /// 获取知识库下的所有文档
  Future<List<Document>> getDocuments(String knowledgeBaseId) async {
    final query = _db.select(_db.documents)
      ..where((t) => t.knowledgeBaseId.equals(knowledgeBaseId))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return await query.get();
  }

  /// 添加文档到知识库
  Future<Document> addDocument({
    required String knowledgeBaseId,
    required String filePath,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('文件不存在: $filePath');
    }

    final fileName = p.basename(filePath);
    final fileType = FileParserService.getFileType(filePath);
    final fileSize = await file.length();
    final now = DateTime.now();
    final docId = 'doc_${now.millisecondsSinceEpoch}';

    // 解析文件内容
    String content;
    try {
      content = await FileParserService.parseFile(filePath);
      debugPrint('[KnowledgeBaseService] 文件解析成功: $fileName, 内容长度: ${content.length}');
      
      if (content.trim().isEmpty) {
        throw Exception('文件内容为空');
      }
    } catch (e) {
      debugPrint('[KnowledgeBaseService] 文件解析失败: $e');
      // 如果解析失败，记录错误
      final doc = DocumentsCompanion.insert(
        id: docId,
        knowledgeBaseId: knowledgeBaseId,
        fileName: fileName,
        filePath: filePath,
        fileType: fileType,
        fileSize: fileSize,
        status: const Value('failed'),
        errorMessage: Value(e.toString()),
        createdAt: now,
        updatedAt: now,
      );
      await _db.into(_db.documents).insert(doc);
      rethrow;
    }

    // 将内容分块
    final chunks = FileParserService.chunkText(content);
    debugPrint('[KnowledgeBaseService] 文档分块数量: ${chunks.length}');
    
    if (chunks.isEmpty) {
      throw Exception('文档分块失败，无法生成有效内容块');
    }
    
    // 确保 FTS 表存在
    await _ensureFtsTableExists(knowledgeBaseId);
    
    // 创建文档记录
    final doc = DocumentsCompanion.insert(
      id: docId,
      knowledgeBaseId: knowledgeBaseId,
      fileName: fileName,
      filePath: filePath,
      fileType: fileType,
      fileSize: fileSize,
      chunkCount: Value(chunks.length),
      status: const Value('completed'),
      createdAt: now,
      updatedAt: now,
    );
    await _db.into(_db.documents).insert(doc);
    debugPrint('[KnowledgeBaseService] 文档记录已创建: $docId');

    // 将分块存入数据库和 FTS
    int successCount = 0;
    for (var i = 0; i < chunks.length; i++) {
      final chunkId = 'chunk_${now.millisecondsSinceEpoch}_$i';
      final chunkContent = chunks[i];
      
      debugPrint('[KnowledgeBaseService] 存储分块 $i: ${chunkContent.substring(0, chunkContent.length > 50 ? 50 : chunkContent.length)}...');
      
      try {
        // 存储到数据库
        final chunk = DocumentChunksCompanion.insert(
          id: chunkId,
          knowledgeBaseId: knowledgeBaseId,
          documentId: docId,
          content: chunkContent,
          chunkIndex: i,
          createdAt: now,
        );
        await _db.into(_db.documentChunks).insert(chunk);
        
        // 添加到 FTS 索引
        await _addToFtsIndex(knowledgeBaseId, chunkId, chunkContent);
        successCount++;
      } catch (e) {
        debugPrint('[KnowledgeBaseService] 分块 $i 存储失败: $e');
        // 继续处理其他分块
      }
    }

    // 更新知识库文档数量
    await _updateDocumentCount(knowledgeBaseId);

    debugPrint('[KnowledgeBaseService] 文档添加完成: $docId, 成功分块数: $successCount/${chunks.length}');
    
    // 验证数据是否正确存储
    final storedChunks = await (_db.select(_db.documentChunks)
      ..where((t) => t.documentId.equals(docId))).get();
    debugPrint('[KnowledgeBaseService] 验证: 数据库中实际存储了 ${storedChunks.length} 个分块');
    
    return (_db.select(_db.documents)..where((t) => t.id.equals(docId))).getSingle();
  }

  /// 删除文档
  Future<void> deleteDocument(String documentId) async {
    // 获取文档信息
    final doc = await (_db.select(_db.documents)
      ..where((t) => t.id.equals(documentId))).getSingleOrNull();
    
    if (doc == null) return;
    
    // 删除关联的分块和 FTS
    final chunks = await (_db.select(_db.documentChunks)
      ..where((t) => t.documentId.equals(documentId))).get();
    
    for (final chunk in chunks) {
      await _removeFromFtsIndex(doc.knowledgeBaseId, chunk.id);
    }
    
    // 删除分块
    await (_db.delete(_db.documentChunks)
      ..where((t) => t.documentId.equals(documentId))).go();
    
    // 删除文档
    await (_db.delete(_db.documents)
      ..where((t) => t.id.equals(documentId))).go();
    
    // 更新知识库文档数量
    await _updateDocumentCount(doc.knowledgeBaseId);
  }

  /// 搜索知识库内容（使用 FTS5 + BM25 排序）
  Future<List<SearchResult>> searchKnowledgeBase(
    String knowledgeBaseId,
    String query, {
    int limit = 5,
  }) async {
    if (query.trim().isEmpty) return [];

    debugPrint('[KnowledgeBaseService] ========== 开始搜索 ==========');
    debugPrint('[KnowledgeBaseService] 知识库ID: $knowledgeBaseId');
    debugPrint('[KnowledgeBaseService] 查询内容: $query');

    // 先检查知识库是否有内容
    final allChunks = await (_db.select(_db.documentChunks)
      ..where((t) => t.knowledgeBaseId.equals(knowledgeBaseId))).get();
    debugPrint('[KnowledgeBaseService] 知识库分块总数: ${allChunks.length}');
    
    if (allChunks.isEmpty) {
      debugPrint('[KnowledgeBaseService] 知识库为空，无搜索结果');
      return [];
    }

    // 打印前几个分块的内容（用于调试）
    for (var i = 0; i < (allChunks.length > 3 ? 3 : allChunks.length); i++) {
      final chunk = allChunks[i];
      debugPrint('[KnowledgeBaseService] 分块${i + 1}: id=${chunk.id}, content=${chunk.content.substring(0, chunk.content.length > 100 ? 100 : chunk.content.length)}...');
    }

    // 确保 FTS 表存在
    await _ensureFtsTableExists(knowledgeBaseId);

    // 使用中文分词预处理查询词（先等待 jieba 初始化）
    final searchTerms = await _preprocessQuery(query);
    debugPrint('[KnowledgeBaseService] 分词结果: $searchTerms');
    
    // 如果分词结果为空，直接使用 BM25 搜索
    if (searchTerms.isEmpty) {
      debugPrint('[KnowledgeBaseService] 分词结果为空，使用 BM25 全量搜索');
      return _bm25Search(knowledgeBaseId, query, limit, allChunks);
    }

    final ftsTableName = 'knowledge_fts_$knowledgeBaseId';
    
    try {
      // 使用 FTS5 MATCH 查询，获取更多结果用于 BM25 重排
      // 支持中英文混合搜索：使用 OR 连接多个词，并添加通配符
      final searchQuery = searchTerms.map((t) => '"$t"*').join(' OR ');
      debugPrint('[KnowledgeBaseService] FTS 查询语句: $searchQuery');
      debugPrint('[KnowledgeBaseService] FTS 表名: $ftsTableName');
      
      final results = await _db.customSelect(
        '''
        SELECT chunk_id, content, rank 
        FROM "$ftsTableName" 
        WHERE "$ftsTableName" MATCH ?
        ORDER BY rank 
        LIMIT ?
        ''',
        variables: [
          Variable.withString(searchQuery),
          Variable.withInt(limit * 3),
        ],
        readsFrom: { _db.documentChunks },
      ).get();
      
      debugPrint('[KnowledgeBaseService] FTS 原始结果数量: ${results.length}');
      
      // 打印 FTS 结果
      for (var i = 0; i < results.length; i++) {
        final row = results[i];
        final content = row.read<String>('content');
        debugPrint('[KnowledgeBaseService] FTS结果${i + 1}: chunk_id=${row.read<String>('chunk_id')}, rank=${row.read<double>('rank')}, content=${content.substring(0, content.length > 50 ? 50 : content.length)}...');
      }

      // 如果 FTS 没有结果，回退到 BM25
      if (results.isEmpty) {
        debugPrint('[KnowledgeBaseService] FTS 无结果，回退到 BM25');
        return _bm25Search(knowledgeBaseId, query, limit, allChunks);
      }

      // 构建 BM25 文档列表
      final bm25Docs = allChunks.map((chunk) => BM25Document(
        id: chunk.id.hashCode,
        content: chunk.content,
      )).toList();

      // 使用 BM25 重排（同时获取分数）
      final bm25Service = BM25Service(documents: bm25Docs);
      final rankedDocs = bm25Service.getRankedDocumentsWithScores(query);
      debugPrint('[KnowledgeBaseService] BM25 排序结果数量: ${rankedDocs.length}');
      
      // 计算相关性阈值：最高分的 20% 作为最低阈值
      double minScoreThreshold = 0;
      if (rankedDocs.isNotEmpty) {
        final maxScore = rankedDocs.first.score;
        minScoreThreshold = maxScore * 0.2; // 至少 20% 的最高分
        debugPrint('[KnowledgeBaseService] BM25 最高分: $maxScore, 阈值: $minScoreThreshold');
      }

      // 合并 FTS 结果和 BM25 排序
      final ftsResultIds = results.map((row) => row.read<String>('chunk_id')).toSet();
      debugPrint('[KnowledgeBaseService] FTS 结果 ID 集合: $ftsResultIds');
      
      final mergedResults = <SearchResult>[];
      final addedIds = <String>{};
      
      // 首先添加 BM25 排序靠前且在 FTS 结果中的（需要超过阈值）
      for (final doc in rankedDocs) {
        if (doc.score < minScoreThreshold) {
          debugPrint('[KnowledgeBaseService] BM25 分数 ${doc.score} 低于阈值 $minScoreThreshold，停止添加');
          break;
        }
        
        final matchingChunk = allChunks.firstWhere(
          (c) => c.content == doc.doc.content,
          orElse: () => allChunks.first,
        );
        
        if (ftsResultIds.contains(matchingChunk.id) && !addedIds.contains(matchingChunk.id)) {
          debugPrint('[KnowledgeBaseService] 添加 BM25+FTS 结果: ${matchingChunk.id}, 分数: ${doc.score}');
          mergedResults.add(SearchResult(
            chunkId: matchingChunk.id,
            content: matchingChunk.content,
            rank: doc.score,
            source: 'hybrid',
          ));
          addedIds.add(matchingChunk.id);
          if (mergedResults.length >= limit) break;
        }
      }
      
      // 如果结果不够，补充 FTS 结果（但也要检查 BM25 分数）
      if (mergedResults.length < limit) {
        debugPrint('[KnowledgeBaseService] BM25+FTS 结果不足，补充 FTS 结果');
        for (final row in results) {
          final chunkId = row.read<String>('chunk_id');
          if (!addedIds.contains(chunkId)) {
            // 检查这个 chunk 的 BM25 分数
            final chunkContent = row.read<String>('content');
            final chunkBm25Score = bm25Service.getDocumentScore(chunkContent, query);
            
            if (chunkBm25Score >= minScoreThreshold || minScoreThreshold == 0) {
              debugPrint('[KnowledgeBaseService] 添加 FTS 结果: $chunkId, BM25分数: $chunkBm25Score');
              mergedResults.add(SearchResult(
                chunkId: chunkId,
                content: chunkContent,
                rank: row.read<double>('rank'),
                source: 'fts',
              ));
              addedIds.add(chunkId);
              if (mergedResults.length >= limit) break;
            } else {
              debugPrint('[KnowledgeBaseService] 跳过低相关性 FTS 结果: $chunkId, 分数: $chunkBm25Score');
            }
          }
        }
      }

      debugPrint('[KnowledgeBaseService] 最终结果数量: ${mergedResults.length}');
      debugPrint('[KnowledgeBaseService] ========== 搜索结束 ==========');
      return mergedResults;
    } catch (e, stack) {
      debugPrint('[KnowledgeBaseService] FTS 搜索失败: $e');
      debugPrint('[KnowledgeBaseService] 堆栈: $stack');
      // 如果 FTS 表不存在或出错，回退到 BM25 搜索
      return _bm25Search(knowledgeBaseId, query, limit, allChunks);
    }
  }

  /// 预处理查询词（使用中文分词）
  Future<List<String>> _preprocessQuery(String query) async {
    // 等待 jieba 初始化完成
    await ChineseSegmenterService.waitForInit();
    // 使用中文分词器提取关键词
    return ChineseSegmenterService.extractKeywords(query, minLength: 2);
  }

  /// BM25 搜索（回退方案）
  Future<List<SearchResult>> _bm25Search(
    String knowledgeBaseId,
    String query,
    int limit,
    List<DocumentChunk> allChunks,
  ) async {
    debugPrint('[KnowledgeBaseService] 使用 BM25 回退搜索');
    
    if (allChunks.isEmpty) return [];

    // 构建 BM25 文档
    final bm25Docs = allChunks.map((chunk) => BM25Document(
      id: chunk.id.hashCode,
      content: chunk.content,
    )).toList();

    // 使用 BM25 排序（带分数）
    final bm25Service = BM25Service(documents: bm25Docs);
    final rankedDocs = bm25Service.getRankedDocumentsWithScores(query);
    
    // 计算相关性阈值
    double minScoreThreshold = 0;
    if (rankedDocs.isNotEmpty) {
      final maxScore = rankedDocs.first.score;
      minScoreThreshold = maxScore * 0.2;
      debugPrint('[KnowledgeBaseService] BM25 回退搜索: 最高分: $maxScore, 阈值: $minScoreThreshold');
    }

    // 映射结果（只添加超过阈值的）
    final results = <SearchResult>[];
    for (final doc in rankedDocs) {
      if (doc.score < minScoreThreshold && minScoreThreshold > 0) {
        debugPrint('[KnowledgeBaseService] BM25 回退: 分数 ${doc.score} 低于阈值，停止');
        break;
      }
      
      final matchingChunk = allChunks.firstWhere(
        (c) => c.content == doc.doc.content,
        orElse: () => allChunks.first,
      );
      results.add(SearchResult(
        chunkId: matchingChunk.id,
        content: matchingChunk.content,
        rank: doc.score,
        source: 'bm25',
      ));
      
      if (results.length >= limit) break;
    }

    debugPrint('[KnowledgeBaseService] BM25 结果数量: ${results.length}');
    return results;
  }

  /// 更新知识库文档数量
  Future<void> _updateDocumentCount(String knowledgeBaseId) async {
    final count = await (_db.select(_db.documents)
      ..where((t) => t.knowledgeBaseId.equals(knowledgeBaseId))).get();
    
    await (_db.update(_db.knowledgeBases)
      ..where((t) => t.id.equals(knowledgeBaseId))).write(
      KnowledgeBasesCompanion(
        documentCount: Value(count.length),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// 创建 FTS5 虚拟表
  Future<void> _createFtsTable(String knowledgeBaseId) async {
    final tableName = 'knowledge_fts_$knowledgeBaseId';
    
    debugPrint('[KnowledgeBaseService] 创建 FTS 表: $tableName');
    
    try {
      await _db.customStatement(
        '''
        CREATE VIRTUAL TABLE IF NOT EXISTS "$tableName" USING fts5(
          chunk_id,
          content,
          tokenize='unicode61'
        )
        ''',
      );
      _ftsTablesCreated.add(knowledgeBaseId);
      debugPrint('[KnowledgeBaseService] FTS 表创建成功: $tableName');
    } catch (e) {
      debugPrint('[KnowledgeBaseService] FTS 表创建失败: $e');
      rethrow;
    }
  }
  
  /// 确保 FTS 表存在（用于旧知识库兼容）
  Future<void> _ensureFtsTableExists(String knowledgeBaseId) async {
    if (_ftsTablesCreated.contains(knowledgeBaseId)) {
      return;
    }
    
    final tableName = 'knowledge_fts_$knowledgeBaseId';
    
    try {
      // 检查表是否存在
      final result = await _db.customSelect(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
        variables: [Variable.withString(tableName)],
      ).get();
      
      if (result.isEmpty) {
        debugPrint('[KnowledgeBaseService] FTS 表不存在，创建: $tableName');
        await _createFtsTable(knowledgeBaseId);
      } else {
        debugPrint('[KnowledgeBaseService] FTS 表已存在: $tableName');
        _ftsTablesCreated.add(knowledgeBaseId);
      }
    } catch (e) {
      debugPrint('[KnowledgeBaseService] 检查 FTS 表失败: $e');
      // 尝试创建
      await _createFtsTable(knowledgeBaseId);
    }
  }

  /// 删除 FTS5 虚拟表
  Future<void> _dropFtsTable(String knowledgeBaseId) async {
    final tableName = 'knowledge_fts_$knowledgeBaseId';
    
    try {
      await _db.customStatement('DROP TABLE IF EXISTS "$tableName"');
      _ftsTablesCreated.remove(knowledgeBaseId);
    } catch (e) {
      debugPrint('[KnowledgeBaseService] 删除 FTS 表失败: $e');
    }
  }

  /// 添加到 FTS 索引
  Future<void> _addToFtsIndex(String knowledgeBaseId, String chunkId, String content) async {
    final tableName = 'knowledge_fts_$knowledgeBaseId';
    
    debugPrint('[KnowledgeBaseService] 添加 FTS 索引: chunk_id=$chunkId, 表=$tableName');
    
    try {
      await _db.customStatement(
        'INSERT INTO "$tableName" (chunk_id, content) VALUES (?, ?)',
        [chunkId, content],
      );
      debugPrint('[KnowledgeBaseService] FTS 索引添加成功: $chunkId');
    } catch (e) {
      debugPrint('[KnowledgeBaseService] FTS 索引添加失败: $e');
      // 不抛出异常，允许继续处理
    }
  }

  /// 从 FTS 索引移除
  Future<void> _removeFromFtsIndex(String knowledgeBaseId, String chunkId) async {
    final tableName = 'knowledge_fts_$knowledgeBaseId';
    
    try {
      await _db.customStatement(
        'DELETE FROM "$tableName" WHERE chunk_id = ?',
        [chunkId],
      );
    } catch (e) {
      debugPrint('[KnowledgeBaseService] 从 FTS 索引移除失败: $e');
    }
  }
  
  /// 健康检查 - 验证知识库数据完整性
  Future<KnowledgeBaseHealth> checkHealth(String knowledgeBaseId) async {
    final health = KnowledgeBaseHealth(knowledgeBaseId: knowledgeBaseId);
    
    try {
      // 检查知识库是否存在
      final kb = await getKnowledgeBase(knowledgeBaseId);
      if (kb == null) {
        health.issues.add('知识库不存在');
        return health;
      }
      health.knowledgeBaseName = kb.name;
      
      // 检查文档数量
      final docs = await getDocuments(knowledgeBaseId);
      health.documentCount = docs.length;
      
      // 检查分块数量
      final chunks = await (_db.select(_db.documentChunks)
        ..where((t) => t.knowledgeBaseId.equals(knowledgeBaseId))).get();
      health.chunkCount = chunks.length;
      
      // 检查 FTS 表是否存在
      final tableName = 'knowledge_fts_$knowledgeBaseId';
      final ftsExists = await _db.customSelect(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
        variables: [Variable.withString(tableName)],
      ).get();
      health.ftsTableExists = ftsExists.isNotEmpty;
      
      if (!health.ftsTableExists) {
        health.issues.add('FTS 表不存在，需要重建索引');
      } else {
        // 检查 FTS 索引中的记录数
        try {
          final ftsCount = await _db.customSelect(
            'SELECT COUNT(*) as count FROM "$tableName"',
          ).getSingle();
          health.ftsIndexCount = ftsCount.data['count'] as int;
          
          if (health.ftsIndexCount != health.chunkCount) {
            health.issues.add('FTS 索引数量(${health.ftsIndexCount})与分块数量(${health.chunkCount})不一致');
          }
        } catch (e) {
          health.issues.add('FTS 索引检查失败: $e');
        }
      }
      
      // 检查是否有空内容的分块
      final emptyChunks = chunks.where((c) => c.content.trim().isEmpty).toList();
      if (emptyChunks.isNotEmpty) {
        health.issues.add('存在 ${emptyChunks.length} 个空内容分块');
      }
      
      health.isHealthy = health.issues.isEmpty;
    } catch (e) {
      health.issues.add('健康检查失败: $e');
      health.isHealthy = false;
    }
    
    return health;
  }
  
  /// 重建 FTS 索引
  Future<void> rebuildFtsIndex(String knowledgeBaseId) async {
    debugPrint('[KnowledgeBaseService] 开始重建 FTS 索引: $knowledgeBaseId');
    
    // 删除旧的 FTS 表
    await _dropFtsTable(knowledgeBaseId);
    
    // 创建新的 FTS 表
    await _createFtsTable(knowledgeBaseId);
    
    // 获取所有分块
    final chunks = await (_db.select(_db.documentChunks)
      ..where((t) => t.knowledgeBaseId.equals(knowledgeBaseId))).get();
    
    debugPrint('[KnowledgeBaseService] 需要索引的分块数: ${chunks.length}');
    
    // 重新添加到 FTS 索引
    for (final chunk in chunks) {
      await _addToFtsIndex(knowledgeBaseId, chunk.id, chunk.content);
    }
    
    debugPrint('[KnowledgeBaseService] FTS 索引重建完成');
  }
}

/// 搜索结果
class SearchResult {
  final String chunkId;
  final String content;
  final double rank;
  final String? source; // 'fts', 'bm25', 'hybrid'

  SearchResult({
    required this.chunkId,
    required this.content,
    required this.rank,
    this.source,
  });
  
  @override
  String toString() => 'SearchResult(chunkId: $chunkId, rank: $rank, source: $source)';
}

/// 知识库健康状态
class KnowledgeBaseHealth {
  final String knowledgeBaseId;
  String? knowledgeBaseName;
  int documentCount = 0;
  int chunkCount = 0;
  bool ftsTableExists = false;
  int ftsIndexCount = 0;
  bool isHealthy = false;
  List<String> issues = [];
  
  KnowledgeBaseHealth({required this.knowledgeBaseId});
  
  @override
  String toString() {
    return 'KnowledgeBaseHealth(id: $knowledgeBaseId, name: $knowledgeBaseName, '
        'docs: $documentCount, chunks: $chunkCount, fts: $ftsTableExists, '
        'ftsIndex: $ftsIndexCount, healthy: $isHealthy, issues: $issues)';
  }
}
