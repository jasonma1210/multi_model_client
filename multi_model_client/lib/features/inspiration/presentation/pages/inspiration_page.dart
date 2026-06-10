library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_mind_map/mind_map.dart';
import 'package:flutter_mind_map/mind_map_node.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_recorder/flutter_recorder.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/services/asr_service.dart';
import '../../../../core/services/document_generation_service.dart';
import '../../../../core/services/voice_model_service.dart';
import '../../../../core/services/recorder_manager.dart';
import '../../../../core/engines/local_ffi_engine.dart';
import '../../../../core/engines/model_inference_engine.dart' show ChatMessage, globalModelEngine;
import '../../../../core/models/model_entry.dart';

/// 全局 ASRService 实例（顶层 final，与原实现保持一致，避免影响其他 import 链）
final asrService = ASRService();

/// 全局 VoiceModelService 实例（顶层 final，与原实现保持一致）
final voiceModelService = VoiceModelService();

class InspirationRecording {
  final String id;
  final String filePath;
  final DateTime createdAt;
  int durationMs;
  String? transcription;
  bool isTranscribing;

  InspirationRecording({
    required this.id,
    required this.filePath,
    required this.createdAt,
    this.durationMs = 0,
    this.transcription,
    this.isTranscribing = false,
  });

  String get dateLabel =>
      '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')} '
      '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';

  String get durationLabel {
    final s = durationMs ~/ 1000;
    return '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'filePath': filePath,
        'createdAt': createdAt.toIso8601String(),
        'durationMs': durationMs,
        'transcription': transcription,
      };

  factory InspirationRecording.fromJson(Map<String, dynamic> json) =>
      InspirationRecording(
        id: json['id'] as String,
        filePath: json['filePath'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        durationMs: json['durationMs'] as int? ?? 0,
        transcription: json['transcription'] as String?,
      );
}

class SummaryRecord {
  final String id;
  final String folderId;
  final List<String> recordingIds;
  final String level;
  final String summaryText;
  final String? mindMapData;
  final DateTime createdAt;

  SummaryRecord({
    required this.id,
    required this.folderId,
    required this.recordingIds,
    required this.level,
    required this.summaryText,
    this.mindMapData,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'folderId': folderId,
        'recordingIds': recordingIds,
        'level': level,
        'summaryText': summaryText,
        'mindMapData': mindMapData,
        'createdAt': createdAt.toIso8601String(),
      };

  factory SummaryRecord.fromJson(Map<String, dynamic> json) => SummaryRecord(
        id: json['id'] as String,
        folderId: json['folderId'] as String,
        recordingIds: List<String>.from(json['recordingIds'] ?? []),
        level: json['level'] as String? ?? 'medium',
        summaryText: json['summaryText'] as String? ?? '',
        mindMapData: json['mindMapData'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class InspirationFolder {
  final String id;
  String name;
  final bool isDefault;
  final List<InspirationRecording> recordings;
  final List<SummaryRecord> summaries;

  InspirationFolder({
    required this.id,
    required this.name,
    this.isDefault = false,
    List<InspirationRecording>? recordings,
    List<SummaryRecord>? summaries,
  })  : recordings = recordings ?? [],
        summaries = summaries ?? [];

  int get recordingCount => recordings.length;
  int get transcribedCount =>
      recordings.where((r) => r.transcription != null).length;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isDefault': isDefault,
        'recordings': recordings.map((r) => r.toJson()).toList(),
        'summaries': summaries.map((s) => s.toJson()).toList(),
      };

  factory InspirationFolder.fromJson(Map<String, dynamic> json) =>
      InspirationFolder(
        id: json['id'] as String,
        name: json['name'] as String,
        isDefault: json['isDefault'] as bool? ?? false,
        recordings: (json['recordings'] as List<dynamic>?)
            ?.map((e) => InspirationRecording.fromJson(e as Map<String, dynamic>))
            .toList(),
        summaries: (json['summaries'] as List<dynamic>?)
            ?.map((e) => SummaryRecord.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

enum _RecordingState { idle, recording, paused, stopped }
enum _SummaryLevel { detailed, medium, simple }

class InspirationPage extends StatefulWidget {
  const InspirationPage({super.key});
  @override
  State<InspirationPage> createState() => _InspirationPageState();
}

class _InspirationPageState extends State<InspirationPage> {
  List<InspirationFolder> _folders = [];
  String? _expandedFolderId;
  _RecordingState _recState = _RecordingState.idle;
  int _recordingSeconds = 0;
  Timer? _recTimer;
  String? _recordingFilePath;
  AudioPlayer? _audioPlayer;
  StreamSubscription<PlayerState>? _playerStateSub;
  String? _playingRecordingId;
  bool _isPaused = false;
  double _playSpeed = 1.0;
  String? _selectedAsrModelId;
  String? _selectedLlmModelId;
  bool _isGeneratingSummary = false;
  bool _showTimeWarning = false;
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _folderKeys = {};
  static const _asrModelPrefKey = 'inspiration_asr_model_id';
  static const _llmModelPrefKey = 'inspiration_llm_model_id';
  static const _dataKey = 'inspiration_folders_data';
  static const _maxRecordingSeconds = 300;
  static const _warningThreshold = 10;
  InspirationFolder get _defaultFolder =>
      _folders.firstWhere((f) => f.isDefault, orElse: () => _folders.first);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _recTimer?.cancel();
    _playerStateSub?.cancel();
    _playerStateSub = null;
    _audioPlayer?.stop();
    _audioPlayer?.dispose();
    _audioPlayer = null;
    _cleanupRecorder();
    _scrollController.dispose();
    super.dispose();
  }

  Future<List<ModelEntry>> _loadFilteredModels() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('saved_models_v2');
    final models = <ModelEntry>[];
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        for (final e in list) {
          final m = ModelEntry.fromJson(e as Map<String, dynamic>);
          if (m.filePath != null && m.filePath!.contains('mmproj')) continue;
          models.add(m);
        }
      } catch (_) {}
    }
    return models;
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAsr = prefs.getString(_asrModelPrefKey);
    if (savedAsr != null && savedAsr.isNotEmpty) _selectedAsrModelId = savedAsr;
    final savedLlm = prefs.getString(_llmModelPrefKey);
    if (savedLlm != null && savedLlm.isNotEmpty) _selectedLlmModelId = savedLlm;
    final jsonStr = prefs.getString(_dataKey);
    if (jsonStr != null) {
      try {
        final list = jsonDecode(jsonStr) as List<dynamic>;
        _folders = list.map((e) => InspirationFolder.fromJson(e as Map<String, dynamic>)).toList();
      } catch (e) {
        debugPrint('[Inspiration] load data error: $e');
      }
    }
    if (_folders.isEmpty || !_folders.any((f) => f.isDefault)) {
      _folders.insert(0, InspirationFolder(id: 'default', name: '自由', isDefault: true));
    }
    _expandedFolderId = _defaultFolder.id;
    for (final f in _folders) { _folderKeys[f.id] = GlobalKey(); }
    if (mounted) setState(() {});
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dataKey, jsonEncode(_folders.map((f) => f.toJson()).toList()));
  }

  void _cleanupRecorder() {
    // ★ 修复：必须等待 RecorderManager.deinit 完成，否则会与后续页面的 init 竞态
    // 之前 fire-and-forget 引发灵感页 dispose 后录音器未真正释放，下次 init 失败
    // 这里 dispose 内部即使 fire-and-forget 也要保留 future 引用，避免被 GC 取消
    final future = RecorderManager.instance.deinit(holder: 'inspiration');
    future.then((_) {
      debugPrint('[Inspiration] dispose: deinit 完成');
    }).catchError((e) {
      debugPrint('[Inspiration] dispose: deinit 错误: $e');
    });
  }

  Future<void> _startRecording() async {
    try {
      if (!Platform.isMacOS) {
        final status = await Permission.microphone.request();
        if (!status.isGranted) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('需要麦克风权限才能录制音频')));
          return;
        }
      }

