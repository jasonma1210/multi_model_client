#!/usr/bin/env dart
// @dart=3.10
// ignore_for_file: avoid_print
// MJ Nexus 下载功能测试套件
// 运行方式: cd multi_model_client && dart test/scripts/download_test.dart

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// 下载任务状态
enum TestDownloadStatus {
  pending,
  downloading,
  paused,
  completed,
  error,
}

/// 下载测试器
class DownloadTester {
  final String downloadDir;
  final List<String> testResults = [];
  int _passedTests = 0;
  int _failedTests = 0;

  DownloadTester({required this.downloadDir});

  void _log(String message, {bool isError = false}) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    final prefix = isError ? '❌' : '✅';
    final logLine = '[$timestamp] $prefix $message';
    print(logLine);
    testResults.add(logLine);
    if (isError) {
      _failedTests++;
    } else {
      _passedTests++;
    }
  }

  void _info(String message) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    print('[$timestamp] ℹ️  $message');
  }

  /// 测试1: 测试文件写入
  Future<bool> testFileWrite() async {
    _info('=== 测试1: 文件写入测试 ===');
    try {
      final testFile = File('$downloadDir/test_write.bin');
      final testData = List.generate(1024 * 100, (i) => i % 256); // 100KB 测试数据
      
      await testFile.writeAsBytes(testData);
      final exists = await testFile.exists();
      
      if (exists) {
        final length = await testFile.length();
        if (length == testData.length) {
          _log('文件写入测试通过: ${testFile.path} ($length bytes)');
          await testFile.delete();
          return true;
        } else {
          _log('文件大小不匹配: 预期 ${testData.length}, 实际 $length', isError: true);
          return false;
        }
      } else {
        _log('文件不存在', isError: true);
        return false;
      }
    } catch (e) {
      _log('文件写入失败: $e', isError: true);
      return false;
    }
  }

  /// 测试2: 测试 SHA256 哈希计算
  Future<bool> testSHA256Calculation() async {
    _info('=== 测试2: SHA256 哈希计算测试 ===');
    try {
      final testFile = File('$downloadDir/test_hash.bin');
      final testData = 'Hello, World! This is a test.'.codeUnits;
      
      await testFile.writeAsBytes(testData);
      
      // 计算 SHA256
      final fileBytes = await testFile.readAsBytes();
      final hash = sha256.convert(fileBytes).toString();
      
      // 验证
      final expectedHash = sha256.convert(testData).toString();
      
      if (hash == expectedHash) {
        _log('SHA256 计算正确: $hash');
        await testFile.delete();
        return true;
      } else {
        _log('SHA256 不匹配: 预期 $expectedHash, 实际 $hash', isError: true);
        return false;
      }
    } catch (e) {
      _log('SHA256 计算失败: $e', isError: true);
      return false;
    }
  }

  /// 测试3: 测试大文件哈希（模拟模型文件）
  Future<bool> testLargeFileHash() async {
    _info('=== 测试3: 大文件 SHA256 哈希测试 (10MB) ===');
    try {
      final testFile = File('$downloadDir/test_large.bin');
      final fileSize = 10 * 1024 * 1024; // 10MB
      final random = Random(42); // 固定种子，确保可重复
      
      _info('生成测试文件...');
      final sink = testFile.openWrite();
      var written = 0;
      while (written < fileSize) {
        final chunk = List.generate(min(65536, fileSize - written), (_) => random.nextInt(256));
        sink.add(chunk);
        written += chunk.length;
      }
      await sink.close();
      
      _info('计算 SHA256...');
      final hash = await _calculateFileHash(testFile.path);
      
      _info('SHA256: $hash');
      
      if (hash.length == 64) {
        _log('大文件哈希计算成功: ${testFile.path} (${(fileSize / 1024 / 1024).toStringAsFixed(1)} MB)');
        await testFile.delete();
        return true;
      } else {
        _log('哈希格式错误: $hash', isError: true);
        return false;
      }
    } catch (e) {
      _log('大文件哈希失败: $e', isError: true);
      return false;
    }
  }

  /// 测试4: 模拟下载流程（暂停/继续）
  Future<bool> testDownloadPauseResume() async {
    _info('=== 测试4: 下载暂停/继续测试 ===');
    try {
      final testFile = File('$downloadDir/test_pause_resume.bin');
      final totalSize = 5 * 1024 * 1024; // 5MB
      final chunkSize = 64 * 1024; // 64KB chunks
      var downloaded = 0;
      var isPaused = false;
      final progressUpdates = <double>[];
      
      // 模拟下载
      _info('开始模拟下载...');
      while (downloaded < totalSize) {
        if (isPaused) {
          // 模拟暂停
          await Future.delayed(const Duration(milliseconds: 50));
          isPaused = false;
          _info('下载已暂停 (${(downloaded / totalSize * 100).toStringAsFixed(1)}%)');
          continue;
        }
        
        // 写入数据块
        final chunk = List.generate(min(chunkSize, totalSize - downloaded), (i) => i % 256);
        await testFile.writeAsBytes(chunk, mode: FileMode.append);
        downloaded += chunk.length;
        
        final progress = downloaded / totalSize;
        progressUpdates.add(progress);
        
        // 模拟网络延迟
        await Future.delayed(const Duration(milliseconds: 10));
        
        // 在 30% 处暂停
        if (progress > 0.3 && progress < 0.32) {
          isPaused = true;
        }
      }
      
      // 验证
      final finalSize = await testFile.length();
      if (finalSize == totalSize) {
        _log('暂停/继续测试通过: 完整下载 ${(finalSize / 1024 / 1024).toStringAsFixed(1)} MB');
        _info('进度更新次数: ${progressUpdates.length}');
        await testFile.delete();
        return true;
      } else {
        _log('文件大小不匹配: 预期 $totalSize, 实际 $finalSize', isError: true);
        return false;
      }
    } catch (e) {
      _log('暂停/继续测试失败: $e', isError: true);
      return false;
    }
  }

  /// 测试5: 测试断点续传
  Future<bool> testResumeDownload() async {
    _info('=== 测试5: 断点续传测试 ===');
    try {
      final testFile = File('$downloadDir/test_resume.bin');
      final totalSize = 3 * 1024 * 1024; // 3MB
      final chunkSize = 64 * 1024;
      var downloaded = 0;
      
      // 第一阶段：下载 50%
      _info('第一阶段：下载前 50%...');
      final firstPhase = totalSize ~/ 2;
      while (downloaded < firstPhase) {
        final chunk = List.generate(min(chunkSize, firstPhase - downloaded), (i) => i % 256);
        await testFile.writeAsBytes(chunk, mode: FileMode.append);
        downloaded += chunk.length;
      }
      
      final sizeAfterFirstPhase = await testFile.length();
      _info('第一阶段完成: ${(sizeAfterFirstPhase / 1024 / 1024).toStringAsFixed(2)} MB');
      
      // 模拟暂停，然后恢复
      _info('模拟暂停...');
      await Future.delayed(const Duration(milliseconds: 100));
      
      // 第二阶段：从断点继续
      _info('第二阶段：从断点继续...');
      while (downloaded < totalSize) {
        final chunk = List.generate(min(chunkSize, totalSize - downloaded), (i) => i % 256);
        await testFile.writeAsBytes(chunk, mode: FileMode.append);
        downloaded += chunk.length;
      }
      
      // 验证
      final finalSize = await testFile.length();
      if (finalSize == totalSize) {
        _log('断点续传测试通过: 从 ${(sizeAfterFirstPhase / 1024 / 1024).toStringAsFixed(2)} MB 继续到完整 ${(finalSize / 1024 / 1024).toStringAsFixed(2)} MB');
        await testFile.delete();
        return true;
      } else {
        _log('文件大小不匹配', isError: true);
        return false;
      }
    } catch (e) {
      _log('断点续传测试失败: $e', isError: true);
      return false;
    }
  }

  /// 测试6: 测试文件完整性校验
  Future<bool> testFileIntegrity() async {
    _info('=== 测试6: 文件完整性校验测试 ===');
    try {
      final testFile = File('$downloadDir/test_integrity.bin');
      final testData = 'Test data for integrity check. ' * 1000;
      final expectedHash = sha256.convert(testData.codeUnits).toString();
      
      // 写入测试数据
      await testFile.writeAsString(testData);
      
      // 验证
      final actualHash = await _calculateFileHash(testFile.path);
      
      if (actualHash == expectedHash) {
        _log('文件完整性校验通过');
        _info('Hash: $actualHash');
        await testFile.delete();
        return true;
      } else {
        _log('完整性校验失败: 预期 $expectedHash, 实际 $actualHash', isError: true);
        return false;
      }
    } catch (e) {
      _log('完整性校验失败: $e', isError: true);
      return false;
    }
  }

  /// 测试7: 测试文件删除
  Future<bool> testFileDelete() async {
    _info('=== 测试7: 文件删除测试 ===');
    try {
      final testFile = File('$downloadDir/test_delete.bin');
      await testFile.writeAsBytes([1, 2, 3, 4, 5]);
      
      if (await testFile.exists()) {
        await testFile.delete();
        if (await testFile.exists()) {
          _log('文件删除失败：文件仍存在', isError: true);
          return false;
        } else {
          _log('文件删除成功');
          return true;
        }
      } else {
        _log('文件不存在，无法测试删除', isError: true);
        return false;
      }
    } catch (e) {
      _log('文件删除失败: $e', isError: true);
      return false;
    }
  }

  /// 测试8: 测试目录创建
  Future<bool> testDirectoryCreation() async {
    _info('=== 测试8: 目录创建测试 ===');
    try {
      final testDir = Directory('$downloadDir/test_subdir/nested');
      await testDir.create(recursive: true);
      
      if (await testDir.exists()) {
        _log('嵌套目录创建成功: ${testDir.path}');
        await testDir.delete(recursive: true);
        return true;
      } else {
        _log('目录创建失败', isError: true);
        return false;
      }
    } catch (e) {
      _log('目录创建失败: $e', isError: true);
      return false;
    }
  }

  /// 测试9: 测试文件列表
  Future<bool> testFileList() async {
    _info('=== 测试9: 文件列表测试 ===');
    try {
      // 创建测试文件
      for (var i = 1; i <= 3; i++) {
        final file = File('$downloadDir/test_list_$i.txt');
        await file.writeAsString('Test $i');
      }
      
      // 列出文件
      final dir = Directory(downloadDir);
      final files = await dir
          .list()
          .where((entity) => entity is File && entity.path.contains('test_list_'))
          .toList();
      
      if (files.length == 3) {
        _log('文件列表测试通过: 找到 ${files.length} 个文件');
        
        // 清理
        for (final file in files) {
          await file.delete();
        }
        return true;
      } else {
        _log('文件列表数量错误: 预期 3, 实际 ${files.length}', isError: true);
        return false;
      }
    } catch (e) {
      _log('文件列表测试失败: $e', isError: true);
      return false;
    }
  }

  /// 测试10: 测试网络下载（使用 httpbin.org 测试小文件）
  Future<bool> testNetworkDownload() async {
    _info('=== 测试10: 网络下载测试 ===');
    try {
      final testFile = File('$downloadDir/test_network.bin');
      final url = 'https://httpbin.org/bytes/102400'; // 100KB
      
      _info('下载测试: $url');
      
      final httpClient = HttpClient();
      final request = await httpClient.getUrl(Uri.parse(url));
      final response = await request.close();
      
      if (response.statusCode == 200) {
        final sink = testFile.openWrite();
        await for (final chunk in response) {
          sink.add(chunk);
        }
        await sink.close();
        
        final size = await testFile.length();
        if (size == 102400) {
          _log('网络下载测试通过: ${(size / 1024).toStringAsFixed(1)} KB');
          await testFile.delete();
          return true;
        } else {
          _log('文件大小不匹配: 预期 102400, 实际 $size', isError: true);
          return false;
        }
      } else {
        _log('HTTP 错误: ${response.statusCode}', isError: true);
        return false;
      }
    } catch (e) {
      _log('网络下载失败: $e', isError: true);
      return false;
    }
  }

  /// 计算文件 SHA256 哈希
  Future<String> _calculateFileHash(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    return sha256.convert(bytes).toString();
  }

  /// 运行所有测试
  Future<void> runAllTests() async {
    print('\n');
    print('═══════════════════════════════════════════════════════');
    print('           MJ Nexus 下载功能测试套件');
    print('═══════════════════════════════════════════════════════');
    print('\n测试目录: $downloadDir\n');

    // 确保测试目录存在
    final dir = Directory(downloadDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    // 运行测试
    await testFileWrite();
    print('');
    await testSHA256Calculation();
    print('');
    await testLargeFileHash();
    print('');
    await testDownloadPauseResume();
    print('');
    await testResumeDownload();
    print('');
    await testFileIntegrity();
    print('');
    await testFileDelete();
    print('');
    await testDirectoryCreation();
    print('');
    await testFileList();
    print('');
    await testNetworkDownload();

    // 打印结果
    print('\n═══════════════════════════════════════════════════════');
    print('                    测试结果汇总');
    print('═══════════════════════════════════════════════════════');
    print('通过: $_passedTests');
    print('失败: $_failedTests');
    print('总计: ${_passedTests + _failedTests}');
    print('成功率: ${(_passedTests / (_passedTests + _failedTests) * 100).toStringAsFixed(1)}%');
    print('═══════════════════════════════════════════════════════\n');

    // 保存测试报告
    final reportFile = File('$downloadDir/test_report.txt');
    await reportFile.writeAsString(testResults.join('\n'));
    _info('测试报告已保存: ${reportFile.path}');

    // 清理测试文件
    _info('清理测试文件...');
    await for (final entity in dir.list()) {
      if (entity is File) {
        await entity.delete();
      }
    }
  }
}

/// 主函数
Future<void> main() async {
  final homeDir = Platform.environment['HOME'] ?? '/tmp';
  final downloadDir = '$homeDir/Downloads/mj_nexus_test';
  
  final tester = DownloadTester(downloadDir: downloadDir);
  await tester.runAllTests();
}
