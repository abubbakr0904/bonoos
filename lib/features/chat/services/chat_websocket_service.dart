import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../models/chat_message.dart';

class ChatWebSocketService {
  WebSocket? _socket;
  StreamSubscription<dynamic>? _subscription;
  final StreamController<ChatMessage> _messagesController =
      StreamController<ChatMessage>.broadcast();
  Timer? _reconnectTimer;
  bool _isManuallyDisconnected = false;
  Uri? _lastUri;

  Stream<ChatMessage> get messagesStream => _messagesController.stream;
  bool get isConnected => _socket != null;

  Future<void> connect({
    required String baseWsUrl,
    required String rolePath,
    required int conversationId,
  }) async {
    _isManuallyDisconnected = false;
    final uri = Uri.parse(
        '$baseWsUrl/api/v1/$rolePath/chat/ws?conversation_id=$conversationId');
    _lastUri = uri;

    await _disposeSocketOnly();
    try {
      _socket = await WebSocket.connect(uri.toString());
      _subscription = _socket?.listen(
        _onRawEvent,
        onError: (_) => _scheduleReconnect(),
        onDone: _scheduleReconnect,
      );
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _onRawEvent(dynamic event) {
    if (event is! String) return;
    final json = jsonDecode(event) as Map<String, dynamic>;
    final type = json['type'] as String? ?? '';
    if (type != 'message') return;
    final payload = json['message'];
    if (payload is! Map<String, dynamic>) return;
    _messagesController.add(ChatMessage.fromJson(payload));
  }

  Future<void> sendMessage(String content) async {
    if (_socket == null) return;
    final payload = <String, dynamic>{'type': 'send', 'content': content};
    _socket!.add(jsonEncode(payload));
  }

  Future<void> sendReadReceipt(List<int> messageIds) async {
    if (_socket == null || messageIds.isEmpty) return;
    final payload = <String, dynamic>{
      'type': 'read',
      'message_ids': messageIds
    };
    _socket!.add(jsonEncode(payload));
  }

  Stream<ChatMessage> listenMessages() => messagesStream;

  Future<void> disconnect() async {
    _isManuallyDisconnected = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    await _disposeSocketOnly();
  }

  void _scheduleReconnect() {
    if (_isManuallyDisconnected || _lastUri == null) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), () async {
      if (_isManuallyDisconnected || _lastUri == null) return;
      try {
        _socket = await WebSocket.connect(_lastUri.toString());
        _subscription = _socket?.listen(
          _onRawEvent,
          onError: (_) => _scheduleReconnect(),
          onDone: _scheduleReconnect,
        );
      } catch (_) {
        _scheduleReconnect();
      }
    });
  }

  Future<void> _disposeSocketOnly() async {
    await _subscription?.cancel();
    _subscription = null;
    await _socket?.close();
    _socket = null;
  }

  Future<void> dispose() async {
    await disconnect();
    await _messagesController.close();
  }
}
