import 'package:bonoos/features/common/widget/weekly_listening_chart_card.dart';
import 'package:bonoos/features/statistics/data/listening_stats_repository.dart';
import 'package:bonoos/features/statistics/statistics_screen.dart';
import 'package:flutter/material.dart';

/// Bosh sahifadagi haftalik grafik — haqiqiy ma'lumot; bosilsa Statistika ekrani.
class HomeWeeklyChart extends StatefulWidget {
  const HomeWeeklyChart({super.key});

  @override
  State<HomeWeeklyChart> createState() => _HomeWeeklyChartState();
}

class _HomeWeeklyChartState extends State<HomeWeeklyChart> {
  ListeningStats? _stats;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final stats = await ListeningStatsRepository().fetch();
      if (mounted) setState(() => _stats = stats);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> _openStatistics() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const StatisticsScreen()),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final stats = _stats;
    return GestureDetector(
      onTap: _openStatistics,
      child: WeeklyListeningChartCard(
        title: "Haftalik tinglash (daqiqa)",
        subtitle: stats != null
            ? "Oxirgi 7 kun: ${stats.weekMinutes} daqiqa · batafsil →"
            : _failed
                ? "Ma'lumot yuklanmadi"
                : "Yuklanmoqda…",
        values: stats?.dayMinutes ?? List.filled(7, 0),
        labels: stats?.dayLabels ?? const ["Du", "Se", "Ch", "Pa", "Ju", "Sha", "Ya"],
      ),
    );
  }
}
