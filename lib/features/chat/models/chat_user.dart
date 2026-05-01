import 'dart:convert';

class ChatUser {
  const ChatUser({
    required this.id,
    required this.role,
    this.displayName,
  });

  final int id;
  final int role;
  final String? displayName;

  bool get isAdmin => role == 2;

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: (json['id'] as num?)?.toInt() ?? 0,
      role: (json['role'] as num?)?.toInt() ?? 1,
      displayName: json['display_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'role': role,
      if (displayName != null) 'display_name': displayName,
    };
  }

  factory ChatUser.fromRawJson(String source) =>
      ChatUser.fromJson(jsonDecode(source) as Map<String, dynamic>);

  String toRawJson() => jsonEncode(toJson());
}
