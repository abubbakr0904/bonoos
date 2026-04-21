import 'dart:math';

import 'package:bonoos/core/values/app_colors.dart';
import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:bonoos/di.dart';
import 'package:bonoos/features/home/domain/repository/quotes_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MessageOfDayScreen extends StatefulWidget {
  const MessageOfDayScreen({super.key});

  static const String routeName = "/message_of_day";

  static const _fallbackMessages = <String>[
    "Bugun o‘zingizga mehr bering — kichik qadamlar ham katta natija.",
    "Sokinlik ham kuch. Nafas oling, shoshilmang.",
    "Siz yetarlisiz. O‘zingizni solishtirmang, o‘zingizni tanlang.",
    "Bugun bitta yaxshi ish qiling — o‘zingiz uchun.",
    "Kichkina odatlar katta o‘zgarishlarni yaratadi.",
  ];

  @override
  State<MessageOfDayScreen> createState() => _MessageOfDayScreenState();
}

class _MessageOfDayScreenState extends State<MessageOfDayScreen> with TickerProviderStateMixin {
  bool _loading = true;
  String _message = '';
  String? _imageUrl;
  late final LinearGradient _backgroundGradient;

  AnimationController? _layoutController;
  Animation<Offset>? _layoutSlide;
  Animation<double>? _layoutFade;

  AnimationController? _typeController;
  Animation<double>? _opacity;
  Animation<Offset>? _slide;

  String _pickFallback() {
    final messages = MessageOfDayScreen._fallbackMessages;
    return messages[Random().nextInt(messages.length)];
  }

