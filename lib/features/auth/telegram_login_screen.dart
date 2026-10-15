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
import 'package:bonoos/features/auth/login_phone_screen.dart';
import 'package:bonoos/features/common/widget/custom_button.dart';
import 'package:bonoos/features/questions/question_screen.dart';
import 'package:bonoos/features/tabbox/tabbox_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// Asosiy login: user @bonoos_auth_bot da raqamini ulashadi, bot bergan
/// 6 xonali kodni shu yerga kiritadi. Telefon + OTP ekrani (App Store test
/// akkaunti uchun) pastdagi havola orqali ochiladi.
class TelegramLoginScreen extends StatefulWidget {
  const TelegramLoginScreen({super.key});

  static const String routeName = "/login";

  @override
  State<TelegramLoginScreen> createState() => _TelegramLoginScreenState();
}

class _TelegramLoginScreenState extends State<TelegramLoginScreen>
    with WidgetsBindingObserver {
  static const int _codeLength = 6;
  static const Color _telegramBlue = Color(0xFF2AABEE);
  static final RegExp _codePattern = RegExp(r'^\d{6}$');

  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _loading = false;
  bool _openedBot = false;
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
    // Botdan "Nusxalash" bilan qaytganda kodni avtomatik qo'yamiz. iOS da
    // clipboard o'qish ruxsat oynasini chiqaradi — u yerda "Joylash" tugmasi bor.
    if (state == AppLifecycleState.resumed &&
        _openedBot &&
        Platform.isAndroid &&
        _controller.text.isEmpty) {
      unawaited(_pasteCode(silent: true));
    }
  }

  Future<void> _openBot() async {
    final ok = await launchUrl(
      Uri.parse(ListAPI.telegramAuthBotUrl),
      mode: LaunchMode.externalApplication,
    );
    if (!mounted) return;
    if (ok) {
      setState(() => _openedBot = true);
    } else {
      setState(() => _errorText = 'Telegram ochilmadi. Telegram ilovasi o‘rnatilganini tekshiring.');
    }
  }

  Future<void> _pasteCode({bool silent = false}) async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim() ?? '';
    if (!mounted) return;
    if (!_codePattern.hasMatch(text)) {
      if (!silent) {
        setState(() => _errorText = 'Nusxalangan matnda 6 xonali kod topilmadi.');
      }
      return;
    }
    _controller.text = text;
    unawaited(_verify());
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
    final verifyResult = await auth.telegramVerify(code: code);
    if (!mounted) return;

    final verifyFailure = verifyResult.fold((l) => l, (r) => null);
    if (verifyFailure != null) {
      setState(() {
        _loading = false;
        _errorText = verifyFailure is ConnectionFailure || verifyFailure is TooManyRequestsFailure
            ? verifyFailure.message
            : 'Kod noto‘g‘ri yoki muddati o‘tgan. Botda “Yangilash” ni bosing.';
      });
      return;
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

    return Scaffold(
      backgroundColor: AppColors.mainBgColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
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
                        "Telegram orqali bir necha soniyada kiring.",
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body14w4.copyWith(
                          color: Colors.white.withOpacity(0.7),
                          height: 1.45,
                        ),
                      ),
                    ),
                    SizedBox(height: 28.h),
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 300),
                      from: 20,
                      child: const _Steps(),
                    ),
                    SizedBox(height: 20.h),
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 400),
                      from: 20,
                      child: SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          text: _openedBot ? "Botni qayta ochish" : "Telegram botni ochish",
                          onTap: () => unawaited(_openBot()),
                          isEnabled: !_loading,
                          height: 50.h,
                          radius: BorderRadius.circular(16.r),
                          bgColor: _telegramBlue,
                          textColor: Colors.white,
                          disabledBgColor: _telegramBlue.withOpacity(0.4),
                          disabledTextColor: Colors.white.withOpacity(0.6),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                      ),
                    ),
                    SizedBox(height: 28.h),
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 500),
                      from: 20,
                      child: Column(
                        children: [
                          Text(
                            "Botdagi kodni kiriting",
                            style: AppTextStyles.body14w6.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Pinput(
                            length: _codeLength,
                            controller: _controller,
                            focusNode: _focusNode,
                            readOnly: _loading,
                            keyboardType: TextInputType.number,
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
                          TextButton.icon(
                            style: TextButton.styleFrom(foregroundColor: Colors.white),
                            onPressed: _loading ? null : () => unawaited(_pasteCode()),
                            icon: Icon(Icons.content_paste_rounded, size: 18.sp),
                            label: Text(
                              "Kodni joylash",
                              style: AppTextStyles.body14w6.copyWith(
                                color: Colors.white.withOpacity(0.85),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_errorText != null)
                      FadeIn(
                        child: Text(
                          _errorText!,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body12w6.copyWith(color: AppColors.red),
                        ),
                      ),
                    const Spacer(),
                    SizedBox(height: 24.h),
                    FadeInUp(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 600),
                      from: 40,
                      child: SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          text: "Kirish",
                          onTap: () => unawaited(_verify()),
                          isEnabled: _isComplete && !_loading,
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
                    TextButton(
                      onPressed: _loading ? null : () => context.push(LoginPhoneScreen.routeName),
                      child: Text(
                        "Telefon raqam orqali kirish",
                        style: AppTextStyles.body12w4.copyWith(
                          color: Colors.white.withOpacity(0.55),
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white.withOpacity(0.55),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Steps extends StatelessWidget {
  const _Steps();

  static const _items = [
    "Telegram botni oching va “Start” ni bosing",
    "“Raqamni ulashish” tugmasi bilan raqamingizni yuboring",
    "Bot bergan 6 xonali kodni pastga kiriting",
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < _items.length; i++) ...[
            if (i > 0) SizedBox(height: 12.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24.w,
                  height: 24.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    "${i + 1}",
                    style: AppTextStyles.body12w6.copyWith(color: Colors.white),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    _items[i],
                    style: AppTextStyles.body14w4.copyWith(
                      color: Colors.white.withOpacity(0.85),
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
