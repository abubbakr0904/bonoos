import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:bonoos/core/api/list_api.dart';
import 'package:bonoos/di.dart';
import 'package:bonoos/core/values/app_colors.dart';
import 'package:bonoos/features/auth/telegram_login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirstEnterScreen extends StatefulWidget {
  const FirstEnterScreen({super.key});

  static const String routeName = "/first-enter";

  @override
  State<FirstEnterScreen> createState() => _FirstEnterScreenState();
}

class _FirstEnterScreenState extends State<FirstEnterScreen> {
  final String _fullText = "Sen hayotingdagi eng to'g'ri qarorni qabul qilding...";
  bool _showActionText = false;
  bool _isExiting = false;

  @override
  void initState() {
    super.initState();
    // Show action text after all words have finished animating
    // Total words: 8. Each word delay: 200ms. Duration: 800ms.
    // Total time around 2.4s.
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) {
        setState(() {
          _showActionText = true;
        });
      }
    });
  }

  Future<void> _handleExit() async {
    if (_isExiting) return;
    
    setState(() {
      _isExiting = true;
    });

    await Future.delayed(const Duration(milliseconds: 700));
    
    if (mounted) {
      _completeFirstEnter();
    }
  }

  Future<void> _completeFirstEnter() async {
    final prefs = inject<SharedPreferences>();
    await prefs.setBool(SharedModel.onBoard, true);
    if (mounted) {
      context.go(TelegramLoginScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final words = _fullText.split(" ");
    
    return Scaffold(
      backgroundColor: AppColors.mainBgColor,
      body: GestureDetector(
        onTap: (_showActionText && !_isExiting) ? _handleExit : null,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: AnimatedOpacity(
              opacity: _isExiting ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8.w,
                    runSpacing: 12.h,
                    children: List.generate(words.length, (index) {
                      return FadeInUp(
                        duration: const Duration(milliseconds: 800),
                        delay: Duration(milliseconds: index * 250),
                        from: 20,
                        child: Text(
                          words[index],
                          style: TextStyle(
                            fontFamily: 'DancingScript',
                            color: Colors.white,
                            fontSize: 36.sp,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                            shadows: [
                              Shadow(
                                color: Colors.white.withOpacity(0.3),
                                blurRadius: 15,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                  const Spacer(),
                  if (_showActionText)
                    FadeInUp(
                      duration: const Duration(milliseconds: 1200),
                      from: 15,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 50.h),
                        child: Text(
                          "Boshlash uchun bosing",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 16.sp,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    )
                  else
                    SizedBox(height: 70.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
