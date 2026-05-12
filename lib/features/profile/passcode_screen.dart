import 'dart:io';
import 'dart:ui';
import 'package:bonoos/core/values/app_colors.dart';
import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:bonoos/features/profile/security_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum PasscodeMode { setup, verify, change, setupConfirm }

class PasscodeScreen extends StatefulWidget {
  const PasscodeScreen({
    super.key,
    this.mode = PasscodeMode.setup,
    this.onSuccess,
  });

  final PasscodeMode mode;
  final VoidCallback? onSuccess;

  @override
  State<PasscodeScreen> createState() => _PasscodeScreenState();
}

class _PasscodeScreenState extends State<PasscodeScreen> with SingleTickerProviderStateMixin {
  late PasscodeMode _currentMode;
  String _code = "";
  String _tempCode = ""; // For setup confirmation
  final int _codeLength = 4;
  String _errorText = "";

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _currentMode = widget.mode;

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: 10), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 10, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: -10, end: 10), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 10, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));

    if (_currentMode == PasscodeMode.verify) {
      _checkBiometrics();
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometrics() async {
    final enabled = await SecurityService.isBiometricEnabled();
    if (enabled) {
      final success = await SecurityService.authenticateBiometrically();
      if (success) {
        _handleSuccess();
      }
    }
  }

  void _onNumberTap(int number) {
    if (_code.length < _codeLength) {
      setState(() {
        _code += number.toString();
        _errorText = "";
      });
      if (_code.length == _codeLength) {
        _processCode();
      }
    }
  }

  void _onBackspace() {
    if (_code.isNotEmpty) {
      setState(() {
        _code = _code.substring(0, _code.length - 1);
        _errorText = "";
      });
    }
  }

  Future<void> _processCode() async {
    switch (_currentMode) {
      case PasscodeMode.setup:
        setState(() {
          _tempCode = _code;
          _code = "";
          _currentMode = PasscodeMode.setupConfirm;
        });
        break;

      case PasscodeMode.setupConfirm:
        if (_code == _tempCode) {
          await SecurityService.setPin(_code);
          await _askBiometrics();
          _handleSuccess();
        } else {
          _shakeController.forward(from: 0);
          setState(() {
            _code = "";
            _errorText = "Kodlar mos kelmadi, qayta urinib ko'ring";
          });
        }
        break;

      case PasscodeMode.verify:
        final ok = await SecurityService.verifyPin(_code);
        if (ok) {
          _handleSuccess();
        } else {
          _shakeController.forward(from: 0);
          setState(() {
            _code = "";
            _errorText = "Noto'g'ri kod";
          });
        }
        break;

      case PasscodeMode.change:
        final ok = await SecurityService.verifyPin(_code);
        if (ok) {
          setState(() {
            _code = "";
            _currentMode = PasscodeMode.setup;
          });
        } else {
          _shakeController.forward(from: 0);
          setState(() {
            _code = "";
            _errorText = "Hozirgi kod noto'g'ri";
          });
        }
        break;
    }
  }

  Future<void> _askBiometrics() async {
    final canCheck = await SecurityService.canCheckBiometrics();
    if (!canCheck || !mounted) return;

    final useBiometric = await showDialog<bool>(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 40.w),
          child: Container(
            padding: EdgeInsets.all(28.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.mainBgColor.withValues(alpha: 0.95),
                  AppColors.c842D5F.withValues(alpha: 0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(32.r),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Platform.isIOS ? CupertinoIcons.viewfinder : CupertinoIcons.device_phone_portrait,
                    color: Colors.white,
                    size: 42.sp,
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  Platform.isIOS ? "Face ID ishlatilsinmi?" : "Barmoq izi ishlatilsinmi?",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body22w7.copyWith(
                    color: Colors.white,
                    fontFamily: 'DancingScript',
                    fontSize: 26.sp,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  "Keyingi safar tezroq va xavfsizroq kirish uchun foydalaning",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body14w4.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 32.h),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          foregroundColor: Colors.white.withValues(alpha: 0.7),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                          ),
                        ),
                        child: Text(
                          "Yo'q",
                          style: AppTextStyles.body15w5,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.c842D5F.withValues(alpha: 0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.mainBgColor,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                          ),
                          child: Text(
                            "Ha",
                            style: AppTextStyles.body15w7.copyWith(
                              color: AppColors.mainBgColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (useBiometric == true) {
      final success = await SecurityService.authenticateBiometrically();
      if (success) {
        await SecurityService.setBiometricEnabled(true);
      }
    }
  }

  void _handleSuccess() {
    if (widget.onSuccess != null) {
      widget.onSuccess!();
    } else {
      Navigator.pop(context, true);
    }
  }

  String get _title {
    switch (_currentMode) {
      case PasscodeMode.setup:
        return "Yangi parol o'rnating";
      case PasscodeMode.setupConfirm:
        return "Parolni tasdiqlang";
      case PasscodeMode.verify:
        return "Parolni kiriting";
      case PasscodeMode.change:
        return "Hozirgi parolni kiriting";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: widget.mode == PasscodeMode.verify 
          ? null 
          : IconButton(
              icon: const Icon(CupertinoIcons.back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
      ),
      body: Column(
        children: [
          SizedBox(height: 20.h),
          Text(
            _title,
            style: AppTextStyles.body22w7.copyWith(color: Colors.white),
          ),
          if (_errorText.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              _errorText,
              style: AppTextStyles.body13w5.copyWith(color: Colors.redAccent),
            ),
          ],
          SizedBox(height: 60.h),
          // Indicators
          AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_shakeAnimation.value, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_codeLength, (index) {
                    bool isFilled = index < _code.length;
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 12.w),
                      height: 16.w,
                      width: 16.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isFilled ? AppColors.white : Colors.white.withValues(alpha: 0.1),
                        border: Border.all(
                          color: isFilled ? Colors.white : Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                    );
                  }),
                ),
              );
            },
          ),
          const Spacer(),
          _NumericKeypad(
            onNumberTap: _onNumberTap,
            onBackspace: _onBackspace,
            showBiometric: _currentMode == PasscodeMode.verify,
            onBiometricTap: _checkBiometrics,
          ),
          SizedBox(height: 60.h),
        ],
      ),
    );
  }
}

