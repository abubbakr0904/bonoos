import 'dart:convert';

class ChatThread {
  const ChatThread({
    required this.id,
    required this.userId,
    required this.adminId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int userId;
  final int adminId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory ChatThread.fromJson(Map<String, dynamic> json) {
    return ChatThread(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      adminId: (json['admin_id'] as num?)?.toInt() ?? 0,
      status: (json['status'] as String?) ?? 'open',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now().toUtc(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now().toUtc(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'user_id': userId,
      'admin_id': adminId,
      'status': status,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };
  }

  factory ChatThread.fromRawJson(String source) =>
      ChatThread.fromJson(jsonDecode(source) as Map<String, dynamic>);

  String toRawJson() => jsonEncode(toJson());
}
