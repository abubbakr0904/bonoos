import 'package:flutter_dotenv/flutter_dotenv.dart';

class Audition {
  const Audition({
    required this.id,
    required this.categoryId,
    required this.type,
    required this.audio,
    required this.duration,
    required this.text,
    this.favorited = false,
  });

  final int id;
  final int categoryId;
  final int type;
  final String audio;
  final int duration;
  final String text;
  final bool favorited;

  factory Audition.fromJson(Map<String, dynamic> json) {
    final fav = json['favorited'];
    return Audition(
      id: (json['id'] as num?)?.toInt() ?? 0,
      categoryId: (json['category_id'] as num?)?.toInt() ?? 0,
      type: (json['type'] as num?)?.toInt() ?? 0,
      audio: json['audio'] as String? ?? '',
      duration: (json['duration'] as num?)?.toInt() ?? 0,
      text: json['text'] as String? ?? '',
      favorited: fav == true || fav == 1,
    );
  }

  Audition copyWith({bool? favorited}) {
    return Audition(
      id: id,
      categoryId: categoryId,
      type: type,
      audio: audio,
      duration: duration,
      text: text,
      favorited: favorited ?? this.favorited,
    );
  }

  String get fullAudioUrl {
    final a = audio.trim();
    if (a.isEmpty) return '';
    if (a.startsWith('http://') || a.startsWith('https://')) return a;
    final base = (dotenv.env['BASE_URL'] ?? '').replaceAll(RegExp(r'/$'), '');
    if (base.isEmpty) return a;
    final path = a.startsWith('/') ? a : '/$a';
    return '$base$path';
  }

  String get formattedDuration {
    final m = duration ~/ 60;
    final s = duration % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get durationLabel {
    final m = duration ~/ 60;
    if (m <= 0) return '$duration soniya';
    return '$m daqiqa';
  }
}
