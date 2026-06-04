/// 数据备份恢复服务 - LLM Studio 数据管理模块
/// 
/// 功能：
/// - 全量数据导出（JSON 格式）
/// - 数据导入与恢复
/// - 合并/覆盖模式支持
/// - 跨设备数据迁移
/// 
/// @author JianMa
/// @version 1.0.0
library;

import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../storage/database.dart';
import '../storage/database_connection.dart';

/// 数据备份恢复服务
class BackupService {
  final AppDatabase _db = database;

  /// 导出所有数据到 JSON 文件
  Future<String> exportAllData({String? outputPath}) async {
    final appDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${appDir.path}/backups');
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }

    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final filePath = outputPath ?? '${backupDir.path}/llm_studio_backup_$timestamp.json';

    final backupData = await _collectAllData();

    final file = File(filePath);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(backupData),
    );

    return filePath;
  }

  /// 收集所有数据
  Future<Map<String, dynamic>> _collectAllData() async {
    final data = <String, dynamic>{};
    final version = 1;

    // 会话数据
    final sessions = await _db.getAllSessions();
    data['sessions'] = sessions.map((s) => {
      'id': s.id,
      'name': s.name,
      'folderId': s.folderId,
      'modelId': s.modelId,
      'systemPrompt': s.systemPrompt,
      'inferenceParams': s.inferenceParams,
      'isPinned': s.isPinned,
      'isArchived': s.isArchived,
      'enableGlobalMemory': s.enableGlobalMemory,
      'enableVideoUnderstanding': s.enableVideoUnderstanding,
      'enabledMcpServerIds': s.enabledMcpServerIds,
      'enableWebSearch': s.enableWebSearch,
      'createdAt': s.createdAt.toIso8601String(),
      'updatedAt': s.updatedAt.toIso8601String(),
    }).toList();

    // 消息数据
    final allMessages = <Map<String, dynamic>>[];
    for (final session in sessions) {
      final messages = await _db.getSessionMessages(session.id);
      allMessages.addAll(messages.map((m) => {
        'id': m.id,
        'sessionId': m.sessionId,
        'role': m.role,
        'content': m.content,
        'type': m.type,
        'tokenCount': m.tokenCount,
        'toolCallInfo': m.toolCallInfo,
        'createdAt': m.createdAt.toIso8601String(),
      }));
    }
    data['messages'] = allMessages;

    // 文件夹数据
    final folders = await _db.getAllFolders();
    data['folders'] = folders.map((f) => {
      'id': f.id,
      'name': f.name,
      'color': f.color,
      'icon': f.icon,
      'sortOrder': f.sortOrder,
      'createdAt': f.createdAt.toIso8601String(),
      'updatedAt': f.updatedAt.toIso8601String(),
    }).toList();

    // 记忆数据
    final memories = await _db.getAllMemories();
    data['memories'] = memories.map((m) => {
      'id': m.id,
      'sessionId': m.sessionId,
      'type': m.type,
      'content': m.content,
      'entityTags': m.entityTags,
      'weight': m.weight,
      'isGlobal': m.isGlobal,
      'isArchived': m.isArchived,
      'embedding': m.embedding,
      'createdAt': m.createdAt.toIso8601String(),
      'updatedAt': m.updatedAt.toIso8601String(),
      'lastAccessedAt': m.lastAccessedAt?.toIso8601String(),
    }).toList();

    // 知识库数据
    final knowledgeBases = await _db.getAllKnowledgeBases();
    data['knowledgeBases'] = knowledgeBases.map((kb) => {
      'id': kb.id,
      'name': kb.name,
      'sessionId': kb.sessionId,
      'isGlobal': kb.isGlobal,
      'createdAt': kb.createdAt.toIso8601String(),
      'updatedAt': kb.updatedAt.toIso8601String(),
    }).toList();

    // 文档块数据
    final allChunks = <Map<String, dynamic>>[];
    for (final kb in knowledgeBases) {
      final chunks = await _db.getKnowledgeBaseChunks(kb.id);
      allChunks.addAll(chunks.map((c) => {
        'id': c.id,
        'knowledgeBaseId': c.knowledgeBaseId,
        'content': c.content,
        'vector': c.vector,
        'metadata': c.metadata,
        'createdAt': c.createdAt.toIso8601String(),
      }));
    }
    data['documentChunks'] = allChunks;

    // 提示词模板
    final templates = await _db.getAllPromptTemplates();
    data['promptTemplates'] = templates.map((t) => {
      'id': t.id,
      'name': t.name,
      'content': t.content,
      'variables': t.variables,
      'category': t.category,
      'isGlobal': t.isGlobal,
      'isBuiltin': t.isBuiltin,
      'createdAt': t.createdAt.toIso8601String(),
      'updatedAt': t.updatedAt.toIso8601String(),
    }).toList();

    // MCP 服务器配置
    final mcpServers = await _db.getAllMcpServerConfigs();
    data['mcpServers'] = mcpServers.map((m) => {
      'id': m.id,
      'serverId': m.serverId,
      'name': m.name,
      'type': m.type,
      'command': m.command,
      'args': m.args,
      'env': m.env,
      'isEnabled': m.isEnabled,
      'isAutoStart': m.isAutoStart,
      'createdAt': m.createdAt.toIso8601String(),
    }).toList();

    // 元数据
    data['metadata'] = {
      'version': version,
      'exportedAt': DateTime.now().toIso8601String(),
      'appVersion': '1.0.0',
    };

    return data;
  }

  /// 从 JSON 文件导入数据
  Future<ImportResult> importData(String filePath, {bool merge = true}) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return ImportResult(success: false, message: 'File not found');
      }

      final jsonStr = await file.readAsString();
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;

      // 验证版本
      final metadata = data['metadata'] as Map<String, dynamic>?;
      final version = metadata?['version'] as int? ?? 1;
      if (version > 1) {
        return ImportResult(success: false, message: 'Unsupported backup version');
      }

      int importedCount = 0;
      int skippedCount = 0;

      if (merge) {
        // 合并模式：保留现有数据，只添加新的
        importedCount = await _importDataMerge(data);
      } else {
        // 覆盖模式：先清空现有数据
        await _clearAllData();
        importedCount = await _importDataReplace(data);
      }

      return ImportResult(
        success: true,
        message: 'Imported $importedCount items',
        importedCount: importedCount,
        skippedCount: skippedCount,
      );
    } catch (e) {
      return ImportResult(success: false, message: 'Import failed: $e');
    }
  }

  /// 合并导入
  Future<int> _importDataMerge(Map<String, dynamic> data) async {
    int count = 0;

    // 导入会话
    final sessions = data['sessions'] as List? ?? [];
    for (final session in sessions) {
      try {
        await _db.insertSession(SessionsCompanion(
          id: Value(session['id']),
          name: Value(session['name']),
          folderId: Value(session['folderId']),
          modelId: Value(session['modelId']),
          systemPrompt: Value(session['systemPrompt']),
          inferenceParams: Value(session['inferenceParams']),
          isPinned: Value(session['isPinned'] ?? false),
          isArchived: Value(session['isArchived'] ?? false),
          enableGlobalMemory: Value(session['enableGlobalMemory'] ?? true),
          enableVideoUnderstanding: Value(session['enableVideoUnderstanding'] ?? false),
          enabledMcpServerIds: Value(session['enabledMcpServerIds']),
          enableWebSearch: Value(session['enableWebSearch'] ?? false),
          createdAt: Value(DateTime.parse(session['createdAt'])),
          updatedAt: Value(DateTime.parse(session['updatedAt'])),
        ));
        count++;
      } catch (e) {
        debugPrint('[backup_service] Error: $e');
      }
    }

    // 导入消息
    final messages = data['messages'] as List? ?? [];
    for (final message in messages) {
      try {
        await _db.insertMessage(MessagesCompanion(
          id: Value(message['id']),
          sessionId: Value(message['sessionId']),
          role: Value(message['role']),
          content: Value(message['content']),
          type: Value(message['type'] ?? 'text'),
          tokenCount: Value(message['tokenCount']),
          toolCallInfo: Value(message['toolCallInfo']),
          createdAt: Value(DateTime.parse(message['createdAt'])),
        ));
        count++;
      } catch (e) {
        debugPrint('[backup_service] Error: $e');
      }
    }

    // 导入文件夹
    final folders = data['folders'] as List? ?? [];
    for (final folder in folders) {
      try {
        await _db.insertFolder(FoldersCompanion(
          id: Value(folder['id']),
          name: Value(folder['name']),
          color: Value(folder['color'] ?? '#007AFF'),
          icon: Value(folder['icon'] ?? 'folder'),
          sortOrder: Value(folder['sortOrder'] ?? 0),
          createdAt: Value(DateTime.parse(folder['createdAt'])),
          updatedAt: Value(DateTime.parse(folder['updatedAt'])),
        ));
        count++;
      } catch (e) {
        debugPrint('[backup_service] Error: $e');
      }
    }

    // 导入记忆
    final memories = data['memories'] as List? ?? [];
    for (final memory in memories) {
      try {
        await _db.insertMemory(MemoriesCompanion(
          id: Value(memory['id']),
          sessionId: Value(memory['sessionId']),
          type: Value(memory['type']),
          content: Value(memory['content']),
          entityTags: Value(memory['entityTags']),
          weight: Value(memory['weight'] ?? 1.0),
          isGlobal: Value(memory['isGlobal'] ?? false),
          isArchived: Value(memory['isArchived'] ?? false),
          embedding: Value(memory['embedding']),
          createdAt: Value(DateTime.parse(memory['createdAt'])),
          updatedAt: Value(DateTime.parse(memory['updatedAt'])),
          lastAccessedAt: Value(memory['lastAccessedAt'] != null
              ? DateTime.parse(memory['lastAccessedAt'])
              : null),
        ));
        count++;
      } catch (e) {
        debugPrint('[backup_service] Error: $e');
      }
    }

    // 导入知识库
    final knowledgeBases = data['knowledgeBases'] as List? ?? [];
    for (final kb in knowledgeBases) {
      try {
        await _db.insertKnowledgeBase(KnowledgeBasesCompanion(
          id: Value(kb['id']),
          name: Value(kb['name']),
          sessionId: Value(kb['sessionId']),
          isGlobal: Value(kb['isGlobal'] ?? false),
          createdAt: Value(DateTime.parse(kb['createdAt'])),
          updatedAt: Value(DateTime.parse(kb['updatedAt'])),
        ));
        count++;
      } catch (e) {
        debugPrint('[backup_service] Error: $e');
      }
    }

    // 导入文档块
    final chunks = data['documentChunks'] as List? ?? [];
    for (final chunk in chunks) {
      try {
        await _db.insertDocumentChunk(DocumentChunksCompanion(
          id: Value(chunk['id']),
          knowledgeBaseId: Value(chunk['knowledgeBaseId']),
          content: Value(chunk['content']),
          vector: Value(chunk['vector']),
          metadata: Value(chunk['metadata']),
          createdAt: Value(DateTime.parse(chunk['createdAt'])),
        ));
        count++;
      } catch (e) {
        debugPrint('[backup_service] Error: $e');
      }
    }

    // 导入提示词模板
    final templates = data['promptTemplates'] as List? ?? [];
    for (final template in templates) {
      try {
        await _db.insertPromptTemplate(PromptTemplatesCompanion(
          id: Value(template['id']),
          name: Value(template['name']),
          content: Value(template['content']),
          variables: Value(template['variables']),
          category: Value(template['category'] ?? 'general'),
          isGlobal: Value(template['isGlobal'] ?? false),
          isBuiltin: Value(template['isBuiltin'] ?? false),
          createdAt: Value(DateTime.parse(template['createdAt'])),
          updatedAt: Value(DateTime.parse(template['updatedAt'])),
        ));
        count++;
      } catch (e) {
        debugPrint('[backup_service] Error: $e');
      }
    }

    // 导入 MCP 服务器配置
    final mcpServers = data['mcpServers'] as List? ?? [];
    for (final server in mcpServers) {
      try {
        await _db.insertMcpServerConfig(McpServerConfigsCompanion(
          id: Value(server['id']),
          serverId: Value(server['serverId']),
          name: Value(server['name']),
          type: Value(server['type']),
          command: Value(server['command']),
          args: Value(server['args']),
          env: Value(server['env']),
          isEnabled: Value(server['isEnabled'] ?? false),
          isAutoStart: Value(server['isAutoStart'] ?? false),
          createdAt: Value(DateTime.parse(server['createdAt'])),
        ));
        count++;
      } catch (e) {
        debugPrint('[backup_service] Error: $e');
      }
    }

    return count;
  }

  /// 替换导入
  Future<int> _importDataReplace(Map<String, dynamic> data) async {
    return await _importDataMerge(data);
  }

  /// 清空所有数据
  Future<void> _clearAllData() async {
    // 注意：这会删除所有用户数据，请谨慎使用
    // 使用 Drift 的 delete 语句清空各表
    await _db.delete(_db.messages).go();
    await _db.delete(_db.sessions).go();
    await _db.delete(_db.folders).go();
    await _db.delete(_db.memories).go();
    await _db.delete(_db.knowledgeBases).go();
    await _db.delete(_db.documentChunks).go();
    await _db.delete(_db.promptTemplates).go();
    await _db.delete(_db.mcpServerConfigs).go();
  }

  /// 分享备份文件
  Future<void> shareBackup(String filePath) async {
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: 'LLM Studio Backup',
    );
  }

  /// 获取备份列表
  Future<List<BackupInfo>> listBackups() async {
    final appDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${appDir.path}/backups');

    if (!await backupDir.exists()) {
      return [];
    }

    final files = await backupDir.list().toList();
    final backups = <BackupInfo>[];

    for (final entity in files) {
      if (entity is File && entity.path.endsWith('.json')) {
        final stat = await entity.stat();
        backups.add(BackupInfo(
          path: entity.path,
          fileName: entity.path.split('/').last,
          size: stat.size,
          createdAt: stat.modified,
        ));
      }
    }

    // 按时间排序，最新的在前
    backups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return backups;
  }

  /// 删除备份
  Future<void> deleteBackup(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}

/// 导入结果
class ImportResult {
  final bool success;
  final String message;
  final int importedCount;
  final int skippedCount;

  ImportResult({
    required this.success,
    required this.message,
    this.importedCount = 0,
    this.skippedCount = 0,
  });
}

/// 备份信息
class BackupInfo {
  final String path;
  final String fileName;
  final int size;
  final DateTime createdAt;

  BackupInfo({
    required this.path,
    required this.fileName,
    required this.size,
    required this.createdAt,
  });

  String get formattedSize {
    if (size < 1024) {
      return '$size B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}

// Riverpod Providers

// 备份服务 Provider
final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService();
});

// 备份列表 Provider
final backupListProvider = FutureProvider<List<BackupInfo>>((ref) async {
  final service = ref.watch(backupServiceProvider);
  return await service.listBackups();
});