import 'package:flutter_test/flutter_test.dart';
import 'package:multi_model_client/core/services/embedding_service.dart';

void main() {
  group('EmbeddingService', () {
    late EmbeddingService service;

    setUp(() {
      service = EmbeddingService();
    });

    test('应正确初始化', () {
      expect(service, isNotNull);
    });

    test('余弦相似度计算应正确', () {
      // Arrange
      final vec1 = [1.0, 0.0, 0.0];
      final vec2 = [1.0, 0.0, 0.0];
      final vec3 = [0.0, 1.0, 0.0];
      final vec4 = [1.0, 1.0, 0.0];

      // Act & Assert
      // 相同向量相似度应为1
      expect(service.cosineSimilarity(vec1, vec2), closeTo(1.0, 0.001));

      // 正交向量相似度应为0
      expect(service.cosineSimilarity(vec1, vec3), closeTo(0.0, 0.001));

      // 45度角向量相似度应为√2/2
      expect(
        service.cosineSimilarity(vec1, vec4),
        closeTo(0.707, 0.01),
      );
    });

    test('向量JSON序列化应正确', () {
      // Arrange
      final vector = [1.0, 2.0, 3.0, 4.0, 5.0];

      // Act
      final json = service.vectorToJson(vector);
      final restored = service.jsonToVector(json);

      // Assert
      expect(restored, equals(vector));
    });

    test('应处理零向量', () {
      // Arrange
      final zeroVec = [0.0, 0.0, 0.0];
      final normalVec = [1.0, 0.0, 0.0];

      // Act & Assert
      // 零向量与任何向量的相似度应为0
      expect(
        service.cosineSimilarity(zeroVec, normalVec),
        equals(0.0),
      );
    });

    test('应处理不同维度的向量', () {
      // Arrange
      final vec1 = [1.0, 2.0, 3.0];
      final vec2 = [1.0, 2.0, 3.0, 4.0];

      // Act & Assert
      expect(
        () => service.cosineSimilarity(vec1, vec2),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
