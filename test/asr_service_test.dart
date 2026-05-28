import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mj_nexus/core/services/asr_service.dart';

/// Helper: int32 小端序转 bytes
List<int> _int32Bytes(int value) {
  return [
    value & 0xFF,
    (value >> 8) & 0xFF,
    (value >> 16) & 0xFF,
    (value >> 24) & 0xFF,
  ];
}

/// Helper: int16 小端序转 bytes
List<int> _int16Bytes(int value) {
  return [
    value & 0xFF,
    (value >> 8) & 0xFF,
  ];
}

/// 生成 WAV 文件数据
List<int> _createPcmWavData({
  required int sampleRate,
  required int bitsPerSample,
  required int channels,
  required int durationSeconds,
}) {
  final bytesPerSample = bitsPerSample ~/ 8;
  final numSamples = sampleRate * durationSeconds;
  final dataSize = numSamples * bytesPerSample * channels;
  final fileSize = 36 + dataSize;

  final header = <int>[];
  header.addAll('RIFF'.codeUnits);
  header.addAll(_int32Bytes(fileSize));
  header.addAll('WAVE'.codeUnits);
  header.addAll('fmt '.codeUnits);
  header.addAll(_int32Bytes(16));
  header.addAll(_int16Bytes(1));
  header.addAll(_int16Bytes(channels));
  header.addAll(_int32Bytes(sampleRate));
  header.addAll(_int32Bytes(sampleRate * channels * bitsPerSample ~/ 8));
  header.addAll(_int16Bytes(channels * bitsPerSample ~/ 8));
  header.addAll(_int16Bytes(bitsPerSample));
  header.addAll('data'.codeUnits);
  header.addAll(_int32Bytes(dataSize));

  final data = <int>[];
  for (int i = 0; i < numSamples; i++) {
    final sampleValue = sin(i / sampleRate * 440 * 2 * pi) * 32767 * 0.3;
    final sample = sampleValue.toInt();
    if (bitsPerSample == 16) {
      data.addAll(_int16Bytes(sample));
    } else if (bitsPerSample == 32) {
      data.addAll(_int32Bytes(sample));
    } else if (bitsPerSample == 8) {
      data.add((sample ~/ 256 + 128).clamp(0, 255));
    }
  }
  return [...header, ...data];
}

/// 生成立体声 WAV 数据
List<int> _createStereoWavData() {
  const sampleRate = 16000;
  const durationSeconds = 1;
  final numSamples = sampleRate * durationSeconds;
  final dataSize = numSamples * 2 * 2;
  final fileSize = 36 + dataSize;

  final header = <int>[];
  header.addAll('RIFF'.codeUnits);
  header.addAll(_int32Bytes(fileSize));
  header.addAll('WAVE'.codeUnits);
  header.addAll('fmt '.codeUnits);
  header.addAll(_int32Bytes(16));
  header.addAll(_int16Bytes(1));
  header.addAll(_int16Bytes(2));
  header.addAll(_int32Bytes(sampleRate));
  header.addAll(_int32Bytes(sampleRate * 2 * 2));
  header.addAll(_int16Bytes(4));
  header.addAll(_int16Bytes(16));
  header.addAll('data'.codeUnits);
  header.addAll(_int32Bytes(dataSize));

  final data = <int>[];
  for (int i = 0; i < numSamples; i++) {
    final phase = i / sampleRate * 440 * 2 * pi;
    data.addAll(_int16Bytes((sin(phase) * 32767 * 0.3).toInt()));
    data.addAll(_int16Bytes((cos(phase) * 32767 * 0.3).toInt()));
  }
  return [...header, ...data];
}

/// 创建 8-bit WAV 数据
List<int> _createPcm8BitWavData() {
  const sampleRate = 16000;
  const durationSeconds = 1;
  final numSamples = sampleRate * durationSeconds;
  final dataSize = numSamples;
  final fileSize = 36 + dataSize;

  final header = <int>[];
  header.addAll('RIFF'.codeUnits);
  header.addAll(_int32Bytes(fileSize));
  header.addAll('WAVE'.codeUnits);
  header.addAll('fmt '.codeUnits);
  header.addAll(_int32Bytes(16));
  header.addAll(_int16Bytes(1));
  header.addAll(_int16Bytes(1));
  header.addAll(_int32Bytes(sampleRate));
  header.addAll(_int32Bytes(sampleRate));
  header.addAll(_int16Bytes(1));
  header.addAll(_int16Bytes(8));
  header.addAll('data'.codeUnits);
  header.addAll(_int32Bytes(dataSize));

  for (int i = 0; i < numSamples; i++) {
    header.add(((sin(i / sampleRate * 440 * 2 * pi) * 127 * 0.3).toInt() + 128).clamp(0, 255));
  }
  return header;
}

