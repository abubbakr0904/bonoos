import 'package:animate_do/animate_do.dart';
import 'package:bonoos/core/resources/assets/images/app_images.dart';
import 'package:bonoos/core/values/app_colors.dart';
import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:bonoos/di.dart';
import 'package:bonoos/features/auth/domain/repository/auth_repository.dart';
import 'package:bonoos/features/common/widget/custom_button.dart';
import 'package:bonoos/features/auth/otp_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class LoginPhoneScreen extends StatefulWidget {
  const LoginPhoneScreen({super.key});

  static const String routeName = "/login_phone";

  @override
  State<LoginPhoneScreen> createState() => _LoginPhoneScreenState();
}

class _LoginPhoneScreenState extends State<LoginPhoneScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _loading = false;
  String? _errorText;

  final _mask = MaskTextInputFormatter(
    mask: '+998 (##) ### ## ##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  bool get _isComplete => _mask.getUnmaskedText().length == 9;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        if (_errorText != null) _errorText = null;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_isComplete || _loading) return;
    final phoneDigits = _mask.getUnmaskedText();
    final phoneMasked = _mask.getMaskedText();
    setState(() {
      _errorText = null;
      _loading = true;
    });
    FocusScope.of(context).unfocus();

    final result = await inject<AuthRepository>().sendOtp(phoneDigits: phoneDigits);

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _loading = false;
          _errorText = failure.message ?? 'Xatolik yuz berdi.';
        });
      },
      (_) {
        setState(() => _loading = false);
        context.push(
          OtpScreen.routeName,
          extra: OtpArgs(phone: phoneMasked, phoneDigits: phoneDigits),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBgColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 32.h),
              Center(
                child: Column(
                  children: [
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
                        "Davom etish uchun telefon raqamingizni kiriting —\nkeyin sizga tasdiqlash kodi yuboramiz.",
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body14w4.copyWith(
                          color: Colors.white.withOpacity(0.7),
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40.h),
              FadeInLeft(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 300),
                from: 20,
                child: Text(
                  "Telefon raqam",
                  style: AppTextStyles.body14w6.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 400),
                from: 30,
                child: _PhoneField(
                  controller: _controller,
                  focusNode: _focusNode,
                  inputFormatters: [_mask],
                  readOnly: _loading,
                ),
              ),
              SizedBox(height: 10.h),
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 500),
                from: 20,
                child: Text(
                  "Masalan: +998 (90) 900 90 90",
                  style: AppTextStyles.body12w4.copyWith(
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
              if (_errorText != null) ...[
                SizedBox(height: 12.h),
                FadeIn(
                  child: Text(
                    _errorText!,
                    style: AppTextStyles.body12w6.copyWith(color: AppColors.red),
                  ),
                ),
              ],
              const Spacer(),
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 600),
                from: 40,
                child: SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: "Davom etish",
                    onTap: _submit,
                    isEnabled: _isComplete,
                    isLoading: _loading,
                    height: 50.h,
                    radius: BorderRadius.circular(16.r),
                    textColor: AppColors.mainBgColor,
                    disabledBgColor: Colors.white.withOpacity(0.1),
                    disabledTextColor: Colors.white.withOpacity(0.3),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    bgColor: Colors.white,
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

class _PhoneField extends StatelessWidget {
  const _PhoneField({
    required this.controller,
    required this.focusNode,
    required this.inputFormatters,
    this.readOnly = false,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final List inputFormatters;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        readOnly: readOnly,
        keyboardType: TextInputType.phone,
        cursorColor: Colors.white,
        inputFormatters: inputFormatters.cast(),
        style: AppTextStyles.body16w6.copyWith(
          color: Colors.white.withOpacity(0.95),
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          border: InputBorder.none,
          hintText: "+998 (__) ___ __ __",
          hintStyle: AppTextStyles.body16w4.copyWith(
            color: Colors.white.withOpacity(0.35),
          ),
        ),
      ),
    );
  }
}