      final appDir = await getApplicationSupportDirectory();
      final recDir = Directory('${appDir.path}/inspiration');
      if (!await recDir.exists()) await recDir.create(recursive: true);
      _recordingFilePath = '${recDir.path}/insp_${DateTime.now().millisecondsSinceEpoch}.wav';

      // ★ 使用 RecorderManager 统一管理初始化，避免多页面竞态
      final ok = await RecorderManager.instance.init(
        holder: 'inspiration',
        sampleRate: 16000,
        channels: RecorderChannels.mono,
        format: PCMFormat.s16le,
      );
      if (!ok) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('录音初始化失败，请重试')));
        return;
      }

      RecorderManager.instance.startRecording(_recordingFilePath!);
      setState(() { _recState = _RecordingState.recording; _recordingSeconds = 0; _showTimeWarning = false; });
      _recTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) return;
        setState(() {
          _recordingSeconds++;
          final remaining = _maxRecordingSeconds - _recordingSeconds;
          if (remaining <= _warningThreshold && !_showTimeWarning) {
            _showTimeWarning = true;
            if (remaining > 0) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('录音将在 $remaining 秒后自动停止'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 2),
              ));
            }
          }
          if (_recordingSeconds >= _maxRecordingSeconds) {
            _stopRecording();
          }
        });
      });
    } catch (e) {
      debugPrint('[Inspiration] start error: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('录音启动失败: $e')));
    }
  }

  Future<void> _pauseRecording() async {
    try {
      RecorderManager.instance.pauseRecording(); _recTimer?.cancel(); setState(() => _recState = _RecordingState.paused); }
    catch (e) { debugPrint('[Inspiration] pause error: $e'); }
  }

  Future<void> _resumeRecording() async {
    try {
      RecorderManager.instance.resumeRecording();
      _recTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) return;
        setState(() {
          _recordingSeconds++;
          final remaining = _maxRecordingSeconds - _recordingSeconds;
          if (remaining <= _warningThreshold && !_showTimeWarning) {
            _showTimeWarning = true;
            if (remaining > 0) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('录音将在 $remaining 秒后自动停止'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 2),
              ));
            }
          }
          if (_recordingSeconds >= _maxRecordingSeconds) {
            _stopRecording();
          }
        });
      });
      setState(() => _recState = _RecordingState.recording);
    } catch (e) { debugPrint('[Inspiration] resume error: $e'); }
  }

  Future<void> _stopRecording() async {
    _recTimer?.cancel();
    try {
      RecorderManager.instance.stopRecording();
      await RecorderManager.instance.deinit(holder: 'inspiration');
      setState(() => _recState = _RecordingState.stopped);
      final path = _recordingFilePath;
      if (path == null) return;
      final file = File(path);
      if (!await file.exists() || await file.length() < 1024) {
        setState(() { _recState = _RecordingState.idle; _recordingFilePath = null; _recordingSeconds = 0; });
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('录音保存失败，请重新录制')));
        return;
      }
      _showSaveRecordingDialog(InspirationRecording(
        id: 'rec_${DateTime.now().millisecondsSinceEpoch}', filePath: path, createdAt: DateTime.now(), durationMs: _recordingSeconds * 1000,
      ));
    } catch (e) {
      debugPrint('[Inspiration] stop error: $e');
      _cleanupRecorder();
      setState(() { _recState = _RecordingState.idle; _recordingFilePath = null; _recordingSeconds = 0; });
    }
  }

  Future<void> _playRecording(InspirationRecording recording) async {
    if (_playingRecordingId == recording.id) {
      await _stopPlayback();
      return;
    }
    await _stopPlayback();
    try {
      _audioPlayer = AudioPlayer();
      await _audioPlayer!.setFilePath(recording.filePath);
      _audioPlayer!.setSpeed(_playSpeed);
      _playerStateSub?.cancel();
      _playerStateSub = _audioPlayer!.playerStateStream.listen((state) {
        if (!mounted) return;
        if (state.processingState == ProcessingState.completed) _stopPlayback();
      });
      setState(() { _playingRecordingId = recording.id; _isPaused = false; });
      await _audioPlayer!.play();
    } catch (e) {
      debugPrint('[Inspiration] play error: $e');
      await _stopPlayback();
    }
  }

  Future<void> _pausePlayback() async { await _audioPlayer?.pause(); setState(() => _isPaused = true); }

  Future<void> _stopPlayback() async {
    _playerStateSub?.cancel();
    _playerStateSub = null;
    await _audioPlayer?.stop();
    await _audioPlayer?.dispose();
    _audioPlayer = null;
    if (mounted) setState(() { _playingRecordingId = null; _isPaused = false; _playSpeed = 1.0; });
  }

  void _cyclePlaySpeed() {
    setState(() {
      if (_playSpeed == 1.0) _playSpeed = 0.5;
      else if (_playSpeed == 0.5) _playSpeed = 1.0;
      else if (_playSpeed == 1.5) _playSpeed = 2.0;
      else if (_playSpeed == 2.0) _playSpeed = 1.0;
      else _playSpeed = 1.0;
      _audioPlayer?.setSpeed(_playSpeed);
    });
  }

  Future<void> _ensureAsrModel() async {
    if (_selectedAsrModelId != null) return;
    final downloaded = await voiceModelService.getDownloadedModelIds(VoiceModelType.asr);
    if (downloaded.isNotEmpty) {
      _selectedAsrModelId = downloaded.first;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_asrModelPrefKey, _selectedAsrModelId!);
    }
  }

  Future<void> _transcribeRecording(InspirationRecording recording) async {
    if (recording.isTranscribing) return;
    await _ensureAsrModel();
    if (_selectedAsrModelId == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请先在语音设置中下载 ASR 模型')));
      return;
    }
    setState(() => recording.isTranscribing = true);
    ASRService? asr;
    try {
      asr = ASRService(provider: ASRProvider.sherpa, sherpaModelId: _selectedAsrModelId);
      await asr.initSherpa();
      final text = await asr.recognizeFile(recording.filePath);
      if (!mounted) return;
      setState(() { recording.transcription = text.isNotEmpty ? text : '（未识别到内容）'; recording.isTranscribing = false; });
      _saveData();
    } catch (e) {
      if (!mounted) return;
      setState(() => recording.isTranscribing = false);
      debugPrint('[Inspiration] transcribe error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('转录失败: $e')));
    } finally {
      // ★ 关键修复：确保 ASRService（含 OfflineRecognizer）在 finally 中释放
      // 避免原生 C++ 资源泄漏，导致后续转录或其他页面的 ASR 初始化冲突闪退
      asr?.dispose();
    }
  }

  void _expandFolder(String folderId) {
    setState(() { _expandedFolderId = _expandedFolderId == folderId ? null : folderId; });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _folderKeys[folderId];
      if (key?.currentContext != null) {
        Scrollable.ensureVisible(key!.currentContext!, duration: const Duration(milliseconds: 300), alignment: 0.0);
      }
    });
  }

  void _showCreateFolderDialog() {
    final nameController = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('创建新目录'),
      content: TextField(controller: nameController, decoration: const InputDecoration(labelText: '目录名称', hintText: '例如：项目灵感、读书笔记'), autofocus: true),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
        FilledButton(onPressed: () {
          if (nameController.text.trim().isNotEmpty) {
            final newFolder = InspirationFolder(id: 'folder_${DateTime.now().millisecondsSinceEpoch}', name: nameController.text.trim());
            setState(() { _folders.add(newFolder); _folderKeys[newFolder.id] = GlobalKey(); });
            _saveData();
            Navigator.pop(ctx);
          }
        }, child: const Text('创建')),
      ],
    ));
  }

  void _deleteFolder(InspirationFolder folder) {
    if (folder.isDefault) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('默认目录不能删除'))); return; }
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('删除目录'),
      content: Text('确定删除「${folder.name}」？其中的 ${folder.recordingCount} 条录音将一并删除。'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
        FilledButton(style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error), onPressed: () {
          setState(() { _folders.removeWhere((f) => f.id == folder.id); _folderKeys.remove(folder.id); if (_expandedFolderId == folder.id) _expandedFolderId = _defaultFolder.id; });
          _saveData();
          Navigator.pop(ctx);
        }, child: const Text('删除')),
      ],
    ));
  }

  Future<void> _generateSummary(InspirationFolder folder, List<String> recordingIds, _SummaryLevel level, String modelId) async {
    setState(() => _isGeneratingSummary = true);
    try {
      final allText = folder.recordings.where((r) => recordingIds.contains(r.id) && r.transcription != null).map((r) => r.transcription!).join('\n\n');
      if (allText.trim().isEmpty) {
        setState(() => _isGeneratingSummary = false);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('所选录音均无转录文本，请先转录')));
        return;
      }

      final prompt = _buildSummaryPrompt(allText, level);
      String summary;

      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('saved_models_v2');
      ModelEntry? modelEntry;
      if (raw != null) {
        try {
          final list = jsonDecode(raw) as List<dynamic>;
          for (final e in list) {
            final m = ModelEntry.fromJson(e as Map<String, dynamic>);
            if (m.id == modelId) { modelEntry = m; break; }
          }
        } catch (_) {}
      }

      if (modelEntry != null && modelEntry.isRemote) {
        summary = await globalModelEngine.generateChat(modelId, [ChatMessage.user(prompt)]);
      } else {
        final engine = LocalFFIEngine.instance;
        String? modelPath = modelEntry?.filePath ?? modelId;
        if (!engine.isInitialized) await engine.loadModel(modelPath: modelPath);
        summary = await engine.generate([ChatMessage(role: 'user', content: prompt)]);
      }

      final mindMapJson = _buildMindMapJson(folder.name, summary);
      final record = SummaryRecord(id: 'sum_${DateTime.now().millisecondsSinceEpoch}', folderId: folder.id, recordingIds: recordingIds, level: level.name, summaryText: summary, mindMapData: mindMapJson, createdAt: DateTime.now());
      setState(() { folder.summaries.add(record); _isGeneratingSummary = false; });
      _saveData();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('总结生成完成')));
    } catch (e) {
      setState(() => _isGeneratingSummary = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('总结生成失败: $e')));
    }
  }

  String _buildSummaryPrompt(String allText, _SummaryLevel level) {
    String levelDesc;
    switch (level) { case _SummaryLevel.detailed: levelDesc = '详细'; break; case _SummaryLevel.medium: levelDesc = '适中'; break; case _SummaryLevel.simple: levelDesc = '简单'; break; }
    return '请根据以下录音转录文本，生成一份"$levelDesc"级别的内容总结。\n\n要求：\n- 详细模式：完整保留所有关键信息，逐段分析，保留细节\n- 适中模式：提炼核心要点，保留重要细节，结构化输出\n- 简单模式：仅保留关键结论和主题，简洁明了\n\n请直接输出总结内容，不要包含额外的说明。\n\n转录文本：\n$allText';
  }

  String _buildMindMapJson(String folderName, String summary) {
    final sentences = summary.split(RegExp(r'[。！？\n]')).where((s) => s.trim().isNotEmpty).toList();
    final Map<String, dynamic> root = {};
    final mainTopics = <String, List<String>>{};
    String? currentTopic;
    for (final s in sentences) {
      final trimmed = s.trim();
      if (trimmed.length > 15 && (trimmed.startsWith(RegExp(r'^[\d\-\*•#]')) || trimmed.contains('：') || trimmed.contains(':'))) {
        currentTopic = trimmed.length > 50 ? '${trimmed.substring(0, 50)}...' : trimmed;
        mainTopics[currentTopic] = [];
      } else if (currentTopic != null && trimmed.isNotEmpty) { mainTopics[currentTopic]!.add(trimmed); }
    }
    if (mainTopics.isEmpty && sentences.isNotEmpty) {
      final chunkSize = (sentences.length / 3).ceil().clamp(1, 10);
      for (var i = 0; i < sentences.length; i += chunkSize) {
        final end = (i + chunkSize).clamp(0, sentences.length);
        final chunk = sentences.sublist(i, end);
        final title = chunk.first.trim();
        final key = title.length > 40 ? '${title.substring(0, 40)}...' : title;
        mainTopics[key] = chunk.skip(1).map((s) => s.trim()).toList();
      }
    }
    for (final entry in mainTopics.entries.take(8)) { root[entry.key] = entry.value; }
    return jsonEncode(root);
  }

  Future<void> _showSummaryDialog(InspirationFolder folder) async {
    final transcribedRecordings = folder.recordings.where((r) => r.transcription != null && r.transcription!.isNotEmpty).toList();
    if (transcribedRecordings.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('该目录下没有已转录的录音，请先转录'))); return; }
    final selectedIds = Set<String>.from(transcribedRecordings.map((r) => r.id));
    _SummaryLevel selectedLevel = _SummaryLevel.medium;

    final allModels = await _loadFilteredModels();
    final prefs = await SharedPreferences.getInstance();
    final savedLlm = prefs.getString('inspiration_llm_model_id');
    String? selectedModelId = savedLlm;
    if (selectedModelId == null && allModels.isNotEmpty) selectedModelId = allModels.first.id;

    if (!mounted) return;
    await showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) => AlertDialog(
      title: const Text('生成总结'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('选择录音：', style: TextStyle(fontWeight: FontWeight.bold)),
        ...transcribedRecordings.map((r) => CheckboxListTile(value: selectedIds.contains(r.id), title: Text(r.dateLabel), subtitle: Text('${r.durationLabel} · ${(r.transcription ?? '').length}字'), onChanged: (v) { setDialogState(() { if (v == true) selectedIds.add(r.id); else selectedIds.remove(r.id); }); }, dense: true)),
        const Divider(),
        const Text('总结方式：', style: TextStyle(fontWeight: FontWeight.bold)),
        RadioGroup<_SummaryLevel>(
          groupValue: selectedLevel,
          onChanged: (v) { if (v != null) setDialogState(() => selectedLevel = v); },
          child: Column(children: [
            ListTile(leading: Radio<_SummaryLevel>(value: _SummaryLevel.detailed), title: const Text('详细'), subtitle: const Text('完整保留所有关键信息'), dense: true, onTap: () => setDialogState(() => selectedLevel = _SummaryLevel.detailed)),
            ListTile(leading: Radio<_SummaryLevel>(value: _SummaryLevel.medium), title: const Text('适中'), subtitle: const Text('提炼核心要点'), dense: true, onTap: () => setDialogState(() => selectedLevel = _SummaryLevel.medium)),
            ListTile(leading: Radio<_SummaryLevel>(value: _SummaryLevel.simple), title: const Text('简单'), subtitle: const Text('仅保留关键结论'), dense: true, onTap: () => setDialogState(() => selectedLevel = _SummaryLevel.simple)),
          ]),
        ),
        if (allModels.isNotEmpty) ...[
          const Divider(),
          const Text('选择 LLM 模型：', style: TextStyle(fontWeight: FontWeight.bold)),
          RadioGroup<String>(
            groupValue: selectedModelId,
            onChanged: (v) { if (v != null) setDialogState(() => selectedModelId = v); },
            child: Column(children: allModels.map((m) {
              final isLocal = m.type == ModelType.local;
              final subtitle = isLocal ? '本地' : '${m.remoteConfig?.protocol.name ?? 'API'}';
              return ListTile(leading: Radio<String>(value: m.id), title: Text(m.displayName, style: const TextStyle(fontSize: 13)), subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)), dense: true, onTap: () => setDialogState(() => selectedModelId = m.id));
            }).toList()),
          ),
        ],
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
        FilledButton(onPressed: selectedIds.isEmpty || selectedModelId == null ? null : () async { 
          Navigator.pop(ctx); 
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('inspiration_llm_model_id', selectedModelId!);
          _generateSummary(folder, selectedIds.toList(), selectedLevel, selectedModelId!); 
        }, child: const Text('开始生成')),
      ],
    )));
  }

  Future<void> _switchAsrModel() async {
    final downloaded = await voiceModelService.getDownloadedModelIds(VoiceModelType.asr);
    if (downloaded.isEmpty) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请先在语音设置中下载 ASR 模型'))); return; }
    if (!mounted) return;
    final chosen = await showDialog<String>(context: context, builder: (ctx) => SimpleDialog(
      title: const Text('选择语音识别模型'),
      children: downloaded.map((id) {
        final info = VoiceModelService.asrModels.where((m) => m.id == id).toList();
        final name = info.isNotEmpty ? info.first.name : id;
        return SimpleDialogOption(onPressed: () => Navigator.pop(ctx, id), child: ListTile(leading: const Icon(Icons.graphic_eq), title: Text(name), subtitle: Text(id), dense: true));
      }).toList(),
    ));
    if (chosen != null) { final prefs = await SharedPreferences.getInstance(); await prefs.setString(_asrModelPrefKey, chosen); setState(() => _selectedAsrModelId = chosen); }
  }

  Future<void> _switchLlmModel() async {
    final allModels = await _loadFilteredModels();

    if (allModels.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请先在模型设置中添加 LLM 模型（本地或 API）')),
        );
      }
      return;
    }

    if (!mounted) return;
    final chosen = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('选择总结模型'),
        children: allModels.map((m) {
          final isLocal = m.type == ModelType.local;
          final subtitle = isLocal
              ? '本地模型${m.parameterSize != null ? ' · ${m.parameterSize}B' : ''}'
              : '${m.remoteConfig?.protocol.name ?? 'API'} · ${m.remoteConfig?.modelId ?? ''}';
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, m.id),
            child: ListTile(
              leading: Icon(isLocal ? Icons.storage : Icons.cloud_outlined),
              title: Text(m.displayName),
              subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
              dense: true,
            ),
          );
        }).toList(),
      ),
    );
    if (chosen != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_llmModelPrefKey, chosen);
      setState(() => _selectedLlmModelId = chosen);
    }
  }

  Future<void> _exportAsMarkdown(SummaryRecord record) async {
    try {
      // ★ 修复导出失败：iOS 上 getApplicationSupportDirectory 的文件无法被 share_plus 访问
      // 使用 getTemporaryDirectory 代替，share_plus 在 iOS 上需要临时目录的文件
      final dir = await getTemporaryDirectory();
      final exportDir = Directory('${dir.path}/inspiration/exports');
      if (!await exportDir.exists()) await exportDir.create(recursive: true);
      final file = File('${exportDir.path}/summary_${record.id}.md');
      await file.writeAsString(record.summaryText);
      final box = context.findRenderObject() as RenderBox?;
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: '灵感总结',
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('导出失败: $e'))); }
  }

  Future<void> _exportAsMindMap(InspirationFolder folder, SummaryRecord record) async {
    try {
      Map<String, dynamic> mindMapData = {};
      if (record.mindMapData != null) mindMapData = jsonDecode(record.mindMapData!) as Map<String, dynamic>;
      final result = await DocumentGenerationService.instance.generateXMind(title: '灵感导图_${folder.name}', mindMapData: mindMapData);
      final box = context.findRenderObject() as RenderBox?;
      await Share.shareXFiles(
        [XFile(result.filePath)],
        subject: '思维导图 - ${folder.name}',
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('XMind 思维导图已导出: ${result.fileName}')));
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('导出失败: $e'))); }
  }

  String _fmtDuration(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _showSaveRecordingDialog(InspirationRecording recording) {
    String selectedFolderId = _defaultFolder.id;
    showDialog(context: context, barrierDismissible: false, builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) => AlertDialog(
      title: const Text('保存录音'),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('时长: ${_fmtDuration(_recordingSeconds)}'),
        const SizedBox(height: 16),
        const Text('选择目录:'),
        const SizedBox(height: 8),
        RadioGroup<String>(
          groupValue: selectedFolderId,
          onChanged: (v) { if (v != null) setDialogState(() => selectedFolderId = v); },
          child: Column(children: _folders.map((folder) => ListTile(leading: Radio<String>(value: folder.id), title: Text('${folder.name} (${folder.recordingCount}条)'), dense: true, onTap: () => setDialogState(() => selectedFolderId = folder.id))).toList()),
        ),
        const Divider(),
        ListTile(leading: const Icon(Icons.create_new_folder_outlined), title: const Text('+ 新建目录'), onTap: () { Navigator.pop(ctx); _showCreateFolderAndSave(recording); }, dense: true),
      ]),
      actions: [
        TextButton(onPressed: () { Navigator.pop(ctx); _saveRecordingToFolder(recording, _defaultFolder.id); }, child: const Text('直接保存到自由')),
        FilledButton(onPressed: () { Navigator.pop(ctx); _saveRecordingToFolder(recording, selectedFolderId); }, child: const Text('保存')),
      ],
    )));
  }

  void _showCreateFolderAndSave(InspirationRecording recording) {
    final nameController = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('创建新目录'),
      content: TextField(controller: nameController, decoration: const InputDecoration(labelText: '目录名称', hintText: '例如：项目灵感、读书笔记'), autofocus: true),
      actions: [
        TextButton(onPressed: () { Navigator.pop(ctx); _saveRecordingToFolder(recording, _defaultFolder.id); }, child: const Text('取消，保存到自由')),
        FilledButton(onPressed: () {
          if (nameController.text.trim().isNotEmpty) {
            final newFolder = InspirationFolder(id: 'folder_${DateTime.now().millisecondsSinceEpoch}', name: nameController.text.trim());
            setState(() { _folders.add(newFolder); _folderKeys[newFolder.id] = GlobalKey(); });
            _saveData();
            Navigator.pop(ctx);
            _saveRecordingToFolder(recording, newFolder.id);
          }
        }, child: const Text('创建并保存')),
      ],
    ));
  }

  void _saveRecordingToFolder(InspirationRecording recording, String folderId) {
    final folder = _folders.where((f) => f.id == folderId).firstOrNull;
    if (folder == null) return;
    setState(() { folder.recordings.insert(0, recording); _recState = _RecordingState.idle; _recordingSeconds = 0; _recordingFilePath = null; _expandedFolderId = folderId; });
    _saveData();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已保存到「${folder.name}」')));
  }

  void _deleteRecording(InspirationFolder folder, InspirationRecording recording) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('删除录音'),
      content: Text('确定删除 ${recording.dateLabel} 的录音？'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
        FilledButton(style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error), onPressed: () {
          setState(() { folder.recordings.removeWhere((r) => r.id == recording.id); if (_playingRecordingId == recording.id) _stopPlayback(); });
          _saveData(); Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('录音已删除')));
        }, child: const Text('删除')),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: const Text('灵感一瞬'),
        actions: [
          IconButton(icon: const Icon(Icons.graphic_eq), tooltip: '切换识别模型', onPressed: _switchAsrModel),
          IconButton(icon: const Icon(Icons.smart_toy_outlined), tooltip: '切换总结模型', onPressed: _switchLlmModel),
          IconButton(icon: const Icon(Icons.create_new_folder_outlined), tooltip: '新建目录', onPressed: _showCreateFolderDialog),
        ],
      ),
      body: Column(children: [
        if (_isGeneratingSummary)
          Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), color: theme.colorScheme.primaryContainer.withAlpha(77), child: const Row(children: [SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)), SizedBox(width: 12), Text('正在生成总结...', style: TextStyle(color: Colors.blue))])),
        if (_recState == _RecordingState.recording || _recState == _RecordingState.paused) _buildRecordingBar(theme),
        Expanded(child: _folders.isEmpty ? _buildEmptyState(theme) : ListView.builder(controller: _scrollController, padding: const EdgeInsets.all(12), itemCount: _folders.length, itemBuilder: (ctx, i) => _buildFolderItem(theme, _folders[i]))),
      ]),
      floatingActionButton: _buildRecordingFab(theme),
    );
  }

  Widget _buildRecordingFab(ThemeData theme) {
    if (_recState == _RecordingState.recording || _recState == _RecordingState.paused) {
      return Row(mainAxisSize: MainAxisSize.min, children: [
        if (_recState == _RecordingState.paused) FloatingActionButton(heroTag: 'resume', onPressed: _resumeRecording, backgroundColor: Colors.green, child: const Icon(Icons.play_arrow)),
        if (_recState == _RecordingState.recording) ...[FloatingActionButton(heroTag: 'pause', onPressed: _pauseRecording, backgroundColor: Colors.orange, child: const Icon(Icons.pause)), const SizedBox(width: 16)],
        FloatingActionButton.large(heroTag: 'stop', onPressed: _stopRecording, backgroundColor: theme.colorScheme.error, child: const Icon(Icons.stop, size: 36)),
      ]);
    }
    return FloatingActionButton.large(onPressed: _startRecording, backgroundColor: theme.colorScheme.primaryContainer, child: const Icon(Icons.mic, size: 36));
  }

  Widget _buildRecordingBar(ThemeData theme) {
    final isPaused = _recState == _RecordingState.paused;
    final remaining = _maxRecordingSeconds - _recordingSeconds;
    final isWarning = remaining <= _warningThreshold;
    final progress = _recordingSeconds / _maxRecordingSeconds;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isWarning ? Colors.orange.withAlpha(77) : theme.colorScheme.errorContainer.withAlpha(77),
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(children: [
        Row(children: [
          Icon(Icons.fiber_manual_record, color: isWarning ? Colors.orange : (isPaused ? Colors.orange : Colors.red), size: 16),
          const SizedBox(width: 8),
          Text(
            isWarning ? '即将停止' : (isPaused ? '已暂停' : '录音中...'),
            style: TextStyle(color: isWarning ? Colors.orange : (isPaused ? Colors.orange : Colors.red), fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Text(
            _fmtDuration(_recordingSeconds),
            style: theme.textTheme.titleMedium?.copyWith(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              color: isWarning ? Colors.orange : null,
            ),
          ),
          Text(
            ' / ${_fmtDuration(_maxRecordingSeconds)}',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        ]),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.withAlpha(51),
          valueColor: AlwaysStoppedAnimation<Color>(
            isWarning ? Colors.orange : theme.colorScheme.primary,
          ),
          minHeight: 4,
          borderRadius: BorderRadius.circular(2),
        ),
        if (isWarning) ...[
          const SizedBox(height: 4),
          Text(
            '剩余 $remaining 秒',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.orange, fontWeight: FontWeight.bold),
          ),
        ],
      ]),
    );
  }

  Widget _buildFolderItem(ThemeData theme, InspirationFolder folder) {
    final isExpanded = _expandedFolderId == folder.id;
    final key = _folderKeys.putIfAbsent(folder.id, () => GlobalKey());
    return Card(key: key, margin: const EdgeInsets.only(bottom: 8), clipBehavior: Clip.antiAlias, child: Column(children: [
      InkWell(
        onTap: () => _expandFolder(folder.id),
        onLongPress: folder.isDefault ? null : () => _deleteFolder(folder),
        child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), color: isExpanded ? theme.colorScheme.primaryContainer.withAlpha(51) : null, child: Row(children: [
          Icon(folder.isDefault ? Icons.all_inclusive : (isExpanded ? Icons.folder_open : Icons.folder_outlined), color: isExpanded ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(folder.name, style: TextStyle(fontWeight: isExpanded ? FontWeight.bold : FontWeight.normal, fontSize: 15)),
            Text('${folder.recordingCount}条 · ${folder.transcribedCount}已转录', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ])),
          TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => _FolderDetailPage(folder: folder, selectedAsrModelId: _selectedAsrModelId, onSummaryChanged: () { if (mounted) setState(() {}); _saveData(); }, onRecordingDeleted: () { if (mounted) setState(() {}); _saveData(); }))), child: const Text('详细')),
        ])),
      ),
      if (isExpanded && folder.recordings.isNotEmpty)
        Container(decoration: BoxDecoration(border: Border(top: BorderSide(color: theme.dividerColor, width: 0.5))), child: Column(children: folder.recordings.map((r) => _buildRecordingItem(theme, folder, r)).toList())),
      if (isExpanded && folder.recordings.isEmpty)
        Container(padding: const EdgeInsets.all(24), child: Text('暂无录音', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant))),
    ]));
  }

  Widget _buildRecordingItem(ThemeData theme, InspirationFolder folder, InspirationRecording recording) {
    final isPlaying = _playingRecordingId == recording.id;
    return Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(border: Border(bottom: BorderSide(color: theme.dividerColor, width: 0.3))), child: Row(children: [
      IconButton(icon: Icon(isPlaying ? Icons.stop_circle : Icons.play_circle, size: 28, color: isPlaying ? Colors.red : theme.colorScheme.primary), onPressed: () { if (isPlaying) _stopPlayback(); else _playRecording(recording); }, padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 36, minHeight: 36)),
      const SizedBox(width: 8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(recording.dateLabel, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)), Text(recording.durationLabel, style: theme.textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'))])),
      if (recording.isTranscribing) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
      else ...[
        if (recording.transcription == null)
          TextButton(onPressed: () => _transcribeRecording(recording), style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap), child: const Text('转录'))
        else
          TextButton(onPressed: () => _showTranscriptionPopup(recording), style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap), child: const Text('文本')),
        IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red), onPressed: () => _deleteRecording(folder, recording), padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 32, minHeight: 32)),
      ],
    ]));
  }

  void _showTranscriptionPopup(InspirationRecording recording) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7, minChildSize: 0.3, maxChildSize: 0.95, expand: false,
        builder: (ctx, scrollController) => Column(children: [
          Container(padding: const EdgeInsets.all(16), child: Row(children: [
            Icon(Icons.mic, color: Theme.of(ctx).colorScheme.primary), const SizedBox(width: 8),
            Text(recording.dateLabel, style: Theme.of(ctx).textTheme.titleMedium), const Spacer(),
            Text(recording.durationLabel, style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(fontFamily: 'monospace')),
            IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
          ])),
          const Divider(height: 1),
          Expanded(child: SingleChildScrollView(controller: scrollController, padding: const EdgeInsets.all(16), child: SelectableText(recording.transcription ?? '（无转录内容）', style: Theme.of(ctx).textTheme.bodyLarge?.copyWith(height: 1.6)))),
        ]),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.lightbulb_outline, size: 80, color: theme.colorScheme.primary.withAlpha(128)),
      const SizedBox(height: 24),
      Text('点击下方按钮开始录音', style: theme.textTheme.titleLarge),
      const SizedBox(height: 8),
      Text('灵感稍纵即逝，用声音捕捉它', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
    ]));
  }
}

