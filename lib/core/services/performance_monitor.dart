import 'dart:async';
import 'dart:collection';

/// 性能指标类型
enum MetricType {
  counter,    // 计数器
  gauge,      // 仪表盘（可增可减）
  histogram,  // 直方图（分布统计）
  timer,      // 计时器
}

/// 性能指标
class Metric {
  final String name;
  final MetricType type;
  final dynamic value;
  final DateTime timestamp;
  final Map<String, String>? tags;

  Metric({
    required this.name,
    required this.type,
    required this.value,
    DateTime? timestamp,
    this.tags,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.name,
      'value': value,
      'timestamp': timestamp.toIso8601String(),
      if (tags != null) 'tags': tags,
    };
  }
}

/// 性能监控服务
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final Map<String, Metric> _metrics = {};
  final Queue<Metric> _metricHistory = Queue();
  final int _maxHistorySize = 1000;

  /// 记录计数器
  void increment(String name, {int delta = 1, Map<String, String>? tags}) {
    final current = (_metrics[name]?.value as int?) ?? 0;
    _metrics[name] = Metric(
      name: name,
      type: MetricType.counter,
      value: current + delta,
      tags: tags,
    );
  }

  /// 记录仪表盘值
  void gauge(String name, dynamic value, {Map<String, String>? tags}) {
    final metric = Metric(
      name: name,
      type: MetricType.gauge,
      value: value,
      tags: tags,
    );
    _metrics[name] = metric;
    _addToHistory(metric);
  }

  /// 记录直方图值
  void histogram(String name, double value, {Map<String, String>? tags}) {
    final metric = Metric(
      name: name,
      type: MetricType.histogram,
      value: value,
      tags: tags,
    );
    _metrics[name] = metric;
    _addToHistory(metric);
  }

  /// 开始计时
  Stopwatch startTimer(String name) {
    return Stopwatch()..start();
  }

  /// 结束计时并记录
  void endTimer(String name, Stopwatch stopwatch, {Map<String, String>? tags}) {
    stopwatch.stop();
    final metric = Metric(
      name: name,
      type: MetricType.timer,
      value: stopwatch.elapsedMilliseconds,
      tags: tags,
    );
    _metrics[name] = metric;
    _addToHistory(metric);
  }

  /// 测量异步操作耗时
  Future<T> measureAsync<T>(
    String name,
    Future<T> Function() operation, {
    Map<String, String>? tags,
  }) async {
    final stopwatch = startTimer(name);
    try {
      final result = await operation();
      endTimer(name, stopwatch, tags: tags);
      return result;
    } catch (e) {
      endTimer(name, stopwatch, tags: {'error': 'true', ...?tags});
      rethrow;
    }
  }

  /// 测量同步操作耗时
  T measureSync<T>(
    String name,
    T Function() operation, {
    Map<String, String>? tags,
  }) {
    final stopwatch = startTimer(name);
    try {
      final result = operation();
      endTimer(name, stopwatch, tags: tags);
      return result;
    } catch (e) {
      endTimer(name, stopwatch, tags: {'error': 'true', ...?tags});
      rethrow;
    }
  }

  /// 获取指标值
  dynamic getMetric(String name) {
    return _metrics[name]?.value;
  }

  /// 获取所有指标
  Map<String, Metric> getAllMetrics() {
    return Map.unmodifiable(_metrics);
  }

  /// 获取指标历史
  List<Metric> getMetricHistory(String name) {
    return _metricHistory
        .where((m) => m.name == name)
        .toList();
  }

  /// 获取最近的指标
  List<Metric> getRecentMetrics({int count = 100}) {
    return _metricHistory.take(count).toList();
  }

  /// 清除指标
  void clearMetric(String name) {
    _metrics.remove(name);
  }

  /// 清除所有指标
  void clearAll() {
    _metrics.clear();
    _metricHistory.clear();
  }

  /// 添加到历史记录
  void _addToHistory(Metric metric) {
    _metricHistory.addLast(metric);
    if (_metricHistory.length > _maxHistorySize) {
      _metricHistory.removeFirst();
    }
  }

  /// 生成性能报告
  Map<String, dynamic> generateReport() {
    final report = <String, dynamic>{};

    // 计数器统计
    final counters = _metrics.entries
        .where((e) => e.value.type == MetricType.counter)
        .map((e) => {e.key: e.value.value})
        .toList();
    if (counters.isNotEmpty) {
      report['counters'] = counters;
    }

    // 仪表盘统计
    final gauges = _metrics.entries
        .where((e) => e.value.type == MetricType.gauge)
        .map((e) => {e.key: e.value.value})
        .toList();
    if (gauges.isNotEmpty) {
      report['gauges'] = gauges;
    }

    // 计时器统计
    final timers = _metrics.entries
        .where((e) => e.value.type == MetricType.timer)
        .toList();

    if (timers.isNotEmpty) {
      final timerStats = <String, Map<String, dynamic>>{};

      for (final entry in timers) {
        final history = getMetricHistory(entry.key);
        if (history.isNotEmpty) {
          final values = history.map((m) => m.value as int).toList();
          values.sort();

          timerStats[entry.key] = {
            'count': values.length,
            'min': values.first,
            'max': values.last,
            'avg': values.reduce((a, b) => a + b) / values.length,
            'p50': _percentile(values, 50),
            'p95': _percentile(values, 95),
            'p99': _percentile(values, 99),
          };
        }
      }

      report['timers'] = timerStats;
    }

    // 直方图统计
    final histograms = _metrics.entries
        .where((e) => e.value.type == MetricType.histogram)
        .toList();

    if (histograms.isNotEmpty) {
      final histogramStats = <String, Map<String, dynamic>>{};

      for (final entry in histograms) {
        final history = getMetricHistory(entry.key);
        if (history.isNotEmpty) {
          final values = history.map((m) => m.value as double).toList();
          values.sort();

          histogramStats[entry.key] = {
            'count': values.length,
            'min': values.first,
            'max': values.last,
            'avg': values.reduce((a, b) => a + b) / values.length,
            'stddev': _stddev(values),
          };
        }
      }

      report['histograms'] = histogramStats;
    }

    return report;
  }

  /// 计算百分位数
  int _percentile(List<int> sortedValues, int percentile) {
    if (sortedValues.isEmpty) return 0;

    final index = (sortedValues.length * percentile / 100).floor();
    return sortedValues[index.clamp(0, sortedValues.length - 1)];
  }

  /// 计算标准差
  double _stddev(List<double> values) {
    if (values.isEmpty) return 0;

    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance = values.map((v) => (v - mean) * (v - mean)).reduce((a, b) => a + b) / values.length;
    return variance;
  }
}

