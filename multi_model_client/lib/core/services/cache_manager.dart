import 'dart:collection';

/// LRU缓存实现
/// 用于缓存模型信息、API响应等，减少重复请求
class LRUCache<K, V> {
  final int maxSize;
  final LinkedHashMap<K, V> _cache = LinkedHashMap<K, V>();
  final Map<K, DateTime> _accessTimes = {};

  LRUCache(this.maxSize);

  /// 获取缓存值
  V? get(K key) {
    if (!_cache.containsKey(key)) return null;

    // 更新访问时间并移到队列尾部
    final value = _cache.remove(key);
    if (value != null) {
      _cache[key] = value;
      _accessTimes[key] = DateTime.now();
    }
    return value;
  }

  /// 设置缓存值
  void set(K key, V value) {
    // 如果已存在，先移除
    if (_cache.containsKey(key)) {
      _cache.remove(key);
      _accessTimes.remove(key);
    }

    // 如果缓存已满，移除最久未使用的项
    if (_cache.length >= maxSize) {
      _evictLRU();
    }

    // 添加新项
    _cache[key] = value;
    _accessTimes[key] = DateTime.now();
  }

  /// 移除缓存值
  void remove(K key) {
    _cache.remove(key);
    _accessTimes.remove(key);
  }

  /// 清空缓存
  void clear() {
    _cache.clear();
    _accessTimes.clear();
  }

  /// 获取缓存大小
  int get size => _cache.length;

  /// 检查是否包含键
  bool containsKey(K key) => _cache.containsKey(key);

  /// 获取所有键
  Iterable<K> get keys => _cache.keys;

  /// 获取所有值
  Iterable<V> get values => _cache.values;

  /// 移除最久未使用的项
  void _evictLRU() {
    if (_cache.isEmpty) return;

    // 找到最久未使用的键
    K? oldestKey;
    DateTime? oldestTime;

    for (final entry in _accessTimes.entries) {
      if (oldestTime == null || entry.value.isBefore(oldestTime)) {
        oldestTime = entry.value;
        oldestKey = entry.key;
      }
    }

    if (oldestKey != null) {
      remove(oldestKey);
    }
  }

  /// 清理过期项
  void cleanupExpired(Duration maxAge) {
    final now = DateTime.now();
    final keysToRemove = <K>[];

    for (final entry in _accessTimes.entries) {
      final age = now.difference(entry.value);
      if (age > maxAge) {
        keysToRemove.add(entry.key);
      }
    }

    for (final key in keysToRemove) {
      remove(key);
    }
  }

  /// 获取缓存统计信息
  Map<String, dynamic> getStats() {
    return {
      'size': size,
      'maxSize': maxSize,
      'utilization': size / maxSize,
    };
  }
}

/// 缓存管理器
/// 统一管理应用中的各种缓存
class CacheManager {
  static final CacheManager _instance = CacheManager._internal();
  factory CacheManager() => _instance;
  CacheManager._internal();

  // 模型信息缓存（1小时有效期）
  final LRUCache<String, Map<String, dynamic>> modelInfoCache = LRUCache(100);

  // API响应缓存（5分钟有效期）
  final LRUCache<String, Map<String, dynamic>> apiResponseCache = LRUCache(200);

  // 向量缓存（持久化存储，不限制大小）
  final LRUCache<String, List<double>> vectorCache = LRUCache(1000);

  // Token估算缓存
  final LRUCache<String, int> tokenEstimateCache = LRUCache(500);

  /// 清理所有缓存
  void clearAll() {
    modelInfoCache.clear();
    apiResponseCache.clear();
    vectorCache.clear();
    tokenEstimateCache.clear();
  }

  /// 清理过期缓存
  void cleanupExpired() {
    modelInfoCache.cleanupExpired(const Duration(hours: 1));
    apiResponseCache.cleanupExpired(const Duration(minutes: 5));
    vectorCache.cleanupExpired(const Duration(hours: 24));
    tokenEstimateCache.cleanupExpired(const Duration(hours: 12));
  }

  /// 获取缓存统计信息
  Map<String, Map<String, dynamic>> getStats() {
    return {
      'modelInfo': modelInfoCache.getStats(),
      'apiResponse': apiResponseCache.getStats(),
      'vector': vectorCache.getStats(),
      'tokenEstimate': tokenEstimateCache.getStats(),
    };
  }

  /// 预热缓存
  /// 在应用启动时预加载常用数据
  Future<void> warmup(List<String> modelIds) async {
    // 这里可以预加载常用模型信息
    // 实际实现需要在服务初始化后调用
  }
}

/// 缓存键生成器
class CacheKeyGenerator {
  /// 生成模型信息缓存键
  static String modelInfo(String modelId, String source) {
    return 'model_info_${source}_$modelId';
  }

  /// 生成模型搜索缓存键
  static String modelSearch(String query, String source, int limit) {
    return 'model_search_${source}_${query}_$limit';
  }

  /// 生成API响应缓存键
  static String apiResponse(String endpoint, Map<String, dynamic> params) {
    final paramsStr = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    return 'api_${endpoint}_$paramsStr';
  }

  /// 生成向量缓存键
  static String vector(String text) {
    return 'vector_${text.hashCode}';
  }

  /// 生成Token估算缓存键
  static String tokenEstimate(String text, String model) {
    return 'tokens_${model}_${text.hashCode}';
  }
}
