import 'package:bonoos/core/api/dio_client.dart';
import 'package:bonoos/core/api/list_api.dart';
import 'package:bonoos/core/values/app_colors.dart';
import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:bonoos/di.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Bo'limlar → «Ko'p so'raladigan savollar» (FAQ). Ma'lumot: `GET /api/v1/faqs`.
class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  static const String routeName = '/sections/faq';

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final DioClient _dio = inject<DioClient>();
  List<FaqItem> _items = const [];
  bool _loading = true;
  String? _error;
  bool _animateIn = false;

  @override
  void initState() {
    super.initState();
    _loadFaqs();
  }

  Future<void> _loadFaqs() async {
    setState(() {
      _loading = true;
      _error = null;
      _animateIn = false;
    });
    try {
      final raw = await _dio.get(ListAPI.faqs);
      final response = raw as Response<dynamic>;
      final body = response.data;
      if (body is! Map) {
        throw Exception('Javob formati noto‘g‘ri');
      }
      final map = Map<String, dynamic>.from(body);
      final data = map['data'];
      if (data is! List) {
        throw Exception('FAQ ro‘yxati topilmadi');
      }
      final parsed = data
          .whereType<Map>()
          .map((e) => FaqItem.fromJson(Map<String, dynamic>.from(e)))
          .where((e) => e.isActive && e.question.trim().isNotEmpty)
          .toList()
        ..sort((a, b) => a.id.compareTo(b.id));
      if (!mounted) return;
      setState(() {
        _items = parsed;
        _loading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _animateIn = true);
      });
    } on DioException catch (e) {
      if (!mounted) return;
      final message = e.response?.data is Map
          ? Map<String, dynamic>.from(e.response!.data)['message']?.toString()
          : null;
      setState(() {
        _loading = false;
        _error = message ?? 'FAQ yuklab bo‘lmadi';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'FAQ yuklab bo‘lmadi';
      });
    }
  }

  void _showAnswerSheet(FaqItem item) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      enableDrag: true,
      showDragHandle: false,
      builder: (sheetContext) {
        final mq = MediaQuery.of(sheetContext);
        final keyboardBottom = mq.viewInsets.bottom;
        final safeBottom = mq.padding.bottom;
        final sheetH = mq.size.height * 0.78;

        return Padding(
          padding: EdgeInsets.only(bottom: keyboardBottom),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: sheetH,
              width: double.infinity,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1234),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
                    border: Border(
                      top: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
                      left: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                      right: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x66000000),
                        blurRadius: 24,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 10.h),
                      Center(
                        child: Container(
                          width: 42.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.28),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Center(
                        child: Text(
                          "Javob",
                          style: AppTextStyles.body12w6.copyWith(
                            color: Colors.white.withValues(alpha: 0.55),
                          ),
                        ),
                      ),
                      SizedBox(height: 14.h),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    CupertinoIcons.question_circle_fill,
                                    color: AppColors.c842D5F,
                                    size: 22.sp,
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: Text(
                                      item.question,
                                      style: AppTextStyles.body17w5.copyWith(
                                        color: Colors.white.withValues(alpha: 0.96),
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.h),
                              Container(
                                height: 1,
                                color: Colors.white.withValues(alpha: 0.12),
                              ),
                              SizedBox(height: 14.h),
                              Text(
                                item.answer,
                                style: AppTextStyles.body15w5.copyWith(
                                  color: Colors.white.withValues(alpha: 0.84),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          16.w,
                          8.h,
                          16.w,
                          keyboardBottom > 0 ? 12.h : (safeBottom > 0 ? safeBottom : 12.h),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () => Navigator.of(sheetContext).pop(),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.c842D5F,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                            ),
                            child: Text(
                              "Tushundim",
                              style: AppTextStyles.body15w6.copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF140B2A),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(
          "Ko'p so'raladigan savollar",
          style: AppTextStyles.body18w6.copyWith(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: AppTextStyles.body14w5.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              SizedBox(height: 14.h),
              TextButton(
                onPressed: _loadFaqs,
                child: Text(
                  "Qayta urinish",
                  style: AppTextStyles.body14w6.copyWith(
                    color: AppColors.c842D5F,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (_items.isEmpty) {
      return Center(
        child: Text(
          "Hozircha savollar yo‘q",
          style: AppTextStyles.body15w5.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.c842D5F,
      onRefresh: _loadFaqs,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount: _items.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return AnimatedSlide(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              offset: _animateIn ? Offset.zero : const Offset(0, 0.12),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 320),
                opacity: _animateIn ? 1 : 0,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 14.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Savolni tanlang",
                        style: AppTextStyles.body15w6.copyWith(
                          color: Colors.white.withValues(alpha: 0.92),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        "Ro‘yxatdan savolni bosing — javob pastdan ochiladi. Yangilash uchun pastga torting.",
                        style: AppTextStyles.body13w4.copyWith(
                          color: Colors.white.withValues(alpha: 0.62),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          final i = index - 1;
          final item = _items[i];
          final delayMs = 220 + (i * 70);
          return Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: AnimatedSlide(
              duration: Duration(milliseconds: delayMs.clamp(220, 900)),
              curve: Curves.easeOutCubic,
              offset: _animateIn ? Offset.zero : const Offset(0, 0.16),
              child: AnimatedOpacity(
                duration: Duration(milliseconds: delayMs.clamp(220, 900)),
                opacity: _animateIn ? 1 : 0,
                child: _FaqQuestionRow(
                  key: ValueKey(item.id),
                  question: item.question,
                  onTap: () => _showAnswerSheet(item),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class FaqItem {
  const FaqItem({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
    required this.isActive,
  });

  final int id;
  final String question;
  final String answer;
  final int category;
  final bool isActive;

  factory FaqItem.fromJson(Map<String, dynamic> json) {
    return FaqItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      question: json['question']?.toString() ?? '',
      answer: json['answer']?.toString() ?? '',
      category: (json['category'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] == true || json['is_active'] == 1,
    );
  }
}

class _FaqQuestionRow extends StatelessWidget {
  const _FaqQuestionRow({
    super.key,
    required this.question,
    required this.onTap,
  });

  final String question;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        splashColor: AppColors.c842D5F.withValues(alpha: 0.18),
        highlightColor: Colors.white.withValues(alpha: 0.06),
        child: Ink(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.09),
                Colors.white.withValues(alpha: 0.04),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x2014082A),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color: AppColors.c842D5F.withValues(alpha: 0.22),
                ),
                child: Icon(
                  CupertinoIcons.chat_bubble_text_fill,
                  color: AppColors.c842D5F,
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  question,
                  style: AppTextStyles.body15w6.copyWith(
                    color: Colors.white.withValues(alpha: 0.95),
                    height: 1.3,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                CupertinoIcons.chevron_compact_down,
                size: 22.sp,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
