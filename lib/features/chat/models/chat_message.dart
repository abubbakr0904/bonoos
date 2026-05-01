import 'dart:convert';

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderRole,
    required this.senderId,
    required this.content,
    required this.isRead,
    required this.sentAt,
    this.isLocalPending = false,
    this.localId,
  });

  final int id;
  final int conversationId;
  final int senderRole;
  final int senderId;
  final String content;
  final bool isRead;
  final DateTime sentAt;
  final bool isLocalPending;
  final String? localId;

  bool get isFromClient => senderRole == 1;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: (json['id'] as num?)?.toInt() ?? 0,
      conversationId: (json['conversation_id'] as num?)?.toInt() ?? 0,
      senderRole: (json['sender_role'] as num?)?.toInt() ?? 1,
      senderId: (json['sender_id'] as num?)?.toInt() ?? 0,
      content: (json['content'] as String?) ?? '',
      isRead: (json['is_read'] as bool?) ?? false,
      sentAt: DateTime.tryParse(json['sent_at'] as String? ?? '') ??
          DateTime.now().toUtc(),
      isLocalPending: (json['is_local_pending'] as bool?) ?? false,
      localId: json['local_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'conversation_id': conversationId,
      'sender_role': senderRole,
      'sender_id': senderId,
      'content': content,
      'is_read': isRead,
      'sent_at': sentAt.toUtc().toIso8601String(),
      if (isLocalPending) 'is_local_pending': isLocalPending,
      if (localId != null) 'local_id': localId,
    };
  }

  ChatMessage copyWith({
    int? id,
    int? conversationId,
    int? senderRole,
    int? senderId,
    String? content,
    bool? isRead,
    DateTime? sentAt,
    bool? isLocalPending,
    String? localId,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderRole: senderRole ?? this.senderRole,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      isRead: isRead ?? this.isRead,
      sentAt: sentAt ?? this.sentAt,
      isLocalPending: isLocalPending ?? this.isLocalPending,
      localId: localId ?? this.localId,
    );
  }

  factory ChatMessage.fromRawJson(String source) =>
      ChatMessage.fromJson(jsonDecode(source) as Map<String, dynamic>);

  String toRawJson() => jsonEncode(toJson());
}
