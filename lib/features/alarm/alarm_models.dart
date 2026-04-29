import 'dart:convert';

class AlarmVoiceCatalog {
  AlarmVoiceCatalog._();

  static const String defaultPath = 'assets/voice/audio1.mp3';
  static const String defaultLabel = 'Ovoz 1';

  static const List<({String label, String path})> options = [
    (label: 'Ovoz 1', path: 'assets/voice/audio1.mp3'),
    (label: 'Ovoz 2', path: 'assets/voice/audio2.mp3'),
    (label: 'Ovoz 3', path: 'assets/voice/audio3.mp3'),
  ];
}

class AlarmItem {
  const AlarmItem({
    required this.time,
    required this.enabled,
    this.id = 0,
    this.hour = 0,
    this.minute = 0,
    this.voiceAssetPath = AlarmVoiceCatalog.defaultPath,
    this.voiceLabel = AlarmVoiceCatalog.defaultLabel,
  });

  factory AlarmItem.fromHourMinute({
    required int id,
    required int hour,
    required int minute,
    required bool enabled,
    required String voiceAssetPath,
    required String voiceLabel,
  }) {
    final h = hour.clamp(0, 23);
    final m = minute.clamp(0, 59);
    final twoHour = h.toString().padLeft(2, '0');
    final twoMinute = m.toString().padLeft(2, '0');
    return AlarmItem(
      id: id,
      hour: h,
      minute: m,
      time: '$twoHour:$twoMinute',
      enabled: enabled,
      voiceAssetPath: voiceAssetPath,
      voiceLabel: voiceLabel,
    );
  }

  factory AlarmItem.fromJson(Map<String, dynamic> json) {
    return AlarmItem.fromHourMinute(
      id: json['id'] as int? ?? 0,
      hour: json['hour'] as int? ?? 0,
      minute: json['minute'] as int? ?? 0,
      enabled: json['enabled'] as bool? ?? true,
      voiceAssetPath: json['voiceAssetPath'] as String? ?? AlarmVoiceCatalog.defaultPath,
      voiceLabel: json['voiceLabel'] as String? ?? AlarmVoiceCatalog.defaultLabel,
    );
  }

  static List<AlarmItem> decodeList(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(AlarmItem.fromJson)
        .toList();
  }

  static String encodeList(List<AlarmItem> items) {
    return jsonEncode(items.map((e) => e.toJson()).toList());
  }

  final int id;
  final int hour;
  final int minute;
  final String time;
  final bool enabled;
  final String voiceAssetPath;
  final String voiceLabel;

  AlarmItem copyWith({
    int? id,
    int? hour,
    int? minute,
    String? time,
    bool? enabled,
    String? voiceAssetPath,
    String? voiceLabel,
  }) {
    return AlarmItem(
      id: id ?? this.id,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      time: time ?? this.time,
      enabled: enabled ?? this.enabled,
      voiceAssetPath: voiceAssetPath ?? this.voiceAssetPath,
      voiceLabel: voiceLabel ?? this.voiceLabel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hour': hour,
      'minute': minute,
      'enabled': enabled,
      'voiceAssetPath': voiceAssetPath,
      'voiceLabel': voiceLabel,
    };
  }
}

class AlarmDraft {
  const AlarmDraft({
    required this.hour,
    required this.minute,
    required this.voiceAssetPath,
    required this.voiceLabel,
  });

  final int hour;
  final int minute;
  final String voiceAssetPath;
  final String voiceLabel;
}

/// Add / edit alarm ekranidan qaytish natijasi.
class AlarmFormResult {
  const AlarmFormResult.saved(AlarmDraft this.draft) : deleted = false;

  const AlarmFormResult.deleted()
      : draft = null,
        deleted = true;

  final AlarmDraft? draft;
  final bool deleted;

  bool get isDeleted => deleted;
}
