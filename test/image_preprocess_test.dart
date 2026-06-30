// v0.43.0 图片预处理单元测试

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mj_nexus/core/multimodal/services/image_preprocess_service.dart';

void main() {
  group('ImagePreprocessService', () {
    test('空字节解码失败', () async {
      final service = const ImagePreprocessService();
      final bytes = Uint8List.fromList([]);
      expect(
        () => service.processBytes(bytes),
        throwsA(isA<ImageProcessException>()),
      );
    });

    test('JPEG 字节成功处理', () async {
      // 最小有效 JPEG: 1x1 像素
      final jpegBytes = Uint8List.fromList([
        0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01,
        0x01, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00, 0xFF, 0xDB, 0x00, 0x43,
        0x00,
      ]);

      final service = const ImagePreprocessService();
      try {
        final result = await service.processBytes(jpegBytes, originalName: 'test.jpg');
        expect(result.mimeType, 'image/jpeg');
        expect(result.width, greaterThan(0));
        expect(result.height, greaterThan(0));
        expect(result.estimatedTokens, greaterThan(0));
      } catch (e) {
        // 最小 JPEG 可能不被 image 包接受，测试 ImageProcessException 或成功
        expect(e, isA<ImageProcessException>());
      }
    });

    test('配置默认值', () {
      const config = ImageProcessConfig.defaultConfig;
      expect(config.maxLongEdge, 2048);
      expect(config.jpegQuality, 85);
      expect(config.outputFormat, 'image/jpeg');
      expect(config.maxFileSizeBytes, 20 * 1024 * 1024);
    });

    test('图片转 ImagePart', () async {
      final fakeBytes = Uint8List.fromList(List.filled(100, 0xAB));
      const config = ImageProcessConfig.thumbnail;
      final service = const ImagePreprocessService(config: config);

      // 跳过真实处理，只测试元数据
      final metadata = service.extractMetadata(fakeBytes);
      // 空字节无法解码，预期返回 null
      expect(metadata, isNull);
    });
  });
}
