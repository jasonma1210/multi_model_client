/// 思考预算 Riverpod Provider
///
/// v0.42.0 新增：管理模型的思考预算配置状态。
library;

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/thinking_config.dart';
import '../../../core/storage/database.dart';

/// AppDatabase Provider（必须在 main.dart 中 override）
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('appDatabaseProvider 必须在 main.dart 中重写');
});

/// 思考预算状态
class ThinkingBudgetState {
  final ThinkingConfig config;
  final bool isLoading;
  final String? error;

  const ThinkingBudgetState({
    required this.config,
    this.isLoading = false,
    this.error,
  });

  ThinkingBudgetState copyWith({
    ThinkingConfig? config,
    bool? isLoading,
    String? error,
  }) {
    return ThinkingBudgetState(
      config: config ?? this.config,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 思考预算控制器
class ThinkingBudgetController extends StateNotifier<ThinkingBudgetState> {
  final String modelConfigId;
  final AppDatabase _db;

  ThinkingBudgetController({
    required this.modelConfigId,
    required AppDatabase db,
  })  : _db = db,
        super(const ThinkingBudgetState(config: ThinkingConfig.adaptive)) {
    _load();
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final model = await _db.getModelById(modelConfigId);
      if (model != null) {
        final config = ThinkingConfig.fromString(
          model.thinkingMode,
          budgetTokens: model.thinkingBudget,
        );
        state = ThinkingBudgetState(config: config);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// 更新模式
  Future<void> updateMode(ThinkingMode mode) async {
    final newConfig = state.config.copyWith(mode: mode);
    final error = newConfig.validate();
    if (error != null) {
      state = state.copyWith(error: error);
      return;
    }

    state = state.copyWith(config: newConfig, isLoading: true, error: null);
    try {
      await _db.updateModel(ModelsCompanion(
        id: Value(modelConfigId),
        thinkingMode: Value(mode.name),
        thinkingBudget: Value(
          mode == ThinkingMode.enabled
              ? (state.config.budgetTokens ?? 10000)
              : null,
        ),
      ));
      state = state.copyWith(config: newConfig, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// 更新预算
  Future<void> updateBudget(int tokens) async {
    final capability = ThinkingCapability.fromModelId(modelConfigId);
    final clamped = tokens.clamp(capability.minBudget, capability.maxBudget);
    final newConfig = ThinkingConfig(
      mode: ThinkingMode.enabled,
      budgetTokens: clamped,
      showThinkingProcess: state.config.showThinkingProcess,
    );

    state = state.copyWith(config: newConfig, isLoading: true, error: null);
    try {
      await _db.updateModel(ModelsCompanion(
        id: Value(modelConfigId),
        thinkingMode: Value(ThinkingMode.enabled.name),
        thinkingBudget: Value(clamped),
      ));
      state = state.copyWith(config: newConfig, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// 切换思考过程显示
  Future<void> toggleShowProcess(bool show) async {
    final newConfig = state.config.copyWith(showThinkingProcess: show);
    state = state.copyWith(config: newConfig, isLoading: true);
    try {
      await _db.updateModel(ModelsCompanion(
        id: Value(modelConfigId),
        thinkingMode: Value(state.config.mode.name),
        thinkingBudget: Value(state.config.budgetTokens),
      ));
      state = state.copyWith(config: newConfig, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

/// 思考预算 Provider（按模型 ID 隔离）
final thinkingBudgetProvider = StateNotifierProvider.family<
    ThinkingBudgetController, ThinkingBudgetState, String>((ref, modelId) {
  final db = ref.watch(appDatabaseProvider);
  return ThinkingBudgetController(modelConfigId: modelId, db: db);
});

/// 当前选中模型的能力（从 modelId 推断）
final thinkingCapabilityProvider =
    Provider.family<ThinkingCapability, String>((ref, modelId) {
  return ThinkingCapability.fromModelId(modelId);
});
