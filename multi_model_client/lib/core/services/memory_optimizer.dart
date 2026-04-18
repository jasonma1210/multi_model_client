import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';

/// 内存优化器
/// 提供内存管理、垃圾回收建议、资源清理等功能
class MemoryOptimizer {
  static final MemoryOptimizer _instance = MemoryOptimizer._internal();
  factory MemoryOptimizer() => _instance;
  MemoryOptimizer._internal();

  final List<VoidCallback> _cleanupCallbacks = [];
  Timer? _periodicCleanupTimer;

  /// 注册清理回调
  /// 当内存不足时会调用这些回调释放资源
  void registerCleanupCallback(VoidCallback callback) {
    _cleanupCallbacks.add(callback);
  }

  /// 取消注册清理回调
  void unregisterCleanupCallback(VoidCallback callback) {
    _cleanupCallbacks.remove(callback);
  }

  /// 执行内存清理
  /// 会调用所有注册的清理回调
  Future<void> cleanup() async {
    debugPrint('🧹 执行内存清理...');

    for (final callback in _cleanupCallbacks) {
      try {
        callback();
      } catch (e) {
        debugPrint('清理回调执行失败: $e');
      }
    }

    // 建议执行垃圾回收
    _suggestGC();
  }

  /// 建议执行垃圾回收
  void _suggestGC() {
    // Dart的GC是自动的，但我们可以通过释放引用来帮助它
    debugPrint('建议执行垃圾回收');
  }

  /// 启动定期清理
  void startPeriodicCleanup({Duration interval = const Duration(minutes: 5)}) {
    _periodicCleanupTimer?.cancel();
    _periodicCleanupTimer = Timer.periodic(interval, (_) {
      cleanup();
    });
    debugPrint('启动定期内存清理，间隔: ${interval.inMinutes}分钟');
  }

  /// 停止定期清理
  void stopPeriodicCleanup() {
    _periodicCleanupTimer?.cancel();
    _periodicCleanupTimer = null;
    debugPrint('停止定期内存清理');
  }

  /// 获取内存使用情况（估算）
  Map<String, dynamic> getMemoryStats() {
    // Dart不提供直接的内存API，这里返回估算值
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'cleanupCallbacksCount': _cleanupCallbacks.length,
      'periodicCleanupEnabled': _periodicCleanupTimer != null,
    };
  }

  /// 释放资源
  void dispose() {
    stopPeriodicCleanup();
    _cleanupCallbacks.clear();
  }
}

/// 资源池
/// 用于管理可复用的资源，减少创建和销毁开销
class ResourcePool<T> {
  final int maxSize;
  final T Function() _factory;
  final void Function(T)? _resetter;
  final Queue<T> _pool = Queue();
  final Set<T> _inUse = {};

  ResourcePool({
    required this.maxSize,
    required T Function() factory,
    void Function(T)? resetter,
  })  : _factory = factory,
        _resetter = resetter;

  /// 获取资源
  T acquire() {
    if (_pool.isNotEmpty) {
      final resource = _pool.removeLast();
      _inUse.add(resource);
      return resource;
    }

    if (_inUse.length < maxSize) {
      final resource = _factory();
      _inUse.add(resource);
      return resource;
    }

    throw StateError('资源池已满，无法创建新资源');
  }

  /// 释放资源
  void release(T resource) {
    if (!_inUse.contains(resource)) {
      throw StateError('资源不属于此池');
    }

    _inUse.remove(resource);

    if (_pool.length < maxSize) {
      _resetter?.call(resource);
      _pool.add(resource);
    }
  }

  /// 清空池
  void clear() {
    _pool.clear();
    _inUse.clear();
  }

  /// 获取池状态
  Map<String, int> getStats() {
    return {
      'available': _pool.length,
      'inUse': _inUse.length,
      'total': _pool.length + _inUse.length,
      'maxSize': maxSize,
    };
  }
}

/// 对象池示例：用于缓存大型对象
class ObjectPool<T> {
  final int maxCapacity;
  final T Function() _creator;
  final void Function(T)? _reset;
  final List<T> _available = [];
  int _created = 0;

  ObjectPool({
    required this.maxCapacity,
    required T Function() creator,
    void Function(T)? reset,
  })  : _creator = creator,
        _reset = reset;

  /// 从池中获取对象
  T get() {
    if (_available.isNotEmpty) {
      return _available.removeLast();
    }

    _created++;
    return _creator();
  }

  /// 将对象返回池中
  void put(T object) {
    if (_available.length < maxCapacity) {
      _reset?.call(object);
      _available.add(object);
    }
  }

  /// 获取池状态
  Map<String, dynamic> getStats() {
    return {
      'available': _available.length,
      'created': _created,
      'maxCapacity': maxCapacity,
    };
  }

  /// 清空池
  void clear() {
    _available.clear();
  }
}

/// 延迟加载容器
/// 只在第一次访问时创建对象
class Lazy<T> {
  final T Function() _factory;
  T? _value;

  Lazy(this._factory);

  /// 获取值
  T get value {
    return _value ??= _factory();
  }

  /// 检查是否已初始化
  bool get isInitialized => _value != null;

  /// 重置（清除缓存的值）
  void reset() {
    _value = null;
  }
}

/// 软引用（模拟）
/// Dart没有真正的软引用，这里用弱引用模拟
class SoftReference<T> {
  final T? _value;

  SoftReference(this._value);

  T? get value => _value;

  bool get isAlive => _value != null;
}

/// 内存敏感操作包装器
/// 当内存压力大时自动释放资源
class MemorySensitiveOperation<T> {
  final Future<T> Function() _operation;
  final VoidCallback? _onMemoryPressure;

  MemorySensitiveOperation({
    required Future<T> Function() operation,
    VoidCallback? onMemoryPressure,
  })  : _operation = operation,
        _onMemoryPressure = onMemoryPressure;

  Future<T> execute() async {
    try {
      return await _operation();
    } catch (e) {
      if (e.toString().contains('memory') || e.toString().contains('allocation')) {
        _onMemoryPressure?.call();
        MemoryOptimizer().cleanup();
      }
      rethrow;
    }
  }
}

/// 批处理执行器
/// 将多个小操作合并成批次执行，减少内存碎片
class BatchExecutor<T, R> {
  final int batchSize;
  final Future<List<R>> Function(List<T>) _processor;

  BatchExecutor({
    required this.batchSize,
    required Future<List<R>> Function(List<T>) processor,
  }) : _processor = processor;

  /// 批量执行
  Future<List<R>> execute(List<T> items) async {
    final results = <R>[];

    for (var i = 0; i < items.length; i += batchSize) {
      final batch = items.sublist(
        i,
        i + batchSize > items.length ? items.length : i + batchSize,
      );

      final batchResults = await _processor(batch);
      results.addAll(batchResults);

      // 给GC机会运行
      await Future.delayed(Duration.zero);
    }

    return results;
  }
}
