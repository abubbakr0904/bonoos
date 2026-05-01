import 'package:bonoos/core/api/dio_client.dart';
import 'package:bonoos/core/api/list_api.dart';

import '../models/chat_message.dart';
import '../models/chat_thread.dart';
import '../models/conversation_response.dart';
import '../models/message_response.dart';
import '../models/postman_collection.dart';
import '../services/chat_seed_loader_service.dart';
import '../services/chat_websocket_service.dart';

class ChatRepository {
  ChatRepository({
    required ChatSeedLoaderService seedLoaderService,
    required ChatWebSocketService websocketService,
    required DioClient dioClient,
  })  : _seedLoaderService = seedLoaderService,
        _websocketService = websocketService,
        _dioClient = dioClient;

  final ChatSeedLoaderService _seedLoaderService;
  final ChatWebSocketService _websocketService;
  final DioClient _dioClient;

  Future<PostmanCollection> loadChatDocumentation() {
    return _seedLoaderService.loadChatCollection();
  }

  /// Fetch conversations from API
  Future<List<Conversation>> getConversations({int limit = 50}) async {
    final response = await _dioClient.get(
      ListAPI.clientChatConversations(limit: limit),
    );
    final conversationResponse = ConversationResponse.fromJson(response.data);
    return conversationResponse.data;
  }

  /// Create new conversation
  Future<Conversation> createConversation({int adminId = 2}) async {
    final response = await _dioClient.post(
      ListAPI.clientChatConversationsCreate,
      data: CreateConversationRequest(adminId: adminId).toJson(),
    );
    return Conversation.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  /// Fetch messages from API for a conversation
  Future<List<Message>> getMessages({
    required int conversationId,
    int limit = 50,
    int beforeId = 0,
  }) async {
    final response = await _dioClient.get(
      ListAPI.clientChatMessages(
        conversationId: conversationId,
        limit: limit,
        beforeId: beforeId,
      ),
    );
    final messageResponse = MessageResponse.fromJson(response.data);
    return messageResponse.data;
  }

  /// Send message via API (HTTP)
  Future<Message> sendMessageHttp({
    required int conversationId,
    required String content,
  }) async {
    final response = await _dioClient.post(
      ListAPI.clientChatMessagesSend,
      data: SendMessageRequest(
        conversationId: conversationId,
        content: content,
      ).toJson(),
    );
    return Message.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<List<ChatThread>> loadInitialThreads() {
    return _seedLoaderService.loadSeedThreads();
  }

  Future<List<ChatMessage>> loadInitialMessages() {
    return _seedLoaderService.loadSeedMessages();
  }

  Future<void> connectToConversation({
    required int conversationId,
    required bool asAdmin,
    required String wsBaseUrl,
  }) {
    return _websocketService.connect(
      baseWsUrl: wsBaseUrl,
      rolePath: asAdmin ? 'admin' : 'client',
      conversationId: conversationId,
    );
  }

  /// Send message via WebSocket (real-time)
  Future<void> sendMessageWebSocket(String content) =>
      _websocketService.sendMessage(content);

  Stream<ChatMessage> listenMessages() => _websocketService.listenMessages();

  Future<void> disconnect() => _websocketService.disconnect();
}
