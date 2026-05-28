/// 数据库 Provider - LLM Studio 数据库依赖注入模块
/// 
/// 功能：
/// - 全局数据库实例提供
/// - Riverpod Provider 封装
/// - 数据库生命周期管理
/// 
/// @author JianMa
/// @version 1.0.0
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/database.dart';
import '../storage/database_connection.dart';

/// 全局数据库 Provider
final databaseProvider = Provider<AppDatabase>((ref) {
  return database;
});