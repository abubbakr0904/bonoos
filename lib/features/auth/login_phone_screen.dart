import 'package:bonoos/core/resources/assets/images/app_images.dart';
import 'package:bonoos/core/values/app_colors.dart';
import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:bonoos/di.dart';
import 'package:bonoos/features/auth/domain/repository/auth_repository.dart';
import 'package:bonoos/features/common/widget/custom_button.dart';
import 'package:bonoos/features/common/widget/home_gradient_background.dart';
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
      backgroundColor: const Color(0xFF140B2A),
      body: Stack(
        children: [
          HomeGradientBackground(),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 14.h),
                  Center(
                    child: Column(
                      children: [
                        Image.asset(AppImages.appLogoPurple, width: 64.w, height: 64.w),
                        SizedBox(height: 10.h),
                        Text(
                          "Xush kelibsiz!",
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body22w7.copyWith(
                            color: Colors.white.withValues(alpha: 0.95),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          "Davom etish uchun telefon raqamingizni kiriting —\nkeyin sizga tasdiqlash kodi yuboramiz.",
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body14w4.copyWith(
                            color: Colors.white.withValues(alpha: 0.72),
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    "Telefon raqam",
                    style: AppTextStyles.body14w6.copyWith(
                      color: Colors.white.withValues(alpha: 0.88),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  _PhoneField(
                    controller: _controller,
                    focusNode: _focusNode,
                    inputFormatters: [_mask],
                    readOnly: _loading,
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    "Masalan: +998 (90) 900 90 90",
                    style: AppTextStyles.body12w4.copyWith(
                      color: Colors.white.withValues(alpha: 0.55),
                    ),
                  ),
                  if (_errorText != null) ...[
                    SizedBox(height: 12.h),
                    Text(
                      _errorText!,
                      style: AppTextStyles.body12w6.copyWith(color: AppColors.red),
                    ),
                  ],
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: "Davom etish",
                      onTap: _submit,
                      isEnabled: _isComplete,
                      isLoading: _loading,
                      height: 56.h,
                      radius: BorderRadius.circular(999),
                      textColor: AppColors.white,
                      disabledBgColor: Colors.white.withValues(alpha: 0.08),
                      disabledTextColor: Colors.white.withValues(alpha: 0.38),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      bgColor: AppColors.c842D5F,
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
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        readOnly: readOnly,
        keyboardType: TextInputType.phone,
        cursorColor: AppColors.c842D5F,
        inputFormatters: inputFormatters.cast(),
        style: AppTextStyles.body16w6.copyWith(
          color: Colors.white.withValues(alpha: 0.95),
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          border: InputBorder.none,
          hintText: "+998 (__) ___ __ __",
          hintStyle: AppTextStyles.body16w4.copyWith(
            color: Colors.white.withValues(alpha: 0.42),
          ),
        ),
      ),
    );
  }
}

