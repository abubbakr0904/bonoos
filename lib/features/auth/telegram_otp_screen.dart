import 'dart:async';
import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:bonoos/core/api/list_api.dart';
import 'package:bonoos/core/error/failure.dart';
import 'package:bonoos/core/resources/assets/images/app_images.dart';
import 'package:bonoos/core/values/app_colors.dart';
import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:bonoos/di.dart';
import 'package:bonoos/features/auth/domain/repository/auth_repository.dart';
import 'package:bonoos/features/common/widget/custom_button.dart';
import 'package:bonoos/features/questions/question_screen.dart';
import 'package:bonoos/features/tabbox/tabbox_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// Login ekranida bot ochilgandan keyin keladi: qaytganda Pinput fokus oladi →
/// 6 xonali kod `telegram/verify` ga yuboriladi → sessiya → ilovaga.
class TelegramOtpScreen extends StatefulWidget {
  const TelegramOtpScreen({super.key});

  static const String routeName = "/telegram_otp";

  @override
  State<TelegramOtpScreen> createState() => _TelegramOtpScreenState();
}

class _TelegramOtpScreenState extends State<TelegramOtpScreen> with WidgetsBindingObserver {
  static const int _codeLength = 6;
  static final RegExp _codePattern = RegExp(r'^\d{6}$');

  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  bool _loading = false;

  /// Kod tasdiqlangan (tokenlar saqlangan), lekin sessiya yozilmagan bo'lsa —
  /// qayta urinishda kodni qayta yubormaymiz (u bir martalik).
  bool _verified = false;
  String? _errorText;

  bool get _isComplete => _controller.text.trim().length == _codeLength;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || _controller.text.isNotEmpty) return;
    // Botdan "Nusxalash" bilan qaytganda Androidda kodni avtomatik qo'yamiz.
    // iOS da clipboard o'qish ruxsat oynasini chiqaradi — u yerda faqat fokus beramiz.
    if (Platform.isAndroid) {
      unawaited(_pasteCode().then((pasted) {
        if (!pasted && mounted) _focusNode.requestFocus();
      }));
    } else {
      _focusNode.requestFocus();
    }
  }

  Future<void> _openBot() async {
    _controller.clear();
    setState(() => _errorText = null);
    final ok = await launchUrl(
      Uri.parse(ListAPI.telegramAuthBotUrl),
      mode: LaunchMode.externalApplication,
    );
    if (!mounted || ok) return;
    setState(() => _errorText = 'Telegram ochilmadi. Telegram ilovasi o‘rnatilganini tekshiring.');
  }

  /// `true` — kod topildi va qo'yildi.
  Future<bool> _pasteCode() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = (data?.text ?? '').replaceAll(RegExp(r'\s'), '');
    if (!mounted) return false;
    if (!_codePattern.hasMatch(text)) return false;
    _controller.text = text;
    unawaited(_verify());
    return true;
  }

  Future<void> _verify() async {
    final code = _controller.text.trim();
    if (code.length != _codeLength || _loading) return;

    setState(() {
      _loading = true;
      _errorText = null;
    });
    FocusScope.of(context).unfocus();

    final auth = inject<AuthRepository>();
    if (!_verified) {
      final verifyResult = await auth.telegramVerify(code: code);
      if (!mounted) return;

      final failure = verifyResult.fold((l) => l, (r) => null);
      if (failure != null) {
        setState(() {
          _loading = false;
          _errorText = failure is ConnectionFailure || failure is TooManyRequestsFailure
              ? failure.message
              : 'Kod noto‘g‘ri yoki muddati o‘tgan. Botdan yangi kod oling.';
        });
        return;
      }
      _verified = true;
    }

    final sessionResult = await auth.registerClientSession();
    if (!mounted) return;

    sessionResult.fold(
      (failure) {
        setState(() {
          _loading = false;
          _errorText = failure.message ?? 'Sessiya saqlanmadi. Qayta urinib ko‘ring.';
        });
      },
      (_) {
        setState(() => _loading = false);
        final isNewUser = inject<SharedPreferences>().getBool(SharedModel.newUser) ?? false;
        context.go(isNewUser ? QuestionScreen.routeName : TabBoxScreen.routeName);
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
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: _loading ? null : () => context.pop(),
                  padding: EdgeInsets.zero,
                  icon: Icon(CupertinoIcons.chevron_left, color: Colors.white, size: 24.sp),
                ),
              ),
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
                  "Telegram botdan olgan 6 xonali kodni kiriting.",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body14w4.copyWith(
                    color: Colors.white.withOpacity(0.7),
                    height: 1.45,
                  ),
                ),
              ),
              SizedBox(height: 32.h),
              _buildCodeInput(),
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
                delay: const Duration(milliseconds: 400),
                from: 40,
                child: SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: "Kirish",
                    onTap: () => unawaited(_verify()),
                    isEnabled: _isComplete,
                    isLoading: _loading,
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

  Widget _buildCodeInput() {
    final basePinTheme = PinTheme(
      width: 48.w,
      height: 56.h,
      textStyle: AppTextStyles.body20w7.copyWith(color: Colors.white.withOpacity(0.95)),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14.r),
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

    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      from: 30,
      child: Column(
        children: [
          Pinput(
            length: _codeLength,
            controller: _controller,
            focusNode: _focusNode,
            readOnly: _loading,
            keyboardType: TextInputType.number,
            autofillHints: const [AutofillHints.oneTimeCode],
            cursor: Text(
              '|',
              style: AppTextStyles.body20w7.copyWith(color: Colors.white, height: 1),
            ),
            defaultPinTheme: basePinTheme,
            focusedPinTheme: focusedTheme,
            submittedPinTheme: submittedTheme,
            errorPinTheme: errorTheme,
            forceErrorState: _errorText != null,
            onCompleted: (_) => unawaited(_verify()),
            onChanged: (_) {
              if (_errorText != null) setState(() => _errorText = null);
            },
          ),
          SizedBox(height: 12.h),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            onPressed: _loading ? null : () => unawaited(_openBot()),
            child: Text(
              "Kodni qayta olish",
              style: AppTextStyles.body14w6.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
