/// Chat message API response model
class MessageResponse {
  final List<Message> data;

  const MessageResponse({required this.data});

  factory MessageResponse.fromJson(Map<String, dynamic> json) {
    return MessageResponse(
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => Message.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

/// Single message model from API
class Message {
  final int id;
  final int conversationId;
  final int senderRole;
  final int senderId;
  final String content;
  final bool isRead;
  final DateTime sentAt;

  const Message({
    required this.id,
    required this.conversationId,
    required this.senderRole,
    required this.senderId,
    required this.content,
    required this.isRead,
    required this.sentAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as int,
      conversationId: json['conversation_id'] as int,
      senderRole: json['sender_role'] as int,
      senderId: json['sender_id'] as int,
      content: json['content'] as String,
      isRead: json['is_read'] as bool,
      sentAt: DateTime.parse(json['sent_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_role': senderRole,
      'sender_id': senderId,
      'content': content,
      'is_read': isRead,
      'sent_at': sentAt.toIso8601String(),
    };
  }
}

/// Send message request body
class SendMessageRequest {
  final int conversationId;
  final String content;

  const SendMessageRequest({
    required this.conversationId,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'conversation_id': conversationId,
      'content': content,
    };
  }
}
