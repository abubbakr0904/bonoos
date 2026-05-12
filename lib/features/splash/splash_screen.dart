import 'dart:ui';

import 'package:bonoos/core/resources/assets/images/app_images.dart';
import 'package:bonoos/core/api/list_api.dart';
import 'package:bonoos/core/utils/pref_manager.dart';
import 'package:bonoos/di.dart';
import 'package:bonoos/core/values/app_colors.dart';
import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:bonoos/features/auth/login_phone_screen.dart';
import 'package:bonoos/features/on_boarding/first_enter_screen.dart';
import 'package:bonoos/features/profile/passcode_screen.dart';
import 'package:bonoos/features/questions/question_screen.dart';
import 'package:bonoos/features/tabbox/tabbox_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bonoos/features/profile/security_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const String routeName = "/splash";

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _glow;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _accentLine;

  Future<void> _init() async {
    await Future<void>.delayed(const Duration(seconds: 4));

    if (!mounted) return;

    final prefs = inject<SharedPreferences>();
    final token = inject<PrefManager>().token;
    final hasToken = token != null && token.isNotEmpty;
    final hasSeenOnboarding = prefs.getBool(SharedModel.onBoard) ?? false;
    final hasPendingQuestions = prefs.getBool(SharedModel.newUser) ?? false;

    if (!hasSeenOnboarding) {
      context.go(FirstEnterScreen.routeName);
      return;
    }
    //
    if (!hasToken) {
      context.go(LoginPhoneScreen.routeName);
      return;
    }
    //
    if (hasPendingQuestions) {
      SecurityService.isSplashActive = false;
      context.go(QuestionScreen.routeName);
    } else {
      SecurityService.isSplashActive = false;
      context.go(TabBoxScreen.routeName);
    }
  }

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _glow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    )..repeat(reverse: true);

    _logoScale = Tween<double>(begin: 0.78, end: 1.0).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0.0, 0.52, curve: Curves.easeOutCubic),
      ),
    );
    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0.0, 0.48, curve: Curves.easeOut),
      ),
    );
    _textFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0.32, 0.88, curve: Curves.easeOutCubic),
      ),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.22),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0.32, 0.88, curve: Curves.easeOutCubic),
      ),
    );
    _accentLine = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0.52, 0.95, curve: Curves.easeOutCubic),
      ),
    );

    _intro.forward();
    _init();
  }

  @override
  void dispose() {
    _intro.dispose();
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: AppColors.mainBgColor),
          RepaintBoundary(child: _AmbientGlow(controller: _glow)),
          SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 28.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _intro,
                      builder: (context, _) {
                        return Opacity(
                          opacity: _logoFade.value,
                          child: Transform.scale(
                            scale: _logoScale.value,
                            child: Image.asset(
                              AppImages.splashImage,
                              width: 200.w,
                              fit: BoxFit.contain,
                            ),
                          ),
                        );
                      },
                    ),

                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Yumshoq, nafas kabi pulsatsiya — fonni jonli qiladi.
class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(controller.value);
        final breathe = 0.92 + 0.08 * t;
        final blur = 48.0 + 24 * t;
        return IgnorePointer(
          child: Stack(
            children: [
              Positioned(
                top: -60.h,
                right: -40.w,
                child: Transform.scale(
                  scale: breathe,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                    child: Container(
                      width: 220.w,
                      height: 220.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.22),
                            Colors.white.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 40.h,
                left: -50.w,
                child: Transform.scale(
                  scale: 1.06 - 0.08 * t,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(
                        sigmaX: blur * 0.85, sigmaY: blur * 0.85),
                    child: Container(
                      width: 280.w,
                      height: 280.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF9B6DFF).withOpacity(0.18),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
