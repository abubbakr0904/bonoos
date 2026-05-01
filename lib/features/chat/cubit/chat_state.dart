import '../models/chat_message.dart';
import '../models/chat_thread.dart';
import '../models/conversation_response.dart';

enum ChatStatus { initial, loading, loaded, error }

class ChatState {
  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const <ChatMessage>[],
    this.threads = const <ChatThread>[],
    this.conversations = const <Conversation>[],
    this.activeThread,
    this.errorMessage,
    this.isSending = false,
    this.isSocketConnected = false,
  });

  final ChatStatus status;
  final List<ChatMessage> messages;
  final List<ChatThread> threads;
  final List<Conversation> conversations;
  final ChatThread? activeThread;
  final String? errorMessage;
  final bool isSending;
  final bool isSocketConnected;

  ChatState copyWith({
    ChatStatus? status,
    List<ChatMessage>? messages,
    List<ChatThread>? threads,
    List<Conversation>? conversations,
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
      conversations: conversations ?? this.conversations,
      activeThread: activeThread ?? this.activeThread,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSending: isSending ?? this.isSending,
      isSocketConnected: isSocketConnected ?? this.isSocketConnected,
    );
  }
}
