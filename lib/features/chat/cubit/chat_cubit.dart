import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/chat_message.dart';
import '../models/chat_thread.dart';
import '../repository/chat_repository.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({required ChatRepository repository})
      : _repository = repository,
        super(const ChatState());

  final ChatRepository _repository;
  StreamSubscription<ChatMessage>? _liveMessagesSubscription;

  Future<void> initialize() async {
    emit(state.copyWith(status: ChatStatus.loading, clearError: true));
    try {
      final chatDoc = await _repository.loadChatDocumentation();
      final variables = {
        for (final variable in chatDoc.variables) variable.key: variable.value
      };
      final threads = await _repository.loadInitialThreads();
      final messages = await _repository.loadInitialMessages();
      final activeThread = threads.isNotEmpty
          ? threads.first
          : ChatThread(
              id: 1,
              userId: 1,
              adminId: 1,
              status: 'open',
              createdAt: DateTime.utc(2026, 04, 29, 20, 18, 29),
              updatedAt: DateTime.utc(2026, 04, 29, 20, 18, 29),
            );
      final wsBaseUrl = variables['wsBaseUrl'] ?? 'ws://localhost:8080';
      final asAdmin = false;
      await _repository.connectToConversation(
        conversationId: activeThread.id,
        asAdmin: asAdmin,
        wsBaseUrl: wsBaseUrl,
      );
      await _liveMessagesSubscription?.cancel();
      _liveMessagesSubscription =
          _repository.listenMessages().listen(_onIncomingMessage);

      final sortedMessages = List<ChatMessage>.from(messages)
        ..sort((a, b) => a.sentAt.compareTo(b.sentAt));
      emit(
        state.copyWith(
          status: ChatStatus.loaded,
          threads: threads,
          activeThread: activeThread,
          messages: sortedMessages,
          isSocketConnected: true,
        ),
      );
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
      await _repository.sendMessage(trimmed);
      final confirmedMessages = state.messages.map((message) {
        if (message.localId == optimistic.localId) {
          return message.copyWith(isLocalPending: false);
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
