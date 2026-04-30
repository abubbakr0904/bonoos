import 'package:bonoos/features/calendar/calendar_tasks_screen.dart';
import 'package:bonoos/features/gratitude/gratitude_notes_screen.dart';
import 'package:bonoos/core/values/app_colors.dart';
import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:bonoos/features/home/home_screen.dart';
import 'package:bonoos/features/sections/sections_screen.dart';
import 'package:bonoos/features/subscription/subscription_screen.dart';
import 'package:bonoos/features/tabbox/tabbox_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TabBoxScreen extends StatefulWidget {
  const TabBoxScreen({super.key});

  static const String routeName = "/tabbox";

  @override
  State<TabBoxScreen> createState() => _TabBoxScreenState();
}

class _TabBoxScreenState extends State<TabBoxScreen> {
  int _index = 0;
  int _gratitudeViewVersion = 0;
  final _controller = TabBoxController.instance;

  @override
  void initState() {
    super.initState();
    _index = _controller.index.value;
    _controller.index.addListener(_onIndexChanged);
  }

  @override
  void dispose() {
    _controller.index.removeListener(_onIndexChanged);
    super.dispose();
  }

  void _onIndexChanged() {
    if (!mounted) return;
    setState(() => _index = _controller.index.value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        _index == 0 || _index == 1 || _index == 2 || _index == 3 || _index == 4;
    final items = <_TabItem>[
      const _TabItem(label: "Home", icon: CupertinoIcons.house),
      const _TabItem(label: "Calendar", icon: CupertinoIcons.calendar_today),
      const _TabItem(label: "Shukrona", icon: CupertinoIcons.heart_fill),
      const _TabItem(label: "Abonement", icon: CupertinoIcons.tickets),
      const _TabItem(label: "Bo'limlar", icon: CupertinoIcons.square_grid_2x2),
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF140B2A) : AppColors.white,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final slide = Tween<Offset>(
            begin: const Offset(0.02, 0),
            end: Offset.zero,
          ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
          return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: slide, child: child));
        },
        child: _buildBody(items, _index),
      ),
      bottomNavigationBar: _BonoosBottomNav(
        items: items,
        index: _index,
        isDark: isDark,
        onChanged: (i) {
          if (i == 2) {
            _gratitudeViewVersion++;
          }
          _controller.setIndex(i);
          setState(() => _index = i);
        },
      ),
    );
  }

  Widget _buildBody(List<_TabItem> items, int index) {
    switch (index) {
      case 0:
        return const HomeScreen(key: ValueKey("home"));
      case 1:
        return const CalendarTasksScreen(key: ValueKey("calendar_tasks"));
      case 2:
        return GratitudeNotesScreen(
          key: ValueKey("gratitude_$_gratitudeViewVersion"),
        );
      case 3:
        return const SubscriptionScreen(key: ValueKey("subscription"));
      case 4:
        return const SectionsScreen(key: ValueKey("sections"));
      default:
        return _PlaceholderTab(
          key: ValueKey(index),
          title: items[index].label,
        );
    }
  }
}

class _TabItem {
  final String label;
  final IconData icon;
  const _TabItem({required this.label, required this.icon});
}

class _BonoosBottomNav extends StatelessWidget {
  const _BonoosBottomNav({
    required this.items,
    required this.index,
    required this.isDark,
    required this.onChanged,
  });

  final List<_TabItem> items;
  final int index;
  final bool isDark;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final height = 70.h;
    return SafeArea(
      top: false,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF140B2A) : AppColors.white,
          border: Border(
            top: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : AppColors.transparent,
              width: 1,
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: 10.w, right: 10.w, bottom: 2.h),
          child: Row(
            children: [
              for (int i = 0; i < items.length; i++)
                Expanded(
                  child: _NavItem(
                    item: items[i],
                    selected: i == index,
                    isDark: isDark,
                    onTap: () => onChanged(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.item,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  final _TabItem item;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor = AppColors.c842D5F;
    final inactiveColor =
        isDark ? Colors.white.withValues(alpha: 0.62) : AppColors.grey600;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              height: 40.w,
              width: 40.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? (isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : activeColor.withValues(alpha: 0.14))
                    : AppColors.transparent,
              ),
              child: Center(
                child: Icon(
                  item.icon,
                  size: 22.sp,
                  color: selected ? activeColor : inactiveColor,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body10w6.copyWith(
                color: selected ? activeColor : inactiveColor,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Text(
          title,
          style:
              AppTextStyles.body22w7.copyWith(color: AppColors.textColorBlack),
        ),
      ),
    );
  }
}