  @override
  void initState() {
    super.initState();
    _backgroundGradient = AppColors.randomBrandScreenGradient(
      Object.hash(
        widget.key,
        DateTime.now().microsecondsSinceEpoch,
        Random().nextInt(1 << 30),
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadQuotes());
  }

  Future<void> _loadQuotes() async {
    final result = await inject<QuotesRepository>().fetchQuotes();
    if (!mounted) return;

    result.fold(
      (_) {
        _message = _pickFallback();
        _imageUrl = null;
      },
      (list) {
        if (list.isEmpty) {
          _message = _pickFallback();
          _imageUrl = null;
        } else {
          final q = list[Random().nextInt(list.length)];
          _message = q.text.trim().isEmpty ? _pickFallback() : q.text;
          final base = dotenv.env['BASE_URL'] ?? '';
          _imageUrl = q.image.isNotEmpty ? q.resolveImageUrl(base) : null;
        }
      },
    );

    if (!mounted) return;
    setState(() => _loading = false);
    // Keyingi frame — layout (Expanded / LayoutBuilder) barqaror bo‘lgach animatsiya (ketma-ket kirishda buzilmasin).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _beginContentAnimation();
    });
  }

  void _beginContentAnimation() {
    _layoutController?.dispose();
    _typeController?.dispose();

    if (_message.trim().isEmpty) {
      _message = _pickFallback();
    }

    _layoutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 780),
    );
    _layoutSlide = Tween<Offset>(begin: const Offset(0, -0.14), end: Offset.zero).animate(
      CurvedAnimation(parent: _layoutController!, curve: Curves.easeOutCubic),
    );
    _layoutFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _layoutController!, curve: const Interval(0.0, 0.55, curve: Curves.easeOut)),
    );

    setState(() {});

    _layoutController!.forward().then((_) {
      if (!mounted) return;
      _startTypingAnimation();
    });
  }

  void _startTypingAnimation() {
    _typeController?.dispose();

    final ms = (_message.length * 28).clamp(900, 2600);
    _typeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: ms),
    );

    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _typeController!,
        curve: const Interval(0.0, 0.36, curve: Curves.easeOut),
      ),
    );
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _typeController!,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _typeController!.forward();
    setState(() {});
  }

  @override
  void dispose() {
    _layoutController?.dispose();
    _typeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: _backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                SizedBox(height: 6.h),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(CupertinoIcons.back, color: Colors.white),
                    ),
                  ],
                ),
                SizedBox(height: 18.h),
                Expanded(
                  child: _loading
                      ? Center(
                          child: Text(
                            'Bonoos',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body22w7.copyWith(
                              color: Colors.white.withValues(alpha: 0.95),
                              letterSpacing: 0.2,
                              height: 1.15,
                            ),
                          ),
                        )
                      : _layoutController == null
                          ? const SizedBox.shrink()
                          : AnimatedBuilder(
                              animation: Listenable.merge([
                                _layoutController!,
                                if (_typeController != null) _typeController!,
                              ]),
                              builder: (context, _) {
                                return LayoutBuilder(
                                  builder: (context, constraints) {
                                    final maxH = constraints.maxHeight;
                                    final minScrollHeight = maxH.isFinite && maxH > 0
                                        ? maxH
                                        : (MediaQuery.sizeOf(context).height * 0.55).clamp(200.0, 900.0);
                                    return SingleChildScrollView(
                                      physics: const BouncingScrollPhysics(),
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(minHeight: minScrollHeight),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SlideTransition(
                                              position: _layoutSlide!,
                                              child: FadeTransition(
                                                opacity: _layoutFade!,
                                                child: Container(
                                                  width: double.infinity,
                                                  padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                                    children: [
                                                      Text(
                                                        'Kunlik xabar',
                                                        textAlign: TextAlign.center,
                                                        style: AppTextStyles.body14w6.copyWith(
                                                          color: const Color(0xCCFFFFFF),
                                                          letterSpacing: 0,
                                                          height: 1.25,
                                                        ),
                                                      ),
                                                      SizedBox(height: 12.h),
                                                      // if (_imageUrl != null && _imageUrl!.isNotEmpty) ...[
                                                      //   ClipRRect(
                                                      //     borderRadius: BorderRadius.circular(18.r),
                                                      //     child: CachedNetworkImage(
                                                      //       imageUrl: _imageUrl!,
                                                      //       height: 200.h,
                                                      //       width: double.infinity,
                                                      //       fit: BoxFit.cover,
                                                      //       placeholder: (_, __) => Container(
                                                      //         height: 200.h,
                                                      //         color: Colors.white.withValues(alpha: 0.08),
                                                      //         alignment: Alignment.center,
                                                      //         child: SizedBox(
                                                      //           width: 28.w,
                                                      //           height: 28.w,
                                                      //           child: const CircularProgressIndicator(
                                                      //             strokeWidth: 2,
                                                      //             color: Colors.white54,
                                                      //           ),
                                                      //         ),
                                                      //       ),
                                                      //       errorWidget: (_, __, ___) => const SizedBox.shrink(),
                                                      //     ),
                                                      //   ),
                                                      //   SizedBox(height: 18.h),
                                                      // ],
                                                      if (_typeController != null && _opacity != null && _slide != null)
                                                        AnimatedBuilder(
                                                          animation: _typeController!,
                                                          builder: (context, __) {
                                                            final p = _typeController!.value;
                                                            final end =
                                                                (_message.length * p).round().clamp(0, _message.length);
                                                            final typed = _message.substring(0, end);

                                                            return SlideTransition(
                                                              position: _slide!,
                                                              child: FadeTransition(
                                                                opacity: _opacity!,
                                                                child: Text(
                                                                  typed,
                                                                  textAlign: TextAlign.center,
                                                                  style: AppTextStyles.body20w7.copyWith(
                                                                    color: AppColors.white,
                                                                    height: 1.22,
                                                                    letterSpacing: 0,
                                                                    wordSpacing: 0,
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        )
                                                      else
                                                        const SizedBox.shrink(),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                ),
                if (!_loading)
                  Padding(
                    padding: EdgeInsets.only(bottom: 18.h),
                    child: Text(
                      'Bonoos',
                      style: AppTextStyles.body14w6.copyWith(color: const Color(0xCCFFFFFF)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
