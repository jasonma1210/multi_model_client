/// 音视频引擎 - LLM Studio 多媒体处理模块
/// 
/// 功能：
/// - 音频录制与播放
/// - 视频捕获与处理
/// - 原生平台 MethodChannel 集成
/// - 多媒体流管理
/// 
/// @author JianMa
/// @version 1.0.0
library;

import 'package:flutter/services.dart';

/// 音视频引擎
class AudioVideoEngine {
  static const MethodChannel _audioChannel = MethodChannel('com.multimodel.client/audio');
  static const MethodChannel _videoChannel = MethodChannel('com.multimodel.client/video');

  // Audio Methods
  static Future<bool> startAudioRecording() async {
    try {
      final bool started = await _audioChannel.invokeMethod('startRecording');
      return started;
    } on PlatformException catch (e) {
      throw AudioException('Failed to start audio recording: ${e.message}');
    }
  }

  static Future<void> stopAudioRecording() async {
    try {
      await _audioChannel.invokeMethod('stopRecording');
    } on PlatformException catch (e) {
      throw AudioException('Failed to stop audio recording: ${e.message}');
    }
  }

  static Future<List<double>> getAudioSamples() async {
    try {
      final List<dynamic> samples = await _audioChannel.invokeMethod('getAudioSamples');
      return samples.cast<double>();
    } on PlatformException catch (e) {
      throw AudioException('Failed to get audio samples: ${e.message}');
    }
  }

  static Future<void> playAudio(String filePath) async {
    try {
      await _audioChannel.invokeMethod('playAudio', {'filePath': filePath});
    } on PlatformException catch (e) {
      throw AudioException('Failed to play audio: ${e.message}');
    }
  }

  static Future<void> stopAudioPlayback() async {
    try {
      await _audioChannel.invokeMethod('stopPlayback');
    } on PlatformException catch (e) {
      throw AudioException('Failed to stop audio playback: ${e.message}');
    }
  }

  // Audio Processing
  static Future<List<double>> applyNoiseReduction(List<double> samples) async {
    try {
      final result = await _audioChannel.invokeMethod('applyNoiseReduction', {
        'samples': samples,
      });
      return (result as List).cast<double>();
    } on PlatformException catch (e) {
      throw AudioException('Failed to apply noise reduction: ${e.message}');
    }
  }

  static Future<List<double>> applyEchoCancellation(List<double> samples) async {
    try {
      final result = await _audioChannel.invokeMethod('applyEchoCancellation', {
        'samples': samples,
      });
      return (result as List).cast<double>();
    } on PlatformException catch (e) {
      throw AudioException('Failed to apply echo cancellation: ${e.message}');
    }
  }

  // Video Methods
  static Future<bool> startCameraPreview() async {
    try {
      final bool started = await _videoChannel.invokeMethod('startPreview');
      return started;
    } on PlatformException catch (e) {
      throw VideoException('Failed to start camera preview: ${e.message}');
    }
  }

  static Future<void> stopCameraPreview() async {
    try {
      await _videoChannel.invokeMethod('stopPreview');
    } on PlatformException catch (e) {
      throw VideoException('Failed to stop camera preview: ${e.message}');
    }
  }

  static Future<String?> captureFrame() async {
    try {
      final String? path = await _videoChannel.invokeMethod('captureFrame');
      return path;
    } on PlatformException catch (e) {
      throw VideoException('Failed to capture frame: ${e.message}');
    }
  }

  static Future<List<String>> extractKeyFrames(String videoPath, {int maxFrames = 10}) async {
    try {
      final List<dynamic> frames = await _videoChannel.invokeMethod('extractKeyFrames', {
        'videoPath': videoPath,
        'maxFrames': maxFrames,
      });
      return frames.cast<String>();
    } on PlatformException catch (e) {
      throw VideoException('Failed to extract key frames: ${e.message}');
    }
  }

  static Future<String?> recordVideo({Duration maxDuration = const Duration(seconds: 30)}) async {
    try {
      final String? path = await _videoChannel.invokeMethod('recordVideo', {
        'maxDurationMs': maxDuration.inMilliseconds,
      });
      return path;
    } on PlatformException catch (e) {
      throw VideoException('Failed to record video: ${e.message}');
    }
  }

  static Future<void> stopVideoRecording() async {
    try {
      await _videoChannel.invokeMethod('stopRecording');
    } on PlatformException catch (e) {
      throw VideoException('Failed to stop video recording: ${e.message}');
    }
  }

  // Camera Info
  static Future<List<CameraInfo>> getAvailableCameras() async {
    try {
      final List<dynamic> cameras = await _videoChannel.invokeMethod('getAvailableCameras');
      return cameras
          .map((cam) => CameraInfo.fromMap(cam as Map<String, dynamic>))
          .toList();
    } on PlatformException catch (e) {
      throw VideoException('Failed to get available cameras: ${e.message}');
    }
  }

  static Future<void> switchCamera(String cameraId) async {
    try {
      await _videoChannel.invokeMethod('switchCamera', {'cameraId': cameraId});
    } on PlatformException catch (e) {
      throw VideoException('Failed to switch camera: ${e.message}');
    }
  }
}

class CameraInfo {
  final String id;
  final String name;
  final CameraDirection direction;

  const CameraInfo({
    required this.id,
    required this.name,
    required this.direction,
  });

  factory CameraInfo.fromMap(Map<String, dynamic> map) {
    return CameraInfo(
      id: map['id'] as String,
      name: map['name'] as String,
      direction: CameraDirection.values.firstWhere(
        (d) => d.name == map['direction'],
        orElse: () => CameraDirection.back,
      ),
    );
  }
}

enum CameraDirection {
  front,
  back,
  external,
}

class AudioException implements Exception {
  final String message;
  AudioException(this.message);

  @override
  String toString() => 'AudioException: $message';
}

class VideoException implements Exception {
  final String message;
  VideoException(this.message);

  @override
  String toString() => 'VideoException: $message';
}
