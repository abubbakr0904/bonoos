import 'package:bonoos/core/values/app_colors.dart';
import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AudioListTile extends StatelessWidget {
  const AudioListTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.duration,
    required this.colors,
    required this.onTap,
    this.onMoreTap,
    this.isFavorite = false,
    this.onFavoriteTap,
    this.locked = false,
  });


  final String title;
  final String subtitle;
  final String tag;
  final String duration;
  final List<Color> colors;
  final VoidCallback onTap;
  final VoidCallback? onMoreTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;

  /// Pullik to‘plamdan, hali ochilmagan audio — play o‘rniga qulf.
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.r),
          color: Colors.white.withValues(alpha: 0.06),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Row(
          children: [
            Container(
              height: 40.w,
              width: 40.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100.r),
             color : Colors.white.withValues(alpha: 0.2)
              ),
              child: Icon(
                locked ? CupertinoIcons.lock_fill : CupertinoIcons.play_fill,
                color: Colors.white.withValues(alpha: locked ? 0.85 : 1),
                size: locked ? 18 : 20,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body16w6.copyWith(
                      color: Colors.white.withValues(alpha: locked ? 0.70 : 0.92),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body12w4.copyWith(
                      color: Colors.white.withValues(alpha: 0.70),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            if (onFavoriteTap != null && !locked)
              GestureDetector(
                onTap: onFavoriteTap,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Icon(
                    isFavorite
                        ? CupertinoIcons.heart_fill
                        : CupertinoIcons.heart,
                    size: 22,
                    color: isFavorite
                        ? const Color(0xFFFF8A9B)
                        : Colors.white.withValues(alpha: 0.45),
                  ),
                ),
              ),
            if (onMoreTap != null)
              GestureDetector(
                onTap: onMoreTap,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.only(left: 8.w),
                  child: Icon(
                    CupertinoIcons.info_circle,
                    size: 20,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
