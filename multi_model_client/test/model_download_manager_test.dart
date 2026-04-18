import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:multi_model_client/core/services/model_download_manager.dart';
import 'package:multi_model_client/core/services/hardware_compatibility_checker.dart';

// Mock classes
class MockDio extends Mock implements Dio {}

class MockHardwareChecker extends Mock implements HardwareCompatibilityChecker {}

void main() {
  group('ModelDownloadManager', () {
    late ModelDownloadManager manager;
    late MockDio mockDio;
    late MockHardwareChecker mockHardwareChecker;

    setUp(() {
      mockDio = MockDio();
      mockHardwareChecker = MockHardwareChecker();
      manager = ModelDownloadManager(
        dio: mockDio,
        hardwareChecker: mockHardwareChecker,
        downloadDir: '/tmp/test_models',
      );
    });

    tearDown(() {
      manager.dispose();
    });

    group('searchHuggingFace', () {
      test('should return list of models on successful search', () async {
        // Arrange
        final responseData = [
          {
            'id': 'meta-llama/Llama-2-7b-chat-hf',
            'modelId': 'meta-llama/Llama-2-7b-chat-hf',
            'author': 'meta-llama',
            'downloads': 1000000,
            'likes': 5000,
            'tags': ['7b', 'chat', 'llama-2'],
            'description': 'Llama 2 7B Chat model',
          },
        ];

        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => Response(
              data: responseData,
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        // Act
        final models = await manager.searchHuggingFace('llama');

        // Assert
        expect(models.length, equals(1));
        expect(models.first.id, equals('meta-llama/Llama-2-7b-chat-hf'));
        expect(models.first.name, equals('meta-llama/Llama-2-7b-chat-hf'));
        expect(models.first.source, equals(ModelSource.huggingFace));
        expect(models.first.downloads, equals(1000000));

        verify(() => mockDio.get(
              'https://huggingface.co/api/models',
              queryParameters: any(named: 'queryParameters'),
            )).called(1);
      });

      test('should return empty list on network error', () async {
        // Arrange
        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenThrow(DioException(
              requestOptions: RequestOptions(path: ''),
              type: DioExceptionType.connectionError,
            ));

        // Act
        final models = await manager.searchHuggingFace('llama');

        // Assert
        expect(models, isEmpty);
      });

      test('should parse model metadata correctly', () async {
        // Arrange
        final responseData = [
          {
            'id': 'test/model-7b-gguf',
            'modelId': 'test/model-7b-gguf',
            'tags': ['7b', 'gguf', 'quantized'],
          },
        ];

        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => Response(
              data: responseData,
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        // Act
        final models = await manager.searchHuggingFace('test');

        // Assert
        expect(models.first.parameterSize, equals(7));
        expect(models.first.isQuantized, isTrue);
        expect(models.first.quantizationMethod, equals('GGUF'));
      });
    });

    group('searchModelScope', () {
      test('should return list of models on successful search', () async {
        // Arrange
        final responseData = {
          'Data': {
            'Models': [
              {
                'id': 'qwen/Qwen-7B-Chat',
                'model_id': 'qwen/Qwen-7B-Chat',
                'name': 'Qwen 7B Chat',
                'owner': 'qwen',
                'download_count': 500000,
                'stars': 3000,
                'tags': ['7b', 'chat'],
                'description': 'Qwen 7B Chat model',
              },
            ],
          },
        };

        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => Response(
              data: responseData,
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        // Act
        final models = await manager.searchModelScope('qwen');

        // Assert
        expect(models.length, equals(1));
        expect(models.first.id, equals('qwen/Qwen-7B-Chat'));
        expect(models.first.name, equals('Qwen 7B Chat'));
        expect(models.first.source, equals(ModelSource.modelScope));
      });

      test('should handle empty response', () async {
        // Arrange
        final responseData = {'Data': {'Models': []}};

        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => Response(
              data: responseData,
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        // Act
        final models = await manager.searchModelScope('test');

        // Assert
        expect(models, isEmpty);
      });
    });

    group('checkCompatibility', () {
      test('should return compatible result when hardware meets requirements', () async {
        // Arrange
        final model = ModelInfo(
          id: 'test/model',
          name: 'Test Model',
          description: 'Test',
          author: 'test',
          source: ModelSource.huggingFace,
          downloadUrl: 'https://example.com/model.gguf',
          minRamGB: 8,
          minStorageGB: 10,
        );

        when(() => mockHardwareChecker.checkModelCompatibility(
              minRamGB: any(named: 'minRamGB'),
              minStorageGB: any(named: 'minStorageGB'),
              requiredFeatures: any(named: 'requiredFeatures'),
            )).thenAnswer((_) async => CompatibilityResult(
              isCompatible: true,
              reasons: [],
              warnings: [],
            ));

        // Act
        final result = await manager.checkCompatibility(model);

        // Assert
        expect(result.isCompatible, isTrue);
        expect(result.reasons, isEmpty);
      });

      test('should return incompatible result when hardware insufficient', () async {
        // Arrange
        final model = ModelInfo(
          id: 'test/model',
          name: 'Test Model',
          description: 'Test',
          author: 'test',
          source: ModelSource.huggingFace,
          downloadUrl: 'https://example.com/model.gguf',
          minRamGB: 16,
          minStorageGB: 20,
        );

        when(() => mockHardwareChecker.checkModelCompatibility(
              minRamGB: any(named: 'minRamGB'),
              minStorageGB: any(named: 'minStorageGB'),
              requiredFeatures: any(named: 'requiredFeatures'),
            )).thenAnswer((_) async => CompatibilityResult(
              isCompatible: false,
              reasons: ['内存不足: 需要16GB，可用8GB'],
              warnings: [],
            ));

        // Act
        final result = await manager.checkCompatibility(model);

        // Assert
        expect(result.isCompatible, isFalse);
        expect(result.reasons, contains('内存不足: 需要16GB，可用8GB'));
      });
    });

    group('downloadModel', () {
      test('should cancel download when compatibility check fails', () async {
        // Arrange
        final model = ModelInfo(
          id: 'test/model',
          name: 'Test Model',
          description: 'Test',
          author: 'test',
          source: ModelSource.huggingFace,
          downloadUrl: 'https://example.com/model.gguf',
          minRamGB: 16,
        );

        when(() => mockHardwareChecker.checkModelCompatibility(
              minRamGB: any(named: 'minRamGB'),
              minStorageGB: any(named: 'minStorageGB'),
              requiredFeatures: any(named: 'requiredFeatures'),
            )).thenAnswer((_) async => CompatibilityResult(
              isCompatible: false,
              reasons: ['硬件不兼容'],
            ));

        // Act
        final success = await manager.downloadModel(model);

        // Assert
        expect(success, isFalse);
        verifyNever(() => mockDio.download(any(), any(), onReceiveProgress: any(named: 'onReceiveProgress')));
      });

      test('should track download progress', () async {
        // Arrange
        final model = ModelInfo(
          id: 'test/model',
          name: 'Test Model',
          description: 'Test',
          author: 'test',
          source: ModelSource.huggingFace,
          downloadUrl: 'https://example.com/model.gguf',
          minRamGB: 4,
          minStorageGB: 2,
        );

        when(() => mockHardwareChecker.checkModelCompatibility(
              minRamGB: any(named: 'minRamGB'),
              minStorageGB: any(named: 'minStorageGB'),
              requiredFeatures: any(named: 'requiredFeatures'),
            )).thenAnswer((_) async => CompatibilityResult(isCompatible: true));

        when(() => mockHardwareChecker.hasEnoughStorage(any()))
            .thenAnswer((_) async => true);

        when(() => mockDio.download(
              any(),
              any(),
              cancelToken: any(named: 'cancelToken'),
              onReceiveProgress: any(named: 'onReceiveProgress'),
            )).thenAnswer((invocation) async {
              final onProgress = invocation.namedArguments[#onReceiveProgress] as void Function(int, int)?;
              if (onProgress != null) {
                onProgress(50, 100);
                onProgress(100, 100);
              }
              return Response(
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              );
            });

        final progressList = <DownloadProgress>[];

        // Act
        await manager.downloadModel(model, onProgress: progressList.add);

        // Assert
        expect(progressList.length, greaterThan(0));
        expect(progressList.last.status, equals('completed'));
      });
    });

    group('cancelDownload', () {
      test('should cancel ongoing download', () async {
        // Arrange
        final model = ModelInfo(
          id: 'test/model',
          name: 'Test Model',
          description: 'Test',
          author: 'test',
          source: ModelSource.huggingFace,
          downloadUrl: 'https://example.com/model.gguf',
          minRamGB: 4,
        );

        when(() => mockHardwareChecker.checkModelCompatibility(
              minRamGB: any(named: 'minRamGB'),
              minStorageGB: any(named: 'minStorageGB'),
              requiredFeatures: any(named: 'requiredFeatures'),
            )).thenAnswer((_) async => CompatibilityResult(isCompatible: true));

        when(() => mockHardwareChecker.hasEnoughStorage(any()))
            .thenAnswer((_) async => true);

        // Act
        manager.cancelDownload(model.id);

        // Assert - progress should be removed
        expect(manager.getDownloadProgress(model.id), isNull);
      });
    });
  });
}
