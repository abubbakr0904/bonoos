import 'package:bonoos/core/values/app_colors.dart';
import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:bonoos/features/alarm/add_alarm_screen.dart';
import 'package:bonoos/features/alarm/alarm_models.dart';
import 'package:bonoos/features/alarm/alarm_ring_label.dart';
import 'package:bonoos/features/alarm/alarm_service.dart';
import 'package:bonoos/features/common/widget/home_gradient_background.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen>
    with SingleTickerProviderStateMixin {
  List<AlarmItem> _alarms = [];
  bool _loading = true;
  late final AnimationController _entryController;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..forward();
    _loadAlarms();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  Future<void> _loadAlarms() async {
    final alarms = await AlarmService.loadAlarms();
    if (!mounted) return;
    setState(() {
      _alarms = alarms;
      _loading = false;
    });
  }

  Future<void> _openAddAlarm() async {
    final result = await Navigator.of(context).push<AlarmFormResult>(
      CupertinoPageRoute(builder: (_) => const AddAlarmScreen()),
    );
    if (!mounted || result == null || result.isDeleted || result.draft == null) {
      return;
    }
    final item = await AlarmService.createAlarm(result.draft!);
    if (!mounted) return;
    setState(() {
      _alarms = [..._alarms, item]
        ..sort((a, b) => '${a.hour}:${a.minute}'.compareTo('${b.hour}:${b.minute}'));
    });
    _entryController.forward(from: 0.45);
  }

  Future<void> _openEditAlarm(AlarmItem alarm) async {
    final result = await Navigator.of(context).push<AlarmFormResult>(
      CupertinoPageRoute(builder: (_) => AddAlarmScreen(editing: alarm)),
    );
    if (!mounted || result == null) return;
    if (result.isDeleted) {
      await AlarmService.deleteAlarm(alarm.id);
      await _loadAlarms();
      return;
    }
    if (result.draft != null) {
      await AlarmService.updateAlarm(alarm, result.draft!);
      await _loadAlarms();
    }
  }

  Future<void> _toggleAlarm(int index, bool enabled) async {
    final item = _alarms[index];
    final next = item.copyWith(enabled: enabled);
    setState(() => _alarms[index] = next);
    await AlarmService.toggleAlarm(item, enabled);
    if (!mounted) return;
    await _loadAlarms();
  }

  Animation<double> _fadeAnim(double begin, double end) {
    return CurvedAnimation(
      parent: _entryController,
      curve: Interval(begin, end, curve: Curves.easeOutCubic),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF140B2A),
      body: Stack(
        children: [
          const HomeGradientBackground(),
          SafeArea(
            child: Column(
              children: [
                FadeTransition(
                  opacity: _fadeAnim(0.0, 0.45),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -0.08),
                      end: Offset.zero,
                    ).animate(_fadeAnim(0.0, 0.45)),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 8.h),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 42.w,
                            height: 42.w,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12.r),
                                onTap: () => Navigator.of(context).maybePop(),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.r),
                                    color: Colors.white.withValues(alpha: 0.08),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.12),
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      CupertinoIcons.back,
                                      size: 20.sp,
                                      color: Colors.white.withValues(alpha: 0.92),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              "Budilnik",
                              style: AppTextStyles.body22w7.copyWith(
                                color: Colors.white.withValues(alpha: 0.95),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 42.w,
                            height: 42.w,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12.r),
                                onTap: _openAddAlarm,
                                child: Ink(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.r),
                                    color: Colors.white.withValues(alpha: 0.08),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.12),
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      CupertinoIcons.add,
                                      size: 20.sp,
                                      color: Colors.white.withValues(alpha: 0.92),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                FadeTransition(
                  opacity: _fadeAnim(0.18, 0.55),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Kun tartibingiz uchun eslatmalar",
                        style: AppTextStyles.body13w4.copyWith(
                          color: Colors.white.withValues(alpha: 0.66),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _alarms.isEmpty
                          ? const _AlarmEmptyState()
                          : ListView.separated(
                              physics: const BouncingScrollPhysics(),
                              padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 4.h),
                              itemCount: _alarms.length,
                              separatorBuilder: (_, __) => SizedBox(height: 10.h),
                              itemBuilder: (context, index) {
                                final alarm = _alarms[index];
                                final start = (0.24 + index * 0.08).clamp(0.0, 0.92);
                                final end = (start + 0.28).clamp(0.15, 1.0);
                                final interval = CurvedAnimation(
                                  parent: _entryController,
                                  curve: Interval(start, end, curve: Curves.easeOutCubic),
                                );
                                return FadeTransition(
                                  opacity: interval,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0, 0.16),
                                      end: Offset.zero,
                                    ).animate(interval),
                                    child: _AlarmTile(
                                      item: alarm,
                                      onChanged: (next) => _toggleAlarm(index, next),
                                      onTapEdit: () => _openEditAlarm(alarm),
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AlarmTile extends StatelessWidget {
  const _AlarmTile({
    required this.item,
    required this.onChanged,
    required this.onTapEdit,
  });

  final AlarmItem item;
  final ValueChanged<bool> onChanged;
  final VoidCallback onTapEdit;

  @override
  Widget build(BuildContext context) {
    final textColor = item.enabled
        ? Colors.white.withValues(alpha: 0.92)
        : Colors.white.withValues(alpha: 0.60);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(18.r),
                ),
                onTap: onTapEdit,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(14.w, 12.h, 8.w, 12.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.time,
                        style: AppTextStyles.body45w9.copyWith(
                          letterSpacing: -1.2,
                          height: 1.0,
                          color: textColor,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        item.voiceLabel,
                        style: AppTextStyles.body14w4.copyWith(
                          color: Colors.white.withValues(alpha: 0.62),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        alarmRingCountdownLabel(item),
                        style: AppTextStyles.body11w4.copyWith(
                          color: Colors.white.withValues(alpha: 0.48),
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 10.w),
            child: Transform.scale(
              scale: 0.95,
              child: CupertinoSwitch(
                value: item.enabled,
                activeTrackColor: AppColors.c842D5F,
                inactiveTrackColor: Colors.white.withValues(alpha: 0.24),
                thumbColor: Colors.white,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlarmEmptyState extends StatelessWidget {
  const _AlarmEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.alarm,
              size: 56.sp,
              color: Colors.white.withValues(alpha: 0.65),
            ),
            SizedBox(height: 12.h),
            Text(
              "Budilniklar yo'q",
              style: AppTextStyles.body18w6.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              "Yuqoridagi + tugmasi orqali birinchi budilnikni qo'shing",
              textAlign: TextAlign.center,
              style: AppTextStyles.body13w4.copyWith(
                color: Colors.white.withValues(alpha: 0.62),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
