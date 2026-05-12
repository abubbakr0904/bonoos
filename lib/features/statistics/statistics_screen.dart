import 'package:bonoos/core/values/app_colors.dart';
import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:bonoos/features/common/widget/weekly_listening_chart_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Demo data (wire to real analytics later)
    const streakDays = 1;
    const meditationsCount = 13;
    const listenedMinutes = 0;
    const breathingDone = 0;
    const favouriteDone = 1;
    const favouriteTitle = "для тебя";
    const favouriteDuration = "2 минуты";
    const weeklyMinutes = <double>[0, 6, 12, 8, 16, 10, 14];

    return Scaffold(
      backgroundColor: AppColors.mainBgColor,
      body: Stack(
        children: [
          const _StatsBackground(),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 18.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _StatsHeader(),
                  SizedBox(height: 14.h),
                  _StreakCard(days: streakDays),
                  SizedBox(height: 12.h),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _MetricCard(
                                  value: "$meditationsCount",
                                  title: "Медитаций вы\nуже послушали",
                                  emoji: "🧘🏻‍♀️",
                                  gradient: const [
                                    AppColors.mainBgColor,
                                    AppColors.c55004D,
                                  ],
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: _MetricCard(
                                  value: "$listenedMinutes",
                                  title: "Минут\nпрослушанных\nмедитаций",
                                  actionLabel: "История",
                                  onAction: () {},
                                  gradient: const [
                                    AppColors.mainBgColor,
                                    AppColors.c55004D,
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          _WideMetricCard(
                            value: "$breathingDone",
                            title: "Раз выполнена\nпрактика дыхания",
                            actionLabel: "История",
                            onAction: () {},
                          ),
                          SizedBox(height: 12.h),
                          _FavouriteCard(
                            doneCount: favouriteDone,
                            title: favouriteTitle,
                            duration: favouriteDuration,
                          ),
                          SizedBox(height: 12.h),
                          WeeklyListeningChartCard(
                            title: "Weekly listening (minutes)",
                            subtitle: "Static demo data",
                            values: weeklyMinutes,
                            labels: const [
                              "Mon",
                              "Tue",
                              "Wed",
                              "Thu",
                              "Fri",
                              "Sat",
                              "Sun"
                            ],
                          ),
                          SizedBox(height: 16.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
              "Statistics",
              style: AppTextStyles.body22w7.copyWith(
                color: Colors.white.withValues(alpha: 0.95),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              "Soft progress you can feel.",
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
                  "Ударный режим",
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
                        "день",
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
    this.actionLabel,
    this.onAction,
    required this.gradient,
  });

  final String value;
  final String title;
  final String? emoji;
  final String? actionLabel;
  final VoidCallback? onAction;
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
            if (actionLabel != null)
              Align(
                alignment: Alignment.centerRight,
                child: _PillButton(
                  label: actionLabel!,
                  onTap: onAction ?? () {},
                ),
              )
            else if (emoji != null)
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
    required this.actionLabel,
    required this.onAction,
  });

  final String value;
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

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
          _PillButton(label: actionLabel, onTap: onAction),
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
            "$doneCount раз вы сделали\nсвою любимую практику",
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

class _PillButton extends StatelessWidget {
  const _PillButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.c842D5F, AppColors.c55004D],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x2A842D5F),
              blurRadius: 14,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(CupertinoIcons.play_fill, color: Colors.white, size: 14),
            SizedBox(width: 8.w),
            Text(
              label,
              style: AppTextStyles.body12w6.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
