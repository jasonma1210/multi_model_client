import 'package:flutter_test/flutter_test.dart';
import 'package:mj_nexus/core/services/tts_service.dart';
import 'dart:typed_data';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('TTSService.splitIntoSentences', () {
    late TTSService ttsService;

    setUp(() {
      ttsService = TTSService();
    });

    test('中文标点分割', () {
      final text = '你好。今天天气不错！我们去散步吧？';
      final sentences = ttsService.splitIntoSentences(text);
      expect(sentences.length, 3);
      expect(sentences[0], '你好');
      expect(sentences[1], '今天天气不错');
      expect(sentences[2], '我们去散步吧');
    });

    test('英文标点不被分割（只支持中文标点）', () {
      // splitIntoSentences 只按中文标点  。！？；\n 分句
      final text = 'Hello. How are you? I\'m fine.';
      final sentences = ttsService.splitIntoSentences(text);
      expect(sentences.length, 1);
      expect(sentences[0], 'Hello. How are you? I\'m fine.');
    });

    test('空字符串返回空列表', () {
      final sentences = ttsService.splitIntoSentences('');
      expect(sentences, isEmpty);
    });

    test('无标点字符串返回1个元素的列表（如果长度>1）', () {
      final text = '这是一个没有标点的字符串';
      final sentences = ttsService.splitIntoSentences(text);
      expect(sentences.length, 1);
      expect(sentences[0], '这是一个没有标点的字符串');
    });

    test('仅空格返回空列表', () {
      final sentences = ttsService.splitIntoSentences('   ');
      expect(sentences, isEmpty);
    });

    test('混合中英文标点分割', () {
      final text = '第一行。第二行？第三行';
      final sentences = ttsService.splitIntoSentences(text);
      expect(sentences.length, 3);
      expect(sentences[0], '第一行');
      expect(sentences[1], '第二行');
      expect(sentences[2], '第三行');
    });
  });

  group('TTSService.cleanThinkTags', () {
    late TTSService ttsService;

    setUp(() {
      ttsService = TTSService();
    });

    test('单行think标签被删除', () {
      final text = '开头<think>思考内容</think>结尾';
      final result = ttsService.cleanThinkTags(text);
      expect(result, '开头结尾');
    });

    test('多行think标签被删除', () {
      final text = '开头<think>第一行\n第二行\n第三行</think>结尾';
      final result = ttsService.cleanThinkTags(text);
      expect(result, '开头结尾');
    });

    test('无think标签返回原文', () {
      final text = '没有任何标签的普通文本';
      final result = ttsService.cleanThinkTags(text);
      expect(result, text);
    });

    test('空字符串返回空字符串', () {
      final result = ttsService.cleanThinkTags('');
      expect(result, '');
    });

    test('多个think标签全部清除', () {
      final text = '开始<think>思考1</think>中间<think>思考2</think>结束';
      final result = ttsService.cleanThinkTags(text);
      expect(result, '开始中间结束');
    });

    test('未闭合的think标签保留原文', () {
      final text = '开头<think>未闭合的内容';
      final result = ttsService.cleanThinkTags(text);
      expect(result, text);
    });
  });

  group('TTSService.createWavFromSamples', () {
    late TTSService ttsService;

    setUp(() {
      ttsService = TTSService();
    });

    test('WAV头格式正确（前44字节RIFF头）', () {
      final samples = Float32List(100); // 静音
      final wavData = ttsService.createWavFromSamples(
        samples,
        sampleRate: 16000,
        bitsPerSample: 16,
        channels: 1,
      );

      // 验证前44字节是WAV头
      expect(wavData.length, greaterThanOrEqualTo(44));

      // RIFF标识
      expect(String.fromCharCodes(wavData.sublist(0, 4)), 'RIFF');
      // WAVE标识
      expect(String.fromCharCodes(wavData.sublist(8, 12)), 'WAVE');
      // fmt子块
      expect(String.fromCharCodes(wavData.sublist(12, 16)), 'fmt ');
      // data子块
      expect(String.fromCharCodes(wavData.sublist(36, 40)), 'data');
    });

    test('sampleRate/bitsPerSample/channels正确写入', () {
      final samples = Float32List(100);
      final wavData = ttsService.createWavFromSamples(
        samples,
        sampleRate: 16000,
        bitsPerSample: 16,
        channels: 1,
      );

      // 读取fmt子块中的参数
      final byteData = ByteData.sublistView(wavData);
      // channels (offset 22, 2 bytes)
      expect(byteData.getUint16(22, Endian.little), 1);
      // sampleRate (offset 24, 4 bytes)
      expect(byteData.getUint32(24, Endian.little), 16000);
      // bitsPerSample (offset 34, 2 bytes)
      expect(byteData.getUint16(34, Endian.little), 16);
    });

    test('音频数据正确编码为小端PCM', () {
      // 创建已知信号：满幅度的方波（+32767, -32768, +32767, -32768）
      final sampleData = [1.0, -1.0, 1.0, -1.0];
      final samples = Float32List.fromList(sampleData);
      final wavData = ttsService.createWavFromSamples(
        samples,
        sampleRate: 16000,
        bitsPerSample: 16,
        channels: 1,
      );

      // 验证PCM数据（44字节头之后）
      final byteData = ByteData.sublistView(wavData);
      // 第一个样本: 1.0 * 32767 = 32767
      expect(byteData.getInt16(44, Endian.little), 32767);
      // 第二个样本: -1.0 * 32767 = -32767
      expect(byteData.getInt16(46, Endian.little), -32767);
    });

    test('静音数据生成正确的WAV', () {
      final samples = Float32List(1000); // 全部为0
      final wavData = ttsService.createWavFromSamples(
        samples,
        sampleRate: 44100,
        bitsPerSample: 16,
        channels: 2,
      );

      // 验证通道数
      final byteData = ByteData.sublistView(wavData);
      expect(byteData.getUint16(22, Endian.little), 2);
      expect(byteData.getUint32(24, Endian.little), 44100);

      // 验证所有PCM数据为0
      for (int i = 44; i < wavData.length; i++) {
        expect(wavData[i], 0);
      }
    });
  });

  group('TTSService.int32ToBytes', () {
    late TTSService ttsService;

    setUp(() {
      ttsService = TTSService();
    });

    test('小端序编码验证', () {
      // 0x12345678 在小端序中为 [0x78, 0x56, 0x34, 0x12]
      final bytes = ttsService.int32ToBytes(0x12345678);
      expect(bytes, [0x78, 0x56, 0x34, 0x12]);
    });

    test('最小值边界', () {
      final bytes = ttsService.int32ToBytes(0);
      expect(bytes, [0, 0, 0, 0]);
    });

    test('最大值边界', () {
      final bytes = ttsService.int32ToBytes(0xFFFFFFFF);
      expect(bytes, [0xFF, 0xFF, 0xFF, 0xFF]);
    });

    test('单字节值', () {
      final bytes = ttsService.int32ToBytes(0x01);
      expect(bytes, [0x01, 0, 0, 0]);
    });
  });

  group('TTSService.int16ToBytes', () {
    late TTSService ttsService;

    setUp(() {
      ttsService = TTSService();
    });

    test('小端序编码验证', () {
      // 0x1234 在小端序中为 [0x34, 0x12]
      final bytes = ttsService.int16ToBytes(0x1234);
      expect(bytes, [0x34, 0x12]);
    });

    test('最小值边界', () {
      final bytes = ttsService.int16ToBytes(0);
      expect(bytes, [0, 0]);
    });

    test('最大值边界', () {
      final bytes = ttsService.int16ToBytes(0xFFFF);
      expect(bytes, [0xFF, 0xFF]);
    });

    test('单字节值', () {
      final bytes = ttsService.int16ToBytes(0x01);
      expect(bytes, [0x01, 0]);
    });
  });
}
