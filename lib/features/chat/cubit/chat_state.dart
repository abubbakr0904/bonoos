import '../models/chat_message.dart';
import '../models/chat_thread.dart';

enum ChatStatus { initial, loading, loaded, error }

class ChatState {
  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const <ChatMessage>[],
    this.threads = const <ChatThread>[],
    this.activeThread,
    this.errorMessage,
    this.isSending = false,
    this.isSocketConnected = false,
  });

  final ChatStatus status;
  final List<ChatMessage> messages;
  final List<ChatThread> threads;
  final ChatThread? activeThread;
  final String? errorMessage;
  final bool isSending;
  final bool isSocketConnected;

  ChatState copyWith({
    ChatStatus? status,
    List<ChatMessage>? messages,
    List<ChatThread>? threads,
    ChatThread? activeThread,
    String? errorMessage,
    bool clearError = false,
    bool? isSending,
    bool? isSocketConnected,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      threads: threads ?? this.threads,
      activeThread: activeThread ?? this.activeThread,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSending: isSending ?? this.isSending,
      isSocketConnected: isSocketConnected ?? this.isSocketConnected,
    );
  }
}
