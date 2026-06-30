// v0.43.0 实现 MCP Streamable HTTP Transport
//
// 参考 MCP 2025-03-26 规范：https://modelcontextprotocol.io/specification/transport
// Streamable HTTP 是 MCP 2025-03-26+ 推荐的传输方式
// - 客户端通过 POST 发送 JSON-RPC 请求到 MCP endpoint
// - 服务端响应：单个 JSON 响应 / SSE 流（application/json 或 text/event-stream）
// - 服务端可主动通过 GET 请求 + SSE 推送通知

import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../mcp_protocol.dart';

/// Streamable HTTP Transport 状态
enum StreamableHttpStatus {
  disconnected,
  connecting,
  connected,
  streaming,
  error,
}

/// Streamable HTTP Transport 事件
class StreamableHttpEvent {
  final String type; // 'open' | 'message' | 'error' | 'close'
  final Map<String, dynamic>? data;
  final String? error;
  final DateTime timestamp;

  StreamableHttpEvent({
    required this.type,
    this.data,
    this.error,
    required this.timestamp,
  });
}

/// MCP Streamable HTTP Transport
class McpStreamableHttpTransport {
  final String endpoint; // 完整 URL: https://api.example.com/mcp
  final Map<String, String> headers; // 含 Authorization 等
  final Dio _dio;
  final Duration _timeout;

  StreamableHttpStatus _status = StreamableHttpStatus.disconnected;
  StreamController<StreamableHttpEvent>? _eventController;
  String? _sessionId; // MCP 会话 ID（Initialize 后由服务端返回）
  CancelToken? _streamingCancelToken;

  McpStreamableHttpTransport({
    required this.endpoint,
    this.headers = const {},
    Dio? dio,
    Duration timeout = const Duration(seconds: 30),
  })  : _dio = dio ?? Dio(),
        _timeout = timeout;

  StreamableHttpStatus get status => _status;
  Stream<StreamableHttpEvent> get events => _eventController!.stream;
  String? get sessionId => _sessionId;

  /// 连接到 MCP Server（发送 initialize）
  Future<MCPResponse> connect(MCPRequest initializeRequest) async {
    if (_status == StreamableHttpStatus.connected || _status == StreamableHttpStatus.streaming) {
      throw const MCPException('Already connected', -32000);
    }

    _updateStatus(StreamableHttpStatus.connecting);
    _eventController = StreamController<StreamableHttpEvent>.broadcast();

    try {
      final (response, mcpResponse) = await _postRequestRaw(initializeRequest);
      _sessionId = _extractSessionId(response.headers);
      _updateStatus(StreamableHttpStatus.connected);
      _emitEvent('open', data: {'sessionId': _sessionId});

      // 启动 GET 长连接接收服务端推送
      unawaited(_startGetStream());

      return mcpResponse;
    } catch (e) {
      _updateStatus(StreamableHttpStatus.error);
      _emitEvent('error', error: e.toString());
      rethrow;
    }
  }

  /// 发送 JSON-RPC 请求
  Future<MCPResponse> send(MCPRequest request) async {
    if (_status != StreamableHttpStatus.connected && _status != StreamableHttpStatus.streaming) {
      throw const MCPException('Not connected', -32001);
    }
    return _postRequest(request);
  }