class _NumericKeypad extends StatelessWidget {
  const _NumericKeypad({
    required this.onNumberTap,
    required this.onBackspace,
    this.showBiometric = false,
    this.onBiometricTap,
  });

  final Function(int) onNumberTap;
  final VoidCallback onBackspace;
  final bool showBiometric;
  final VoidCallback? onBiometricTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var row in [[1, 2, 3], [4, 5, 6], [7, 8, 9]])
          Padding(
            padding: EdgeInsets.only(bottom: 24.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map((n) => _KeyButton(
                label: n.toString(),
                onTap: () => onNumberTap(n),
              )).toList(),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            showBiometric 
              ? _KeyButton(
                  icon: Platform.isIOS ? CupertinoIcons.lock_shield : CupertinoIcons.device_phone_portrait,
                  onTap: onBiometricTap!,
                  isIcon: true,
                )
              : SizedBox(width: 80.w),
            _KeyButton(
              label: "0",
              onTap: () => onNumberTap(0),
            ),
            _KeyButton(
              icon: CupertinoIcons.delete_left,
              onTap: onBackspace,
              isIcon: true,
            ),
          ],
        ),
      ],
    );
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({
    this.label,
    this.icon,
    required this.onTap,
    this.isIcon = false,
  });

  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool isIcon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 80.w,
        width: 80.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.05),
        ),
        child: Center(
          child: isIcon 
            ? Icon(icon, color: Colors.white, size: 28.sp)
            : Text(
                label!,
                style: AppTextStyles.body25w6.copyWith(color: Colors.white),
              ),
        ),
      ),
    );
  }
}
