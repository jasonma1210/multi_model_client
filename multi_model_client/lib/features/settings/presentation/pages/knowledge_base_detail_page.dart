import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_selector/file_selector.dart';

import '../../../../core/storage/database.dart';
import '../../../../core/services/knowledge_base_service.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../generated/app_localizations.dart';

/// 知识库详情页面 - 显示知识库内容并支持上传文件
class KnowledgeBaseDetailPage extends ConsumerStatefulWidget {
  final String knowledgeBaseId;

  const KnowledgeBaseDetailPage({super.key, required this.knowledgeBaseId});

  @override
  ConsumerState<KnowledgeBaseDetailPage> createState() =>
      _KnowledgeBaseDetailPageState();
}

class _KnowledgeBaseDetailPageState
    extends ConsumerState<KnowledgeBaseDetailPage> {
  KnowledgeBase? _knowledgeBase;
  List<Document> _documents = [];
  bool _isLoading = true;
  bool _isUploading = false;
  KnowledgeBaseHealth? _healthStatus;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final db = ref.read(databaseProvider);
      final service = KnowledgeBaseService(db);

      _knowledgeBase = await service.getKnowledgeBase(widget.knowledgeBaseId);
      _documents = await service.getDocuments(widget.knowledgeBaseId);

      // 执行健康检查
      _healthStatus = await service.checkHealth(widget.knowledgeBaseId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('加载失败: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 显示健康检查结果
  Future<void> _showHealthCheck() async {
    final db = ref.read(databaseProvider);
    final service = KnowledgeBaseService(db);

    final health = await service.checkHealth(widget.knowledgeBaseId);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(
              health.isHealthy ? Icons.check_circle : Icons.warning,
              color: health.isHealthy ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 8),
            const Text('知识库健康检查'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHealthItem('知识库名称', health.knowledgeBaseName ?? '-'),
              _buildHealthItem('文档数量', '${health.documentCount}'),
              _buildHealthItem('分块数量', '${health.chunkCount}'),
              _buildHealthItem('FTS 表', health.ftsTableExists ? '存在' : '不存在'),
              _buildHealthItem('FTS 索引数量', '${health.ftsIndexCount}'),
              const Divider(),
              if (health.issues.isNotEmpty) ...[
                const Text(
                  '问题列表:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...health.issues.map(
                  (issue) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '• ',
                          style: TextStyle(color: Colors.orange),
                        ),
                        Expanded(child: Text(issue)),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                const Row(
                  children: [
                    Icon(Icons.check, color: Colors.green, size: 16),
                    SizedBox(width: 4),
                    Text('知识库状态良好'),
                  ],
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (!health.isHealthy || health.ftsIndexCount != health.chunkCount)
            TextButton.icon(
              onPressed: () async {
                Navigator.pop(ctx);
                await _rebuildIndex();
              },
              icon: const Icon(Icons.build),
              label: const Text('重建索引'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  /// 重建 FTS 索引
  Future<void> _rebuildIndex() async {
    setState(() => _isUploading = true);

    try {
      final db = ref.read(databaseProvider);
      final service = KnowledgeBaseService(db);

      await service.rebuildFtsIndex(widget.knowledgeBaseId);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('索引重建完成')));
      }

      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('索引重建失败: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _pickAndUploadFiles() async {
    debugPrint('DEBUG: _pickAndUploadFiles called');
    try {
      // macOS 上使用更宽松的配置
      const typeGroup = XTypeGroup(label: '所有文件');

      // 使用 file_selector 选择文件
      final files = await openFiles(acceptedTypeGroups: [typeGroup]);

      debugPrint('DEBUG: Selected files count = ${files.length}');

      if (files.isEmpty) return;

      setState(() => _isUploading = true);

      final db = ref.read(databaseProvider);
      final service = KnowledgeBaseService(db);

      for (final file in files) {
        try {
          await service.addDocument(
            knowledgeBaseId: widget.knowledgeBaseId,
            filePath: file.path,
          );
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('文件 ${file.name} 处理失败: $e')));
          }
        }
      }

      // 重新加载数据
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('已上传 ${files.length} 个文件')));
      }
    } catch (e) {
      debugPrint('DEBUG: File selection error = $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('选择文件失败: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _deleteDocument(Document doc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除文档 "${doc.fileName}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final db = ref.read(databaseProvider);
      final service = KnowledgeBaseService(db);
      await service.deleteDocument(doc.id);
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('文档已删除')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('删除失败: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        // 右滑返回上一页，与返回按钮行为一致
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/settings/knowledge'),
          ),
          title: Text(_knowledgeBase?.name ?? l10n.knowledgeBase),
          actions: [
            // 健康检查按钮
            IconButton(
              icon: Icon(
                _healthStatus?.isHealthy ?? true
                    ? Icons.health_and_safety
                    : Icons.warning,
                color: _healthStatus?.isHealthy ?? true ? null : Colors.orange,
              ),
              onPressed: _showHealthCheck,
              tooltip: '健康检查',
            ),
            IconButton(
              icon: _isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add),
              onPressed: _isUploading ? null : _pickAndUploadFiles,
              tooltip: '上传文档',
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _documents.isEmpty
            ? _buildEmptyState(theme)
            : _buildDocumentList(theme),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _isUploading ? null : _pickAndUploadFiles,
          icon: _isUploading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.upload_file),
          label: Text(_isUploading ? '上传中...' : '上传文档'),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.6,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.description_outlined,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '还没有文档',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '上传 PDF、Markdown、TXT 等文档\n让 AI 能够基于这些资料进行问答',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _pickAndUploadFiles,
              icon: const Icon(Icons.upload_file),
              label: const Text('上传文档'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentList(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _documents.length,
      itemBuilder: (context, index) {
        final doc = _documents[index];
        return _DocumentCard(
          document: doc,
          onDelete: () => _deleteDocument(doc),
        );
      },
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final Document document;
  final VoidCallback onDelete;

  const _DocumentCard({required this.document, required this.onDelete});

  IconData _getFileIcon() {
    switch (document.fileType) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'md':
      case 'markdown':
        return Icons.description;
      case 'txt':
        return Icons.text_snippet;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'doc':
      case 'docx':
        return Icons.article;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getStatusColor(ThemeData theme) {
    switch (document.status) {
      case 'completed':
        return Colors.green;
      case 'processing':
        return Colors.orange;
      case 'failed':
        return theme.colorScheme.error;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_getFileIcon(), color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.fileName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${document.chunkCount} 个段落',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(theme).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          document.status == 'completed'
                              ? '已完成'
                              : document.status == 'failed'
                              ? '失败'
                              : '处理中',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: _getStatusColor(theme),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (document.errorMessage != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      document.errorMessage!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
              color: theme.colorScheme.error,
            ),
          ],
        ),
      ),
    );
  }
}
