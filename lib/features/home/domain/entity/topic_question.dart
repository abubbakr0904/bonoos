import 'package:bonoos/core/utils/localized_content.dart';
import 'package:flutter/material.dart';

/// GET `/api/v1/topics/{id}/questions` — bitta yo‘nalishdagi savollar.
/// Javobda `text` yoki `content: { en, ru, uz }` bo‘lishi mumkin.
class TopicQuestion {
  const TopicQuestion({
    required this.id,
    required this.contentByLocale,
    required this.sort,
    this.topicId,
    this.status,
  });

  final int id;
  final int? topicId;
  final Map<String, String> contentByLocale;
  final int sort;
  final int? status;

  factory TopicQuestion.fromJson(Map<String, dynamic> json) {
    final contentRaw = json['content'];
    final Map<String, String> content = {};
    if (contentRaw is Map) {
      for (final e in contentRaw.entries) {
        final v = e.value;
        content[e.key.toString()] = v == null ? '' : v.toString();
      }
    }
    if (content.isEmpty) {
      final direct = json['text'] ?? json['question'] ?? json['body'];
      if (direct != null) {
        final s = direct.toString();
        // API `text` bitta til — barcha kalitlarga qo‘yiladi (locale tanlash bir xil matn qaytaradi).
        content['uz'] = s;
        content['en'] = s;
        content['ru'] = s;
      }
    }
    return TopicQuestion(
      id: (json['id'] as num?)?.toInt() ?? 0,
      topicId: (json['topic_id'] as num?)?.toInt(),
      contentByLocale: content,
      sort: (json['sort'] as num?)?.toInt() ?? 0,
      status: (json['status'] as num?)?.toInt(),
    );
  }

  String textForLocale(Locale locale) =>
      localizedFromContentMap(contentByLocale, locale);
}
