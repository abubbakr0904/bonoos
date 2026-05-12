import 'package:bonoos/core/values/app_colors.dart';
import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PasscodeScreen extends StatefulWidget {
  const PasscodeScreen({super.key, this.isVerification = false});

  final bool isVerification;

  @override
  State<PasscodeScreen> createState() => _PasscodeScreenState();
}

class _PasscodeScreenState extends State<PasscodeScreen> {
  String _code = "";
  final int _codeLength = 4;

  void _onNumberTap(int number) {
    if (_code.length < _codeLength) {
      setState(() {
        _code += number.toString();
      });
      if (_code.length == _codeLength) {
        _onComplete();
      }
    }
  }

  void _onBackspace() {
    if (_code.isNotEmpty) {
      setState(() {
        _code = _code.substring(0, _code.length - 1);
      });
    }
  }

  void _onComplete() {
    // In a real app, logic for setting or verifying would go here
    // For now, just a delay and then pop to show it worked in UI
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isVerification ? "Kod tasdiqlandi" : "Kod muvaffaqiyatli o'rnatildi"),
            backgroundColor: AppColors.c842D5F,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 40.h),
          Text(
            widget.isVerification ? "Parolni kiriting" : "Yangi parol o'rnating",
            style: AppTextStyles.body22w7.copyWith(color: Colors.white),
          ),
          SizedBox(height: 12.h),
          Text(
            widget.isVerification 
                ? "Ilovaga kirish uchun parolni kiriting" 
                : "Ilovani himoya qilish uchun 4 xonali kod o'rnating",
            textAlign: TextAlign.center,
            style: AppTextStyles.body14w4.copyWith(
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
          SizedBox(height: 60.h),
          // Code Indicators
          Row(
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
                  boxShadow: isFilled ? [
                    BoxShadow(
                      color: AppColors.c842D5F.withValues(alpha: 0.4),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ] : null,
                ),
              );
            }),
          ),
          const Spacer(),
          // Keypad
          _NumericKeypad(
            onNumberTap: _onNumberTap,
            onBackspace: _onBackspace,
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
  });

  final Function(int) onNumberTap;
  final VoidCallback onBackspace;

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
            SizedBox(width: 80.w), // Empty space for layout
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
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
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
