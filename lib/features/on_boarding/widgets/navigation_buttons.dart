import 'package:bonoos/core/resources/assets/images/app_images.dart';
import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/values/app_colors.dart';

class NavigationButtons extends StatelessWidget {
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool showPrevious;
  final bool showNext;
  final bool isLastPage;

  const NavigationButtons({
    super.key,
    required this.onPrevious,
    required this.onNext,
    this.showPrevious = true,
    this.showNext = true,
    this.isLastPage = false,
  });

  static const _gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.c842D5F, AppColors.c55004D],
  );

  @override
  Widget build(BuildContext context) {
    if (isLastPage) {
      return Padding(
        padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 24.h),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onNext,
            borderRadius: BorderRadius.circular(999),
            child: Ink(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.c842D5F.withValues(alpha: 0.92),
                    AppColors.c55004D.withValues(alpha: 0.92),
                  ],
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x28842D5F),
                    blurRadius: 24,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Boshlash',
                  style: AppTextStyles.body16w7.copyWith(color: AppColors.white),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildButton(
            onPressed: showPrevious ? onPrevious : null,
            icon: AppImages.arrowBackIcon,
            visible: showPrevious,
          ),
          _buildButton(
            onPressed: showNext ? onNext : null,
            icon: AppImages.arrowRight,
            visible: showNext,
            isPrimary: true,
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required VoidCallback? onPressed,
    required String icon,
    required bool visible,
    bool isPrimary = false,
  }) {
    if (!visible) {
      return SizedBox(width: 60.w);
    }

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 56.h,
        width: 66.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isPrimary ? _gradient : null,
          color: isPrimary ? null : Colors.white.withValues(alpha: 0.10),
          border: Border.all(
            color: isPrimary ? Colors.transparent : Colors.white.withValues(alpha: 0.14),
          ),
          boxShadow: isPrimary
              ? const [
                  BoxShadow(
                    color: Color(0x2A842D5F),
                    blurRadius: 18,
                    offset: Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: SvgPicture.asset(
            icon,
            colorFilter: ColorFilter.mode(
              isPrimary ? AppColors.white : Colors.white.withValues(alpha: 0.85),
              BlendMode.srcIn,
            ),
            width: 20.w,
          ),
        ),
      ),
    );
  }
}
