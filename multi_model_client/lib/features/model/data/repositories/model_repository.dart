import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';

import '../../../../core/storage/database.dart';
import '../../../../core/storage/database_connection.dart';

class ModelRepository {
  final AppDatabase _db = database;
  final _uuid = const Uuid();

  Future<Model> createModel({
    required String name,
    required String type,
    required String source,
    String? path,
    Map<String, dynamic>? apiConfig,
    Map<String, dynamic>? capabilities,
    Map<String, dynamic>? defaultParams,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    final model = ModelsCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      source: Value(source),
      path: Value(path),
      apiConfig: Value(apiConfig != null ? jsonEncode(apiConfig) : null),
      capabilities: Value(capabilities != null ? jsonEncode(capabilities) : null),
      defaultParams: Value(defaultParams != null ? jsonEncode(defaultParams) : null),
      createdAt: Value(now),
    );

    await _db.insertModel(model);
    return (await _db.getModel(id))!;
  }

  Future<List<Model>> getAllModels() async {
    return await _db.getAllModels();
  }

  Future<Model?> getModel(String id) async {
    return await _db.getModel(id);
  }

  Future<void> updateModel({
    required String id,
    String? name,
    String? path,
    Map<String, dynamic>? apiConfig,
    Map<String, dynamic>? capabilities,
    Map<String, dynamic>? defaultParams,
  }) async {
    final updates = ModelsCompanion(
      id: Value(id),
      name: name != null ? Value(name) : const Value.absent(),
      path: path != null ? Value(path) : const Value.absent(),
      apiConfig: apiConfig != null ? Value(jsonEncode(apiConfig)) : const Value.absent(),
      capabilities: capabilities != null ? Value(jsonEncode(capabilities)) : const Value.absent(),
      defaultParams: defaultParams != null ? Value(jsonEncode(defaultParams)) : const Value.absent(),
    );

    await _db.updateModel(updates);
  }

  Future<void> deleteModel(String id) async {
    await _db.deleteModel(id);
  }
}
