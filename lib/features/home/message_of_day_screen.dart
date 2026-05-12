import 'dart:math';
import 'package:bonoos/core/resources/assets/images/app_images.dart';
import 'package:bonoos/core/values/app_colors.dart';
import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:bonoos/di.dart';
import 'package:bonoos/features/home/domain/repository/quotes_repository.dart';
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
  bool _isExiting = false;
  String _message = '';
  String? _imageUrl;

  late final AnimationController _revealController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  String _pickFallback() {
    final messages = MessageOfDayScreen._fallbackMessages;
    return messages[Random().nextInt(messages.length)];
  }

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _revealController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
      CurvedAnimation(parent: _revealController, curve: Curves.easeOutCubic),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadQuotes());
  }

  Future<void> _loadQuotes() async {
    final result = await inject<QuotesRepository>().fetchQuotes();
    if (!mounted) return;

    result.fold(
      (_) => _message = _pickFallback(),
      (list) {
        if (list.isEmpty) {
          _message = _pickFallback();
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
    _revealController.forward();
  }

  Future<void> _handleExit() async {
    if (_isExiting || _loading) return;
    setState(() => _isExiting = true);

    await _revealController.reverse();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _revealController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleExit,
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: AppColors.mainBgColor,
        body: SafeArea(
          child: Column(
            children: [
         
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32.w),
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        _message,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 26.sp,
                                          fontFamily: 'DancingScript',
                                          height: 1.4,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withOpacity(0.2),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                 Image.asset(AppImages.splashImage , width: 80.w, height: 80.w)
                                ],
                              ),
                            ),
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
