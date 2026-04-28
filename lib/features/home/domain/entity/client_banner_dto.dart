import 'package:flutter/material.dart';

class ClientBannerDto {
  const ClientBannerDto({
    required this.id,
    required this.pictureNameByLocale,
    required this.picturePathByLocale,
    required this.type,
  });

  final int id;
  final Map<String, String> pictureNameByLocale;
  final Map<String, String> picturePathByLocale;
  final int type;

  static Map<String, String> _localeStringMap(dynamic v) {
    if (v is! Map) return {};
    final out = <String, String>{};
    for (final e in v.entries) {
      out[e.key.toString()] = e.value?.toString() ?? '';
    }
    return out;
  }

  factory ClientBannerDto.fromJson(Map<String, dynamic> json) {
    return ClientBannerDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      pictureNameByLocale: _localeStringMap(json['picture_name']),
      picturePathByLocale: _localeStringMap(json['picture_path']),
      type: (json['type'] as num?)?.toInt() ?? 0,
    );
  }

  String _firstNonEmptyPath() {
    for (final v in picturePathByLocale.values) {
      if (v.trim().isNotEmpty) return v.trim();
    }
    return '';
  }

  /// API kalitlari: `ru_RU`, `uz_UZ`.
  String imageUrlForLocale(Locale locale) {
    final paths = picturePathByLocale;
    switch (locale.languageCode.toLowerCase()) {
      case 'ru':
        return (paths['ru_RU'] ?? paths['ru'] ?? paths['uz_UZ'] ?? paths['uz'] ?? _firstNonEmptyPath()).trim();
      case 'en':
        return (paths['uz_UZ'] ?? paths['en'] ?? paths['ru_RU'] ?? _firstNonEmptyPath()).trim();
      default:
        return (paths['uz_UZ'] ?? paths['uz'] ?? paths['ru_RU'] ?? _firstNonEmptyPath()).trim();
    }
  }
}
