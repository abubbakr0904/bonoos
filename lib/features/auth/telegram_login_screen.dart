import 'package:animate_do/animate_do.dart';
import 'dart:async';

import 'package:bonoos/core/api/list_api.dart';
import 'package:bonoos/core/resources/assets/images/app_images.dart';
import 'package:bonoos/core/values/app_colors.dart';
import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:bonoos/features/auth/telegram_otp_screen.dart';
import 'package:bonoos/features/common/widget/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

/// Asosiy login ekrani. "Kodni olish" @bonoos_auth_bot ni ochadi va
/// [TelegramOtpScreen] (kod kiritish) ga o'tadi.
class TelegramLoginScreen extends StatefulWidget {
  const TelegramLoginScreen({super.key});

  static const String routeName = "/login";

  @override
  State<TelegramLoginScreen> createState() => _TelegramLoginScreenState();
}

class _TelegramLoginScreenState extends State<TelegramLoginScreen> {
  String? _errorText;

  Future<void> _getCode() async {
    setState(() => _errorText = null);
    final ok = await launchUrl(
      Uri.parse(ListAPI.telegramAuthBotUrl),
      mode: LaunchMode.externalApplication,
    );
    if (!mounted) return;
    if (ok) {
      unawaited(context.push(TelegramOtpScreen.routeName));
    } else {
      setState(() => _errorText = 'Telegram ochilmadi. Telegram ilovasi o‘rnatilganini tekshiring.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBgColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              SizedBox(height: 32.h),
              FadeInLeft(
                duration: const Duration(milliseconds: 600),
                from: 30,
                child: Image.asset(AppImages.splashImage, width: 80.w, height: 80.w),
              ),
              SizedBox(height: 16.h),
              FadeInLeft(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 100),
                from: 30,
                child: Text(
                  "Xush kelibsiz!",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body22w7.copyWith(
                    color: Colors.white.withOpacity(0.95),
                    fontFamily: 'DancingScript',
                    fontSize: 32.sp,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              FadeInLeft(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 200),
                from: 30,
                child: Text(
                  "Bonoos ilovasiga kirish uchun Telegram orqali\ntasdiqlovchi kodni kiriting.",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body14w4.copyWith(
                    color: Colors.white.withOpacity(0.7),
                    height: 1.45,
                  ),
                ),
              ),
              SizedBox(height: 40.h),
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 300),
                from: 20,
                child: const _Steps(),
              ),
              if (_errorText != null) ...[
                SizedBox(height: 12.h),
                FadeIn(
                  child: Text(
                    _errorText!,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body12w6.copyWith(color: AppColors.red),
                  ),
                ),
              ],
              const Spacer(),
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 500),
                from: 40,
                child: SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: "Kodni olish",
                    onTap: () => unawaited(_getCode()),
                    height: 50.h,
                    radius: BorderRadius.circular(16.r),
                    bgColor: Colors.white,
                    textColor: AppColors.mainBgColor,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _Steps extends StatelessWidget {
  const _Steps();

  static const _items = [
    "“Kodni olish” tugmasini bosing",
    "Botda raqamingizni ulashib, kodni oling",
    "Kodni ilovaga kiriting",
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < _items.length; i++) ...[
            if (i > 0) SizedBox(height: 14.h),
            Row(
              children: [
                Container(
                  width: 26.w,
                  height: 26.w,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    "${i + 1}",
                    style: AppTextStyles.body12w7.copyWith(color: AppColors.mainBgColor),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    _items[i],
                    style: AppTextStyles.body14w4.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
