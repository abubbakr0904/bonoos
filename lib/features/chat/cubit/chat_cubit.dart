import 'dart:async';
import 'package:bonoos/core/api/list_api.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/chat_message.dart';
import '../models/chat_thread.dart';
import '../models/conversation_response.dart';
import '../repository/chat_repository.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({required ChatRepository repository})
      : _repository = repository,
        super(const ChatState());

  final ChatRepository _repository;
  StreamSubscription<ChatMessage>? _liveMessagesSubscription;

  /// Initialize chat - fetch conversations and setup
  Future<void> initialize() async {
    emit(state.copyWith(status: ChatStatus.loading, clearError: true));
    try {
      // Fetch conversations from API
      final conversations = await _repository.getConversations(limit: 50);

      if (conversations.isEmpty) {
        // No conversations - automatically create one
        await _createConversationAndSetup();
        return;
      }

      // Use first conversation
      final conversation = conversations.first;
      await _setupConversation(conversation, conversations);
    } catch (e) {
      emit(
        state.copyWith(
          status: ChatStatus.error,
          errorMessage: 'Chatni yuklashda xatolik: $e',
          isSocketConnected: false,
        ),
      );
    }
  }

  /// Automatically create conversation and setup
  Future<void> _createConversationAndSetup() async {
    try {
      final conversation = await _repository.createConversation();
      await _setupConversation(conversation, [conversation]);
    } catch (e) {
      emit(
        state.copyWith(
          status: ChatStatus.error,
          errorMessage: 'Suhbat yaratishda xatolik: $e',
          isSocketConnected: false,
        ),
      );
    }
  }

  /// Setup conversation - fetch messages and connect WebSocket
  Future<void> _setupConversation(
    Conversation conversation,
    List<Conversation> conversations,
  ) async {
    try {
      // Fetch messages from API
      final apiMessages = await _repository.getMessages(
        conversationId: conversation.id,
        limit: 50,
        beforeId: 0,
      );

      // Convert API messages to ChatMessage
      final messages = apiMessages
          .map((m) => ChatMessage(
                id: m.id,
                conversationId: m.conversationId,
                senderRole: m.senderRole,
                senderId: m.senderId,
                content: m.content,
                isRead: m.isRead,
                sentAt: m.sentAt,
                isLocalPending: false,
              ))
          .toList();

      // Convert conversation to ChatThread
      final activeThread = ChatThread(
        id: conversation.id,
        userId: conversation.userId,
        adminId: conversation.adminId,
        status: conversation.status,
        createdAt: conversation.createdAt,
        updatedAt: conversation.updatedAt,
      );

      final wsBaseUrl = ListAPI.wsBaseUrl;
      const asAdmin = false;

      print('[ChatCubit] Connecting to WebSocket: $wsBaseUrl');
      await _repository.connectToConversation(
        conversationId: activeThread.id,
        asAdmin: asAdmin,
        wsBaseUrl: wsBaseUrl,
      );

      await _liveMessagesSubscription?.cancel();
      _liveMessagesSubscription = _repository.listenMessages().listen(
        _onIncomingMessage,
        onError: (error) {
          print('[ChatCubit] WebSocket error: $error');
          _handleDisconnect();
        },
        onDone: () {
          print('[ChatCubit] WebSocket connection closed');
          _handleDisconnect();
        },
      );

      final sortedMessages = List<ChatMessage>.from(messages)
        ..sort((a, b) => a.sentAt.compareTo(b.sentAt));

      emit(
        state.copyWith(
          status: ChatStatus.loaded,
          conversations: conversations,
          activeThread: activeThread,
          messages: sortedMessages,
          isSocketConnected: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ChatStatus.error,
          errorMessage: 'WebSocket ulanishida xatolik: $e',
          isSocketConnected: false,
        ),
      );
    }
  }

  /// Send message via HTTP API
  Future<void> sendMessage({
    required String content,
    required int currentUserId,
  }) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty || state.activeThread == null) return;

    final optimistic = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch,
      conversationId: state.activeThread!.id,
      senderRole: 1,
      senderId: currentUserId,
      content: trimmed,
      isRead: true,
      sentAt: DateTime.now().toUtc(),
      isLocalPending: true,
      localId: DateTime.now().microsecondsSinceEpoch.toString(),
    );

    final nextMessages = <ChatMessage>[...state.messages, optimistic]
      ..sort((a, b) => a.sentAt.compareTo(b.sentAt));
    emit(state.copyWith(messages: nextMessages, isSending: true));

    try {
      // Send message via HTTP API
      final sentMessage = await _repository.sendMessageHttp(
        conversationId: state.activeThread!.id,
        content: trimmed,
      );

      // Replace optimistic message with confirmed one
      final confirmedMessages = state.messages.map((message) {
        if (message.localId == optimistic.localId) {
          return ChatMessage(
            id: sentMessage.id,
            conversationId: sentMessage.conversationId,
            senderRole: sentMessage.senderRole,
            senderId: sentMessage.senderId,
            content: sentMessage.content,
            isRead: sentMessage.isRead,
            sentAt: sentMessage.sentAt,
            isLocalPending: false,
            localId: message.localId,
          );
        }
        return message;
      }).toList();

      emit(state.copyWith(messages: confirmedMessages, isSending: false));
    } catch (e) {
      emit(
        state.copyWith(
          isSending: false,
          errorMessage: 'Xabar yuborilmadi: $e',
        ),
      );
    }
  }

  /// WebSocket uzilganda chaqiriladi
  void _handleDisconnect() {
    print('[ChatCubit] Handling disconnect, scheduling reconnect...');
    emit(state.copyWith(isSocketConnected: false));
    // 2 soniyadan keyin qayta ulanish
    Future.delayed(const Duration(seconds: 2), () {
      if (!isClosed) {
        _attemptReconnect();
      }
    });
  }

  /// Qayta ulanishga urinish
  Future<void> _attemptReconnect() async {
    if (state.activeThread == null || isClosed) return;
    print('[ChatCubit] Attempting reconnect...');
    try {
      final wsBaseUrl = ListAPI.wsBaseUrl;
      print('[ChatCubit] Reconnecting to: $wsBaseUrl');

      await _repository.connectToConversation(
        conversationId: state.activeThread!.id,
        asAdmin: false,
        wsBaseUrl: wsBaseUrl,
      );

      await _liveMessagesSubscription?.cancel();
      _liveMessagesSubscription = _repository.listenMessages().listen(
        _onIncomingMessage,
        onError: (error) {
          print('[ChatCubit] Reconnect WebSocket error: $error');
          _handleDisconnect();
        },
        onDone: () {
          print('[ChatCubit] Reconnect WebSocket closed');
          _handleDisconnect();
        },
      );

      emit(state.copyWith(isSocketConnected: true));
      print('[ChatCubit] Reconnected successfully!');
    } catch (e) {
      print('[ChatCubit] Reconnect failed: $e');
      // 5 soniyadan keyin yana urinib ko'rish
      Future.delayed(const Duration(seconds: 5), () {
        if (!isClosed) {
          _attemptReconnect();
        }
      });
    }
  }

  /// Manual reconnect (UI dan chaqirish uchun)
  Future<void> reconnect() async {
    print('[ChatCubit] Manual reconnect triggered');
    await _attemptReconnect();
  }

  void _onIncomingMessage(ChatMessage incoming) {
    final exists = state.messages.any(
      (msg) =>
          msg.id == incoming.id ||
          (msg.localId != null &&
              msg.content == incoming.content &&
              msg.senderId == incoming.senderId),
    );
    if (exists) {
      final updated = state.messages.map((msg) {
        if (msg.content == incoming.content &&
            msg.senderId == incoming.senderId &&
            msg.isLocalPending) {
          return incoming.copyWith(localId: msg.localId, isLocalPending: false);
        }
        return msg;
      }).toList()
        ..sort((a, b) => a.sentAt.compareTo(b.sentAt));
      emit(state.copyWith(messages: updated));
      return;
    }

    final updatedMessages = <ChatMessage>[...state.messages, incoming]
      ..sort((a, b) => a.sentAt.compareTo(b.sentAt));
    emit(state.copyWith(messages: updatedMessages));
  }

  @override
  Future<void> close() async {
    await _liveMessagesSubscription?.cancel();
    await _repository.disconnect();
    return super.close();
  }
}
