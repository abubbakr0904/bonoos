import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LastListenedItem {
  const LastListenedItem({
    required this.title,
    required this.durationLabel,
    required this.audioUrl,
    required this.formattedDuration,
  });

  final String title;
  final String durationLabel;
  final String audioUrl;
  final String formattedDuration;

  Map<String, dynamic> toJson() => {
        'title': title,
        'durationLabel': durationLabel,
        'audioUrl': audioUrl,
        'formattedDuration': formattedDuration,
      };

  factory LastListenedItem.fromJson(Map<String, dynamic> json) {
    return LastListenedItem(
      title: json['title'] as String? ?? '',
      durationLabel: json['durationLabel'] as String? ?? '',
      audioUrl: json['audioUrl'] as String? ?? '',
      formattedDuration: json['formattedDuration'] as String? ?? '',
    );
  }
}

class LastListenedManager {
  LastListenedManager._();

  static const _key = 'last_listened_audio';

  static final ValueNotifier<LastListenedItem?> notifier = ValueNotifier(null);

  static Future<void> init(SharedPreferences prefs) async {
    final raw = prefs.getString(_key);
    if (raw != null && raw.isNotEmpty) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        notifier.value = LastListenedItem.fromJson(map);
      } catch (_) {}
    }
  }

  static Future<void> save({
    required SharedPreferences prefs,
    required String title,
    required String durationLabel,
    required String audioUrl,
    required String formattedDuration,
  }) async {
    final item = LastListenedItem(
      title: title,
      durationLabel: durationLabel,
      audioUrl: audioUrl,
      formattedDuration: formattedDuration,
    );
    notifier.value = item;
    await prefs.setString(_key, jsonEncode(item.toJson()));
  }

  static LastListenedItem? get current => notifier.value;
}
