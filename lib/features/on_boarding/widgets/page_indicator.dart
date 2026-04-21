import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/values/app_colors.dart';

class PageIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const PageIndicator({
    super.key,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          height: 8.h,
          width: currentPage == index ? 24.w : 8.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: currentPage == index
                ? const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [AppColors.c842D5F, AppColors.c55004D],
                  )
                : null,
            color: currentPage == index ? null : Colors.white.withValues(alpha: 0.22),
            boxShadow: currentPage == index
                ? const [
                    BoxShadow(
                      color: Color(0x40842D5F),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }
}
