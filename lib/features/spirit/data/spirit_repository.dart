/// 名灵回响 - 持久化存储仓库
///
/// 使用 SharedPreferences 存储 SpiritPersona 列表
/// 支持增删改查及状态更新
///
/// @author JianMa
/// @version 1.0.0
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/spirit_persona.dart';

/// 名灵仓库
class SpiritRepository {
  static const String _tag = 'SpiritRepository';
  static const String _personasKey = 'spirit_personas';

  /// 缓存
  List<SpiritPersona>? _cachedPersonas;

  /// 获取所有名灵角色
  Future<List<SpiritPersona>> getAllPersonas() async {
    if (_cachedPersonas != null) return List.from(_cachedPersonas!);

    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_personasKey);

    if (jsonStr != null) {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      _cachedPersonas = list
          .map((e) => SpiritPersona.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      _cachedPersonas = [];
    }

    return List.from(_cachedPersonas!);
  }

  /// 获取就绪的名灵角色
  Future<List<SpiritPersona>> getReadyPersonas() async {
    final all = await getAllPersonas();
    return all.where((p) => p.isReady).toList();
  }

  /// 根据 ID 获取名灵角色
  Future<SpiritPersona?> getPersonaById(String id) async {
    final all = await getAllPersonas();
    return all.where((p) => p.id == id).firstOrNull;
  }

  /// 添加名灵角色
  Future<void> addPersona(SpiritPersona persona) async {
    final all = await getAllPersonas();
    // 检查是否已存在
    if (all.any((p) => p.id == persona.id)) {
      debugPrint('[$_tag] 名灵已存在: ${persona.id}');
      return;
    }
    all.add(persona);
    await _savePersonas(all);
    debugPrint('[$_tag] 添加名灵: ${persona.nickname} (${persona.id})');
  }

  /// 更新名灵角色
  Future<void> updatePersona(SpiritPersona persona) async {
    final all = await getAllPersonas();
    final index = all.indexWhere((p) => p.id == persona.id);
    if (index == -1) {
      debugPrint('[$_tag] 名灵不存在: ${persona.id}');
      return;
    }
    all[index] = persona;
    await _savePersonas(all);
    debugPrint('[$_tag] 更新名灵: ${persona.nickname} (${persona.id})');
  }

  /// 删除名灵角色
  Future<void> deletePersona(String id) async {
    final all = await getAllPersonas();
    all.removeWhere((p) => p.id == id);
    await _savePersonas(all);
    debugPrint('[$_tag] 删除名灵: $id');
  }

  /// 更新名灵状态
  Future<void> updatePersonaStatus(
    String id,
    SpiritStatus status, {
    String? errorMessage,
    String? distilledPrompt,
    String? clonedVoiceId,
  }) async {
    final all = await getAllPersonas();
    final index = all.indexWhere((p) => p.id == id);
    if (index == -1) return;

    all[index] = all[index].copyWith(
      status: status,
      errorMessage: errorMessage,
      distilledPrompt: distilledPrompt,
      clonedVoiceId: clonedVoiceId,
      updatedAt: DateTime.now(),
    );
    await _savePersonas(all);
  }

  /// 搜索名灵角色
  Future<List<SpiritPersona>> searchPersonas(String query) async {
    final all = await getAllPersonas();
    final q = query.toLowerCase();
    return all
        .where((p) =>
            p.nickname.toLowerCase().contains(q) ||
            p.domain.toLowerCase().contains(q) ||
            (p.description?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  /// 保存到持久化
  Future<void> _savePersonas(List<SpiritPersona> personas) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(personas.map((e) => e.toJson()).toList());
    await prefs.setString(_personasKey, jsonStr);
    _cachedPersonas = List.from(personas);
  }

  /// 清除缓存
  void clearCache() {
    _cachedPersonas = null;
  }

  /// 获取名灵数量
  Future<int> count() async {
    final all = await getAllPersonas();
    return all.length;
  }
}

// ==================== Riverpod Providers ====================

/// 仓库 Provider
final spiritRepositoryProvider = Provider<SpiritRepository>((ref) {
  return SpiritRepository();
});

/// 所有名灵角色 Provider
final allSpiritPersonasProvider = FutureProvider<List<SpiritPersona>>((ref) async {
  final repo = ref.watch(spiritRepositoryProvider);
  return repo.getAllPersonas();
});

/// 就绪的名灵角色 Provider
final readySpiritPersonasProvider = FutureProvider<List<SpiritPersona>>((ref) async {
  final repo = ref.watch(spiritRepositoryProvider);
  return repo.getReadyPersonas();
});

/// 单个名灵角色 Provider
final spiritPersonaProvider = FutureProvider.family<SpiritPersona?, String>((ref, id) async {
  final repo = ref.watch(spiritRepositoryProvider);
  return repo.getPersonaById(id);
});
