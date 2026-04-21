import 'dart:async';

import 'package:bonoos/core/resources/assets/images/app_images.dart';
import 'package:bonoos/core/values/app_colors.dart';
import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:bonoos/di.dart';
import 'package:bonoos/features/auth/domain/repository/auth_repository.dart';
import 'package:bonoos/features/common/widget/custom_button.dart';
import 'package:bonoos/features/common/widget/home_gradient_background.dart';
import 'package:bonoos/features/tabbox/tabbox_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

class OtpArgs {
  final String phone;
  /// API uchun 9 raqam (prefiksiz), masalan `930374441`.
  final String phoneDigits;
  const OtpArgs({required this.phone, required this.phoneDigits});
}

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.args});

  static const String routeName = "/otp";

  final OtpArgs args;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const int _otpLength = 4;

  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasError = false;
  int _resendSecondsLeft = 30;
  bool _resendLoading = false;
  bool _verifyLoading = false;

  bool get _isComplete => _controller.text.trim().length == _otpLength;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    _tickResend();
  }

  void _tickResend() {
    Future<void>.delayed(const Duration(seconds: 1)).then((_) {
      if (!mounted) return;
      if (_resendSecondsLeft <= 0) return;
      setState(() => _resendSecondsLeft -= 1);
      _tickResend();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _resendOtp() async {
    final digits = widget.args.phoneDigits.trim();
    if (digits.length != 9 || _resendLoading) return;

    setState(() => _resendLoading = true);
    final result = await inject<AuthRepository>().sendOtp(phoneDigits: digits);
    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() => _resendLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message ?? 'Kod yuborilmadi.')),
        );
      },
      (_) {
        setState(() {
          _resendLoading = false;
          _resendSecondsLeft = 30;
        });
        _tickResend();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kod qayta yuborildi.')),
        );
      },
    );
  }

  Future<void> _verify() async {
    final code = _controller.text.trim();
    if (code.length != _otpLength || _verifyLoading) return;

    setState(() {
      _verifyLoading = true;
      _hasError = false;
    });
    FocusScope.of(context).unfocus();

    final verifyResult = await inject<AuthRepository>().verifyOtp(
      phoneDigits: widget.args.phoneDigits.trim(),
      code: code,
    );

    if (!mounted) return;

    final verifyFailure = verifyResult.fold((l) => l, (r) => null);
    if (verifyFailure != null) {
      setState(() {
        _verifyLoading = false;
        _hasError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(verifyFailure.message ?? 'Tasdiqlash muvaffaqiyatsiz.')),
      );
      return;
    }

    final sessionResult = await inject<AuthRepository>().registerClientSession();
    if (!mounted) return;

    sessionResult.fold(
      (failure) {
        setState(() => _verifyLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message ?? 'Sessiya saqlanmadi. Qayta urinib ko‘ring.')),
        );
      },
      (_) {
        setState(() => _verifyLoading = false);
        Future<void>.delayed(const Duration(milliseconds: 200)).then((_) {
          if (!mounted) return;
          context.go(TabBoxScreen.routeName);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final basePinTheme = PinTheme(
      width: 64.w,
      height: 58.h,
      textStyle: AppTextStyles.body20w7.copyWith(
        color: Colors.white.withValues(alpha: 0.95),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
    );

    final focusedTheme = basePinTheme.copyWith(
      decoration: basePinTheme.decoration?.copyWith(
        border: Border.all(color: AppColors.c842D5F, width: 2),
      ),
    );

    final errorTheme = basePinTheme.copyWith(
      decoration: basePinTheme.decoration?.copyWith(
        border: Border.all(color: AppColors.red, width: 2),
      ),
    );

    final submittedTheme = basePinTheme.copyWith(
      decoration: basePinTheme.decoration?.copyWith(
        border: Border.all(color: AppColors.c842D5F, width: 2),
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF140B2A),
      body: Stack(
        children: [
          HomeGradientBackground(),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  SizedBox(height: 14.h),
                  Center(
                    child: Column(
                      children: [
                        Image.asset(AppImages.appLogoPurple, width: 64.w, height: 64.w),
                        SizedBox(height: 10.h),
                        Text(
                          "Tasdiqlash kodi",
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body22w7.copyWith(
                            color: Colors.white.withValues(alpha: 0.95),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          "4 xonali kodni kiriting. Kod quyidagi raqamga yuborildi:",
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body14w4.copyWith(
                            color: Colors.white.withValues(alpha: 0.72),
                            height: 1.45,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                          ),
                          child: Text(
                            widget.args.phone,
                            style: AppTextStyles.body16w6.copyWith(
                              color: Colors.white.withValues(alpha: 0.95),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 22.h),
                  Center(
                    child: Pinput(
                      length: _otpLength,
                      controller: _controller,
                      focusNode: _focusNode,
                      autofocus: true,
                      readOnly: _verifyLoading,
                      cursor: Text(
                        '|',
                        style: AppTextStyles.body20w7.copyWith(
                          color: AppColors.c842D5F,
                          height: 1,
                        ),
                      ),
                      defaultPinTheme: basePinTheme,
                      focusedPinTheme: focusedTheme,
                      submittedPinTheme: submittedTheme,
                      errorPinTheme: errorTheme,
                      forceErrorState: _hasError,
                      onCompleted: (_) => unawaited(_verify()),
                      onChanged: (_) {
                        if (_hasError) setState(() => _hasError = false);
                      },
                    ),
                  ),
                  SizedBox(height: 12.h),
                  if (_hasError)
                    Center(
                      child: Text(
                        "Kod noto‘g‘ri yoki muddati o‘tgan.",
                        style: AppTextStyles.body12w6.copyWith(color: AppColors.red),
                      ),
                    ),
                  SizedBox(height: 10.h),
                  Center(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: _resendSecondsLeft == 0 && !_resendLoading && !_verifyLoading
                            ? AppColors.c842D5F
                            : Colors.white.withValues(alpha: 0.55),
                      ),
                      onPressed: _resendSecondsLeft == 0 && !_resendLoading && !_verifyLoading
                          ? _resendOtp
                          : null,
                      child: _resendLoading
                          ? SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.c842D5F,
                              ),
                            )
                          : Text(
                              _resendSecondsLeft == 0
                                  ? "Kod qayta yuborish"
                                  : "Kod kelmadimi? ${_resendSecondsLeft}s",
                              style: AppTextStyles.body14w6.copyWith(
                                color: _resendSecondsLeft == 0
                                    ? AppColors.c842D5F
                                    : Colors.white.withValues(alpha: 0.55),
                                decoration:
                                    _resendSecondsLeft == 0 ? TextDecoration.underline : TextDecoration.none,
                              ),
                            ),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: "Davom etish",
                      onTap: () => unawaited(_verify()),
                      isEnabled: _isComplete && !_verifyLoading,
                      isLoading: _verifyLoading,
                      height: 56.h,
                      radius: BorderRadius.circular(999),
                      bgColor: AppColors.c842D5F,
                      textColor: AppColors.white,
                      disabledBgColor: Colors.white.withValues(alpha: 0.08),
                      disabledTextColor: Colors.white.withValues(alpha: 0.38),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                    ),
                  ),
                  SizedBox(height: 18.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
