/// Chat conversation API response model
class ConversationResponse {
  final List<Conversation> data;

  const ConversationResponse({required this.data});

  factory ConversationResponse.fromJson(Map<String, dynamic> json) {
    return ConversationResponse(
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => Conversation.fromJson(e as Map<String, dynamic>))
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

/// Single conversation model
class Conversation {
  final int id;
  final int userId;

  /// Backend "shared inbox"ga o‘tgan (migration 000024): `admin_id` endi yuborilmaydi — `0`.
  final int adminId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Conversation({
    required this.id,
    required this.userId,
    required this.adminId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      adminId: (json['admin_id'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'admin_id': adminId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
