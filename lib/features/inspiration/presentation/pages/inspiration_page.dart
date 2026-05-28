// ignore_for_file: use_build_context_synchronously
library;

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_recorder/flutter_recorder.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/asr_service.dart';
import '../../../../core/services/voice_model_service.dart';

class AudioSegment {
  final String id;
  final String? filePath;
  final Duration duration;
  String? transcription;
  final DateTime createdAt;
  bool isArchived;
  bool isTranscribing;

  AudioSegment({
    required this.id,
    this.filePath,
    this.duration = Duration.zero,
    this.transcription,
    required this.createdAt,
    this.isArchived = false,
    this.isTranscribing = false,
  });
}

class ArchiveGroup {
  final String id;
  String name;
  final List<AudioSegment> segments;
  final DateTime createdAt;

  ArchiveGroup({
    required this.id,
    required this.name,
    required this.segments,
    required this.createdAt,
  });
}

class InspirationPage extends StatefulWidget {
  const InspirationPage({super.key});

  @override
  State<InspirationPage> createState() => _InspirationPageState();
}

class _InspirationPageState extends State<InspirationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isRecording = false;
  bool _isPaused = false;
  int _recordingSeconds = 0;
  Timer? _durationTimer;
  String? _currentRecordingPath;

  final List<AudioSegment> _segments = [];
  final List<ArchiveGroup> _archives = [];
  final Set<String> _selectedSegmentIds = {};

  String? _selectedAsrModelId;
  String? _playingSegmentId;

  static const _asrModelPrefKey = 'inspiration_asr_model_id';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _audioPlayer.playerStateStream.listen((state) {
      if (!mounted) return;
      if (state.processingState == ProcessingState.completed) {
        setState(() => _playingSegmentId = null);
      }
    });
    _loadAsrModel();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _durationTimer?.cancel();
    _cleanupRecorder();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _cleanupRecorder() {
    try {
      if (Recorder.instance.isDeviceStarted()) {
        Recorder.instance.stop();
      }
      if (Recorder.instance.isDeviceInitialized()) {
        Recorder.instance.deinit();
      }
    } catch (e) {
      debugPrint('[Inspiration] cleanup error: $e');
    }
  }

  Future<void> _loadAsrModel() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_asrModelPrefKey);
    if (saved != null && saved.isNotEmpty) {
      setState(() => _selectedAsrModelId = saved);
    }
  }

  Future<void> _saveAsrModel(String modelId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_asrModelPrefKey, modelId);
    setState(() => _selectedAsrModelId = modelId);
  }

  Future<void> _ensureAsrModel() async {
    if (_selectedAsrModelId != null) return;

    final modelService = voiceModelService;
    final downloaded = await modelService.getDownloadedModelIds(VoiceModelType.asr);
    if (downloaded.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请先在语音设置中下载 ASR 模型')),
        );
      }
      return;
    }

    if (mounted) {
      final chosen = await _showModelPicker(downloaded, modelService);
      if (chosen != null) {
        await _saveAsrModel(chosen);
      }
    }
  }

  Future<String?> _showModelPicker(
      List<String> modelIds, VoiceModelService modelService) async {
    return showDialog<String>(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          title: const Text('选择语音识别模型'),
          children: modelIds.map((id) {
            final info = VoiceModelService.asrModels
                .where((m) => m.id == id)
                .toList();
            final name = info.isNotEmpty ? info.first.name : id;
            return SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, id),
              child: ListTile(
                leading: const Icon(Icons.graphic_eq),
                title: Text(name),
                subtitle: Text(id),
                dense: true,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ═══════════════ 录音 ═══════════════

  Future<void> _startRecording() async {
    await _ensureAsrModel();
    if (_selectedAsrModelId == null) return;

    try {
      if (!Platform.isMacOS) {
        final status = await Permission.microphone.request();
        if (!status.isGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('需要麦克风权限')),
            );
          }
          return;
        }
      }

      _cleanupRecorder();

      await Recorder.instance.init(
        sampleRate: 16000,
        channels: RecorderChannels.mono,
        format: PCMFormat.f32le,
      );
      Recorder.instance.start();

      final dir = await getApplicationSupportDirectory();
      final recDir = Directory('${dir.path}/inspiration');
      if (!await recDir.exists()) {
        await recDir.create(recursive: true);
      }
      final path =
          '${recDir.path}/insp_${DateTime.now().millisecondsSinceEpoch}.wav';

      Recorder.instance.startRecording(completeFilePath: path);

      if (!mounted) return;
      setState(() {
        _isRecording = true;
        _isPaused = false;
        _currentRecordingPath = path;
        _recordingSeconds = 0;
      });
      _startDurationTimer();
    } catch (e) {
      debugPrint('[Inspiration] start error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('录音启动失败: $e')),
        );
      }
    }
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_isRecording && !_isPaused) {
        setState(() => _recordingSeconds++);
      }
    });
  }

  void _togglePause() {
    try {
      if (_isPaused) {
        Recorder.instance.setPauseRecording(pause: false);
        setState(() => _isPaused = false);
      } else {
        Recorder.instance.setPauseRecording(pause: true);
        setState(() => _isPaused = true);
      }
    } catch (e) {
      debugPrint('[Inspiration] pause error: $e');
    }
  }

  Future<void> _stopRecording() async {
    _durationTimer?.cancel();
    try {
      Recorder.instance.stopRecording();
      Recorder.instance.stop();
      Recorder.instance.deinit();

      final path = _currentRecordingPath;
      if (path == null) return;

      final file = File(path);
      if (!await file.exists() || await file.length() < 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('录音保存失败')),
          );
        }
        setState(() {
          _isRecording = false;
          _isPaused = false;
          _currentRecordingPath = null;
        });
        return;
      }

      final segment = AudioSegment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        filePath: path,
        duration: Duration(seconds: _recordingSeconds),
        createdAt: DateTime.now(),
        isTranscribing: true,
      );

      if (!mounted) return;
      setState(() {
        _isRecording = false;
        _isPaused = false;
        _currentRecordingPath = null;
        _segments.insert(0, segment);
      });

      _transcribeSegment(segment);
    } catch (e) {
      debugPrint('[Inspiration] stop error: $e');
      _cleanupRecorder();
      if (mounted) {
        setState(() {
          _isRecording = false;
          _isPaused = false;
          _currentRecordingPath = null;
        });
      }
    }
  }

  Future<void> _transcribeSegment(AudioSegment segment) async {
    if (segment.filePath == null || _selectedAsrModelId == null) return;
    try {
      final asr = ASRService(
        provider: ASRProvider.sherpa,
        sherpaModelId: _selectedAsrModelId,
      );
      final text = await asr.recognizeFile(segment.filePath!);
      if (!mounted) return;
      setState(() {
        segment.transcription = text.isNotEmpty ? text : '（未识别到内容）';
        segment.isTranscribing = false;
      });
    } catch (e) {
      debugPrint('[Inspiration] transcribe error: $e');
      if (!mounted) return;
      setState(() {
        segment.transcription = '转录失败: $e';
        segment.isTranscribing = false;
      });
    }
  }

  Future<void> _playSegment(AudioSegment segment) async {
    if (segment.filePath == null) return;
    if (_playingSegmentId == segment.id) {
      await _audioPlayer.stop();
      setState(() => _playingSegmentId = null);
      return;
    }
    try {
      await _audioPlayer.setFilePath(segment.filePath!);
      await _audioPlayer.play();
      setState(() => _playingSegmentId = segment.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('播放失败: $e')),
        );
      }
    }
  }

  // ═══════════════ 归档 ═══════════════

  void _showArchiveDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('创建归档'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: '归档名称',
            hintText: '例如：项目灵感',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                _createArchive(nameController.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  void _createArchive(String name) {
    final selected =
        _segments.where((s) => _selectedSegmentIds.contains(s.id)).toList();
    setState(() {
      _archives.add(ArchiveGroup(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        segments: selected,
        createdAt: DateTime.now(),
      ));
      _segments.removeWhere((s) => _selectedSegmentIds.contains(s.id));
      _selectedSegmentIds.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已归档 ${selected.length} 条录音')),
    );
  }

  void _showArchiveDetail(ArchiveGroup archive) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _ArchiveDetailPage(
          archive: archive,
          onRemoveSegment: (segment) {
            setState(() {
              archive.segments.removeWhere((s) => s.id == segment.id);
              if (archive.segments.isEmpty) {
                _archives.removeWhere((a) => a.id == archive.id);
              }
            });
          },
        ),
      ),
    );
  }

  Future<void> _switchModel() async {
    final modelService = voiceModelService;
    final downloaded =
        await modelService.getDownloadedModelIds(VoiceModelType.asr);
    if (downloaded.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请先在语音设置中下载 ASR 模型')),
        );
      }
      return;
    }
    if (!mounted) return;
    final chosen = await _showModelPicker(downloaded, modelService);
    if (chosen != null) {
      await _saveAsrModel(chosen);
    }
  }

  String _fmt(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  String _fmtDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  // ═══════════════ UI ═══════════════

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('灵感一瞬'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: '切换识别模型',
            onPressed: _switchModel,
          ),
          if (_tabController.index == 0 && _selectedSegmentIds.isNotEmpty)
            TextButton.icon(
              icon: const Icon(Icons.archive_outlined),
              label: Text('归档 (${_selectedSegmentIds.length})'),
              onPressed: _showArchiveDialog,
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '录音列表'),
            Tab(text: '归档'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRecordingTab(theme),
          _buildArchiveTab(theme),
        ],
      ),
      floatingActionButton: _buildRecordingFab(theme),
    );
  }

  Widget _buildRecordingFab(ThemeData theme) {
    if (_isRecording) {
      return FloatingActionButton.large(
        onPressed: _stopRecording,
        backgroundColor: theme.colorScheme.error,
        child: const Icon(Icons.stop, size: 36),
      );
    }
    return FloatingActionButton.large(
      onPressed: _startRecording,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: const Icon(Icons.mic, size: 36),
    );
  }

  Widget _buildRecordingTab(ThemeData theme) {
    return Column(
      children: [
        if (_isRecording) _buildRecordingBar(theme),
        if (_selectedAsrModelId != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.graphic_eq, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '识别模型: $_selectedAsrModelId',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: _switchModel,
                  child: Text('切换',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.primary)),
                ),
              ],
            ),
          ),
        Expanded(
          child: _segments.isEmpty
              ? _buildEmptyState(theme)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _segments.length,
                  itemBuilder: (ctx, i) =>
                      _buildSegmentItem(theme, _segments[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildRecordingBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          Icon(Icons.fiber_manual_record,
              color: _isPaused ? Colors.orange : Colors.red, size: 16),
          const SizedBox(width: 8),
          Text(_isPaused ? '已暂停' : '录音中...',
              style: TextStyle(
                  color: _isPaused ? Colors.orange : Colors.red,
                  fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(_fmt(_recordingSeconds),
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontFamily: 'monospace', fontWeight: FontWeight.bold)),
          const Spacer(),
          IconButton(
            icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
            onPressed: _togglePause,
          ),
          IconButton(
            icon: const Icon(Icons.stop, color: Colors.red),
            onPressed: _stopRecording,
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentItem(ThemeData theme, AudioSegment segment) {
    final isSelected = _selectedSegmentIds.contains(segment.id);
    final isPlaying = _playingSegmentId == segment.id;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Checkbox(
                value: isSelected,
                onChanged: (v) {
                  setState(() {
                    if (v == true) {
                      _selectedSegmentIds.add(segment.id);
                    } else {
                      _selectedSegmentIds.remove(segment.id);
                    }
                  });
                },
              ),
              IconButton(
                icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
                onPressed: () => _playSegment(segment),
              ),
              Expanded(
                child: Text(
                  _fmt(segment.duration.inSeconds),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(fontFamily: 'monospace'),
                ),
              ),
              Text(_fmtDate(segment.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: () {
                  setState(() {
                    _segments.removeWhere((s) => s.id == segment.id);
                    _selectedSegmentIds.remove(segment.id);
                  });
                },
              ),
            ]),
            if (segment.isTranscribing)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Row(children: [
                  SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 8),
                  Text('正在转录...', style: TextStyle(color: Colors.blue)),
                ]),
              )
            else if (segment.transcription != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(segment.transcription!,
                    style: theme.textTheme.bodyMedium),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildArchiveTab(ThemeData theme) {
    if (_archives.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.archive_outlined,
                size: 64,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text('暂无归档',
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text('在录音列表中选择录音后点击归档',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _archives.length,
      itemBuilder: (ctx, i) {
        final archive = _archives[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.archive),
            title: Text(archive.name),
            subtitle: Text('${archive.segments.length} 条录音'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showArchiveDetail(archive),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lightbulb_outline,
              size: 80,
              color: theme.colorScheme.primary.withValues(alpha: 0.5)),
          const SizedBox(height: 24),
          Text('点击下方按钮开始录音', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('记录你的灵感瞬间',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          if (_selectedAsrModelId == null) ...[
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: _ensureAsrModel,
              icon: const Icon(Icons.settings),
              label: const Text('选择识别模型'),
            ),
          ],
        ],
      ),
    );
  }
}

class _ArchiveDetailPage extends StatelessWidget {
  final ArchiveGroup archive;
  final Function(AudioSegment) onRemoveSegment;

  const _ArchiveDetailPage({
    required this.archive,
    required this.onRemoveSegment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(archive.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.summarize_outlined),
            onPressed: () => _summarizeAll(context),
            tooltip: '一键总结',
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: archive.segments.length,
        itemBuilder: (ctx, i) {
          final segment = archive.segments[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.mic),
              title: Text(
                segment.transcription ?? '无转录内容',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '${segment.createdAt.year}-${segment.createdAt.month.toString().padLeft(2, '0')}-${segment.createdAt.day.toString().padLeft(2, '0')}',
                style: theme.textTheme.bodySmall,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () {
                  onRemoveSegment(segment);
                  Navigator.pop(context);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _summarizeAll(BuildContext context) {
    final all = archive.segments
        .where((s) => s.transcription != null)
        .map((s) => s.transcription!)
        .join('\n\n');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('归档总结'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('共 ${archive.segments.length} 条录音'),
              const SizedBox(height: 16),
              Text(all.isEmpty ? '暂无转录内容' : all),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
