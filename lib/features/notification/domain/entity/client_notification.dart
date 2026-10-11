import 'package:bonoos/core/api/list_api.dart';
import 'package:bonoos/di.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Backend `title`/`content` ni oddiy satr yoki `{ "uz", "ru", "en" }` ko‘rinishida yuboradi.
/// Ilova tili (`app_lang`) ustun, keyin uz → ru → en.
String localizedText(dynamic value) {
  if (value == null) return '';
  if (value is String) return value;
  if (value is Map) {
    final lang = inject<SharedPreferences>().getString(SharedModel.lang) ?? 'uz';
    for (final key in [lang, 'uz', 'ru', 'en']) {
      final v = value[key];
      if (v is String && v.trim().isNotEmpty) return v;
    }
    for (final v in value.values) {
      if (v is String && v.trim().isNotEmpty) return v;
    }
    return '';
  }
  return value.toString();
}

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
      title: localizedText(json['title']),
      content: localizedText(json['content']),
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
