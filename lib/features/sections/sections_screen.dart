import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:bonoos/features/alarm/alarm_screen.dart';
import 'package:bonoos/features/breath/breathing_practices_screen.dart';
import 'package:bonoos/features/home/message_of_day_screen.dart';
import 'package:bonoos/features/playlist/playlist_screen.dart';
import 'package:bonoos/features/sections/faq_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class SectionsScreen extends StatefulWidget {
  const SectionsScreen({super.key});

  static const String routeName = "/sections";

  @override
  State<SectionsScreen> createState() => _SectionsScreenState();
}

class _SectionsScreenState extends State<SectionsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entryController;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = <_SectionItem>[
      _SectionItem(
        title: "Meditatsiya",
        subtitle: "Mavjud meditatsiya ro'yxati",
        icon: CupertinoIcons.sparkles,
        onTap: () => context.push(BreathingPracticesScreen.routeName),
      ),
      _SectionItem(
        title: "Budilnik",
        subtitle: "Eslatmalar va vaqt nazorati",
        icon: CupertinoIcons.alarm_fill,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AlarmScreen()),
        ),
      ),
      _SectionItem(
        title: "Kun sovg'asi",
        subtitle: "Har kunlik maxsus kontent",
        icon: CupertinoIcons.gift_fill,
        onTap: () => context.push(MessageOfDayScreen.routeName),
      ),
      _SectionItem(
        title: "Playlist",
        subtitle: "Audiolar ro'yxati",
        icon: CupertinoIcons.play_rectangle_fill,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PlaylistScreen()),
        ),
      ),
      _SectionItem(
        title: "Sevimlilar",
        subtitle: "Tanlangan amaliyotlar",
        icon: CupertinoIcons.heart_fill,
        onTap: () => context.push(
          BreathingPracticesScreen.routeName,
          extra: true,
        ),
      ),
      _SectionItem(
        title: "Ko'p so'raladigan savollar",
        subtitle: "FAQ — tez-tez beriladigan savollar",
        icon: CupertinoIcons.question_circle_fill,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const FaqScreen()),
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF140B2A),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Bo'limlar",
                style: AppTextStyles.body22w7.copyWith(
                  color: Colors.white.withValues(alpha: 0.95),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                "Sizga mos yo'nalishni tanlang",
                style: AppTextStyles.body13w4.copyWith(
                  color: Colors.white.withValues(alpha: 0.68),
                ),
              ),
              SizedBox(height: 14.h),
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 6.w,
                    mainAxisSpacing: 6.h,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final start = (0.10 + index * 0.10).clamp(0.0, 0.9);
                    final end = (start + 0.30).clamp(0.2, 1.0);
                    final anim = CurvedAnimation(
                      parent: _entryController,
                      curve: Interval(start, end, curve: Curves.easeOutCubic),
                    );
                    return FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.12),
                          end: Offset.zero,
                        ).animate(anim),
                        child: _SectionCard(item: items[index]),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionItem {
  const _SectionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.item});

  final _SectionItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.all(9.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.r),
          color: Colors.white.withValues(alpha: 0.06),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12842D5F),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -6.w,
              top: -4.h,
              child: Icon(
                item.icon,
                size: 82.sp,
                color: const Color(0xFF842D5F).withValues(alpha: 0.26),
              ),
            ),
            // Positioned(
            //   right: 8.w,
            //   top: 8.h,
            //   child: Container(
            //     height: 30.w,
            //     width: 30.w,
            //     decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(10.r),
            //       color: Colors.white.withValues(alpha: 0.10),
            //       border:
            //           Border.all(color: Colors.white.withValues(alpha: 0.12)),
            //     ),
            //     child: Icon(
            //       item.icon,
            //       color: Colors.white.withValues(alpha: 0.88),
            //       size: 16.sp,
            //     ),
            //   ),
            // ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Text(
                  item.title,
                  style: AppTextStyles.body14w6.copyWith(
                    color: Colors.white.withValues(alpha: 0.96),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  item.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body10w4.copyWith(
                    color: Colors.white.withValues(alpha: 0.70),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
