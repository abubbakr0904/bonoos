import '../models/chat_message.dart';
import '../models/chat_thread.dart';
import '../models/postman_collection.dart';
import '../services/chat_seed_loader_service.dart';
import '../services/chat_websocket_service.dart';

class ChatRepository {
  ChatRepository({
    required ChatSeedLoaderService seedLoaderService,
    required ChatWebSocketService websocketService,
  })  : _seedLoaderService = seedLoaderService,
        _websocketService = websocketService;

  final ChatSeedLoaderService _seedLoaderService;
  final ChatWebSocketService _websocketService;

  Future<PostmanCollection> loadChatDocumentation() {
    return _seedLoaderService.loadChatCollection();
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

  Future<void> sendMessage(String content) =>
      _websocketService.sendMessage(content);

  Stream<ChatMessage> listenMessages() => _websocketService.listenMessages();

  Future<void> disconnect() => _websocketService.disconnect();
}