void main() {
  late ASRService asrService;

  setUp(() {
    asrService = ASRService();
  });

  group('ASRService.readWaveFile', () {
    test('正常WAV解析', () async {
      final wavData = _createPcmWavData(sampleRate: 16000, bitsPerSample: 16, channels: 1, durationSeconds: 1);
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/test_rw_${DateTime.now().millisecondsSinceEpoch}.wav');
      await tempFile.writeAsBytes(wavData);
      final result = await asrService.readWaveFile(tempFile.path);
      await tempFile.delete();
      expect(result, isNotNull);
      expect(result!.length, greaterThan(0));
    });

    test('无效文件（无RIFF头）返回null', () async {
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/test_inv_${DateTime.now().millisecondsSinceEpoch}.wav');
      await tempFile.writeAsBytes([0, 1, 2, 3, 4, 5]);
      final result = await asrService.readWaveFile(tempFile.path);
      await tempFile.delete();
      expect(result, isNull);
    });

    test('8-bit WAV正确处理', () async {
      final wavData = _createPcm8BitWavData();
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/test_8b_${DateTime.now().millisecondsSinceEpoch}.wav');
      await tempFile.writeAsBytes(wavData);
      final result = await asrService.readWaveFile(tempFile.path);
      await tempFile.delete();
      expect(result, isNotNull);
      expect(result!.length, greaterThan(0));
      for (final sample in result) {
        expect(sample, greaterThanOrEqualTo(-1.0));
        expect(sample, lessThanOrEqualTo(1.0));
      }
    });

    test('32-bit WAV正确处理', () async {
      final wavData = _createPcmWavData(sampleRate: 16000, bitsPerSample: 32, channels: 1, durationSeconds: 1);
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/test_32b_${DateTime.now().millisecondsSinceEpoch}.wav');
      await tempFile.writeAsBytes(wavData);
      final result = await asrService.readWaveFile(tempFile.path);
      await tempFile.delete();
      expect(result, isNotNull);
      expect(result!.length, greaterThan(0));
    });

    test('立体声WAV只取第一个通道', () async {
      final wavData = _createStereoWavData();
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/test_st_${DateTime.now().millisecondsSinceEpoch}.wav');
      await tempFile.writeAsBytes(wavData);
      final result = await asrService.readWaveFile(tempFile.path);
      await tempFile.delete();
      expect(result, isNotNull);
      expect(result!.length, 16000);
    });
  });

  group('ASRService.addWavHeader', () {
    test('生成44字节标准WAV头', () {
      final pcmData = List<int>.generate(32000, (i) => i % 256);
      final wavData = asrService.addWavHeader(pcmData);
      expect(wavData.length, 44 + pcmData.length);
    });

    test('RIFF/WAVE/fmt/data chunk标识正确', () {
      final wavData = asrService.addWavHeader(<int>[0, 0]);
      expect(String.fromCharCodes(wavData.sublist(0, 4)), 'RIFF');
      expect(String.fromCharCodes(wavData.sublist(8, 12)), 'WAVE');
      expect(String.fromCharCodes(wavData.sublist(12, 16)), 'fmt ');
      expect(String.fromCharCodes(wavData.sublist(36, 40)), 'data');
    });

    test('数据大小计算正确', () {
      final pcmData = List<int>.generate(32000, (i) => i % 256);
      final wavData = asrService.addWavHeader(pcmData);
      final byteData = ByteData.sublistView(Uint8List.fromList(wavData));
      expect(byteData.getUint32(4, Endian.little), 36 + pcmData.length);
      expect(byteData.getUint32(40, Endian.little), pcmData.length);
    });

    test('音频格式为PCM(1)且参数正确', () {
      final wavData = asrService.addWavHeader(<int>[0, 0]);
      final byteData = ByteData.sublistView(Uint8List.fromList(wavData));
      expect(byteData.getUint16(20, Endian.little), 1);
      expect(byteData.getUint16(22, Endian.little), 1);
      expect(byteData.getUint32(24, Endian.little), 16000);
      expect(byteData.getUint16(34, Endian.little), 16);
    });
  });

  group('ASRService.calculateEnergy', () {
    test('静音数据（全0）能量≈0', () {
      final chunk = Int16List(100);
      final bytes = Uint8List.view(chunk.buffer);
      expect(asrService.calculateEnergy(bytes.toList()), closeTo(0, 0.001));
    });

    test('正常音频数据计算正确的mean square', () {
      final samples = Int16List(100);
      for (int i = 0; i < 100; i++) {
        samples[i] = (sin(i / 100 * 2 * pi) * 10000).toInt();
      }
      final bytes = Uint8List.view(samples.buffer);
      final energy = asrService.calculateEnergy(bytes.toList());
      // 返回值为 mean-square / 32768.0
      expect(energy, greaterThan(1000));
      expect(energy, lessThan(2000));
    });

    test('满幅度信号值约为32767', () {
      final chunk = <int>[];
      for (int i = 0; i < 50; i++) {
        chunk.add(0xFF);
        chunk.add(0x7F);
      }
      expect(asrService.calculateEnergy(chunk), greaterThan(0.5));
    });
  });

  group('VADService', () {
    late VADService vadService;

    setUp(() {
      vadService = VADService();
    });

    group('detectSpeechEnd', () {
      test('静音数据返回true', () {
        expect(vadService.detectSpeechEnd(List<double>.filled(100, 0.0)), isTrue);
      });

      test('正常语音返回false', () {
        final audio = List<double>.generate(100, (i) => 0.5 * sin(i / 100 * 2 * pi));
        expect(vadService.detectSpeechEnd(audio), isFalse);
      });
    });

    group('calculateEnergy', () {
      test('静音数据能量为0', () {
        expect(vadService.calculateEnergy(List<double>.filled(100, 0.0)), closeTo(0.0, 0.001));
      });

      test('正常音频计算正确', () {
        expect(vadService.calculateEnergy(List<double>.filled(100, 0.5)), closeTo(0.25, 0.001));
      });

      test('满幅度信号能量为1.0', () {
        expect(vadService.calculateEnergy(List<double>.filled(100, 1.0)), closeTo(1.0, 0.001));
      });
    });
  });
}
