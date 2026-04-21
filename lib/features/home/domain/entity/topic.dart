import 'package:bonoos/core/utils/localized_content.dart';
import 'package:flutter/material.dart';

/// GET `/api/v1/topics` — yo‘nalish (masalan: Oila, Do‘st).
class Topic {
  const Topic({
    required this.id,
    required this.name,
    required this.description,
    required this.contentByLocale,
    required this.status,
    required this.sort,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String name;
  final String description;
  /// Kalitlar: `en`, `ru`, `uz`
  final Map<String, String> contentByLocale;
  final int status;
  final int sort;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Topic.fromJson(Map<String, dynamic> json) {
    final contentRaw = json['content'];
    final Map<String, String> content = {};
    if (contentRaw is Map) {
      for (final e in contentRaw.entries) {
        final v = e.value;
        content[e.key.toString()] = v == null ? '' : v.toString();
      }
    }
    return Topic(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      contentByLocale: content,
      status: (json['status'] as num?)?.toInt() ?? 0,
      sort: (json['sort'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  /// Joriy ilova tiliga mos matn (`en` / `ru` / `uz`).
  String contentForLocale(Locale locale) =>
      localizedFromContentMap(contentByLocale, locale);
}
