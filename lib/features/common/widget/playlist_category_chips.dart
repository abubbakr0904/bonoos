import 'package:bonoos/core/values/app_colors.dart';
import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:bonoos/features/playlist/domain/entity/category.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class PlaylistCategoryChipRow extends StatelessWidget {
  const PlaylistCategoryChipRow({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
    this.showAllChip = false,
    this.allLabel = 'Hammasi',
  });

  final List<Category> categories;
  /// `-1` — [showAllChip] yoqilganida "Hammasi"; `0..` — category indeksi.
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool showAllChip;
  final String allLabel;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty && !showAllChip) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          if (showAllChip) ...[
            Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: GestureDetector(
                onTap: () => onSelected(-1),
                child: PlaylistCategoryChip(
                  label: allLabel,
                  selected: selectedIndex == -1,
                ),
              ),
            ),
          ],
          ...List.generate(categories.length, (index) {
            final cat = categories[index];
            final selected = index == selectedIndex;
            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: GestureDetector(
                onTap: () => onSelected(index),
                child: PlaylistCategoryChip(
                  label: cat.name,
                  selected: selected,
                  locked: cat.isLocked,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class PlaylistCategoryChip extends StatelessWidget {
  const PlaylistCategoryChip({
    super.key,
    required this.label,
    this.selected = false,
    this.locked = false,
  });

  final String label;
  final bool selected;

  /// Pullik va hali sotib olinmagan to‘plam — kichik qulf belgisi.
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final textColor = selected
        ? Colors.white.withValues(alpha: 0.92)
        : Colors.white.withValues(alpha: 0.70);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: selected
            ? Colors.white.withValues(alpha: 0.14)
            : Colors.white.withValues(alpha: 0.06),
        border: Border.all(
          color: selected
              ? Colors.white.withValues(alpha: 0.14)
              : Colors.white.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (locked) ...[
            Icon(CupertinoIcons.lock_fill, size: 11.sp, color: textColor),
            SizedBox(width: 5.w),
          ],
          Text(
            label,
            style: AppTextStyles.body12w5.copyWith(
              color: textColor,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class PlaylistCategoriesShimmer extends StatelessWidget {
  const PlaylistCategoriesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withValues(alpha: 0.06),
      highlightColor: Colors.white.withValues(alpha: 0.12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(
          children: List.generate(5, (i) {
            final widths = [80.0, 110.0, 95.0, 100.0, 70.0];
            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: Container(
                width: widths[i].w,
                height: 34.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: Colors.white,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class PlaylistCategoriesError extends StatelessWidget {
  const PlaylistCategoriesError({
    super.key,
    required this.error,
    required this.onRetry,
  });

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          CupertinoIcons.exclamationmark_triangle,
          size: 32.sp,
          color: Colors.white.withValues(alpha: 0.5),
        ),
        SizedBox(height: 10.h),
        Text(
          error,
          textAlign: TextAlign.center,
          style: AppTextStyles.body14w5.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        SizedBox(height: 14.h),
        TextButton(
          onPressed: onRetry,
          child: Text(
            'Qayta urinish',
            style: AppTextStyles.body14w6.copyWith(color: AppColors.c842D5F),
          ),
        ),
      ],
    );
  }
}

class PlaylistAuditionsShimmer extends StatelessWidget {
  const PlaylistAuditionsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withValues(alpha: 0.06),
      highlightColor: Colors.white.withValues(alpha: 0.12),
      child: Column(
        children: List.generate(4, (i) {
          return Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Container(
              height: 72.h,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18.r),
                color: Colors.white,
              ),
            ),
          );
        }),
      ),
    );
  }
}
