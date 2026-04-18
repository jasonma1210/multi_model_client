/// 分享服务 - LLM Studio 内容分享模块
/// 
/// 功能：
/// - 会话导出分享（Markdown/JSON）
/// - 消息分享
/// - 知识库分享
/// - 跨应用分享
/// 
/// @author JianMa
/// @version 1.0.0
library;

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../storage/database.dart';
import '../storage/database_connection.dart';

/// 分享服务
/// 支持分享会话、消息、对话记录等到其他应用
class ShareService {
  final AppDatabase _db = database;

  /// 分享会话为 Markdown
  Future<void> shareSessionAsMarkdown(String sessionId) async {
    final session = await _db.getSession(sessionId);
    if (session == null) {
      throw StateError('Session not found');
    }

    final messages = await _db.getSessionMessages(sessionId);
    final markdown = _generateSessionMarkdown(session, messages);

    // 保存为临时文件
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/${session.name.replaceAll(' ', '_')}.md';
    final file = File(filePath);
    await file.writeAsString(markdown);

    // 分享
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: session.name,
    );
  }

  /// 分享会话为纯文本
  Future<void> shareSessionAsText(String sessionId) async {
    final session = await _db.getSession(sessionId);
    if (session == null) {
      throw StateError('Session not found');
    }

    final messages = await _db.getSessionMessages(sessionId);
    final text = _generateSessionText(session, messages);

    await Share.share(text, subject: session.name);
  }

  /// 分享单条消息
  Future<void> shareMessage(String messageId) async {
    // 获取消息
    final message = await _db.getMessage(messageId);
    if (message == null) {
      throw StateError('Message not found');
    }

    await Share.share(message.content, subject: 'Message from LLM Studio');
  }

  /// 分享对话摘要
  Future<void> shareSessionSummary(String sessionId) async {
    final session = await _db.getSession(sessionId);
    if (session == null) {
      throw StateError('Session not found');
    }

    final messages = await _db.getSessionMessages(sessionId);
    final summary = _generateSessionSummary(session, messages);

    await Share.share(summary, subject: '${session.name} - Summary');
  }

  /// 分享为图片（带格式）
  Future<void> shareSessionAsImage(String sessionId) async {
    // 注意：Flutter 中生成图片需要使用截图库如 screenshot
    // 这里提供一个占位实现
    final session = await _db.getSession(sessionId);
    if (session == null) {
      throw StateError('Session not found');
    }

    final messages = await _db.getSessionMessages(sessionId);
    final text = _generateSessionText(session, messages);

    // 分享文本版本作为后备
    await Share.share(text, subject: session.name);
  }

  /// 导出为 PDF（需要 PDF 库支持）
  Future<void> shareSessionAsPdf(String sessionId) async {
    // 注意：生成 PDF 需要使用 pdf 或 flutter_pdfview 等库
    // 这里提供一个占位实现
    await shareSessionAsMarkdown(sessionId);
  }

  /// 生成会话 Markdown
  String _generateSessionMarkdown(Session session, List<Message> messages) {
    final buffer = StringBuffer();

    buffer.writeln('# ${session.name}');
    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln();

    for (final message in messages) {
      final role = message.role == 'user' ? '👤 User' : '🤖 Assistant';
      buffer.writeln('### $role');
      buffer.writeln();
      buffer.writeln(message.content);
      buffer.writeln();
      buffer.writeln('---');
      buffer.writeln();
    }

    buffer.writeln('*Exported from LLM Studio*');

    return buffer.toString();
  }

  /// 生成会话纯文本
  String _generateSessionText(Session session, List<Message> messages) {
    final buffer = StringBuffer();

    buffer.writeln(session.name);
    buffer.writeln('=' * session.name.length);
    buffer.writeln();

    for (final message in messages) {
      final role = message.role == 'user' ? 'User:' : 'Assistant:';
      buffer.writeln('$role ${message.content}');
      buffer.writeln();
    }

    return buffer.toString();
  }

  /// 生成会话摘要
  String _generateSessionSummary(Session session, List<Message> messages) {
    final userMessages = messages.where((m) => m.role == 'user').length;
    final assistantMessages = messages.where((m) => m.role == 'assistant').length;

    final buffer = StringBuffer();
    buffer.writeln('📊 Session Summary: ${session.name}');
    buffer.writeln();
    buffer.writeln('• Total messages: ${messages.length}');
    buffer.writeln('• User messages: $userMessages');
    buffer.writeln('• Assistant messages: $assistantMessages');
    buffer.writeln();

    // 添加最近几条消息的摘要
    if (messages.isNotEmpty) {
      buffer.writeln('📝 Recent messages:');
      final recentMessages = messages.take(3);
      for (final message in recentMessages) {
        final preview = message.content.length > 50
            ? '${message.content.substring(0, 50)}...'
            : message.content;
        buffer.writeln('• ${message.role}: $preview');
      }
    }

    return buffer.toString();
  }

  /// 分享知识库内容
  Future<void> shareKnowledgeBase(String kbId) async {
    final kb = await _db.getKnowledgeBase(kbId);
    if (kb == null) {
      throw StateError('Knowledge base not found');
    }

    final chunks = await _db.getKnowledgeBaseChunks(kbId);
    final content = chunks.map((c) => c.content).join('\n\n---\n\n');

    await Share.share(content, subject: kb.name);
  }

  /// 分享记忆内容
  Future<void> shareMemory(String memoryId) async {
    final memories = await _db.getAllMemories();
    final memory = memories.firstWhere(
      (m) => m.id == memoryId,
      orElse: () => throw StateError('Memory not found'),
    );

    await Share.share(memory.content, subject: 'Memory from LLM Studio');
  }
}

/// 分享选项
enum ShareFormat {
  markdown,
  text,
  pdf,
  image,
}

/// 分享服务配置
class ShareConfig {
  final bool includeTimestamps;
  final bool includeRoleLabels;
  final int maxMessages; // 0 表示不限制

  const ShareConfig({
    this.includeTimestamps = true,
    this.includeRoleLabels = true,
    this.maxMessages = 0,
  });
}

// Riverpod Providers

// 分享服务 Provider
final shareServiceProvider = Provider<ShareService>((ref) {
  return ShareService();
});

// 分享配置 Provider
final shareConfigProvider = StateProvider<ShareConfig>((ref) => const ShareConfig());