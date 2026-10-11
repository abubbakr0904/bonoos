import 'package:bonoos/core/api/dio_client.dart';
import 'package:bonoos/core/api/list_api.dart';
import 'package:bonoos/di.dart';
import 'package:bonoos/features/playlist/domain/entity/audition.dart';
import 'package:dio/dio.dart';

class DayListening {
  const DayListening({required this.day, required this.seconds, required this.listens});

  /// UTC sana (backend kunlarni UTC bo‘yicha hisoblaydi).
  final DateTime day;
  final int seconds;
  final int listens;

  double get minutes => seconds / 60;
}

class TopAudition {
  const TopAudition({required this.audition, required this.listenedCount});

  final Audition audition;
  final int listenedCount;
}

class ListeningStats {
  const ListeningStats({
    required this.totalListens,
    required this.totalSeconds,
    required this.activeDays,
    required this.lastDays,
    this.topToday,
  });

  final int totalListens;
  final int totalSeconds;
  final int activeDays;

  /// Oxirgi 7 kun, eskisidan bugungacha.
  final List<DayListening> lastDays;
  final TopAudition? topToday;

  int get totalMinutes => totalSeconds ~/ 60;
  int get weekMinutes => lastDays.fold<int>(0, (s, d) => s + d.seconds) ~/ 60;

  /// Bugungacha (bugun hali tinglanmagan bo‘lsa — kechagacha) uzluksiz faol kunlar.
  int get streak {
    var i = lastDays.length - 1;
    if (i >= 0 && lastDays[i].listens == 0) i--;
    var n = 0;
    for (; i >= 0 && lastDays[i].listens > 0; i--) {
      n++;
    }
    return n;
  }

  static const _weekdays = ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sha', 'Ya'];
  List<String> get dayLabels => [for (final d in lastDays) _weekdays[d.day.weekday - 1]];
  List<double> get dayMinutes => [for (final d in lastDays) d.minutes];
}

/// `client/actions-summary`, `client/daily-summary`, `auditions/{id}` — tinglash statistikasi.
class ListeningStatsRepository {
  final DioClient _dio = inject<DioClient>();

  Future<ListeningStats> fetch() async {
    final today = DateTime.now().toUtc();
    final days = [
      for (var i = 6; i >= 0; i--) DateTime.utc(today.year, today.month, today.day - i),
    ];

    final results = await Future.wait([
      _summary(),
      for (final d in days) _summary(from: d, to: d),
    ]);
    final total = results.first;
    final lastDays = [
      for (var i = 0; i < days.length; i++)
        DayListening(
          day: days[i],
          seconds: _int(results[i + 1]['total_duration']),
          listens: _int(results[i + 1]['total_listen_events']),
        ),
    ];

    return ListeningStats(
      totalListens: _int(total['total_listen_events']),
      totalSeconds: _int(total['total_duration']),
      activeDays: _int(total['active_days']),
      lastDays: lastDays,
      topToday: lastDays.last.listens > 0 ? await _topToday(days.last) : null,
    );
  }

  Future<Map<String, dynamic>> _summary({DateTime? from, DateTime? to}) async {
    final raw = await _dio.get(
      ListAPI.clientActionsSummary,
      queryParameters: {
        if (from != null) 'from': _ymd(from),
        if (to != null) 'to': _ymd(to),
      },
    );
    final data = ((raw as Response<dynamic>).data as Map?)?['data'];
    return data is Map ? Map<String, dynamic>.from(data) : const {};
  }

  /// Bugun eng ko‘p tinglangan audio. Xatolik statistikani buzmasin — `null`.
  Future<TopAudition?> _topToday(DateTime day) async {
    try {
      final raw = await _dio.get(ListAPI.clientDailySummary, queryParameters: {'day': _ymd(day)});
      final list = ((raw as Response<dynamic>).data as Map?)?['data'];
      if (list is! List || list.isEmpty) return null;
      final rows = list.whereType<Map>().toList()
        ..sort((a, b) => _int(b['listened_count']).compareTo(_int(a['listened_count'])));
      final top = rows.first;
      final res = await _dio.get(ListAPI.auditionById(_int(top['audition_id'])));
      final a = ((res as Response<dynamic>).data as Map?)?['data'];
      if (a is! Map) return null;
      return TopAudition(
        audition: Audition.fromJson(Map<String, dynamic>.from(a)),
        listenedCount: _int(top['listened_count']),
      );
    } on DioException {
      return null;
    }
  }

  static int _int(dynamic v) => (v as num?)?.toInt() ?? 0;

  static String _ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
