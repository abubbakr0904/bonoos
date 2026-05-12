import 'package:bonoos/core/values/app_colors.dart';
import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:bonoos/di.dart';
import 'package:bonoos/features/subscription/domain/entity/plan.dart';
import 'package:bonoos/features/subscription/domain/repository/subscription_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _loading = true;
  String? _error;
  List<Plan> _plans = [];
  bool _animateIn = false;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() {
      _loading = true;
      _error = null;
      _animateIn = false;
    });
    final result = await inject<SubscriptionRepository>().fetchPlans();
    if (!mounted) return;
    result.fold(
      (f) => setState(() {
        _loading = false;
        _error = f.message ?? 'Xatolik yuz berdi';
      }),
      (plans) => setState(() {
        _loading = false;
        _plans = plans;
      }),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _animateIn = true);
    });
  }

  void _openPlanSheet(BuildContext context, Plan plan) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PlanDetailSheet(plan: plan),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBgColor,
      body: Stack(
        children: [
          const _SubscriptionBackground(),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEntrance(
                    index: 0,
                    child: const _Header(),
                  ),
                  SizedBox(height: 14.h),
                  if (_loading)
                    Expanded(
                      child: Center(
                        child: _buildEntrance(
                          index: 1,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(
                                color: AppColors.c842D5F,
                                strokeWidth: 2.5,
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                'Rejalar yuklanmoqda…',
                                style: AppTextStyles.body14w5.copyWith(
                                  color: Colors.white.withValues(alpha: 0.88),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else if (_error != null)
                    Expanded(
                      child: Center(
                        child: _buildEntrance(
                          index: 1,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.exclamationmark_triangle,
                                size: 40.sp,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.body14w5.copyWith(
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                              SizedBox(height: 16.h),
                              TextButton(
                                onPressed: _loadPlans,
                                child: Text(
                                  'Qayta urinish',
                                  style: AppTextStyles.body14w6.copyWith(
                                    color: AppColors.c842D5F,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else if (_plans.isEmpty)
                    Expanded(
                      child: Center(
                        child: _buildEntrance(
                          index: 1,
                          child: Text(
                            'Hozircha rejalar mavjud emas',
                            style: AppTextStyles.body14w5.copyWith(
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      ),
                    )
                  else ...[
                    if (_plans.length >= 3)
                      _buildEntrance(
                        index: 1,
                        child: _FeaturedPlanCard(
                          plan: _plans.last,
                          onTap: () => _openPlanSheet(context, _plans.last),
                        ),
                      ),
                    if (_plans.length >= 3) SizedBox(height: 18.h),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildEntrance(
                              index: 2,
                              child: Text(
                                "Obuna sotib olish",
                                style: AppTextStyles.body17w5.copyWith(
                                  color: Colors.white.withValues(alpha: 0.92),
                                ),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            for (int i = 0; i < _plans.length; i++) ...[
                              _buildEntrance(
                                index: 3 + i,
                                child: _PlanRow(
                                  plan: _plans[i],
                                  highlight: _plans.length >= 2 && i == 1,
                                  tag: _planTag(i, _plans.length),
                                  onTap: () => _openPlanSheet(context, _plans[i]),
                                ),
                              ),
                              if (i < _plans.length - 1) SizedBox(height: 10.h),
                            ],
                            SizedBox(height: 90.h),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _planTag(int index, int total) {
    if (total >= 3) {
      if (index == 0) return 'Boshlang\'ich';
      if (index == 1) return 'Mashhur';
      if (index == total - 1) return 'Eng foydali';
    }
    if (total == 2) {
      if (index == 0) return 'Boshlang\'ich';
      if (index == 1) return 'Eng foydali';
    }
    return '';
  }

  Widget _buildEntrance({
    required int index,
    required Widget child,
  }) {
    final duration = Duration(milliseconds: 420 + (index * 80));
    return AnimatedSlide(
      duration: duration,
      curve: Curves.easeOutCubic,
      offset: _animateIn ? Offset.zero : const Offset(0, 0.16),
      child: AnimatedOpacity(
        duration: duration,
        curve: Curves.easeOut,
        opacity: _animateIn ? 1 : 0,
        child: child,
      ),
    );
  }
}

class _SubscriptionBackground extends StatelessWidget {
  const _SubscriptionBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.mainBgColor,
          ),
        ),
        Positioned(
          top: -80,
          right: -40,
          child: Container(
            height: 230,
            width: 230,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0x3A842D5F), Color(0x00842D5F)],
              ),
            ),
          ),
        ),
        Positioned(
          top: 200,
          left: -60,
          child: Container(
            height: 200,
            width: 200,
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

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Obuna",
          style: AppTextStyles.body22w7.copyWith(
            color: Colors.white.withValues(alpha: 0.95),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          "Oddiy rejalar va aniq imkoniyatlar.",
          style: AppTextStyles.body13w4.copyWith(
            color: Colors.white.withValues(alpha: 0.70),
          ),
        ),
      ],
    );
  }
}

class _FeaturedPlanCard extends StatelessWidget {
  const _FeaturedPlanCard({required this.plan, required this.onTap});

  final Plan plan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final months = (plan.durationDays / 30).round();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          color: Colors.white.withValues(alpha: 0.1),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 52.w,
                  width: 52.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18.r),
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                  child: const Center(
                    child: Icon(
                      CupertinoIcons.sparkles,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  height: 34.w,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        CupertinoIcons.bolt_fill,
                        size: 16,
                        color: Colors.white,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        "Eng foydali",
                        style: AppTextStyles.body11w5.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 18.h),
            Text(
              plan.name,
              style: AppTextStyles.body18w7.copyWith(
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              plan.description.isNotEmpty
                  ? plan.description
                  : "Yil davomida barcha imkoniyatlardan foydalaning.",
              style: AppTextStyles.body13w4.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
                height: 1.3,
              ),
            ),
            SizedBox(height: 14.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$months oy",
                      style: AppTextStyles.body16w6.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      "Obuna bo'lgan kundan boshlanadi",
                      style: AppTextStyles.body12w4.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: Colors.white,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Batafsil",
                        style: AppTextStyles.body13w5.copyWith(
                          color: AppColors.mainBgColor,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      const Icon(
                        CupertinoIcons.chevron_right,
                        size: 16,
                        color: AppColors.mainBgColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  const _PlanRow({
    required this.plan,
    required this.highlight,
    required this.tag,
    required this.onTap,
  });

  final Plan plan;
  final bool highlight;
  final String tag;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.r),
          color: Colors.white.withValues(alpha: 0.08),
          border: Border.all(
            color: highlight
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 46.w,
              width: 46.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.c842D5F, AppColors.c55004D],
                ),
              ),
              child: const Center(
                child: Icon(
                  CupertinoIcons.calendar,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          plan.name,
                          style: AppTextStyles.body16w6.copyWith(
                            color: Colors.white.withValues(alpha: 0.92),
                          ),
                        ),
                      ),
                      if (tag.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: highlight
                                ? Colors.white.withValues(alpha: 0.14)
                                : Colors.white.withValues(alpha: 0.08),
                          ),
                          child: Text(
                            tag,
                            style: AppTextStyles.body10w6.copyWith(
                              color: Colors.white.withValues(alpha: 0.86),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    plan.formattedPrice,
                    style: AppTextStyles.body17wb.copyWith(
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    plan.perMonthFormatted,
                    style: AppTextStyles.body12w4.copyWith(
                      color: Colors.white.withValues(alpha: 0.70),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              CupertinoIcons.chevron_right,
              color: Colors.white.withValues(alpha: 0.60),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanDetailSheet extends StatefulWidget {
  const _PlanDetailSheet({required this.plan});

  final Plan plan;

  @override
  State<_PlanDetailSheet> createState() => _PlanDetailSheetState();
}

class _PlanDetailSheetState extends State<_PlanDetailSheet> {
  bool _subscribing = false;
  String? _error;

  Future<void> _subscribe() async {
    if (_subscribing) return;
    setState(() {
      _subscribing = true;
      _error = null;
    });

    final result = await inject<SubscriptionRepository>().subscribe(widget.plan.id);

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _subscribing = false;
          _error = failure.message ?? 'Xatolik yuz berdi';
        });
      },
      (paymentLink) async {
        setState(() => _subscribing = false);
        final uri = Uri.tryParse(paymentLink);
        if (uri == null) {
          setState(() => _error = 'To\'lov havolasi noto\'g\'ri.');
          return;
        }
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          if (mounted) Navigator.of(context).pop();
        } else {
          if (mounted) {
            setState(() => _error = 'To\'lov sahifasini ochib bo\'lmadi.');
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    final months = (plan.durationDays / 30).round();

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      maxChildSize: 0.85,
      minChildSize: 0.4,
      builder: (context, controller) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.mainBgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 16.h + 10.h),
            child: ListView(
              controller: controller,
              children: [
                Center(
                  child: Container(
                    height: 4,
                    width: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: Colors.white.withValues(alpha: 0.22),
                    ),
                  ),
                ),
                SizedBox(height: 14.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 46.w,
                      width: 46.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.c842D5F, AppColors.c55004D],
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          CupertinoIcons.calendar,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.name,
                            style: AppTextStyles.body18w7.copyWith(
                              color: Colors.white.withValues(alpha: 0.95),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "${plan.durationDays} kun amal qiladi. Obuna bo'lgan kundan boshlanadi.",
                            style: AppTextStyles.body13w4.copyWith(
                              color: Colors.white.withValues(alpha: 0.70),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                Row(
                  children: [
                    Text(
                      plan.formattedPrice,
                      style: AppTextStyles.body22w7.copyWith(
                        color: Colors.white.withValues(alpha: 0.95),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      "/ bir martalik",
                      style: AppTextStyles.body13w4.copyWith(
                        color: Colors.white.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  plan.perMonthFormatted,
                  style: AppTextStyles.body13w4.copyWith(
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),
                if (plan.description.isNotEmpty) ...[
                  SizedBox(height: 16.h),
                  Text(
                    "Tavsif",
                    style: AppTextStyles.body15w6.copyWith(
                      color: Colors.white.withValues(alpha: 0.92),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    plan.description,
                    style: AppTextStyles.body13w4.copyWith(
                      color: Colors.white.withValues(alpha: 0.75),
                      height: 1.35,
                    ),
                  ),
                ],
                SizedBox(height: 16.h),
                Text(
                  "Reja tafsilotlari",
                  style: AppTextStyles.body15w6.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
                SizedBox(height: 8.h),
                _DetailRow(
                  icon: CupertinoIcons.calendar,
                  label: "Muddat",
                  value: "$months oy (${plan.durationDays} kun)",
                ),
                SizedBox(height: 6.h),
                _DetailRow(
                  icon: CupertinoIcons.money_dollar_circle,
                  label: "Narx",
                  value: plan.formattedPrice,
                ),
                SizedBox(height: 6.h),
                _DetailRow(
                  icon: CupertinoIcons.chart_bar,
                  label: "Oylik",
                  value: plan.perMonthFormatted,
                ),
                if (_error != null) ...[
                  SizedBox(height: 12.h),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body12w6.copyWith(color: AppColors.red),
                  ),
                ],
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _subscribing ? null : _subscribe,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.mainBgColor,
                      disabledBackgroundColor: Colors.white.withValues(alpha: 0.12),
                      minimumSize: Size(double.infinity, 54.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: _subscribing
                        ? SizedBox(
                            width: 22.w,
                            height: 22.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.mainBgColor,
                            ),
                          )
                        : Text(
                            "Faollashtirish",
                            style: AppTextStyles.body16w7,
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        color: Colors.white.withValues(alpha: 0.06),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          Container(
            height: 32.w,
            width: 32.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.10),
            ),
            child: Icon(
              icon,
              color: Colors.white.withValues(alpha: 0.8),
              size: 18,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body13w4.copyWith(
                color: Colors.white.withValues(alpha: 0.65),
              ),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.body14w6.copyWith(
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
        ],
      ),
    );
  }
}
