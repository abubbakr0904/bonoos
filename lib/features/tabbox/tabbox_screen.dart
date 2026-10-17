import 'dart:ui';
import 'package:bonoos/features/calendar/calendar_tasks_screen.dart';
import 'package:bonoos/features/gratitude/gratitude_note_editor_screen.dart';
import 'package:bonoos/core/utils/external_payments.dart';
import 'package:bonoos/core/values/app_colors.dart';
import 'package:bonoos/features/home/home_screen.dart';
import 'package:bonoos/features/sections/sections_screen.dart';
import 'package:bonoos/features/playlist/collections_screen.dart';
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

  static const _tabMeta = {
    AppTab.home: _TabItem(label: "Home", icon: CupertinoIcons.house_fill),
    AppTab.calendar: _TabItem(label: "Calendar", icon: CupertinoIcons.calendar),
    AppTab.gratitude: _TabItem(label: "Shukrona", icon: CupertinoIcons.heart_fill),
    AppTab.subscription: _TabItem(label: "To'plamlar", icon: CupertinoIcons.square_stack_3d_up_fill),
    AppTab.sections: _TabItem(label: "Bo'limlar", icon: CupertinoIcons.square_grid_2x2_fill),
  };

  List<_TabItem> get _visibleTabItems =>
      TabBoxController.visibleTabs.map((tab) => _tabMeta[tab]!).toList();

  @override
  void initState() {
    super.initState();
    _index = _controller.index.value.clamp(0, _visibleTabItems.length - 1);
    if (_index != _controller.index.value) {
      _controller.index.value = _index;
    }
    _controller.index.addListener(_onIndexChanged);
    PaymentVisibility.isTestUser.addListener(_onPaymentVisibilityChanged);
  }

  @override
  void dispose() {
    _controller.index.removeListener(_onIndexChanged);
    PaymentVisibility.isTestUser.removeListener(_onPaymentVisibilityChanged);
    super.dispose();
  }

  /// Test foydalanuvchi aniqlansa «To‘plamlar» tabi yo‘qoladi — Home ga qaytamiz.
  void _onPaymentVisibilityChanged() {
    if (!mounted) return;
    _controller.index.value = 0;
    setState(() => _index = 0);
  }

  void _onIndexChanged() {
    if (!mounted) return;
    final next = _controller.index.value.clamp(0, _visibleTabItems.length - 1);
    if (next != _controller.index.value) {
      _controller.index.value = next;
    }
    setState(() => _index = next);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.mainBgColor,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeInOutCubic,
        switchOutCurve: Curves.easeInOutCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: _buildBody(TabBoxController.tabAt(_index)),
      ),
      bottomNavigationBar: _LiquidGlassBottomNav(
        items: _visibleTabItems,
        currentIndex: _index,
        onTap: (i) {
          final tab = TabBoxController.tabAt(i);
          if (tab == AppTab.gratitude) {
            _gratitudeViewVersion++;
          }
          _controller.setIndex(i);
          setState(() => _index = i);
        },
      ),
    );
  }

  Widget _buildBody(AppTab tab) {
    switch (tab) {
      case AppTab.home:
        return const HomeScreen(key: ValueKey("home"));
      case AppTab.calendar:
        return const CalendarTasksScreen(key: ValueKey("calendar_tasks"));
      case AppTab.gratitude:
        return const GratitudeNoteEditorScreen(
          key: ValueKey("gratitude_editor"),
        );
      case AppTab.subscription:
        // Obuna to'xtatilgan — kontent faqat to'plam (kategoriya) sotib olish orqali ochiladi.
        return const CollectionsScreen(key: ValueKey("collections"));
      case AppTab.sections:
        return const SectionsScreen(key: ValueKey("sections"));
    }
  }
}

class _TabItem {
  final String label;
  final IconData icon;
  const _TabItem({required this.label, required this.icon});
}

class _LiquidGlassBottomNav extends StatelessWidget {
  const _LiquidGlassBottomNav({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<_TabItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 36.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 60.h,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(36.r),
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Row(
                children: List.generate(items.length, (index) {
                  final isSelected = index == currentIndex;
                  final item = items[index];

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onTap(index),
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: AnimatedContainer(
                          width: 100.w,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white.withOpacity(0.5) : Colors.transparent,
                            borderRadius: BorderRadius.circular(24.r),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                item.icon,
                                color: isSelected ? AppColors.mainBgColor : Colors.white.withOpacity(0.6),
                                size: 18.sp,
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                item.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isSelected ? AppColors.mainBgColor : Colors.white.withOpacity(0.6),
                                  fontSize: 9.sp,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
