// 灵感一瞬面板 —— 录音、段落管理、总结与思维导图
// 从 session_detail_page.dart 拆分

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'voice_widgets.dart' show AudioSegment;

/// 灵感一瞬面板
class InspirationPanel extends StatefulWidget {
  final ThemeData theme;

  const InspirationPanel({super.key, required this.theme});

  @override
  State<InspirationPanel> createState() => _InspirationPanelState();
}

class _InspirationPanelState extends State<InspirationPanel> {
  bool _isRecording = false;
  bool _isPaused = false;
  final List<AudioSegment> _segments = [];
  String? _summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: widget.theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 拖拽条
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: widget.theme.colorScheme.onSurfaceVariant
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 标题
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: widget.theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('灵感一瞬', style: widget.theme.textTheme.titleLarge),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // 录音波形区域
          Expanded(
            child: _buildWaveformArea(),
          ),

          // 段落列表
          if (_segments.isNotEmpty) _buildSegmentsList(),

          // 录音控制按钮
          _buildRecordingControls(),

          // 操作按钮
          _buildActionButtons(),

          // 底部安全区域
          SizedBox(height: MediaQuery.paddingOf(context).bottom + 16),
        ],
      ),
    );
  }

  Widget _buildWaveformArea() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 录音状态指示
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isRecording
                  ? widget.theme.colorScheme.primaryContainer
                  : widget.theme.colorScheme.surfaceContainerHighest,
            ),
            child: Icon(
              _isRecording ? Icons.mic : Icons.mic_none,
              size: 48,
              color: _isRecording
                  ? widget.theme.colorScheme.primary
                  : widget.theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _isRecording ? '录音中...' : '点击开始录音',
            style: widget.theme.textTheme.bodyLarge,
          ),
          if (_isRecording)
            Text(
              _isPaused ? '已暂停' : '正在录制',
              style: widget.theme.textTheme.bodySmall?.copyWith(
                color: widget.theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSegmentsList() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _segments.length,
        itemBuilder: (context, index) {
          final segment = _segments[index];
          return Container(
            width: 150,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '段落 ${index + 1}',
                  style: widget.theme.textTheme.labelMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  segment.transcription ?? '待转录',
                  style: widget.theme.textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecordingControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 暂停/继续
          IconButton(
            icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
            onPressed: _isRecording ? _togglePause : null,
            iconSize: 32,
          ),
          // 停止（触发转录）
          IconButton(
            icon: const Icon(Icons.stop),
            onPressed: _isRecording ? _stopAndTranscribe : null,
            iconSize: 32,
            color: widget.theme.colorScheme.error,
          ),
          // 播放
          IconButton(
            icon: const Icon(Icons.headphones),
            onPressed: _segments.isNotEmpty ? _playLastSegment : null,
            iconSize: 32,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // 一键总结
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.auto_awesome),
              label: const Text('一键总结'),
              onPressed: _segments.isNotEmpty ? _generateSummary : null,
            ),
          ),
          const SizedBox(width: 12),
          // 生成思维导图
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.account_tree),
              label: const Text('思维导图'),
              onPressed: _segments.isNotEmpty ? _generateMindMap : null,
            ),
          ),
        ],
      ),
    );
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _stopAndTranscribe() {
    setState(() {
      _isRecording = false;
      _isPaused = false;
      // 添加一个示例段落
      _segments.add(AudioSegment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        transcription:
            '这是一段示例转录文本，实际使用时会调用ASR服务进行语音识别。',
      ));
    });
  }

  void _playLastSegment() {
    // 播放最后一段录音
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('播放功能开发中...')),
    );
  }

  void _generateSummary() {
    setState(() {
      _summary = '## 灵感总结\n\n'
          '基于${_segments.length}段录音的总结：\n\n'
          '${_segments.map((s) => '- ${s.transcription}').join('\n')}';
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('灵感总结'),
        content: SingleChildScrollView(
          child: Text(_summary!),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
          TextButton(
            onPressed: () {
              // 复制到剪贴板
              Clipboard.setData(ClipboardData(text: _summary!));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已复制到剪贴板')),
              );
            },
            child: const Text('复制'),
          ),
        ],
      ),
    );
  }

  void _generateMindMap() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('思维导图'),
        content: const Text('思维导图生成功能开发中...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
