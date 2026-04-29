import 'package:bonoos/core/values/app_colors.dart';
import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GratitudeNoteEditorScreen extends StatefulWidget {
  const GratitudeNoteEditorScreen({
    super.key,
    this.initialText,
    this.initialIsPrivate = true,
  });

  final String? initialText;
  final bool initialIsPrivate;

  @override
  State<GratitudeNoteEditorScreen> createState() =>
      _GratitudeNoteEditorScreenState();
}

class _GratitudeNoteEditorScreenState extends State<GratitudeNoteEditorScreen> {
  late final TextEditingController _controller;
  bool _isPrivate = true;
  bool _animateIn = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText ?? '');
    _isPrivate = widget.initialIsPrivate;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _animateIn = true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = (widget.initialText ?? '').trim().isNotEmpty;
    return Scaffold(
      backgroundColor: const Color(0xFF140B2A),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: Container(
            height: 34.w,
            width: 34.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.22),
              ),
            ),
            child: Icon(
              CupertinoIcons.back,
              color: Colors.white,
              size: 18.sp,
            ),
          ),
        ),
        title: Text(
          isEditing ? "Yozuvni tahrirlash" : "Yangi yozuv",
          style: AppTextStyles.body18w6.copyWith(color: Colors.white),
        ),
        actions: [
          if (isEditing)
            IconButton(
              onPressed: () async {
                final sure = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Yozuvni o'chirish"),
                    content: const Text("Rostdan ham ushbu yozuvni o'chirasizmi?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text("Bekor qilish"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text("O'chirish"),
                      ),
                    ],
                  ),
                );
                if (sure != true || !context.mounted) return;
                Navigator.of(context).pop(const GratitudeDraft.delete());
              },
              icon: const Icon(CupertinoIcons.delete_solid, color: Colors.redAccent),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18.r),
                  color: Colors.white.withValues(alpha: 0.06),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                ),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.sparkles,
                      color: AppColors.c842D5F,
                      size: 18.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        "Bugun sizni quvontirgan 1-2 narsani yozing.",
                        style: AppTextStyles.body13w4.copyWith(
                          color: Colors.white.withValues(alpha: 0.78),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12.h),
              
              Expanded(
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.easeOutCubic,
                  offset: _animateIn ? Offset.zero : const Offset(0, 0.16),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 420),
                    opacity: _animateIn ? 1 : 0,
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      expands: true,
                      maxLines: null,
                      minLines: null,
                      textAlignVertical: TextAlignVertical.top,
                      style: AppTextStyles.body16w5.copyWith(
                        color: Colors.white.withValues(alpha: 0.95),
                        height: 1.4,
                      ),
                      decoration: InputDecoration(
                        hintText: "Bugun nimaga shukr qildingiz?",
                        hintStyle: AppTextStyles.body14w4.copyWith(
                          color: Colors.white.withValues(alpha: 0.45),
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.05),
                        contentPadding: EdgeInsets.all(16.r),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _controller.text.trim().isEmpty
                      ? null
                      : () => Navigator.of(context).pop(
                            GratitudeDraft(
                              content: _controller.text.trim(),
                              tags: const [],
                              isPrivate: _isPrivate,
                            ),
                          ),
                  icon: const Icon(CupertinoIcons.check_mark, color: Colors.white),
                  label: Text(
                    "Saqlash",
                    style: AppTextStyles.body15w6.copyWith(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppColors.c842D5F,
                    disabledBackgroundColor: Colors.white.withValues(alpha: 0.08),
                    minimumSize: Size(double.infinity, 52.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GratitudeDraft {
  const GratitudeDraft({
    required this.content,
    required this.tags,
    required this.isPrivate,
  }) : deleteRequested = false;

  const GratitudeDraft.delete()
      : content = '',
        tags = const [],
        isPrivate = true,
        deleteRequested = true;

  final String content;
  final List<String> tags;
  final bool isPrivate;
  final bool deleteRequested;
}