/// 性能监控装饰器
/// 用于自动监控方法调用
class PerformanceInterceptor {
  final PerformanceMonitor _monitor = PerformanceMonitor();

  /// 包装异步方法
  Future<T> Function() wrapAsync<T>(
    String operationName,
    Future<T> Function() operation, {
    Map<String, String>? tags,
  }) {
    return () => _monitor.measureAsync(operationName, operation, tags: tags);
  }

  /// 包装同步方法
  T Function() wrapSync<T>(
    String operationName,
    T Function() operation, {
    Map<String, String>? tags,
  }) {
    return () => _monitor.measureSync(operationName, operation, tags: tags);
  }
}

/// 常用性能指标名称
class MetricNames {
  // API调用
  static const apiCallDuration = 'api_call_duration_ms';
  static const apiCallCount = 'api_call_count';
  static const apiCallErrors = 'api_call_errors';

  // 模型推理
  static const modelInferenceDuration = 'model_inference_duration_ms';
  static const modelInferenceTokens = 'model_inference_tokens';
  static const modelInferenceTPS = 'model_inference_tokens_per_second';

  // 内存
  static const memoryUsage = 'memory_usage_mb';
  static const memoryPeak = 'memory_peak_mb';

  // 缓存
  static const cacheHits = 'cache_hits';
  static const cacheMisses = 'cache_misses';
  static const cacheSize = 'cache_size';

  // 向量检索
  static const vectorSearchDuration = 'vector_search_duration_ms';
  static const vectorSearchResults = 'vector_search_results_count';

  // 语音合成
  static const ttsSynthesisDuration = 'tts_synthesis_duration_ms';
  static const ttsAudioLength = 'tts_audio_length_seconds';
}
