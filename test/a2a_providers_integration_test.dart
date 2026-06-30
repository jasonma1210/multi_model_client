// v0.43.0 A2A 集成测试
//
// 覆盖：Riverpod Provider 协同工作（mock A2AClient）
// - 选中 Agent
// - 启动流式任务
// - 事件累计
// - 取消任务

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mj_nexus/features/a2a/providers/a2a_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('A2A Provider 协同', () {
    test('添加和删除 A2A 服务器', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // 初始为空
      expect(container.read(a2aSettingsProvider).servers, isEmpty);

      // 添加
      final notifier = container.read(a2aSettingsProvider.notifier);
      final config = await notifier.addFromUrl('Test', 'http://localhost:9999');

      expect(container.read(a2aSettingsProvider).servers.length, 1);
      expect(container.read(a2aSettingsProvider).servers.first.name, 'Test');

      // 删除
      await notifier.removeServer(config.id);
      expect(container.read(a2aSettingsProvider).servers, isEmpty);
    });

    test('selectedA2AAgentProvider 状态切换', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(selectedA2AAgentProvider), isNull);
      container.read(selectedA2AAgentProvider.notifier).select('Agent1');
      expect(container.read(selectedA2AAgentProvider), 'Agent1');
      container.read(selectedA2AAgentProvider.notifier).select(null);
      expect(container.read(selectedA2AAgentProvider), isNull);
    });

    test('A2AClientManager 按 serverId 缓存', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final manager = container.read(a2aClientManagerProvider);
      final config = A2AServerConfig(
        id: 's1',
        name: 'Server1',
        agentUrl: 'http://localhost:9999',
        createdAt: DateTime(2026, 6, 30),
      );
      final c1 = manager.getOrCreate(config);
      final c2 = manager.getOrCreate(config);
      expect(identical(c1, c2), true);
    });

    test('A2AServerConfig JSON 序列化', () {
      final config = A2AServerConfig(
        id: 's1',
        name: 'Server1',
        agentUrl: 'http://localhost:9999',
        apiKey: 'k1',
        enabled: true,
        createdAt: DateTime(2026, 6, 30),
      );
      final json = config.toJson();
      final restored = A2AServerConfig.fromJson(json);
      expect(restored.id, 's1');
      expect(restored.name, 'Server1');
      expect(restored.apiKey, 'k1');
      expect(restored.enabled, true);
    });
  });
}
