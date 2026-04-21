import 'package:bonoos/core/resources/assets/images/app_images.dart';
import 'package:bonoos/core/values/app_colors.dart';
import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:bonoos/features/auth/login_phone_screen.dart';
import 'package:bonoos/features/common/widget/custom_button.dart';
import 'package:bonoos/features/common/widget/home_gradient_background.dart';
import 'package:bonoos/features/questions/data/mock_psych_questions.dart';
import 'package:bonoos/features/questions/models/psych_question.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  static const String routeName = "/questions";

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> with TickerProviderStateMixin {
  int _index = 0;
  int? _selected;

  void _next() {
    if (_selected == null) return;
    if (_index >= mockPsychQuestions.length - 1) {
      context.go(LoginPhoneScreen.routeName);
      return;
    }
    setState(() {
      _index += 1;
      _selected = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = mockPsychQuestions.length;
    final question = mockPsychQuestions[_index];
    final progress = (_index + 1) / total;

    return Scaffold(
      backgroundColor: const Color(0xFF140B2A),
      body: Stack(
        children: [
          HomeGradientBackground(),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  SizedBox(height: 8.h),
                  _Header(progress: progress, current: _index + 1, total: total),
                  SizedBox(height: 26.h),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        final slide = Tween<Offset>(
                          begin: const Offset(0.10, 0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(position: slide, child: child),
                        );
                      },
                      child: _QuestionBody(
                        key: ValueKey(_index),
                        title: question.question,
                        options: question.options,
                        selectedIndex: _selected,
                        onSelect: (i) => setState(() => _selected = i),
                      ),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'Davom etish',
                      onTap: _next,
                      isEnabled: _selected != null,
                      height: 48.h,
                      radius: BorderRadius.circular(999),
                      bgColor: AppColors.c842D5F,
                      textColor: AppColors.white,
                      disabledBgColor: Colors.white.withValues(alpha: 0.08),
                      disabledTextColor: Colors.white.withValues(alpha: 0.38),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.progress,
    required this.current,
    required this.total,
  });

  final double progress;
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(AppImages.appLogoPurple, width: 46.w, height: 46.w),
        SizedBox(width: 12.w),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 10.h,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: value.clamp(0, 1),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              gradient: const LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [AppColors.c842D5F, AppColors.c55004D],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Text(
          '$current/$total',
          style: AppTextStyles.body14w6.copyWith(
            color: Colors.white.withValues(alpha: 0.88),
          ),
        ),
      ],
    );
  }
}

class _QuestionBody extends StatelessWidget {
  const _QuestionBody({
    super.key,
    required this.title,
    required this.options,
    required this.selectedIndex,
    required this.onSelect,
  });

  final String title;
  final List<PsychOption> options;
  final int? selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.body20w7.copyWith(
            color: Colors.white.withValues(alpha: 0.95),
            height: 1.35,
          ),
        ),
        SizedBox(height: 22.h),
        Expanded(
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            itemCount: options.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (context, i) {
              final opt = options[i];
              final selected = selectedIndex == i;
              return _OptionTile(
                emoji: opt.emoji,
                title: opt.title,
                selected: selected,
                onTap: () => onSelect(i),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.emoji,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        splashColor: AppColors.c842D5F.withValues(alpha: 0.20),
        highlightColor: Colors.white.withValues(alpha: 0.06),
        onTap: onTap,
        child: Ink(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            color: selected ? AppColors.c842D5F.withValues(alpha: 0.14) : Colors.white.withValues(alpha: 0.06),
            border: Border.all(
              color: selected ? AppColors.c842D5F.withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.10),
              width: selected ? 1.5 : 1,
            ),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x35842D5F),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Text(emoji, style: TextStyle(fontSize: 20.sp)),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.body16w6.copyWith(
                    color: Colors.white.withValues(alpha: selected ? 0.98 : 0.90),
                  ),
                ),
              ),
              _RadioCircle(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadioCircle extends StatelessWidget {
  const _RadioCircle({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      height: 22.w,
      width: 22.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.c842D5F : Colors.white.withValues(alpha: 0.35),
          width: 2,
        ),
      ),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: selected ? 1 : 0,
        child: Center(
          child: Container(
            height: 10.w,
            width: 10.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.c842D5F,
            ),
          ),
        ),
      ),
    );
  }
}
