import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import '../../../core/api/list_api.dart';
import '../../../core/utils/pref_manager.dart';
import '../../../di.dart';
import '../models/chat_message.dart';

class ChatWebSocketService {
  WebSocket? _socket;
  StreamSubscription<dynamic>? _subscription;
  final StreamController<ChatMessage> _messagesController =
      StreamController<ChatMessage>.broadcast();
  Timer? _reconnectTimer;
  bool _isManuallyDisconnected = false;
  Uri? _lastUri;
  String? _authToken;

  Stream<ChatMessage> get messagesStream => _messagesController.stream;
  bool get isConnected => _socket != null;

  Future<void> connect({
    required String baseWsUrl,
    required String rolePath,
    required int conversationId,
  }) async {
    _isManuallyDisconnected = false;

    // Token olish
    final token = inject<PrefManager>().token;
    _authToken = token;

    // URL ni to'g'ri parse qilish - port muammosini oldini olish
    final baseUri = Uri.parse(baseWsUrl);
    final uri = baseUri.replace(
      path: '/api/v1/$rolePath/chat/ws',
      queryParameters: {'conversation_id': conversationId.toString()},
    );
    _lastUri = uri;

    log('[WebSocket] Connecting to: $uri', name: 'ChatWebSocket');
    log('[WebSocket] Token present: ${token != null && token.isNotEmpty}',
        name: 'ChatWebSocket');
    await _disposeSocketOnly();
    try {
      log('[WebSocket] Attempting connection...', name: 'ChatWebSocket');

      // Headers bilan ulanish
      final headers = <String, dynamic>{
        ListAPI.headerXUuid: ListAPI.xUuid,
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      log('[WebSocket] Headers: $headers', name: 'ChatWebSocket');

      _socket = await WebSocket.connect(
        uri.toString(),
        headers: headers,
      );
      log('[WebSocket] Connected successfully!', name: 'ChatWebSocket');

      _subscription = _socket?.listen(
        _onRawEvent,
        onError: (error) {
          log('[WebSocket] Error: $error', name: 'ChatWebSocket');
          _scheduleReconnect();
        },
        onDone: () {
          log('[WebSocket] Connection closed', name: 'ChatWebSocket');
          _scheduleReconnect();
        },
      );

      log('[WebSocket] Listening for messages...', name: 'ChatWebSocket');
    } catch (e, stackTrace) {
      log('[WebSocket] Connection failed: $e',
          name: 'ChatWebSocket', error: e, stackTrace: stackTrace);
      _scheduleReconnect();
    }
  }

  void _onRawEvent(dynamic event) {
    log('[WebSocket] Raw event received: $event', name: 'ChatWebSocket');
    if (event is! String) {
      log('[WebSocket] Event is not a String, skipping', name: 'ChatWebSocket');
      return;
    }
    try {
      final json = jsonDecode(event) as Map<String, dynamic>;
      log('[WebSocket] Parsed JSON: $json', name: 'ChatWebSocket');
      final type = json['type'] as String? ?? '';
      log('[WebSocket] Event type: $type', name: 'ChatWebSocket');

      if (type == 'message') {
        final payload = json['message'];
        if (payload is! Map<String, dynamic>) {
          log('[WebSocket] Invalid payload format', name: 'ChatWebSocket');
          return;
        }
        log('[WebSocket] Adding message to stream: $payload',
            name: 'ChatWebSocket');
        _messagesController.add(ChatMessage.fromJson(payload));
      } else if (type == 'send') {
        log('[WebSocket] Send confirmation received', name: 'ChatWebSocket');
      } else {
        log('[WebSocket] Unknown event type: $type', name: 'ChatWebSocket');
      }
    } catch (e, stackTrace) {
      log('[WebSocket] Error parsing event: $e',
          name: 'ChatWebSocket', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> sendMessage(String content) async {
    if (_socket == null) {
      log('[WebSocket] Cannot send - socket is null', name: 'ChatWebSocket');
      return;
    }
    final payload = <String, dynamic>{'type': 'send', 'content': content};
    final jsonString = jsonEncode(payload);
    log('[WebSocket] Sending message: $jsonString', name: 'ChatWebSocket');
    _socket!.add(jsonString);
    log('[WebSocket] Message sent successfully', name: 'ChatWebSocket');
  }

  Future<void> sendReadReceipt(List<int> messageIds) async {
    if (_socket == null || messageIds.isEmpty) {
      log('[WebSocket] Cannot send read receipt - socket null or no message IDs',
          name: 'ChatWebSocket');
      return;
    }
    final payload = <String, dynamic>{
      'type': 'read',
      'message_ids': messageIds
    };
    final jsonString = jsonEncode(payload);
    log('[WebSocket] Sending read receipt: $jsonString', name: 'ChatWebSocket');
    _socket!.add(jsonString);
    log('[WebSocket] Read receipt sent', name: 'ChatWebSocket');
  }

  Stream<ChatMessage> listenMessages() {
    log('[WebSocket] Subscribing to message stream', name: 'ChatWebSocket');
    return messagesStream;
  }

  Future<void> disconnect() async {
    log('[WebSocket] Disconnecting...', name: 'ChatWebSocket');
    _isManuallyDisconnected = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    await _disposeSocketOnly();
    log('[WebSocket] Disconnected', name: 'ChatWebSocket');
  }

  void _scheduleReconnect() {
    if (_isManuallyDisconnected || _lastUri == null) {
      log('[WebSocket] Reconnect not scheduled (manual disconnect or no URI)',
          name: 'ChatWebSocket');
      return;
    }
    log('[WebSocket] Scheduling reconnect in 3 seconds...',
        name: 'ChatWebSocket');
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), () async {
      if (_isManuallyDisconnected || _lastUri == null) {
        log('[WebSocket] Reconnect aborted', name: 'ChatWebSocket');
        return;
      }
      log('[WebSocket] Attempting reconnect...', name: 'ChatWebSocket');
      try {
        // Reconnect with auth headers
        final headers = <String, dynamic>{
          ListAPI.headerXUuid: ListAPI.xUuid,
        };
        if (_authToken != null && _authToken!.isNotEmpty) {
          headers['Authorization'] = 'Bearer $_authToken';
        }

        _socket = await WebSocket.connect(
          _lastUri.toString(),
          headers: headers,
        );
        log('[WebSocket] Reconnected successfully!', name: 'ChatWebSocket');
        _subscription = _socket?.listen(
          _onRawEvent,
          onError: (error) {
            log('[WebSocket] Error after reconnect: $error',
                name: 'ChatWebSocket');
            _scheduleReconnect();
          },
          onDone: () {
            log('[WebSocket] Connection closed after reconnect',
                name: 'ChatWebSocket');
            _scheduleReconnect();
          },
        );
      } catch (e, stackTrace) {
        log('[WebSocket] Reconnect failed: $e',
            name: 'ChatWebSocket', error: e, stackTrace: stackTrace);
        _scheduleReconnect();
      }
    });
  }

  Future<void> _disposeSocketOnly() async {
    log('[WebSocket] Disposing socket...', name: 'ChatWebSocket');
    await _subscription?.cancel();
    _subscription = null;
    await _socket?.close();
    _socket = null;
    log('[WebSocket] Socket disposed', name: 'ChatWebSocket');
  }

  Future<void> dispose() async {
    log('[WebSocket] Disposing service...', name: 'ChatWebSocket');
    await disconnect();
    await _messagesController.close();
    log('[WebSocket] Service disposed', name: 'ChatWebSocket');
  }
}
