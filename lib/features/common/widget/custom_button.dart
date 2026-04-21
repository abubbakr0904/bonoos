import 'package:bonoos/core/extension/widget_extension.dart';
import 'package:bonoos/core/values/app_colors.dart';
import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.text = "",
    required this.onTap,
    this.radius,
    this.bgColor,
    this.textColor,
    this.disabledBgColor,
    this.disabledTextColor,
    this.isLoading = false,
    this.paddingV,
    this.fontSize,
    this.colorL,
    this.icon,
    this.rightW,
    this.borderColor,
    this.fontW,
    this.iconC,
    this.leftW,
    this.height,
    this.padding = const EdgeInsets.symmetric(vertical: 16),
    this.isEnabled=true,
  });

  final String text;
  final Function() onTap;
  final BorderRadius? radius;
  final double? paddingV;
  final double? fontSize;
  final FontWeight? fontW;
  final EdgeInsets padding;
  final bool isEnabled;
  final Color? colorL;
  final String? icon;
  final Color? bgColor;
  final Color? iconC;

  final Color? borderColor;
  final Color? textColor;
  final Color? disabledBgColor;
  final Color? disabledTextColor;
  final bool isLoading;
  final double? height;
  final Widget? rightW, leftW;

  @override
  Widget build(BuildContext context) {
    final resolvedBgColor = isEnabled ? (bgColor ?? AppColors.primaryGreen) : (disabledBgColor ?? AppColors.grey200);
    final resolvedTextColor = isEnabled ? (textColor ?? AppColors.white) : (disabledTextColor ?? AppColors.grey808080);

    return Material(
      color: AppColors.transparent,
      borderRadius: radius ?? BorderRadius.circular(8),
      child: InkWell(
        borderRadius: radius ?? BorderRadius.circular(8),
        onTap: isEnabled&&!isLoading?onTap:null,
        child: Ink(
          padding: padding,
          height: height,
          decoration: BoxDecoration(
            borderRadius: radius ?? BorderRadius.circular(8),
            border: borderColor != null ? Border.all(color: borderColor ?? AppColors.transparent) : null,
            color: resolvedBgColor,
          ),
          child: Center(
            child: FittedBox(
              child: isLoading
                  ? const CupertinoActivityIndicator(color: AppColors.white)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          text,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: AppTextStyles.body16w5.copyWith(
                            color: resolvedTextColor,
                            height: 1,
                            fontSize: fontSize ?? 16,
                            letterSpacing: 0,
                            fontWeight: fontW,
                          ),
                        ),
                      ],
                    ).paddingSymmetric(horizontal: 8),
            ),
          ),
        ),
      ),
    );
  }
}
