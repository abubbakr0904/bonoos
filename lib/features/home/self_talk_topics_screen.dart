import 'package:bonoos/core/values/app_colors.dart';
import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:bonoos/di.dart';
import 'package:bonoos/features/common/widget/home_gradient_background.dart';
import 'package:bonoos/features/home/domain/entity/topic.dart';
import 'package:bonoos/features/home/domain/repository/topics_repository.dart';
import 'package:bonoos/features/home/self_talk_questions_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

class SelfTalkTopicsScreen extends StatefulWidget {
  const SelfTalkTopicsScreen({super.key});

  static const String routeName = '/self_talk_topics';

  @override
  State<SelfTalkTopicsScreen> createState() => _SelfTalkTopicsScreenState();
}

class _SelfTalkTopicsScreenState extends State<SelfTalkTopicsScreen> {
  bool _loading = true;
  String? _error;
  List<Topic> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await inject<TopicsRepository>().fetchTopics();
    if (!mounted) return;
    result.fold(
      (f) => setState(() {
        _loading = false;
        _error = f.message ?? 'Xatolik';
      }),
      (list) => setState(() {
        _loading = false;
        _error = null;
        _items = list;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);

    return Scaffold(
      backgroundColor: const Color(0xFF140B2A),
      body: Stack(
        children: [
          const HomeGradientBackground(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(4.w, 6.h, 20.w, 16.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.06),
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
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'O‘zing bilan suhbat',
                              style: AppTextStyles.body18w6.copyWith(
                                color: Colors.white.withValues(alpha: 0.96),
                                letterSpacing: -0.2,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 4.h),
                              child: Text(
                                'Yo‘nalishlar',
                                style: AppTextStyles.body12w4.copyWith(
                                  color: Colors.white.withValues(alpha: 0.42),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _loading
                      ? const _TopicsLoading()
                      : RefreshIndicator(
                          color: const Color(0xFFD4A5C4),
                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                          displacement: 48,
                          onRefresh: _load,
                          child: CustomScrollView(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            slivers: [
                              if (_error != null)
                                SliverFillRemaining(
                                  hasScrollBody: false,
                                  child: _TopicsError(
                                    message: _error!,
                                    onRetry: _load,
                                  ),
                                )
                              else if (_items.isEmpty)
                                const SliverFillRemaining(
                                  hasScrollBody: false,
                                  child: _TopicsEmpty(),
                                )
                              else
                                SliverPadding(
                                  padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 40.h),
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        if (index.isOdd) {
                                          return SizedBox(height: 12.h);
                                        }
                                        final i = index ~/ 2;
                                        final topic = _items[i];
                                        return _TopicCard(
                                          topic: topic,
                                          body: topic.contentForLocale(locale),
                                          onTap: () => context.push(
                                            SelfTalkQuestionsScreen.routeName,
                                            extra: TopicSwipeArgs(
                                              topicId: topic.id,
                                              title: topic.name,
                                              description: topic.description,
                                            ),
                                          ),
                                        );
                                      },
                                      childCount: _items.length * 2 - 1,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({
    required this.topic,
    required this.body,
    required this.onTap,
  });

  final Topic topic;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 18.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.c30215A.withValues(alpha: 0.45),
                const Color(0xFF1A0F28).withValues(alpha: 0.85),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                topic.name,
                style: AppTextStyles.body16w6.copyWith(
                  color: Colors.white.withValues(alpha: 0.95),
                  letterSpacing: -0.2,
                ),
              ),
              if (topic.description.trim().isNotEmpty) ...[
                SizedBox(height: 6.h),
                Text(
                  topic.description,
                  style: AppTextStyles.body13w4.copyWith(
                    color: Colors.white.withValues(alpha: 0.52),
                    height: 1.35,
                  ),
                ),
              ],
              if (body.trim().isNotEmpty) ...[
                SizedBox(height: 12.h),
                Text(
                  body,
                  style: AppTextStyles.body14w4.copyWith(
                    color: Colors.white.withValues(alpha: 0.78),
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicsLoading extends StatelessWidget {
  const _TopicsLoading();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 24.h),
      child: Shimmer.fromColors(
        baseColor: Colors.white.withValues(alpha: 0.05),
        highlightColor: Colors.white.withValues(alpha: 0.1),
        period: const Duration(milliseconds: 1100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(4, (i) {
            return Padding(
              padding: EdgeInsets.only(bottom: i == 3 ? 0 : 12.h),
              child: Container(
                height: 112.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14.r),
                  color: Colors.white,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _TopicsEmpty extends StatelessWidget {
  const _TopicsEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Text(
          'Hozircha yo‘nalishlar yo‘q.',
          textAlign: TextAlign.center,
          style: AppTextStyles.body14w4.copyWith(
            color: Colors.white.withValues(alpha: 0.45),
          ),
        ),
      ),
    );
  }
}

class _TopicsError extends StatelessWidget {
  const _TopicsError({
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
