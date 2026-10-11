import 'package:bonoos/core/values/app_colors.dart';
import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:bonoos/features/common/widget/weekly_listening_chart_card.dart';
import 'package:bonoos/features/statistics/data/listening_stats_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late Future<ListeningStats> _stats = ListeningStatsRepository().fetch();

  void _reload() => setState(() => _stats = ListeningStatsRepository().fetch());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBgColor,
      body: Stack(
        children: [
          const _StatsBackground(),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 18.h),
              child: FutureBuilder<ListeningStats>(
                future: _stats,
                builder: (context, snap) {
                  final stats = snap.data;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _StatsHeader(),
                      SizedBox(height: 14.h),
                      if (snap.connectionState != ConnectionState.done)
                        const Expanded(
                          child: Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          ),
                        )
                      else if (stats == null)
                        Expanded(child: _StatsError(onRetry: _reload))
                      else ...[
                        _StreakCard(days: stats.streak),
                        SizedBox(height: 12.h),
                        Expanded(
                          child: RefreshIndicator(
                            color: AppColors.mainBgColor,
                            onRefresh: () async {
                              _reload();
                              await _stats;
                            },
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              child: _StatsBody(stats: stats),
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsBody extends StatelessWidget {
  const _StatsBody({required this.stats});

  final ListeningStats stats;

  @override
  Widget build(BuildContext context) {
    final top = stats.topToday;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                value: "${stats.totalListens}",
                title: "Marta audio\ntinglagansiz",
                emoji: "🧘🏻‍♀️",
                gradient: const [AppColors.mainBgColor, AppColors.c55004D],
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _MetricCard(
                value: "${stats.totalMinutes}",
                title: "Daqiqa\ntinglangan\nmashg'ulotlar",
                emoji: "🎧",
                gradient: const [AppColors.mainBgColor, AppColors.c55004D],
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        _WideMetricCard(
          value: "${stats.activeDays}",
          title: "Kun davomida\nmashg'ulot qilgansiz",
        ),
        if (top != null) ...[
          SizedBox(height: 12.h),
          _FavouriteCard(
            doneCount: top.listenedCount,
            title: top.audition.text,
            duration: top.audition.durationLabel,
          ),
        ],
        SizedBox(height: 12.h),
        WeeklyListeningChartCard(
          title: "Haftalik tinglash (daqiqa)",
          subtitle: "Oxirgi 7 kun: ${stats.weekMinutes} daqiqa",
          values: stats.dayMinutes,
          labels: stats.dayLabels,
        ),
        SizedBox(height: 16.h),
      ],
    );
  }
}

class _StatsError extends StatelessWidget {
  const _StatsError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.exclamationmark_triangle,
            size: 32.sp,
            color: Colors.white.withValues(alpha: 0.5),
          ),
          SizedBox(height: 10.h),
          Text(
            "Statistikani yuklab bo'lmadi",
            style: AppTextStyles.body13w5.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 12.h),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'Qayta urinish',
              style: AppTextStyles.body14w6.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsBackground extends StatelessWidget {
  const _StatsBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.mainBgColor,
                AppColors.c55004D,
                AppColors.mainBgColor,
              ],
            ),
          ),
        ),
        Positioned(
          top: -90.h,
          left: -70.w,
          child: Container(
            height: 220.w,
            width: 220.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0x3A842D5F), Color(0x00842D5F)],
              ),
            ),
          ),
        ),
        Positioned(
          top: 160.h,
          right: -90.w,
          child: Container(
            height: 260.w,
            width: 260.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0x2A55004D), Color(0x0055004D)],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.04),
                  Colors.white.withValues(alpha: 0.00),
                  Colors.black.withValues(alpha: 0.10),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatsHeader extends StatelessWidget {
  const _StatsHeader();

  @override
  Widget build(BuildContext context) {
    return Row
      (
      children: [
        GestureDetector(
            onTap: (){
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back_ios_new ,color: Colors.white,size: 22.sp,)),
        SizedBox(width: 20.w,),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Statistika",
              style: AppTextStyles.body22w7.copyWith(
                color: Colors.white.withValues(alpha: 0.95),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              "Kichik qadamlar — katta o'zgarish.",
              style: AppTextStyles.body13w4.copyWith(
                color: Colors.white.withValues(alpha: 0.70),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child, this.padding});

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.r),
        color: Colors.white.withValues(alpha: 0.06),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x20842D5F),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.mainBgColor,
            AppColors.c55004D,
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2A842D5F),
            blurRadius: 20,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Ketma-ket kunlar",
                  style: AppTextStyles.body14w6.copyWith(
                    color: Colors.white.withValues(alpha: 0.86),
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "$days",
                      style: AppTextStyles.body24w5.copyWith(
                        color: const Color(0xFFFFC07D),
                        fontSize: 44.sp,
                        height: 1,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Padding(
                      padding: EdgeInsets.only(bottom: 6.h),
                      child: Text(
                        "kun",
                        style: AppTextStyles.body16w6.copyWith(
                          color: const Color(0xFFFFC07D),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 44.w,
            width: 44.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFC07D).withValues(alpha: 0.10),
            ),
            child: const Center(
              child: Text("🔥", style: TextStyle(fontSize: 22)),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.value,
    required this.title,
    this.emoji,
    required this.gradient,
  });

  final String value;
  final String title;
  final String? emoji;
  final List<Color> gradient;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 168.h,
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: AppTextStyles.body24w5.copyWith(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: 36.sp,
                height: 1.0,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: AppTextStyles.body13w4.copyWith(
                color: Colors.white.withValues(alpha: 0.72),
                height: 1.25,
              ),
            ),
            const Spacer(),
            if (emoji != null)
              Text(
                emoji!,
                style: TextStyle(fontSize: 20.sp),
              )
            else
              SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}

class _WideMetricCard extends StatelessWidget {
  const _WideMetricCard({
    required this.value,
    required this.title,
  });

  final String value;
  final String title;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTextStyles.body24w5.copyWith(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontSize: 36.sp,
                    height: 1.0,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  title,
                  style: AppTextStyles.body13w4.copyWith(
                    color: Colors.white.withValues(alpha: 0.72),
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          Text("📅", style: TextStyle(fontSize: 22.sp)),
        ],
      ),
    );
  }
}

class _FavouriteCard extends StatelessWidget {
  const _FavouriteCard({
    required this.doneCount,
    required this.title,
    required this.duration,
  });

  final int doneCount;
  final String title;
  final String duration;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Bugun eng ko'p tinglaganingiz\n$doneCount marta",
            style: AppTextStyles.body14w6.copyWith(
              color: Colors.white.withValues(alpha: 0.90),
              height: 1.2,
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Container(
                height: 44.w,
                width: 44.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.c842D5F, AppColors.c55004D],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x2A842D5F),
                      blurRadius: 16,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(CupertinoIcons.play_fill,
                    color: Colors.white, size: 20),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body16w7.copyWith(
                        color: Colors.white.withValues(alpha: 0.95),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      duration,
                      style: AppTextStyles.body12w4.copyWith(
                        color: Colors.white.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