class _FolderDetailPage extends StatefulWidget {
  final InspirationFolder folder;
  final String? selectedAsrModelId;
  final String? initialRecordingId;
  final VoidCallback onSummaryChanged;
  final VoidCallback onRecordingDeleted;
  const _FolderDetailPage({required this.folder, this.selectedAsrModelId, this.initialRecordingId, required this.onSummaryChanged, required this.onRecordingDeleted});
  @override
  State<_FolderDetailPage> createState() => _FolderDetailPageState();
}

class _FolderDetailPageState extends State<_FolderDetailPage> {
  AudioPlayer? _audioPlayer;
  StreamSubscription<PlayerState>? _playerStateSub;
  String? _playingRecordingId;
  bool _isPaused = false;
  double _playSpeed = 1.0;
  final ScrollController _scrollController = ScrollController();
  final Map<String, bool> _expandedSummaries = {};
  final Set<String> _selectedRecordingIds = {};
  String? _selectedAsrModelId;

  @override
  void initState() {
    super.initState();
    _selectedAsrModelId = widget.selectedAsrModelId;
    if (widget.initialRecordingId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final recording = widget.folder.recordings.where((r) => r.id == widget.initialRecordingId).firstOrNull;
        if (recording != null) _showTranscriptionSheet(recording);
      });
    }
  }

  @override
  void dispose() {
    _playerStateSub?.cancel();
    _playerStateSub = null;
    _audioPlayer?.stop();
    _audioPlayer?.dispose();
    _audioPlayer = null;
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _playRecording(InspirationRecording recording) async {
    if (_playingRecordingId == recording.id) { await _stopPlayback(); return; }
    await _stopPlayback();
    try {
      _audioPlayer = AudioPlayer();
      await _audioPlayer!.setFilePath(recording.filePath);
      _audioPlayer!.setSpeed(_playSpeed);
      _playerStateSub?.cancel();
      _playerStateSub = _audioPlayer!.playerStateStream.listen((state) { if (!mounted) return; if (state.processingState == ProcessingState.completed) _stopPlayback(); });
      setState(() { _playingRecordingId = recording.id; _isPaused = false; });
      await _audioPlayer!.play();
    } catch (e) {
      debugPrint('[Inspiration] play error: $e');
      await _stopPlayback();
    }
  }

  Future<void> _pausePlayback() async { await _audioPlayer?.pause(); setState(() => _isPaused = true); }

  Future<void> _stopPlayback() async {
    _playerStateSub?.cancel();
    _playerStateSub = null;
    await _audioPlayer?.stop();
    await _audioPlayer?.dispose();
    _audioPlayer = null;
    if (mounted) setState(() { _playingRecordingId = null; _isPaused = false; _playSpeed = 1.0; });
  }

  void _cyclePlaySpeed() {
    setState(() {
      if (_playSpeed == 1.0) _playSpeed = 0.5;
      else if (_playSpeed == 0.5) _playSpeed = 1.0;
      else if (_playSpeed == 1.5) _playSpeed = 2.0;
      else if (_playSpeed == 2.0) _playSpeed = 1.0;
      else _playSpeed = 1.0;
      _audioPlayer?.setSpeed(_playSpeed);
    });
  }

  Future<void> _transcribeRecording(InspirationRecording recording) async {
    if (recording.isTranscribing) return;
    if (_selectedAsrModelId == null) {
      final downloaded = await voiceModelService.getDownloadedModelIds(VoiceModelType.asr);
      if (downloaded.isNotEmpty) _selectedAsrModelId = downloaded.first;
    }
    if (_selectedAsrModelId == null) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请先在语音设置中下载 ASR 模型'))); return; }
    setState(() => recording.isTranscribing = true);
    final slowTimer = Timer(const Duration(seconds: 5), () { if (mounted && recording.isTranscribing) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('文本转换速度时间较久，请稍待'))); });
    ASRService? asr;
    try {
      asr = ASRService(provider: ASRProvider.sherpa, sherpaModelId: _selectedAsrModelId);
      await asr.initSherpa();
      final text = await asr.recognizeFile(recording.filePath);
      slowTimer.cancel();
      if (!mounted) return;
      setState(() { recording.transcription = text.isNotEmpty ? text : '（未识别到内容）'; recording.isTranscribing = false; });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('转录完成')));
    } catch (e) {
      slowTimer.cancel();
      if (!mounted) return;
      setState(() => recording.isTranscribing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('转录失败: $e')));
    } finally {
      // ★ 关键修复：确保 ASRService（含 OfflineRecognizer）在 finally 中释放
      asr?.dispose();
    }
  }

  void _showTranscriptionSheet(InspirationRecording recording) {
    if (recording.transcription == null && !recording.isTranscribing) _transcribeRecording(recording);
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.7, minChildSize: 0.3, maxChildSize: 0.95, expand: false,
      builder: (ctx, scrollController) => Column(children: [
        Container(padding: const EdgeInsets.all(16), child: Row(children: [
          Icon(Icons.mic, color: Theme.of(ctx).colorScheme.primary), const SizedBox(width: 8),
          Text(recording.dateLabel, style: Theme.of(ctx).textTheme.titleMedium), const Spacer(),
          Text(recording.durationLabel, style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(fontFamily: 'monospace')),
          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
        ])),
        const Divider(height: 1),
        Expanded(child: StatefulBuilder(builder: (ctx, setSheetState) {
          if (recording.isTranscribing) return const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(), SizedBox(height: 16), Text('正在转录...')]));
          if (recording.transcription != null) return SingleChildScrollView(controller: scrollController, padding: const EdgeInsets.all(16), child: SelectableText(recording.transcription!, style: Theme.of(ctx).textTheme.bodyLarge?.copyWith(height: 1.6)));
          return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.transcribe, size: 48, color: Theme.of(ctx).colorScheme.onSurfaceVariant),
            const SizedBox(height: 8), const Text('暂无转录内容'), const SizedBox(height: 16),
            FilledButton.icon(icon: const Icon(Icons.transcribe), label: const Text('立即转录'), onPressed: () { Navigator.pop(ctx); _transcribeRecording(recording); }),
          ]));
        })),
      ]),
    ));
  }

  bool _isGeneratingSummary = false;

  Future<void> _showSummaryDialogLocal() async {
    final folder = widget.folder;
    final transcribedRecordings = folder.recordings.where((r) => r.transcription != null && r.transcription!.isNotEmpty).toList();
    if (transcribedRecordings.isEmpty) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('该目录下没有已转录的录音，请先转录'))); return; }
    final preSelected = _selectedRecordingIds.where((id) => transcribedRecordings.any((r) => r.id == id)).toSet();
    final selectedIds = preSelected.isNotEmpty ? preSelected : Set<String>.from(transcribedRecordings.map((r) => r.id));
    _SummaryLevel selectedLevel = _SummaryLevel.medium;

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('saved_models_v2');
    final allModels = <ModelEntry>[];
    if (raw != null) { try { final list = jsonDecode(raw) as List<dynamic>; for (final e in list) { final m = ModelEntry.fromJson(e as Map<String, dynamic>); if (m.filePath != null && m.filePath!.contains('mmproj')) continue; allModels.add(m); } } catch (_) {} }
    final savedLlm = prefs.getString('inspiration_llm_model_id');
    String? selectedModelId = savedLlm;
    if (selectedModelId == null && allModels.isNotEmpty) selectedModelId = allModels.first.id;

    if (!mounted) return;
    await showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) => AlertDialog(
      title: const Text('一键总结'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('选择录音：', style: TextStyle(fontWeight: FontWeight.bold)),
        ...transcribedRecordings.map((r) => CheckboxListTile(value: selectedIds.contains(r.id), title: Text(r.dateLabel), subtitle: Text('${r.durationLabel} · ${(r.transcription ?? '').length}字'), onChanged: (v) { setDialogState(() { if (v == true) selectedIds.add(r.id); else selectedIds.remove(r.id); }); }, dense: true)),
        const Divider(),
        const Text('总结方式：', style: TextStyle(fontWeight: FontWeight.bold)),
        RadioGroup<_SummaryLevel>(groupValue: selectedLevel, onChanged: (v) { if (v != null) setDialogState(() => selectedLevel = v); }, child: Column(children: [
          ListTile(leading: Radio<_SummaryLevel>(value: _SummaryLevel.detailed), title: const Text('详细'), dense: true, onTap: () => setDialogState(() => selectedLevel = _SummaryLevel.detailed)),
          ListTile(leading: Radio<_SummaryLevel>(value: _SummaryLevel.medium), title: const Text('适中'), dense: true, onTap: () => setDialogState(() => selectedLevel = _SummaryLevel.medium)),
          ListTile(leading: Radio<_SummaryLevel>(value: _SummaryLevel.simple), title: const Text('简单'), dense: true, onTap: () => setDialogState(() => selectedLevel = _SummaryLevel.simple)),
        ])),
        if (allModels.isNotEmpty) ...[
          const Divider(),
          const Text('选择模型：', style: TextStyle(fontWeight: FontWeight.bold)),
          RadioGroup<String>(groupValue: selectedModelId, onChanged: (v) { if (v != null) setDialogState(() => selectedModelId = v); }, child: Column(children: allModels.map((m) { final isLocal = m.type == ModelType.local; return ListTile(leading: Radio<String>(value: m.id), title: Text(m.displayName, style: const TextStyle(fontSize: 13)), subtitle: Text(isLocal ? '本地' : 'API', style: const TextStyle(fontSize: 11)), dense: true, onTap: () => setDialogState(() => selectedModelId = m.id)); }).toList())),
        ],
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
        FilledButton(onPressed: selectedIds.isEmpty || selectedModelId == null ? null : () async { 
          Navigator.pop(ctx); 
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('inspiration_llm_model_id', selectedModelId!);
          _generateSummaryLocal(selectedIds.toList(), selectedLevel, selectedModelId!); 
        }, child: const Text('开始生成')),
      ],
    )));
  }

  Future<void> _generateSummaryLocal(List<String> recordingIds, _SummaryLevel level, String modelId) async {
    setState(() => _isGeneratingSummary = true);
    try {
      final folder = widget.folder;
      final allText = folder.recordings.where((r) => recordingIds.contains(r.id) && r.transcription != null).map((r) => r.transcription!).join('\n\n');
      if (allText.trim().isEmpty) { setState(() => _isGeneratingSummary = false); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('所选录音均无转录文本'))); return; }

      String levelDesc;
      switch (level) { case _SummaryLevel.detailed: levelDesc = '详细'; break; case _SummaryLevel.medium: levelDesc = '适中'; break; case _SummaryLevel.simple: levelDesc = '简单'; break; }
      final prompt = '请根据以下录音转录文本，生成一份"$levelDesc"级别的内容总结。\n\n要求：\n- 详细模式：完整保留所有关键信息，逐段分析\n- 适中模式：提炼核心要点，保留重要细节\n- 简单模式：仅保留关键结论和主题\n\n请直接输出总结内容。\n\n转录文本：\n$allText';

      String summary;
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('saved_models_v2');
      ModelEntry? modelEntry;
      if (raw != null) { try { final list = jsonDecode(raw) as List<dynamic>; for (final e in list) { final m = ModelEntry.fromJson(e as Map<String, dynamic>); if (m.id == modelId) { modelEntry = m; break; } } } catch (_) {} }

      if (modelEntry != null && modelEntry.isRemote) {
        summary = await globalModelEngine.generateChat(modelId, [ChatMessage.user(prompt)]);
      } else {
        final engine = LocalFFIEngine.instance;
        if (!engine.isInitialized) await engine.loadModel(modelPath: modelEntry?.filePath ?? modelId);
        summary = await engine.generate([ChatMessage.user(prompt)]);
      }

      final sentences = summary.split(RegExp(r'[。！？\n]')).where((s) => s.trim().isNotEmpty).toList();
      final Map<String, dynamic> mindMapRoot = {};
      final mainTopics = <String, List<String>>{};
      String? currentTopic;
      for (final s in sentences) { final trimmed = s.trim(); if (trimmed.length > 15 && (trimmed.startsWith(RegExp(r'^[\d\-\*•#]')) || trimmed.contains('：') || trimmed.contains(':'))) { currentTopic = trimmed.length > 50 ? '${trimmed.substring(0, 50)}...' : trimmed; mainTopics[currentTopic] = []; } else if (currentTopic != null && trimmed.isNotEmpty) { mainTopics[currentTopic]!.add(trimmed); } }
      if (mainTopics.isEmpty && sentences.isNotEmpty) { final chunkSize = (sentences.length / 3).ceil().clamp(1, 10); for (var i = 0; i < sentences.length; i += chunkSize) { final end = (i + chunkSize).clamp(0, sentences.length); final chunk = sentences.sublist(i, end); final key = chunk.first.trim().length > 40 ? '${chunk.first.trim().substring(0, 40)}...' : chunk.first.trim(); mainTopics[key] = chunk.skip(1).map((s) => s.trim()).toList(); } }
      for (final entry in mainTopics.entries.take(8)) { mindMapRoot[entry.key] = entry.value; }

      final record = SummaryRecord(id: 'sum_${DateTime.now().millisecondsSinceEpoch}', folderId: folder.id, recordingIds: recordingIds, level: level.name, summaryText: summary, mindMapData: jsonEncode(mindMapRoot), createdAt: DateTime.now());
      setState(() { folder.summaries.add(record); _isGeneratingSummary = false; });
      widget.onSummaryChanged();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('总结生成完成')));
    } catch (e) {
      setState(() => _isGeneratingSummary = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('总结生成失败: $e')));
    }
  }

  void _deleteRecording(InspirationRecording recording) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('删除录音'), content: Text('确定删除 ${recording.dateLabel} 的录音？'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
        FilledButton(style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error), onPressed: () {
          setState(() { widget.folder.recordings.removeWhere((r) => r.id == recording.id); if (_playingRecordingId == recording.id) _stopPlayback(); });
          widget.onRecordingDeleted(); Navigator.pop(ctx);
        }, child: const Text('删除')),
      ],
    ));
  }

  void _deleteSummary(SummaryRecord record) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('删除总结'), content: const Text('确定删除这条总结记录？'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
        FilledButton(style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error), onPressed: () {
          setState(() { widget.folder.summaries.removeWhere((s) => s.id == record.id); });
          widget.onSummaryChanged(); Navigator.pop(ctx);
        }, child: const Text('删除')),
      ],
    ));
  }

  Future<void> _exportAsMarkdown(SummaryRecord record) async {
    try {
      final dir = await getTemporaryDirectory();
      final exportDir = Directory('${dir.path}/inspiration/exports');
      if (!await exportDir.exists()) await exportDir.create(recursive: true);
      final file = File('${exportDir.path}/summary_${record.id}.md');
      await file.writeAsString(record.summaryText);
      final box = context.findRenderObject() as RenderBox?;
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: '灵感总结',
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('导出失败: $e'))); }
  }

  Future<void> _exportAsMindMap(SummaryRecord record) async {
    try {
      Map<String, dynamic> mindMapData = {};
      if (record.mindMapData != null) mindMapData = jsonDecode(record.mindMapData!) as Map<String, dynamic>;
      final result = await DocumentGenerationService.instance.generateXMind(title: '灵感导图_${widget.folder.name}', mindMapData: mindMapData);
      final box = context.findRenderObject() as RenderBox?;
      await Share.shareXFiles(
        [XFile(result.filePath)],
        subject: '思维导图 - ${widget.folder.name}',
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('导出失败: $e'))); }
  }

  MindMap _buildMindMap(String summaryText, String? mindMapJson) {
    final mindMap = MindMap();
    final root = mindMap.getRootNode();
    root.setTitle(widget.folder.name);
    (root as MindMapNode).setBackgroundColor(Colors.blue.shade100);
    root.setLinkColor(Colors.blue);

    Map<String, dynamic> topics = {};
    if (mindMapJson != null) { try { topics = jsonDecode(mindMapJson) as Map<String, dynamic>; } catch (_) {} }

    if (topics.isEmpty) {
      final sentences = summaryText.split(RegExp(r'[。！？\n]')).where((s) => s.trim().isNotEmpty).toList();
      final chunkSize = (sentences.length / 3).ceil().clamp(1, 10);
      for (var i = 0; i < sentences.length && i < 30; i += chunkSize) {
        final end = (i + chunkSize).clamp(0, sentences.length);
        final chunk = sentences.sublist(i, end);
        final title = chunk.first.trim();
        final key = title.length > 30 ? '${title.substring(0, 30)}...' : title;
        topics[key] = chunk.skip(1).map((s) => s.trim()).toList();
      }
    }

    final colors = [Colors.red.shade100, Colors.green.shade100, Colors.orange.shade100, Colors.purple.shade100, Colors.teal.shade100, Colors.pink.shade100];
    var colorIndex = 0;
    for (final entry in topics.entries.take(8)) {
      final node = MindMapNode();
      node.setTitle(entry.key);
      node.setBackgroundColor(colors[colorIndex % colors.length]);
      node.setTextStyle(const TextStyle(fontSize: 12.0, color: Colors.black));
      node.setPadding(const EdgeInsets.fromLTRB(16, 4, 16, 4));
      root.addRightItem(node);
      if (entry.value is List) {
        for (final sub in (entry.value as List).take(5)) {
          final subNode = MindMapNode();
          subNode.setTitle(sub.toString());
          subNode.setBackgroundColor(Colors.white);
          subNode.setTextStyle(const TextStyle(fontSize: 10.0, color: Colors.black87));
          subNode.setPadding(const EdgeInsets.fromLTRB(12, 2, 12, 2));
          node.addRightItem(subNode);
        }
      }
      colorIndex++;
    }

    mindMap.onChanged();
    mindMap.setReadOnly(true);
    mindMap.setExpandedLevel(3);
    mindMap.setZoom(0.8);
    return mindMap;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allIds = widget.folder.recordings.map((r) => r.id).toSet();
    final allSelected = allIds.isNotEmpty && allIds.every((id) => _selectedRecordingIds.contains(id));
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folder.name),
        actions: [
          if (_isGeneratingSummary)
            const Padding(padding: EdgeInsets.all(16), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
          else
            IconButton(icon: const Icon(Icons.summarize_outlined), tooltip: '一键总结', onPressed: _showSummaryDialogLocal),
        ],
      ),
      body: ListView(controller: _scrollController, padding: const EdgeInsets.all(12), children: [
        if (widget.folder.recordings.isNotEmpty) ...[
          Row(children: [
            Checkbox(value: allSelected, tristate: false, onChanged: (v) { setState(() { if (v == true) { _selectedRecordingIds.addAll(allIds); } else { _selectedRecordingIds.clear(); } }); }),
            Text('全选 (${widget.folder.recordings.length}条录音)', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const Spacer(),
            if (_selectedRecordingIds.isNotEmpty)
              Text('${_selectedRecordingIds.length} 已选', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary)),
          ]),
          ...widget.folder.recordings.map((r) => _buildRecordingItem(theme, r)),
          if (_selectedRecordingIds.isNotEmpty)
            Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: SizedBox(width: double.infinity, child: _isGeneratingSummary 
              ? FilledButton.icon(icon: const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)), label: const Text('正在生成...'), onPressed: null)
              : FilledButton.icon(icon: const Icon(Icons.summarize_outlined), label: Text('一键总结 (${_selectedRecordingIds.length}条)'), onPressed: _showSummaryDialogLocal))),
          const SizedBox(height: 24),
        ],
        if (widget.folder.summaries.isNotEmpty) ...[
          Padding(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8), child: Text('总结记录 (${widget.folder.summaries.length})', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))),
          ...widget.folder.summaries.reversed.map((s) => _buildSummaryCard(theme, s)),
        ],
        if (widget.folder.recordings.isEmpty && widget.folder.summaries.isEmpty)
          Center(child: Padding(padding: const EdgeInsets.all(48), child: Text('暂无录音和总结', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)))),
      ]),
    );
  }

  Widget _buildRecordingItem(ThemeData theme, InspirationRecording recording) {
    final isPlaying = _playingRecordingId == recording.id;
    final isSelected = _selectedRecordingIds.contains(recording.id);
    return Card(margin: const EdgeInsets.only(bottom: 8), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8), child: Row(children: [
      Checkbox(value: isSelected, onChanged: (v) { setState(() { if (v == true) _selectedRecordingIds.add(recording.id); else _selectedRecordingIds.remove(recording.id); }); }),
      IconButton(icon: Icon(isPlaying ? Icons.stop_circle : Icons.play_circle, size: 28, color: isPlaying ? Colors.red : theme.colorScheme.primary), onPressed: () { if (isPlaying) _stopPlayback(); else _playRecording(recording); }, padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 36, minHeight: 36)),
      const SizedBox(width: 4),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(recording.dateLabel, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)), Text(recording.durationLabel, style: theme.textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'))])),
      if (recording.isTranscribing) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
      else if (recording.transcription != null) TextButton(onPressed: () => _showTranscriptionSheet(recording), style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap), child: const Text('详细'))
      else TextButton(onPressed: () => _transcribeRecording(recording), style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap), child: const Text('转录')),
      IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red), onPressed: () => _deleteRecording(recording), padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 32, minHeight: 32)),
    ])));
  }

  Widget _buildSummaryCard(ThemeData theme, SummaryRecord record) {
    final isExpanded = _expandedSummaries[record.id] ?? false;
    final levelLabels = {'detailed': '详细', 'medium': '适中', 'simple': '简单'};
    final levelName = levelLabels[record.level] ?? record.level;
    final dateStr = '${record.createdAt.year}-${record.createdAt.month.toString().padLeft(2, '0')}-${record.createdAt.day.toString().padLeft(2, '0')} ${record.createdAt.hour.toString().padLeft(2, '0')}:${record.createdAt.minute.toString().padLeft(2, '0')}';
    final previewLines = record.summaryText.split('\n').take(2).join('\n');

    return Card(margin: const EdgeInsets.only(bottom: 8), clipBehavior: Clip.antiAlias, child: InkWell(
      onTap: () => setState(() { _expandedSummaries[record.id] = !isExpanded; }),
      child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.description_outlined, size: 18, color: Colors.blue), const SizedBox(width: 8),
          Expanded(child: Text('$levelName模式 · $dateStr', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600))),
          Icon(isExpanded ? Icons.expand_less : Icons.expand_more, size: 20),
        ]),
        const SizedBox(height: 8),
        if (!isExpanded) Text(previewLines, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium)
        else ...[
          SelectableText(record.summaryText, style: theme.textTheme.bodyMedium?.copyWith(height: 1.6)),
          if (record.mindMapData != null) ...[
            const SizedBox(height: 16), const Divider(), const SizedBox(height: 8),
            Text('思维导图', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(height: 300, child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: theme.dividerColor)), child: _buildMindMap(record.summaryText, record.mindMapData))),
          ],
        ],
        const SizedBox(height: 8),
        Row(children: [
          TextButton.icon(icon: const Icon(Icons.text_snippet_outlined, size: 16), label: const Text('导出文档', style: TextStyle(fontSize: 12)), onPressed: () => _exportAsMarkdown(record), style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap)),
          TextButton.icon(icon: const Icon(Icons.account_tree_outlined, size: 16), label: const Text('导出思维导图', style: TextStyle(fontSize: 12)), onPressed: () => _exportAsMindMap(record), style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap)),
          const Spacer(),
          IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red), onPressed: () => _deleteSummary(record), padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 32, minHeight: 32)),
        ]),
      ])),
    ));
  }
}
