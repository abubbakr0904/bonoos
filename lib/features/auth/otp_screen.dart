import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:bonoos/core/api/list_api.dart';
import 'package:bonoos/core/resources/assets/images/app_images.dart';
import 'package:bonoos/core/values/app_colors.dart';
import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:bonoos/di.dart';
import 'package:bonoos/features/auth/domain/repository/auth_repository.dart';
import 'package:bonoos/features/common/widget/custom_button.dart';
import 'package:bonoos/features/questions/question_screen.dart';
import 'package:bonoos/features/tabbox/tabbox_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OtpArgs {
  final String phone;
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
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text(failure.message ?? 'Kod yuborilmadi.')),
        // );
      },
      (_) {
        setState(() {
          _resendLoading = false;
          _resendSecondsLeft = 30;
        });
        _tickResend();
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('Kod qayta yuborildi.')),
        // );
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
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text(verifyFailure.message ?? 'Tasdiqlash muvaffaqiyatsiz.')),
      // );
      return;
    }

    final sessionResult = await inject<AuthRepository>().registerClientSession();
    if (!mounted) return;

    sessionResult.fold(
      (failure) {
        setState(() => _verifyLoading = false);
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text(failure.message ?? 'Sessiya saqlanmadi. Qayta urinib ko‘ring.')),
        // );
      },
      (_) {
        setState(() => _verifyLoading = false);
        Future<void>.delayed(const Duration(milliseconds: 200)).then((_) {
          if (!mounted) return;
          final isNewUser = inject<SharedPreferences>().getBool(SharedModel.newUser) ?? false;
          if (isNewUser) {
            context.go(QuestionScreen.routeName);
          } else {
            context.go(TabBoxScreen.routeName);
          }
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
        color: Colors.white.withOpacity(0.95),
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
    );

    final focusedTheme = basePinTheme.copyWith(
      decoration: basePinTheme.decoration?.copyWith(
        border: Border.all(color: Colors.white, width: 2),
      ),
    );

    final errorTheme = basePinTheme.copyWith(
      decoration: basePinTheme.decoration?.copyWith(
        border: Border.all(color: AppColors.red, width: 2),
      ),
    );

    final submittedTheme = basePinTheme.copyWith(
      decoration: basePinTheme.decoration?.copyWith(
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.mainBgColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              SizedBox(height: 32.h),
              Center(
                child: Column(
                  children: [
                    FadeInLeft(
                      duration: const Duration(milliseconds: 600),
                      from: 30,
                      child: Image.asset(AppImages.appLogoPurple, width: 80.w, height: 80.w),
                    ),
                    SizedBox(height: 16.h),
                    FadeInLeft(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 100),
                      from: 30,
                      child: Text(
                        "Tasdiqlash kodi",
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
                        "4 xonali kodni kiriting. Kod quyidagi raqamga yuborildi:",
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body14w4.copyWith(
                          color: Colors.white.withOpacity(0.7),
                          height: 1.45,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    FadeInLeft(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 300),
                      from: 30,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Text(
                          widget.args.phone,
                          style: AppTextStyles.body16w6.copyWith(
                            color: Colors.white.withOpacity(0.95),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.h),
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 400),
                from: 30,
                child: Center(
                  child: Pinput(
                    length: _otpLength,
                    controller: _controller,
                    focusNode: _focusNode,
                    autofocus: true,
                    readOnly: _verifyLoading,
                    cursor: Text(
                      '|',
                      style: AppTextStyles.body20w7.copyWith(
                        color: Colors.white,
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
              ),
              SizedBox(height: 16.h),
              if (_hasError)
                Center(
                  child: Text(
                    "Kod noto‘g‘ri yoki muddati o‘tgan.",
                    style: AppTextStyles.body12w6.copyWith(color: AppColors.red),
                  ),
                ),
              SizedBox(height: 12.h),
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 500),
                from: 20,
                child: Center(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _resendSecondsLeft == 0 && !_resendLoading && !_verifyLoading ? _resendOtp : null,
                    child: _resendLoading
                        ? SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _resendSecondsLeft == 0 ? "Kod qayta yuborish" : "Kod kelmadimi? ${_resendSecondsLeft}s",
                            style: AppTextStyles.body14w6.copyWith(
                              color: _resendSecondsLeft == 0 ? Colors.white : Colors.white.withOpacity(0.5),
                            ),
                          ),
                  ),
                ),
              ),
              const Spacer(),
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 600),
                from: 40,
                child: SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: "Davom etish",
                    onTap: () => unawaited(_verify()),
                    isEnabled: _isComplete && !_verifyLoading,
                    isLoading: _verifyLoading,
                    height: 50.h,
                    radius: BorderRadius.circular(16.r),
                    bgColor: Colors.white,
                    textColor: AppColors.mainBgColor,
                    disabledBgColor: Colors.white.withOpacity(0.1),
                    disabledTextColor: Colors.white.withOpacity(0.3),
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
