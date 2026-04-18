import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/database.dart';
import '../../../core/storage/database_connection.dart';
import '../domain/prompt_engine.dart';

// Database provider
final databaseProvider = Provider<AppDatabase>((ref) {
  return database;
});

// Prompt Engine provider
final promptEngineProvider = Provider<PromptEngine>((ref) {
  return PromptEngine();
});

// All prompt templates provider
final promptTemplatesProvider = FutureProvider<List<PromptTemplate>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.getAllPromptTemplates();
});

// User prompt templates (non-builtin)
final userPromptTemplatesProvider = FutureProvider<List<PromptTemplate>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.getUserPromptTemplates();
});

// Builtin prompt templates
final builtinPromptTemplatesProvider = FutureProvider<List<PromptTemplate>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.getBuiltinPromptTemplates();
});

// Prompt templates by category
final promptTemplatesByCategoryProvider =
    FutureProvider.family<List<PromptTemplate>, String>((ref, category) async {
  final db = ref.watch(databaseProvider);
  return db.getPromptTemplatesByCategory(category);
});

// Global prompt templates
final globalPromptTemplatesProvider = FutureProvider<List<PromptTemplate>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.getGlobalPromptTemplates();
});

// Single prompt template by ID
final promptTemplateProvider =
    FutureProvider.family<PromptTemplate?, String>((ref, id) async {
  final db = ref.watch(databaseProvider);
  return db.getPromptTemplate(id);
});

// Session prompts provider
final sessionPromptsProvider =
    FutureProvider.family<List<SessionPrompt>, String>((ref, sessionId) async {
  final db = ref.watch(databaseProvider);
  return db.getSessionPrompts(sessionId);
});

// Latest session prompt
final latestSessionPromptProvider =
    FutureProvider.family<SessionPrompt?, String>((ref, sessionId) async {
  final db = ref.watch(databaseProvider);
  return db.getLatestSessionPrompt(sessionId);
});

// Prompt template notifier for CRUD operations
class PromptTemplateNotifier extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;
  final Ref _ref;

  PromptTemplateNotifier(this._db, this._ref) : super(const AsyncValue.data(null));

  Future<void> createTemplate({
    required String id,
    required String name,
    required String content,
    List<String>? variables,
    String category = 'general',
    bool isGlobal = false,
    bool isBuiltin = false,
  }) async {
    state = const AsyncValue.loading();
    try {
      final now = DateTime.now();
      await _db.insertPromptTemplate(PromptTemplatesCompanion(
        id: Value(id),
        name: Value(name),
        content: Value(content),
        variables: Value(variables != null ? jsonEncode(variables) : null),
        category: Value(category),
        isGlobal: Value(isGlobal),
        isBuiltin: Value(isBuiltin),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));
      _ref.invalidate(promptTemplatesProvider);
      _ref.invalidate(userPromptTemplatesProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateTemplate({
    required String id,
    String? name,
    String? content,
    List<String>? variables,
    String? category,
    bool? isGlobal,
  }) async {
    state = const AsyncValue.loading();
    try {
      final existing = await _db.getPromptTemplate(id);
      if (existing == null) {
        throw Exception('Template not found');
      }

      await _db.updatePromptTemplate(PromptTemplatesCompanion(
        id: Value(id),
        name: name != null ? Value(name) : Value(existing.name),
        content: content != null ? Value(content) : Value(existing.content),
        variables: Value(variables != null ? jsonEncode(variables) : existing.variables),
        category: Value(category ?? existing.category),
        isGlobal: Value(isGlobal ?? existing.isGlobal),
        isBuiltin: const Value(false), // Preserve builtin status
        updatedAt: Value(DateTime.now()),
      ));
      _ref.invalidate(promptTemplatesProvider);
      _ref.invalidate(promptTemplateProvider(id));
      _ref.invalidate(userPromptTemplatesProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteTemplate(String id) async {
    state = const AsyncValue.loading();
    try {
      await _db.deletePromptTemplate(id);
      _ref.invalidate(promptTemplatesProvider);
      _ref.invalidate(userPromptTemplatesProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> initializeBuiltinTemplates() async {
    try {
      final existing = await _db.getBuiltinPromptTemplates();
      if (existing.isNotEmpty) {
        return; // Already initialized
      }

      for (var template in PresetPromptTemplates.all) {
        await _db.insertPromptTemplate(PromptTemplatesCompanion(
          id: Value(template['id'] as String),
          name: Value(template['name'] as String),
          content: Value(template['content'] as String),
          variables: Value(template['variables'] as String?),
          category: Value(template['category'] as String),
          isGlobal: const Value(false),
          isBuiltin: Value(template['isBuiltin'] as bool),
          createdAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ));
      }
      _ref.invalidate(promptTemplatesProvider);
      _ref.invalidate(builtinPromptTemplatesProvider);
    } catch (e) {
      // Ignore errors during initialization
    }
  }
}

final promptTemplateNotifierProvider =
    StateNotifierProvider<PromptTemplateNotifier, AsyncValue<void>>((ref) {
  final db = ref.watch(databaseProvider);
  return PromptTemplateNotifier(db, ref);
});

// Session prompt notifier
class SessionPromptNotifier extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;
  final Ref _ref;

  SessionPromptNotifier(this._db, this._ref) : super(const AsyncValue.data(null));

  Future<void> createSessionPrompt({
    required String id,
    required String sessionId,
    String? templateId,
    required String promptContent,
    Map<String, String>? variables,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _db.insertSessionPrompt(SessionPromptsCompanion(
        id: Value(id),
        sessionId: Value(sessionId),
        templateId: Value(templateId),
        promptContent: Value(promptContent),
        variables: Value(variables != null ? jsonEncode(variables) : null),
        createdAt: Value(DateTime.now()),
      ));
      _ref.invalidate(sessionPromptsProvider(sessionId));
      _ref.invalidate(latestSessionPromptProvider(sessionId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteSessionPrompts(String sessionId) async {
    state = const AsyncValue.loading();
    try {
      await _db.deleteSessionPrompts(sessionId);
      _ref.invalidate(sessionPromptsProvider(sessionId));
      _ref.invalidate(latestSessionPromptProvider(sessionId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final sessionPromptNotifierProvider =
    StateNotifierProvider<SessionPromptNotifier, AsyncValue<void>>((ref) {
  final db = ref.watch(databaseProvider);
  return SessionPromptNotifier(db, ref);
});

// Selected category filter
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// Filtered templates based on selected category
final filteredPromptTemplatesProvider = FutureProvider<List<PromptTemplate>>((ref) async {
  final category = ref.watch(selectedCategoryProvider);
  final db = ref.watch(databaseProvider);

  if (category == null || category == 'all') {
    return db.getAllPromptTemplates();
  }
  return db.getPromptTemplatesByCategory(category);
});
