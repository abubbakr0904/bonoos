import 'package:bonoos/core/api/dio_client.dart';
import 'package:bonoos/core/api/list_api.dart';
import 'package:bonoos/core/values/app_colors.dart';
import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:bonoos/di.dart';
import 'package:bonoos/features/gratitude/gratitude_notes_screen.dart';
import 'package:dio/dio.dart';
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
  late final ScrollController _scrollController;
  bool _isPrivate = true;
  bool _animateIn = false;
  bool _isSaving = false;
  bool _showIntro = true;
  bool _slideAway = false;
  
  final List<_StepData> _steps = [];

  final List<String> _questions = [
    "Bugungi kunimdan minnatdormanmi?",
    "Bugun meni nima quvontirdi?",
    "Bugun kimga yaxshilik qildim?",
    "Ertangi kundan nimalarni kutyapman?",
  ];

  final DioClient _dio = inject<DioClient>();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _isPrivate = widget.initialIsPrivate;
    
    final isNew = (widget.initialText ?? '').trim().isEmpty;
    if (isNew && widget.initialText == null) {
      _steps.add(_StepData(question: _questions[0]));
    } else {
      // For existing notes or pushed text, just one big step
      _steps.add(_StepData(
        question: "Shukrona yozuvi",
        controller: TextEditingController(text: widget.initialText ?? ''),
      ));
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      
      // Wait for intro to show
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;
      
      setState(() => _slideAway = true);
      
      // Delay slightly before showing notepad
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      
      setState(() => _animateIn = true);
      
      // Hide intro completely after animation
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      setState(() => _showIntro = false);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for (final step in _steps) {
      step.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = (widget.initialText ?? '').trim().isNotEmpty;
    return Scaffold(
      backgroundColor: AppColors.mainBgColor,
      appBar: AppBar(
        surfaceTintColor: AppColors.mainBgColor,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: Navigator.of(context).canPop()
            ? IconButton(
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
              )
            : null,
        title: Text(
          "Shukronalik daftari",
          style: AppTextStyles.body18w6.copyWith(color: Colors.white),
        ),
        actions: [
          if (!isEditing)
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const GratitudeNotesScreen()),
                );
              },
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
                  CupertinoIcons.clock,
                  color: Colors.white,
                  size: 18.sp,
                ),
              ),
            ),
          if (isEditing)
            IconButton(
              onPressed: () async {
                final sure = await showGeneralDialog<bool>(
                  context: context,
                  barrierDismissible: true,
                  barrierLabel: '',
                  barrierColor: Colors.black.withValues(alpha: 0.4),
                  transitionDuration: const Duration(milliseconds: 300),
                  pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
                  transitionBuilder: (context, anim1, anim2, child) {
                    return Transform.scale(
                      scale: anim1.value,
                      child: Opacity(
                        opacity: anim1.value,
                        child: Center(
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 40.w),
                            padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 20.h),
                            decoration: BoxDecoration(
                              color: AppColors.mainBgColor,
                              borderRadius: BorderRadius.circular(24.r),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    height: 54.w,
                                    width: 54.w,
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      CupertinoIcons.trash_fill,
                                      color: Colors.redAccent,
                                      size: 26.sp,
                                    ),
                                  ),
                                  SizedBox(height: 18.h),
                                  Text(
                                    'Yozuvni o\'chirish',
                                    style: AppTextStyles.body18w6.copyWith(color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 10.h),
                                  Text(
                                    'Rostdan ham ushbu yozuvni o\'chirasizmi?',
                                    style: AppTextStyles.body14w4.copyWith(
                                      color: Colors.white.withValues(alpha: 0.6),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 24.h),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () => Navigator.of(context).pop(false),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(vertical: 12.h),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(alpha: 0.06),
                                              borderRadius: BorderRadius.circular(14.r),
                                            ),
                                            child: Text(
                                              'Bekor',
                                              style: AppTextStyles.body14w6.copyWith(
                                                color: Colors.white.withValues(alpha: 0.7),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () => Navigator.of(context).pop(true),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(vertical: 12.h),
                                            decoration: BoxDecoration(
                                              color: Colors.redAccent,
                                              borderRadius: BorderRadius.circular(14.r),
                                            ),
                                            child: Text(
                                              'O\'chirish',
                                              style: AppTextStyles.body14w6.copyWith(color: Colors.white),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
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
              SizedBox(height: 12.h),
              
              Expanded(
                child: Stack(
                  children: [
                    // Notepad
                    AnimatedSlide(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      offset: _animateIn ? Offset.zero : const Offset(0, 0.2),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 500),
                        opacity: _animateIn ? 1 : 0,
                        child: _NotepadContainer(
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: EdgeInsets.fromLTRB(20.w, 10.h, 16.w, 100.h),
                            itemCount: _steps.length,
                            itemBuilder: (context, index) {
                              final step = _steps[index];
                              return _AnimatedStepWidget(
                                key: ValueKey(step.question),
                                step: step,
                                isLast: index == _steps.length - 1,
                                onChanged: () => setState(() {}),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    
                    // Intro Illustration
                    if (_showIntro)
                      AnimatedSlide(
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeInOutCubic,
                        offset: _slideAway ? const Offset(-1.2, 0) : Offset.zero,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 600),
                          opacity: _slideAway ? 0 : 1,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 280.w,
                                  height: 280.w,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(32.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.3),
                                        blurRadius: 30,
                                        offset: const Offset(0, 15),
                                      ),
                                    ],
                                    image: const DecorationImage(
                                      image: AssetImage('assets/images/gratitude_illustration.png'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 24.h),
                                Text(
                                  "Har bir kun uchun\nminnatdor bo'ling",
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.body18w6.copyWith(
                                    color: Colors.white,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 14.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _steps.last.controller.text.trim().isEmpty || _isSaving
                      ? null
                      : () => _handleSave(isEditing),
                  icon: _isSaving
                      ? SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: const CircularProgressIndicator(
                            color: AppColors.mainBgColor,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(CupertinoIcons.check_mark),
                  label: Text(
                    _isSaving 
                        ? "Saqlanmoqda..." 
                        : (_steps.length < 4 && isNewNote ? "Keyingisi" : "Saqlash"),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.mainBgColor,
                    disabledBackgroundColor: Colors.white.withValues(alpha: 0.12),
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

  Future<void> _handleSave(bool isEditing) async {
    if (_isSaving) return;

    if (_steps.length < 4 && isNewNote) {
      setState(() {
        final newStep = _StepData(question: _questions[_steps.length]);
        _steps.add(newStep);
        _scrollToBottom();
        // Request focus for the new step after it's built
        WidgetsBinding.instance.addPostFrameCallback((_) {
          newStep.focusNode.requestFocus();
        });
      });
      return;
    } else if (_steps.length == 4 && isNewNote && !_steps.any((s) => s.isCompletion)) {
      setState(() {
        final completionStep = _StepData(
          question: "Davom ettirishingiz mumkin",
          isCompletion: true,
        );
        _steps.add(completionStep);
        _scrollToBottom();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          completionStep.focusNode.requestFocus();
        });
      });
      return;
    }

    // Final Save
    final fullContent = _steps.map((s) {
      if (s.isCompletion) {
        return s.controller.text.trim();
      }
      return "${s.question}\n${s.controller.text.trim()}";
    }).where((text) => text.isNotEmpty).join("\n\n");
    
    final draft = GratitudeDraft(
      content: fullContent,
      tags: const [],
      isPrivate: _isPrivate,
    );

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(draft);
      return;
    }

    setState(() => _isSaving = true);
    try {
      await _dio.post(
        ListAPI.clientGratitudeDiary,
        data: {
          'content': fullContent,
          'tags': const [],
          'is_private': _isPrivate,
        },
      );
      if (!mounted) return;
      
      // Reset for next note
      setState(() {
        for (final s in _steps) {
          s.controller.dispose();
        }
        _steps.clear();
        _steps.add(_StepData(question: _questions[0]));
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Shukrona muvaffaqiyatli saqlandi"),
          backgroundColor: AppColors.mainBgColor,
        ),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      final message = e.response?.data is Map
          ? Map<String, dynamic>.from(e.response!.data)['message']?.toString()
          : null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message ?? "Shukrona saqlanmadi"),
          backgroundColor: AppColors.mainBgColor,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Shukrona saqlanmadi"),
          backgroundColor: AppColors.mainBgColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  bool get isNewNote => (widget.initialText ?? '').trim().isEmpty;
}

class _StepData {
  _StepData({
    required this.question,
    TextEditingController? controller,
    this.isCompletion = false,
  })  : controller = controller ?? TextEditingController(),
        focusNode = FocusNode();

  final String question;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isCompletion;
}

class _AnimatedStepWidget extends StatefulWidget {
  const _AnimatedStepWidget({
    super.key,
    required this.step,
    required this.isLast,
    required this.onChanged,
  });

  final _StepData step;
  final bool isLast;
  final VoidCallback onChanged;

  @override
  State<_AnimatedStepWidget> createState() => _AnimatedStepWidgetState();
}

class _AnimatedStepWidgetState extends State<_AnimatedStepWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: EdgeInsets.only(bottom: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.step.question,
                style: AppTextStyles.body14w7.copyWith(
                  color: AppColors.mainBgColor.withValues(alpha: 0.6),
                  height: 2.0,
                ),
              ),
              TextField(
                controller: widget.step.controller,
                focusNode: widget.step.focusNode,
                autofocus: widget.isLast,
                maxLines: null,
                minLines: 1,
                style: AppTextStyles.body16w5.copyWith(
                  color: widget.step.isCompletion ? Colors.black.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.85),
                  height: 2.0,
                  fontStyle: widget.step.isCompletion ? FontStyle.italic : FontStyle.normal,
                ),
                readOnly: false, // User should be able to continue writing
                decoration: InputDecoration(
                  hintText: widget.step.isCompletion 
                      ? "O'z fikrlaringizni bu yerda davom ettirishingiz mumkin..." 
                      : "Javobingiz...",
                  hintStyle: AppTextStyles.body14w4.copyWith(
                    color: Colors.black.withValues(alpha: 0.2),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (_) => widget.onChanged(),
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

class _NotepadContainer extends StatelessWidget {
  const _NotepadContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // The Notepad Paper
        Container(
          margin: EdgeInsets.only(top: 40.h),
          decoration: BoxDecoration(
            color: const Color(0xFFFDFDFD),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            children: [
              SizedBox(height: 16.h), // Tight space for holes area
              // Lined Paper Area
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _LinedPaperPainter(),
                      ),
                    ),
                    child,
                  ],
                ),
              ),
            ],
          ),
        ),
        // The Spirals (positioned to stick out into the background)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SizedBox(
            height: 60.h,
            child: CustomPaint(
              painter: _SpiralPainter(),
            ),
          ),
        ),
      ],
    );
  }
}

class _SpiralPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final ringPaint = Paint()
      ..color = const Color(0xFF9E9E9E)
      ..style = PaintingStyle.fill;

    final ringCount = 10;
    final spacing = size.width / (ringCount + 1);

    for (int i = 1; i <= ringCount; i++) {
      final x = spacing * i;
      final y = 40.h; // Paper top edge (matched with margin)

      // Draw the dark hole
      canvas.drawCircle(
        Offset(x, y + 10.h), 
        5.w, 
        Paint()..color = const Color(0xFF222222)
      );

      // Draw the vertical bar (oblong)
      final RRect bar = RRect.fromLTRBR(
        x - 4.w, 
        y - 20.h, 
        x + 4.w, 
        y + 12.h, 
        Radius.circular(4.r)
      );
      
      // Draw shadow for the bar
      canvas.drawRRect(
        bar.shift(const Offset(1, 1)), 
        Paint()..color = Colors.black.withValues(alpha: 0.2)
      );
      
      // Draw the bar itself
      canvas.drawRRect(bar, ringPaint);
      
      // Add a small highlight to the bar
      canvas.drawRRect(
        RRect.fromLTRBR(x - 1.w, y - 18.h, x + 1.w, y + 8.h, Radius.circular(2.r)),
        Paint()..color = Colors.white.withValues(alpha: 0.3)
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LinedPaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.1)
      ..strokeWidth = 1.0;

    final marginPaint = Paint()
      ..color = Colors.red.withValues(alpha: 0.15)
      ..strokeWidth = 1.5;

    // Draw horizontal lines
    // Match the lineHeight: 2.0 and fontSize: 16 (from AppTextStyles.body16w5)
    // Approximate calculation for line spacing
    final double firstLineY = 46.h;
    final double lineSpacing = 32.h; // Should match text height roughly

    for (double y = firstLineY; y < size.height; y += lineSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    // Draw vertical margin
    canvas.drawLine(Offset(44.w, 0), Offset(44.w, size.height), marginPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