  /// 发送流式请求（接收 SSE）
  Stream<Map<String, dynamic>> sendStreaming(MCPRequest request) async* {
    if (_status != StreamableHttpStatus.connected) {
      throw const MCPException('Not connected', -32001);
    }

    _updateStatus(StreamableHttpStatus.streaming);
    try {
      final response = await _dio.post<ResponseBody>(
        endpoint,
        data: request.toJson(),
        options: Options(
          headers: {
            ...headers,
            'Content-Type': 'application/json',
            'Accept': 'application/json, text/event-stream',
            if (_sessionId != null) 'Mcp-Session-Id': _sessionId!,
          },
          responseType: ResponseType.stream,
          sendTimeout: _timeout,
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      // 检查 Content-Type
      final contentType = response.headers.value('content-type') ?? '';
      if (!contentType.contains('text/event-stream')) {
        // 单次 JSON 响应
        final bytes = await response.data!.stream.fold<List<int>>([], (acc, chunk) {
          acc.addAll(chunk);
          return acc;
        });
        final jsonStr = utf8.decode(bytes);
        final json = jsonDecode(jsonStr) as Map<String, dynamic>;
        yield json;
        return;
      }

      // SSE 流
      final lineStream = response.data!.stream
          .map((chunk) => utf8.decode(chunk))
          .transform(const LineSplitter());
      await for (final line in lineStream) {
        if (line.isEmpty) continue;
        if (line.startsWith('data:')) {
          final data = line.substring(5).trim();
          if (data.isEmpty) continue;
          try {
            yield jsonDecode(data) as Map<String, dynamic>;
          } catch (e) {
            debugPrint('[MCPStreamableHTTP] SSE parse error: $e, data: $data');
          }
        }
      }
    } on DioException catch (e) {
      _emitEvent('error', error: e.toString());
      rethrow;
    } finally {
      _updateStatus(StreamableHttpStatus.connected);
    }
  }

  /// 关闭连接
  Future<void> close() async {
    _streamingCancelToken?.cancel('Connection closing');
    _streamingCancelToken = null;

    if (_sessionId != null) {
      try {
        // 通知服务端关闭
        await _dio.delete(
          endpoint,
          options: Options(headers: {...headers, 'Mcp-Session-Id': _sessionId!}),
        );
      } catch (e) {
        debugPrint('[MCPStreamableHTTP] DELETE close error: $e');
      }
    }

    _updateStatus(StreamableHttpStatus.disconnected);
    _emitEvent('close');
    await _eventController?.close();
    _eventController = null;
    _sessionId = null;
  }

  // === Private ===

  /// 发送 POST 请求并返回原始 Response（用于获取 headers）
  Future<(Response<dynamic>, MCPResponse)> _postRequestRaw(MCPRequest request) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: request.toJson(),
        options: Options(
          headers: {
            ...headers,
            'Content-Type': 'application/json',
            'Accept': 'application/json, text/event-stream',
            if (_sessionId != null) 'Mcp-Session-Id': _sessionId!,
          },
          sendTimeout: _timeout,
          receiveTimeout: _timeout,
        ),
      );

      // 更新 session ID（如果服务端在 header 中返回）
      final newSessionId = _extractSessionId(response.headers);
      if (newSessionId != null) _sessionId = newSessionId;

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return (response, MCPResponse.fromJson(data));
      }
      throw const MCPException('Invalid response format', -32002);
    } on DioException catch (e) {
      throw MCPException('HTTP ${e.response?.statusCode ?? "?"}: ${e.message}', -32003);
    }
  }

  Future<MCPResponse> _postRequest(MCPRequest request) async {
    final (_, mcpResponse) = await _postRequestRaw(request);
    return mcpResponse;
  }

  /// 启动 GET 长连接接收服务端推送通知
  Future<void> _startGetStream() async {
    if (_sessionId == null) return;
    _streamingCancelToken = CancelToken();

    try {
      final response = await _dio.get<ResponseBody>(
        endpoint,
        options: Options(
          headers: {
            ...headers,
            'Accept': 'text/event-stream',
            'Mcp-Session-Id': _sessionId!,
          },
          responseType: ResponseType.stream,
        ),
        cancelToken: _streamingCancelToken,
      );

      final contentType = response.headers.value('content-type') ?? '';
      if (!contentType.contains('text/event-stream')) return;

      final lineStream = response.data!.stream
          .map((chunk) => utf8.decode(chunk))
          .transform(const LineSplitter());
      await for (final line in lineStream) {
        if (_streamingCancelToken?.isCancelled ?? true) break;
        if (line.startsWith('data:')) {
          final data = line.substring(5).trim();
          if (data.isEmpty) continue;
          try {
            final json = jsonDecode(data) as Map<String, dynamic>;
            _emitEvent('message', data: json);
          } catch (e) {
            debugPrint('[MCPStreamableHTTP] GET SSE parse error: $e');
          }
        }
      }
    } on DioException catch (e) {
      if (e.type != DioExceptionType.cancel) {
        debugPrint('[MCPStreamableHTTP] GET stream error: ${e.message}');
        _emitEvent('error', error: e.toString());
      }
    }
  }

  String? _extractSessionId(Headers headers) {
    return headers.value('mcp-session-id') ?? headers.value('Mcp-Session-Id');
  }

  void _updateStatus(StreamableHttpStatus newStatus) {
    _status = newStatus;
  }

  void _emitEvent(String type, {Map<String, dynamic>? data, String? error}) {
    _eventController?.add(StreamableHttpEvent(
      type: type,
      data: data,
      error: error,
      timestamp: DateTime.now(),
    ));
  }
}

class MCPException implements Exception {
  final String message;
  final int code;
  const MCPException(this.message, this.code);

  @override
  String toString() => 'MCPException($code): $message';
}
