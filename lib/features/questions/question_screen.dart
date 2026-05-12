import 'dart:async';

import 'package:bonoos/core/resources/assets/images/app_images.dart';
import 'package:bonoos/core/api/dio_client.dart';
import 'package:bonoos/core/api/list_api.dart';
import 'package:bonoos/core/values/app_colors.dart';
import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:bonoos/di.dart';
import 'package:bonoos/features/common/widget/custom_button.dart';
import 'package:bonoos/features/common/widget/home_gradient_background.dart';
import 'package:bonoos/features/questions/models/psych_question.dart';
import 'package:bonoos/features/tabbox/tabbox_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  static const String routeName = "/questions";

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen>
    with TickerProviderStateMixin {
  final DioClient _dio = inject<DioClient>();
  List<PsychQuestion> _questions = const [];
  final Map<int, List<int>> _answersByQuestionId = {};
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorText;
  int _index = 0;
  int? _selected;

  @override
  void initState() {
    super.initState();
    unawaited(_loadQuestions());
  }

  void _next() {
    if (_selected == null || _isSubmitting) return;
    final question = _questions[_index];
    final selectedOption = question.options[_selected!];
    _answersByQuestionId[question.id] = [selectedOption.id];

    if (_index >= _questions.length - 1) {
      unawaited(_submitAnswersAndComplete());
      return;
    }
    setState(() {
      _index += 1;
      final nextQuestion = _questions[_index];
      final savedIds = _answersByQuestionId[nextQuestion.id];
      if (savedIds == null || savedIds.isEmpty) {
        _selected = null;
        return;
      }
      final savedOptionId = savedIds.first;
      _selected = nextQuestion.options.indexWhere((e) => e.id == savedOptionId);
      if (_selected != null && _selected! < 0) {
        _selected = null;
      }
    });
  }

  Future<void> _completeQuestions() async {
    await inject<SharedPreferences>().setBool(SharedModel.newUser, false);
    if (!mounted) return;
    context.go(TabBoxScreen.routeName);
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
      _errorText = null;
    });
    try {
      final raw = await _dio.get(ListAPI.onboardingQuestions);
      final response = raw as Response<dynamic>;
      final body = response.data;
      if (body is! Map) {
        throw Exception('Javob formati noto‘g‘ri');
      }
      final map = Map<String, dynamic>.from(body);
      final data = map['data'];
      if (data is! List) {
        throw Exception('Savollar ro‘yxati topilmadi');
      }
      final parsed = data
          .whereType<Map>()
          .map((e) => PsychQuestion.fromJson(Map<String, dynamic>.from(e)))
          .where((e) => e.isActive && e.question.trim().isNotEmpty)
          .toList();
      if (!mounted) return;
      setState(() {
        _questions = parsed;
        _answersByQuestionId.clear();
        _index = 0;
        _selected = null;
        _isLoading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorText = e.response?.data is Map
            ? Map<String, dynamic>.from(e.response!.data)['message']
                    ?.toString() ??
                'Savollarni yuklab bo‘lmadi'
            : 'Savollarni yuklab bo‘lmadi';
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorText = 'Savollarni yuklab bo‘lmadi';
        _isLoading = false;
      });
    }
  }

  Future<void> _submitAnswersAndComplete() async {
    if (_answersByQuestionId.isEmpty) {
      await _completeQuestions();
      return;
    }
    setState(() {
      _isSubmitting = true;
    });
    try {
      final answers = _answersByQuestionId.entries
          .map((entry) => {
                'question_id': entry.key,
                'option_ids': entry.value,
              })
          .toList();
      await _dio.post(
        ListAPI.clientOnboardingAnswers,
        data: {
          'answers': answers,
        },
      );
      if (!mounted) return;
      await _completeQuestions();
    } on DioException catch (e) {
      if (!mounted) return;
      final message = e.response?.data is Map
          ? Map<String, dynamic>.from(e.response!.data)['message']?.toString()
          : null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message ?? 'Javoblarni yuborib bo‘lmadi'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Javoblarni yuborib bo‘lmadi'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _questions.length;
    final hasQuestions = total > 0;
    final question = hasQuestions ? _questions[_index] : null;
    final progress = hasQuestions ? (_index + 1) / total : 0.0;

    return Scaffold(
      backgroundColor: AppColors.mainBgColor,
      body: Stack(
        children: [
          HomeGradientBackground(),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  SizedBox(height: 8.h),
                  _Header(
                    progress: progress,
                    current: hasQuestions ? _index + 1 : 0,
                    total: total,
                  ),
                  SizedBox(height: 26.h),
                  Expanded(
                    child: _buildBody(question),
                  ),
                  SizedBox(height: 18.h),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: _isSubmitting ? 'Yuborilmoqda...' : 'Davom etish',
                      onTap: _next,
                      isEnabled: _selected != null &&
                          !_isLoading &&
                          hasQuestions &&
                          !_isSubmitting,
                      height: 48.h,
                      radius: BorderRadius.circular(16),
                      bgColor: AppColors.white,
                      textColor: AppColors.mainBgColor,
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

  Widget _buildBody(PsychQuestion? question) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    if (_errorText != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _errorText!,
              textAlign: TextAlign.center,
              style: AppTextStyles.body16w6.copyWith(color: Colors.white),
            ),
            SizedBox(height: 12.h),
            TextButton(
              onPressed: _loadQuestions,
              child: const Text('Qayta urinish'),
            ),
          ],
        ),
      );
    }
    if (_questions.isEmpty || question == null) {
      return Center(
        child: Text(
          'Savollar topilmadi',
          style: AppTextStyles.body16w6.copyWith(color: Colors.white),
        ),
      );
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final slide = Tween<Offset>(
          begin: const Offset(0.10, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        );
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
        Image.asset(AppImages.splashImage, width: 46.w, height: 46.w),
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
                                colors: [AppColors.white, AppColors.white
                                ],
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
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.10),
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
              if (emoji.isNotEmpty) ...[
                Text(emoji, style: TextStyle(fontSize: 20.sp)),
                SizedBox(width: 12.w),
              ],
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.body16w6.copyWith(
                    color:
                        Colors.white.withValues(alpha: selected ? 0.98 : 0.90),
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
          color: Colors.white.withValues(alpha: 0.35),
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
              color: AppColors.white
              ,
            ),
          ),
        ),
      ),
    );
  }
}
