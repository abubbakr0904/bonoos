import 'package:animate_do/animate_do.dart';
import 'package:bonoos/core/resources/assets/images/app_images.dart';
import 'package:bonoos/core/values/app_colors.dart';
import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:bonoos/di.dart';
import 'package:bonoos/features/common/widget/home_gradient_background.dart';
import 'package:bonoos/features/home/data/self_talk_static_questions.dart';
import 'package:bonoos/features/home/domain/entity/topic_question.dart';
import 'package:bonoos/features/home/domain/repository/topics_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shimmer/shimmer.dart';

class TopicSwipeArgs  {
  const TopicSwipeArgs({
    required this.topicId,
    required this.title,
    this.description,
  });

  final int topicId;
  final String title;
  final String? description;
}

class SelfTalkQuestionsScreen extends StatefulWidget {
  const SelfTalkQuestionsScreen({
    super.key,
    required this.args,
  });

  final TopicSwipeArgs args;

  static const String routeName = '/self_talk_questions';

  @override
  State<SelfTalkQuestionsScreen> createState() =>
      _SelfTalkQuestionsScreenState();
}

class _SelfTalkQuestionsScreenState extends State<SelfTalkQuestionsScreen> {
  bool _loading = true;
  String? _error;
  List<TopicQuestion> _questions = [];
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    if (widget.args.topicId <= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.pop();
      });
      return;
    }
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _completed = false;
    });
    if (kSelfTalkPreviewStaticOnly) {
      await Future<void>.delayed(const Duration(milliseconds: 280));
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = null;
        _questions = selfTalkStaticPreviewQuestions;
      });
      return;
    }
    final result = await inject<TopicsRepository>()
        .fetchTopicQuestions(widget.args.topicId);
    if (!mounted) return;
    result.fold(
      (f) => setState(() {
        _loading = false;
        _error = f.message ?? 'Xatolik';
      }),
      (list) => setState(() {
        _loading = false;
        _error = null;
        _questions = list;
      }),
    );
  }

  void _showInfo() {
    final d = widget.args.description?.trim();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A1F3D),
        title: Text(
          widget.args.title,
          style: AppTextStyles.body16w6.copyWith(color: Colors.white),
        ),
        content: Text(
          (d != null && d.isNotEmpty)
              ? d
              : 'Savollarni ketma-ket o‘qing va keyingisiga o‘tish uchun kartani chapga yoki o‘ngga siljiting.',
          style: AppTextStyles.body14w4.copyWith(
            color: Colors.white.withValues(alpha: 0.85),
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Yopish',
              style: AppTextStyles.body14w6.copyWith(
                color: const Color(0xFFD4A5C4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _swipeHint(Locale locale) {
    switch (locale.languageCode) {
      case 'ru':
        return 'Проведите в сторону, когда будете готовы перейти к следующему вопросу';
      case 'en':
        return 'Swipe sideways when you\'re ready for the next question';
      default:
        return 'Keyingi savolga o‘tish uchun kartani chapga yoki o‘ngga siljiting.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);

    return Scaffold(
      backgroundColor: AppColors.mainBgColor,
      body: Stack(
        children: [
          const HomeGradientBackground(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(4.w, 6.h, 12.w, 8.h),
                  child: Row(
                    children: [
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor:
                              Colors.white.withValues(alpha: 0.06),
                          padding: EdgeInsets.all(10.w),
                          minimumSize: Size(40.w, 40.w),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () => context.pop(),
                        icon: Icon(
                          CupertinoIcons.chevron_back,
                          color: Colors.white.withValues(alpha: 0.9),
                          size: 20.sp,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          widget.args.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.body17w5.copyWith(
                            color: Colors.white.withValues(alpha: 0.96),
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor:
                              Colors.white.withValues(alpha: 0.06),
                          padding: EdgeInsets.all(10.w),
                          minimumSize: Size(40.w, 40.w),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: _showInfo,
                        icon: Icon(
                          CupertinoIcons.info,
                          color: Colors.white.withValues(alpha: 0.85),
                          size: 20.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _loading
                      ? const _QuestionsLoading()
                      : _error != null
                          ? _QuestionsError(
                              message: _error!,
                              onRetry: _load,
                            )
                          : _questions.isEmpty
                              ? const _QuestionsEmpty()
                              : _completed
                                  ? _TopicQuestionsCelebration(
                                      onFinished: () {
                                        if (context.mounted) {
                                          context.pop();
                                        }
                                      },
                                    )
                                  : _SwipeDeck(
                                      questions: _questions,
                                      locale: locale,
                                      swipeHint: _swipeHint(locale),
                                      onFinished: () =>
                                          setState(() => _completed = true),
                                    ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 14.h, top: 8.h),
                  child: const _BrandFooter(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandFooter extends StatelessWidget {
  const _BrandFooter();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snap) {
        final name = (snap.data?.appName ?? 'BONOOS').toUpperCase();
        return Text(
          name,
          textAlign: TextAlign.center,
          style: AppTextStyles.body11w5.copyWith(
            color: Colors.white.withValues(alpha: 0.35),
            letterSpacing: 2,
          ),
        );
      },
    );
  }
}

class _QuestionsLoading extends StatelessWidget {
  const _QuestionsLoading();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 24.h),
      child: Shimmer.fromColors(
        baseColor: Colors.white.withValues(alpha: 0.05),
        highlightColor: Colors.white.withValues(alpha: 0.1),
        period: const Duration(milliseconds: 1100),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _QuestionsError extends StatelessWidget {
  const _QuestionsError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body14w4.copyWith(
                color: Colors.white.withValues(alpha: 0.65),
              ),
            ),
            SizedBox(height: 16.h),
            TextButton(
              onPressed: onRetry,
              child: Text(
                'Qayta urinish',
                style: AppTextStyles.body14w6.copyWith(
                  color: const Color(0xFFD4A5C4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionsEmpty extends StatelessWidget {
  const _QuestionsEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Text(
          'Bu yo‘nalish uchun hozircha savollar yo‘q.',
          textAlign: TextAlign.center,
          style: AppTextStyles.body14w4.copyWith(
            color: Colors.white.withValues(alpha: 0.45),
          ),
        ),
      ),
    );
  }
}

/// Barcha kartalar tugagach — qisqa quvonch animatsiyasi, keyin ekran yopiladi.
class _TopicQuestionsCelebration extends StatefulWidget {
  const _TopicQuestionsCelebration({required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<_TopicQuestionsCelebration> createState() =>
      _TopicQuestionsCelebrationState();
}

class _TopicQuestionsCelebrationState extends State<_TopicQuestionsCelebration> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 2900), () {
      if (mounted) widget.onFinished();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BounceInDown(
                  delay: const Duration(milliseconds: 120),
                  duration: const Duration(milliseconds: 700),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    size: 26.sp,
                    color: AppColors.c842D5F.withValues(alpha: 0.95),
                  ),
                ),
                SizedBox(width: 14.w),
                BounceInDown(
                  delay: const Duration(milliseconds: 260),
                  duration: const Duration(milliseconds: 700),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    size: 34.sp,
                    color: AppColors.c55004D.withValues(alpha: 0.98),
                  ),
                ),
                SizedBox(width: 14.w),
                BounceInDown(
                  delay: const Duration(milliseconds: 400),
                  duration: const Duration(milliseconds: 700),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    size: 26.sp,
                    color: AppColors.c842D5F.withValues(alpha: 0.95),
                  ),
                ),
              ],
            ),
            SizedBox(height: 28.h),
            ElasticIn(
              duration: const Duration(milliseconds: 1200),
              curve: Curves.elasticOut,
              child: Pulse(
                infinite: true,
                duration: const Duration(milliseconds: 950),
                from: 1,
                to: 1.09,
                curve: Curves.easeInOut,
                child: Container(
                  padding: EdgeInsets.all(26.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color.lerp(
                              AppColors.c842D5F,
                              Colors.white,
                              0.22,
                            )!
                            .withValues(alpha: 0.75),
                        AppColors.c55004D.withValues(alpha: 0.88),
                        AppColors.c30215A.withValues(alpha: 0.95),
                      ],
                      stops: const [0.0, 0.42, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.c842D5F.withValues(alpha: 0.45),
                        blurRadius: 32,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Icon(
                    Icons.celebration_rounded,
                    size: 64.sp,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ),
              ),
            ),
            SizedBox(height: 32.h),
            FadeInUp(
              delay: const Duration(milliseconds: 350),
              duration: const Duration(milliseconds: 650),
              from: 36,
              child: Text(
                'Ajoyib!',
                textAlign: TextAlign.center,
                style: AppTextStyles.body22w7.copyWith(
                  color: Color.lerp(
                    Colors.white,
                    AppColors.c842D5F,
                    0.12,
                  )!,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            FadeInUp(
              delay: const Duration(milliseconds: 520),
              duration: const Duration(milliseconds: 700),
              from: 28,
              child: Text(
                'Barcha savollarni yakunladingiz — o‘zingiz bilan yana bir qadam yaqinlashdingiz.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body14w4.copyWith(
                  color: Colors.white.withValues(alpha: 0.72),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwipeDeck extends StatelessWidget {
  const _SwipeDeck({
    required this.questions,
    required this.locale,
    required this.swipeHint,
    required this.onFinished,
  });

  final List<TopicQuestion> questions;
  final Locale locale;
  final String swipeHint;
  final VoidCallback onFinished;

  @override
  Widget build(BuildContext context) {
    final n = questions.length;
    final displayed = n >= 3 ? 3 : n;

    return CardSwiper(
      padding: EdgeInsets.fromLTRB(32.w, 28.h, 32.w, 36.h),
      cardsCount: n,
      numberOfCardsDisplayed: displayed,
      scale: 0.88,
      backCardOffset: const Offset(0, 11),
      maxAngle: 18,
      threshold: 45,
      isLoop: false,
      allowedSwipeDirection:
          const AllowedSwipeDirection.symmetric(horizontal: true),
      onEnd: onFinished,
      cardBuilder: (context, index, hp, vp) {
        final q = questions[index];
        final text = q.textForLocale(locale);
        return Center(
          child: FractionallySizedBox(
            widthFactor: 0.92,
            heightFactor: 0.70,
            child: _QuestionSwipeCard(
              questionText: text,
              swipeHint: swipeHint,
            ),
          ),
        );
      },
    );
  }
}

class _QuestionSwipeCard extends StatelessWidget {
  const _QuestionSwipeCard({
    required this.questionText,
    required this.swipeHint,
  });

  final String questionText;
  final String swipeHint;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6B4E7C).withValues(alpha: 0.95),
            const Color(0xFF4A3560).withValues(alpha: 0.92),
            AppColors.c30215A.withValues(alpha: 0.88),
          ],
          stops: const [0.0, 0.45, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 14.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 32.h,
              width: 44.w,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  AppImages.appLogoPurple,
                  fit: BoxFit.contain,
                  alignment: Alignment.centerLeft,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.self_improvement_rounded,
                    color: Colors.white.withValues(alpha: 0.92),
                    size: 28.sp,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Text(
                    questionText.isNotEmpty ? questionText : '—',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body15w5.copyWith(
                      color: Colors.white.withValues(alpha: 0.95),
                      height: 1.42,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    swipeHint,
                    style: AppTextStyles.body11w4.copyWith(
                      color: Colors.white.withValues(alpha: 0.72),
                      height: 1.38,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.swipe_rounded,
                  color: Colors.white.withValues(alpha: 0.55),
                  size: 28.sp,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
