// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_recorder/flutter_recorder.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/voice_clone_service.dart';
import '../../../../core/services/recorder_manager.dart';

enum _RecordingState { idle, recording, paused, stopped }

class VoiceClonePage extends ConsumerStatefulWidget {
  /// TTS 提供商: 'mimo' 或 'cosyvoice'，决定克隆提交行为
  final String provider;
  const VoiceClonePage({super.key, this.provider = 'mimo'});

  @override
  ConsumerState<VoiceClonePage> createState() => _VoiceClonePageState();
}

class _VoiceClonePageState extends ConsumerState<VoiceClonePage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final TextEditingController _nameController = TextEditingController();

  _RecordingState _recState = _RecordingState.idle;
  bool _isPlayingRecord = false;
  String? _recordedAudioPath;
  int _recordingDuration = 0;
  bool _isSubmitting = false;

  Timer? _durationTimer;
  late final VoiceCloneService _voiceService;

  List<ClonedVoice> _clonedVoices = [];
  final Map<String, CloneTaskProgress> _taskProgress = {};
  String? _testAudioPath;

  void _onCloneProgress(CloneTaskProgress progress) {
    if (!mounted) return;
    setState(() => _taskProgress[progress.taskId] = progress);
    if (progress.status == CloneVoiceStatus.completed ||
        progress.status == CloneVoiceStatus.failed) {
      _loadClonedVoices();
      if (progress.status == CloneVoiceStatus.completed) {
        _loadTestAudio(progress.taskId);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _voiceService = ref.read(voiceCloneServiceProvider);
    _loadClonedVoices();
    _voiceService.addProgressCallback(_onCloneProgress);
    _audioPlayer.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() => _isPlayingRecord = state.playing);
      if (state.processingState == ProcessingState.completed) {
        setState(() => _isPlayingRecord = false);
      }
    });
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _voiceService.removeProgressCallback(_onCloneProgress);
    _cleanupRecorder();
    _audioPlayer.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _cleanupRecorder() {
    try {
      // ★ 使用 RecorderManager 统一管理，避免多页面竞态
      RecorderManager.instance.deinit(holder: 'voice_clone');
    } catch (e) {
      debugPrint('[VoiceClone] cleanup error: $e');
    }
  }

  Future<void> _loadClonedVoices() async {
    final voices = await _voiceService.getClonedVoicesByProvider(widget.provider);
    if (mounted) setState(() => _clonedVoices = voices);
  }

  // ═══════════════ 录音控制 ═══════════════

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_recState == _RecordingState.recording) {
        setState(() => _recordingDuration++);
        // ★ CosyVoice 参考音频最长 30 秒，自动停止
        if (_recordingDuration >= 30) {
          debugPrint('[VoiceClone] 录音已达30秒上限，自动停止');
          _stopRecording();
        }
      }
    });
  }

  void _stopDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = null;
  }

  Future<void> _startRecording() async {
    try {
      if (!Platform.isMacOS) {
        final status = await Permission.microphone.request();
        if (!status.isGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('需要麦克风权限才能录制音频')),
            );
          }
          return;
        }
      }

      _cleanupRecorder();

      // ★ 使用 RecorderManager 统一管理初始化，避免多页面竞态
      final ok = await RecorderManager.instance.init(
        holder: 'voice_clone',
        sampleRate: 16000,
        channels: RecorderChannels.mono,
        format: PCMFormat.f32le,
      );
      if (!ok) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('录音初始化失败，请重试')),
          );
        }
        return;
      }

      final dir = await getApplicationSupportDirectory();
      final recordingsDir = Directory('${dir.path}/recordings');
      if (!await recordingsDir.exists()) {
        await recordingsDir.create(recursive: true);
      }
      final path =
          '${recordingsDir.path}/clone_${DateTime.now().millisecondsSinceEpoch}.wav';

      RecorderManager.instance.startRecording(path);

      if (!mounted) return;
      setState(() {
        _recState = _RecordingState.recording;
        _recordedAudioPath = path;
        _recordingDuration = 0;
        _testAudioPath = null;
      });
      _startDurationTimer();
      debugPrint('[VoiceClone] recording started: $path');
    } catch (e) {
      debugPrint('[VoiceClone] start error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('录音启动失败: $e')),
        );
      }
    }
  }

  void _pauseRecording() {
    try {
      RecorderManager.instance.pauseRecording();
      _stopDurationTimer();
      if (!mounted) return;
      setState(() => _recState = _RecordingState.paused);
      debugPrint('[VoiceClone] paused');
    } catch (e) {
      debugPrint('[VoiceClone] pause error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('暂停失败: $e')),
        );
      }
    }
  }

  void _resumeRecording() {
    try {
      RecorderManager.instance.resumeRecording();
      if (!mounted) return;
      setState(() => _recState = _RecordingState.recording);
      _startDurationTimer();
      debugPrint('[VoiceClone] resumed');
    } catch (e) {
      debugPrint('[VoiceClone] resume error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('恢复失败: $e')),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    _stopDurationTimer();
    debugPrint('[VoiceClone] _stopRecording called');

    try {
      // ★ 使用 RecorderManager 统一管理停止和释放
      RecorderManager.instance.stopRecording();
      await RecorderManager.instance.deinit(holder: 'voice_clone');

      final finalPath = _recordedAudioPath;
      debugPrint('[VoiceClone] stopped, path=$finalPath');

      if (!mounted) return;

      bool valid = false;
      if (finalPath != null) {
        final f = File(finalPath);
        if (await f.exists()) {
          final size = await f.length();
          valid = size > 1024;
          debugPrint('[VoiceClone] file size=$size, valid=$valid');
        }
      }

      if (valid) {
        setState(() {
          _recState = _RecordingState.stopped;
          _recordedAudioPath = finalPath;
        });
      } else {
        setState(() {
          _recState = _RecordingState.idle;
          _recordedAudioPath = null;
          _recordingDuration = 0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('录音保存失败，请重新录制')),
        );
      }
    } catch (e) {
      debugPrint('[VoiceClone] stop error: $e');
      _cleanupRecorder();
      if (!mounted) return;
      setState(() {
        _recState = _RecordingState.idle;
        _recordedAudioPath = null;
        _recordingDuration = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('停止录音失败: $e')),
      );
    }
  }

  Future<void> _playRecordedAudio() async {
    if (_recordedAudioPath == null) return;
    if (_isPlayingRecord) {
      await _audioPlayer.stop();
      return;
    }
    try {
      await _audioPlayer.setFilePath(_recordedAudioPath!);
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('[VoiceClone] play error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('播放失败: $e')),
        );
      }
    }
  }

  void _resetRecording() {
    _stopDurationTimer();
    _audioPlayer.stop();
    setState(() {
      _recState = _RecordingState.idle;
      _recordedAudioPath = null;
      _recordingDuration = 0;
      _isPlayingRecord = false;
      _testAudioPath = null;
    });
  }

  // ═══════════════ 克隆提交 ═══════════════

  Future<void> _submitCloneTask() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入音色名称')),
      );
      return;
    }
    if (_recordedAudioPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先录制音频')),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      if (widget.provider == 'cosyvoice') {
        // CosyVoice: 仅保存参考音频，无需远程验证
        await _voiceService.submitCosyVoiceCloneTask(
          audioPath: _recordedAudioPath!,
          voiceName: name,
        );
      } else {
        // MiMo: 提交到远程服务器验证
        await _voiceService.submitCloneTask(
          audioPath: _recordedAudioPath!,
          voiceName: name,
        );
      }
      await _loadClonedVoices();
      _nameController.clear();
      _resetRecording();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.provider == 'cosyvoice'
              ? 'CosyVoice 音色已创建'
              : '克隆任务已提交，正在后台处理...')),
        );
      }
    } catch (e) {
      debugPrint('[VoiceClone] submit error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('提交失败: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _loadTestAudio(String voiceId) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final p = '${dir.path}/voice_clones/test_$voiceId.wav';
      if (await File(p).exists() && mounted) {
        setState(() => _testAudioPath = p);
      }
    } catch (e) {
      debugPrint('[VoiceClone] load test audio error: $e');
    }
  }

  Future<void> _playTestAudio() async {
    if (_testAudioPath == null) return;
    try {
      await _audioPlayer.setFilePath(_testAudioPath!);
      await _audioPlayer.play();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('试听失败: $e')),
        );
      }
    }
  }

  Future<void> _deleteCloneVoice(ClonedVoice voice) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除克隆音色 "${voice.name}" 吗?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _voiceService.deleteClonedVoice(voice.id);
      await _loadClonedVoices();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已删除 "${voice.name}"')),
        );
      }
    }
  }

  Future<void> _retryClone(ClonedVoice voice) async {
    await _voiceService.retryClone(voice);
    await _loadClonedVoices();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('正在重试克隆...')),
      );
    }
  }

  String _fmt(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  // ═══════════════ UI ═══════════════

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/settings/voice'),
        ),
        title: Text(widget.provider == 'cosyvoice' ? 'CosyVoice 语音克隆' : '语音克隆'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        children: [
          _section('录制参考音频', [
            SizedBox(
              width: double.infinity,
              child: Container(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(children: [
                  Text(_fmt(_recordingDuration),
                      style: theme.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace')),
                  const SizedBox(height: 4),
                  Text('最长 30 秒',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: AppTheme.spacingM),
                  _buildStatusBadge(),
                  const SizedBox(height: AppTheme.spacingL),
                  _buildControls(),
                  if (_testAudioPath != null) ...[
                    const SizedBox(height: AppTheme.spacingL),
                    const Divider(),
                    const SizedBox(height: AppTheme.spacingM),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.headphones, color: Colors.purple),
                          const SizedBox(width: 8),
                          const Text('克隆试听',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.purple)),
                          const SizedBox(width: AppTheme.spacingM),
                          IconButton.filled(
                            onPressed: _playTestAudio,
                            icon: const Icon(Icons.play_arrow),
                            style: IconButton.styleFrom(
                                backgroundColor: Colors.purple),
                          ),
                        ]),
                    const SizedBox(height: 8),
                    const Text('试听满意后可在下方保存音色',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ]),
              ),
            ),
          ]),
          const SizedBox(height: AppTheme.spacingL),
          if (_recState == _RecordingState.stopped)
            _section('提交克隆任务', [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '音色名称',
                  hintText: '例如: 我的声音',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.record_voice_over),
                ),
              ),
              const SizedBox(height: AppTheme.spacingS),
              const Text('提交后系统将自动进行格式转换与克隆处理',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: AppTheme.spacingM),
              Row(children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isSubmitting ? null : _submitCloneTask,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.cloud_upload),
                    label: Text(_isSubmitting
                        ? '提交中...'
                        : (widget.provider == 'cosyvoice' ? '创建音色' : '提交克隆')),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                OutlinedButton.icon(
                  onPressed: _isSubmitting ? null : _resetRecording,
                  icon: const Icon(Icons.refresh),
                  label: const Text('重新录制'),
                ),
              ]),
            ]),
          const SizedBox(height: AppTheme.spacingL),
          _section('我的克隆音色', [
            if (_clonedVoices.isEmpty)
              const Padding(
                padding: EdgeInsets.all(AppTheme.spacingL),
                child: Column(children: [
                  Icon(Icons.mic_off, size: 48, color: Colors.grey),
                  SizedBox(height: AppTheme.spacingM),
                  Text('暂无克隆音色', style: TextStyle(color: Colors.grey)),
                  Text('录制参考音频后可以提交克隆任务',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ]),
              )
            else
              ..._clonedVoices.map(_buildVoiceItem),
          ]),
          const SizedBox(height: AppTheme.spacingXXL),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    switch (_recState) {
      case _RecordingState.idle:
        return const SizedBox.shrink();
      case _RecordingState.recording:
        return const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PulsingDot(),
              SizedBox(width: 8),
              Text('录音中...', style: TextStyle(color: Colors.red)),
            ]);
      case _RecordingState.paused:
        return const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pause_circle, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text('已暂停', style: TextStyle(color: Colors.blue)),
            ]);
      case _RecordingState.stopped:
        return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Text('录音完成 ${_fmt(_recordingDuration)}',
              style: const TextStyle(color: Colors.green)),
        ]);
    }
  }

  Widget _buildControls() {
    switch (_recState) {
      case _RecordingState.idle:
        return Center(
          child: ElevatedButton.icon(
            onPressed: _startRecording,
            icon: const Icon(Icons.mic),
            label: const Text('开始录音'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: const Size(160, 48),
            ),
          ),
        );
      case _RecordingState.recording:
        return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          ElevatedButton.icon(
            onPressed: _pauseRecording,
            icon: const Icon(Icons.pause),
            label: const Text('暂停'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              minimumSize: const Size(120, 48),
            ),
          ),
          const SizedBox(width: AppTheme.spacingL),
          ElevatedButton.icon(
            onPressed: _stopRecording,
            icon: const Icon(Icons.stop),
            label: const Text('停止'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: const Size(120, 48),
            ),
          ),
        ]);
      case _RecordingState.paused:
        return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          ElevatedButton.icon(
            onPressed: _resumeRecording,
            icon: const Icon(Icons.mic),
            label: const Text('继续'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              minimumSize: const Size(120, 48),
            ),
          ),
          const SizedBox(width: AppTheme.spacingL),
          ElevatedButton.icon(
            onPressed: _stopRecording,
            icon: const Icon(Icons.stop),
            label: const Text('停止'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: const Size(120, 48),
            ),
          ),
        ]);
      case _RecordingState.stopped:
        return Center(
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton.filled(
              onPressed: _playRecordedAudio,
              icon: Icon(_isPlayingRecord ? Icons.stop : Icons.play_arrow),
              style: IconButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(56, 56),
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Text(_isPlayingRecord ? '播放中...' : '播放录音',
                style: const TextStyle(color: Colors.green)),
          ]),
        );
    }
  }

  Widget _buildVoiceItem(ClonedVoice voice) {
    final progress = _taskProgress[voice.id];
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            if (voice.isProcessing)
              const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2))
            else if (voice.isReady)
              const Icon(Icons.check_circle, color: Colors.green, size: 24)
            else if (voice.isFailed)
              const Icon(Icons.error, color: Colors.red, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(voice.name,
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(_statusText(voice, progress),
                        style: TextStyle(
                          color: voice.isProcessing
                              ? Colors.blue
                              : voice.isFailed
                                  ? Colors.red
                                  : Colors.grey,
                          fontSize: 12,
                        )),
                  ]),
            ),
            if (voice.isFailed)
              IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.blue),
                  tooltip: '重试',
                  onPressed: () => _retryClone(voice)),
            if (!voice.isProcessing)
              IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _deleteCloneVoice(voice)),
          ]),
          if (voice.isProcessing && progress?.progress != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress!.progress!,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
          ],
        ]),
      ),
    );
  }

  String _statusText(ClonedVoice v, CloneTaskProgress? p) {
    if (v.isProcessing) return p?.message ?? '正在处理中...';
    if (v.isReady) return '克隆完成 - ${v.createdAt.toString().substring(0, 10)}';
    if (v.isFailed) return v.errorMessage ?? '克隆失败';
    return '';
  }

  Widget _section(String title, List<Widget> children) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
      ),
      ...children,
    ]);
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this)
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(_ctl);
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => Opacity(
        opacity: _anim.value,
        child: Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
              color: Colors.red, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
