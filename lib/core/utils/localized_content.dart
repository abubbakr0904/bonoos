import 'package:flutter/material.dart';

/// `content: { en, ru, uz }` kabi obyektlardan joriy tilga mos qatorni tanlaydi.
String localizedFromContentMap(Map<String, String> map, Locale locale) {
  final code = locale.languageCode.toLowerCase();
  final script = locale.scriptCode?.toLowerCase();
  final country = locale.countryCode?.toLowerCase();
  if (code == 'ru') {
    return _firstNonEmpty(map, ['ru', 'uz', 'en']);
  }
  if (code == 'en') {
    return _firstNonEmpty(map, ['en', 'uz', 'ru']);
  }
  if (code == 'uz' || country == 'cyrl' || script == 'cyrl') {
    return _firstNonEmpty(map, ['uz', 'ru', 'en']);
  }
  return _firstNonEmpty(map, ['uz', 'en', 'ru']);
}

String _firstNonEmpty(Map<String, String> map, List<String> keys) {
  for (final k in keys) {
    final t = map[k]?.trim();
    if (t != null && t.isNotEmpty) return t;
  }
  for (final v in map.values) {
    if (v.trim().isNotEmpty) return v;
  }
  return '';
}
