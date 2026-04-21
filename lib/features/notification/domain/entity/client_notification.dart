class ClientNotification {
  const ClientNotification({
    required this.id,
    required this.scope,
    required this.type,
    required this.title,
    required this.content,
    this.createdAt,
    required this.read,
  });

  final int id;
  final int scope;
  final int type;
  final String title;
  final String content;
  final DateTime? createdAt;
  final bool read;

  factory ClientNotification.fromJson(Map<String, dynamic> json) {
    final readRaw = json['read'];
    return ClientNotification(
      id: (json['id'] as num?)?.toInt() ?? 0,
      scope: (json['scope'] as num?)?.toInt() ?? 0,
      type: (json['type'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      read: readRaw == true || readRaw == 1,
    );
  }

  ClientNotification copyWith({bool? read}) {
    return ClientNotification(
      id: id,
      scope: scope,
      type: type,
      title: title,
      content: content,
      createdAt: createdAt,
      read: read ?? this.read,
    );
  }
}
