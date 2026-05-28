import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/storage/database.dart';
import '../data/repositories/message_repository.dart';

/// 会话导出服务
class SessionExportService {
  final MessageRepository _messageRepository;

  SessionExportService({MessageRepository? messageRepository})
      : _messageRepository = messageRepository ?? MessageRepository();

  /// 导出为 Markdown
  Future<String> exportToMarkdown(Session session) async {
    final messages = await _messageRepository.getSessionMessages(session.id);
    final buffer = StringBuffer();

    // 标题
    buffer.writeln('# ${session.name}');
    buffer.writeln();

    // 元信息
    buffer.writeln('> **创建时间**: ${_formatDateTime(session.createdAt)}');
    buffer.writeln('> **更新时间**: ${_formatDateTime(session.updatedAt)}');
    buffer.writeln('> **模型ID**: ${session.modelId}');
    if (session.systemPrompt != null && session.systemPrompt!.isNotEmpty) {
      buffer.writeln('> **系统提示词**: ${session.systemPrompt}');
    }
    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln();

    // 消息内容
    for (final message in messages) {
      final role = _getRoleDisplayName(message.role);
      final time = _formatDateTime(message.createdAt);

      buffer.writeln('## $role ($time)');
      buffer.writeln();

      if (message.type == 'text') {
        // 处理代码块，确保正确转义
        final content = _escapeMarkdownCodeBlocks(message.content);
        buffer.writeln(content);
      } else if (message.type == 'image') {
        buffer.writeln('*[图片消息]*');
      } else if (message.type == 'audio') {
        buffer.writeln('*[语音消息]*');
      } else if (message.type == 'video') {
        buffer.writeln('*[视频消息]*');
      } else {
        buffer.writeln(message.content);
      }

      buffer.writeln();
      buffer.writeln('---');
      buffer.writeln();
    }

    return buffer.toString();
  }

  /// 导出为纯文本
  Future<String> exportToText(Session session) async {
    final messages = await _messageRepository.getSessionMessages(session.id);
    final buffer = StringBuffer();

    // 标题
    buffer.writeln('会话: ${session.name}');
    buffer.writeln('创建时间: ${_formatDateTime(session.createdAt)}');
    buffer.writeln('=' * 50);
    buffer.writeln();

    // 消息内容
    for (final message in messages) {
      final role = _getRoleDisplayName(message.role);
      final time = _formatDateTime(message.createdAt);

      buffer.writeln('[$time] $role:');
      buffer.writeln(message.content);
      buffer.writeln();
      buffer.writeln('-' * 30);
      buffer.writeln();
    }

    return buffer.toString();
  }

  /// 导出为 JSON
  Future<String> exportToJson(Session session) async {
    final messages = await _messageRepository.getSessionMessages(session.id);

    final data = {
      'session': {
        'id': session.id,
        'name': session.name,
        'modelId': session.modelId,
        'systemPrompt': session.systemPrompt,
        'createdAt': session.createdAt.toIso8601String(),
        'updatedAt': session.updatedAt.toIso8601String(),
      },
      'messages': messages.map((m) => {
        'id': m.id,
        'role': m.role,
        'content': m.content,
        'type': m.type,
        'createdAt': m.createdAt.toIso8601String(),
        'tokenCount': m.tokenCount,
      }).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// 导出并保存到文件
  Future<File> exportToFile(
    Session session, {
    ExportFormat format = ExportFormat.markdown,
  }) async {
    final content = await _getExportContent(session, format);
    final extension = _getFileExtension(format);
    final fileName = _sanitizeFileName('${session.name}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.$extension');

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/exports/$fileName');

    // 确保目录存在
    await file.parent.create(recursive: true);

    await file.writeAsString(content);
    return file;
  }

  /// 分享会话
  Future<void> shareSession(
    Session session, {
    ExportFormat format = ExportFormat.markdown,
  }) async {
    final content = await _getExportContent(session, format);

    await Share.share(
      content,
      subject: '会话: ${session.name}',
    );
  }

  /// 分享会话文件
  Future<void> shareSessionFile(
    Session session, {
    ExportFormat format = ExportFormat.markdown,
  }) async {
    final file = await exportToFile(session, format: format);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: '会话: ${session.name}',
      text: '分享会话 "${session.name}"',
    );
  }

  /// 复制到剪贴板（返回字符串供调用方复制）
  Future<String> copyToClipboard(Session session) async {
    return await exportToMarkdown(session);
  }

  /// 获取导出内容
  Future<String> _getExportContent(Session session, ExportFormat format) async {
    switch (format) {
      case ExportFormat.markdown:
        return await exportToMarkdown(session);
      case ExportFormat.text:
        return await exportToText(session);
      case ExportFormat.json:
        return await exportToJson(session);
    }
  }

  /// 获取文件扩展名
  String _getFileExtension(ExportFormat format) {
    switch (format) {
      case ExportFormat.markdown:
        return 'md';
      case ExportFormat.text:
        return 'txt';
      case ExportFormat.json:
        return 'json';
    }
  }

  /// 格式化日期时间
  String _formatDateTime(DateTime dt) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dt);
  }

  /// 获取角色显示名称
  String _getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
      case 'user':
        return '用户';
      case 'assistant':
        return '助手';
      case 'system':
        return '系统';
      case 'tool':
        return '工具';
      default:
        return role;
    }
  }

  /// 转义 Markdown 代码块
  String _escapeMarkdownCodeBlocks(String content) {
    // 确保代码块正确闭合
    final codeBlockPattern = RegExp(r'```[\s\S]*?```');
    final matches = codeBlockPattern.allMatches(content);

    // 如果没有代码块，直接返回
    if (matches.isEmpty) return content;

    // 检查代码块是否正确闭合
    final openCount = '```'.allMatches(content).length;
    if (openCount % 2 != 0) {
      // 代码块未闭合，添加闭合标记
      return '$content\n\n```';
    }

    return content;
  }

  /// 清理文件名（移除非法字符）
  String _sanitizeFileName(String fileName) {
    // 移除或替换 Windows/macOS/Linux 的非法字符
    final illegalChars = RegExp(r'[<>:"/\\|?*]');
    return fileName.replaceAll(illegalChars, '_');
  }
}

/// 导出格式枚举
enum ExportFormat {
  markdown,
  text,
  json,
}

/// 导出格式扩展
extension ExportFormatExtension on ExportFormat {
  String get displayName {
    switch (this) {
      case ExportFormat.markdown:
        return 'Markdown';
      case ExportFormat.text:
        return '纯文本';
      case ExportFormat.json:
        return 'JSON';
    }
  }

  String get fileExtension {
    switch (this) {
      case ExportFormat.markdown:
        return '.md';
      case ExportFormat.text:
        return '.txt';
      case ExportFormat.json:
        return '.json';
    }
  }

  String get mimeType {
    switch (this) {
      case ExportFormat.markdown:
        return 'text/markdown';
      case ExportFormat.text:
        return 'text/plain';
      case ExportFormat.json:
        return 'application/json';
    }
  }
}
