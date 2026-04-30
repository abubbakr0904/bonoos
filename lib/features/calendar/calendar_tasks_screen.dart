import 'package:bonoos/core/values/app_colors.dart';
import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:bonoos/features/statistics/statistics_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CalendarTasksScreen extends StatefulWidget {
  const CalendarTasksScreen({super.key});

  @override
  State<CalendarTasksScreen> createState() => _CalendarTasksScreenState();
}

class _CalendarTasksScreenState extends State<CalendarTasksScreen> {
  DateTime _selectedDate = DateTime.now();
  final Map<String, List<String>> _tasksByDay = <String, List<String>>{};

  @override
  Widget build(BuildContext context) {
    final tasks = _tasksByDay[_toApiDay(_selectedDate)] ?? const <String>[];
    return Scaffold(
      backgroundColor: const Color(0xFF140B2A),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTaskSheet,
        backgroundColor: AppColors.c842D5F,
        foregroundColor: Colors.white,
        child: const Icon(CupertinoIcons.add),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Kalendar",
                      style: AppTextStyles.body24w7.copyWith(
                        color: Colors.white.withValues(alpha: 0.95),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const StatisticsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      CupertinoIcons.chart_bar_alt_fill,
                      color: Colors.white,
                    ),
                    tooltip: "Statistika",
                  ),
                ],
              ),
              Text(
                "${tasks.length} ta task",
                style: AppTextStyles.body13w4.copyWith(
                  color: Colors.white.withValues(alpha: 0.68),
                ),
              ),
              SizedBox(height: 12.h),
              _WeekDateSelector(
                selectedDate: _selectedDate,
                onSelect: (date) => setState(() => _selectedDate = date),
              ),
              SizedBox(height: 14.h),
              Expanded(
                child: tasks.isEmpty
                    ? _CalendarEmptyState(onAdd: _openAddTaskSheet)
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        itemCount: tasks.length,
                        separatorBuilder: (_, __) => SizedBox(height: 10.h),
                        itemBuilder: (context, index) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 13.h,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.r),
                              color: Colors.white.withValues(alpha: 0.08),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.12),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  height: 22.w,
                                  width: 22.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.c842D5F.withValues(alpha: 0.18),
                                  ),
                                  child: Icon(
                                    CupertinoIcons.checkmark_alt,
                                    color: AppColors.c842D5F,
                                    size: 14.sp,
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Text(
                                    tasks[index],
                                    style: AppTextStyles.body14w5.copyWith(
                                      color: Colors.white.withValues(alpha: 0.92),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _deleteTask(index),
                                  child: Icon(
                                    CupertinoIcons.delete_simple,
                                    size: 18.sp,
                                    color: Colors.white.withValues(alpha: 0.62),
                                  ),
                                ),
                              ],
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

  Future<void> _openAddTaskSheet() async {
    final controller = TextEditingController();
    final value = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 14.w,
            right: 14.w,
            bottom: MediaQuery.of(context).viewInsets.bottom + 10.h,
          ),
          child: Container(
            padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1032),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Yangi task qo'shish",
                  style: AppTextStyles.body16w6.copyWith(
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ),
                SizedBox(height: 10.h),
                TextField(
                  controller: controller,
                  autofocus: true,
                  style: AppTextStyles.body14w5.copyWith(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Task matni...",
                    hintStyle: AppTextStyles.body14w4.copyWith(
                      color: Colors.white.withValues(alpha: 0.45),
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.06),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: AppColors.c842D5F),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(controller.text.trim()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.c842D5F,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: const Text("Saqlash"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    controller.dispose();
    if (value == null || value.isEmpty) return;
    final key = _toApiDay(_selectedDate);
    setState(() {
      final list = List<String>.from(_tasksByDay[key] ?? const <String>[]);
      list.add(value);
      _tasksByDay[key] = list;
    });
  }

  void _deleteTask(int index) {
    final key = _toApiDay(_selectedDate);
    final list = List<String>.from(_tasksByDay[key] ?? const <String>[]);
    if (index < 0 || index >= list.length) return;
    setState(() {
      list.removeAt(index);
      _tasksByDay[key] = list;
    });
  }

  String _toApiDay(DateTime d) {
    final y = d.year.toString();
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }
}

class _CalendarEmptyState extends StatelessWidget {
  const _CalendarEmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.calendar_badge_plus,
            size: 46.sp,
            color: Colors.white.withValues(alpha: 0.5),
          ),
          SizedBox(height: 10.h),
          Text(
            "Bu kunda task yo'q",
            style: AppTextStyles.body16w6.copyWith(
              color: Colors.white.withValues(alpha: 0.84),
            ),
          ),
          SizedBox(height: 6.h),
          TextButton(
            onPressed: onAdd,
            child: Text(
              "Task qo'shish",
              style: AppTextStyles.body14w6.copyWith(color: AppColors.c842D5F),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekDateSelector extends StatefulWidget {
  const _WeekDateSelector({
    required this.selectedDate,
    required this.onSelect,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelect;

  @override
  State<_WeekDateSelector> createState() => _WeekDateSelectorState();
}

class _WeekDateSelectorState extends State<_WeekDateSelector> {
  static final DateTime _refMonday = DateTime(2024, 1, 1);
  static const int _pageCenter = 5000;

  late final PageController _pageController;
  int _lastPageIndex = _pageCenter;

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime _mondayOf(DateTime d) {
    final n = _dateOnly(d);
    return n.subtract(Duration(days: n.weekday - DateTime.monday));
  }

  static int _pageForMonday(DateTime monday) {
    final days = _dateOnly(monday).difference(_refMonday).inDays;
    return _pageCenter + (days ~/ 7);
  }

  @override
  void initState() {
    super.initState();
    final initial = _pageForMonday(_mondayOf(widget.selectedDate));
    _lastPageIndex = initial;
    _pageController = PageController(initialPage: initial);
  }

  @override
  void didUpdateWidget(covariant _WeekDateSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newPage = _pageForMonday(_mondayOf(widget.selectedDate));
    if (newPage != _lastPageIndex &&
        _mondayOf(oldWidget.selectedDate) != _mondayOf(widget.selectedDate)) {
      _lastPageIndex = newPage;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(newPage);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _mondayForPageIndex(int pageIndex) {
    return _refMonday.add(Duration(days: (pageIndex - _pageCenter) * 7));
  }

  @override
  Widget build(BuildContext context) {
    const week = ['Du', 'Se', 'Cho', 'Pa', 'Ju', 'Sha', 'Ya'];
    const monthNames = [
      'Yanvar',
      'Fevral',
      'Mart',
      'Aprel',
      'May',
      'Iyun',
      'Iyul',
      'Avgust',
      'Sentyabr',
      'Oktyabr',
      'Noyabr',
      'Dekabr',
    ];
    final sel = _dateOnly(widget.selectedDate);
    final monthLabel = "${monthNames[sel.month - 1]} ${sel.year}";

    return Container(
      height: 85.h,
      padding: EdgeInsets.fromLTRB(10.w, 7.h, 10.w, 7.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2E2053).withValues(alpha: 0.94),
            const Color(0xFF1D1337).withValues(alpha: 0.96),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (pageIndex) {
                final delta = pageIndex - _lastPageIndex;
                _lastPageIndex = pageIndex;
                if (delta == 0) return;
                widget.onSelect(sel.add(Duration(days: 7 * delta)));
              },
              itemCount: 10000,
              itemBuilder: (context, pageIndex) {
                final monday = _mondayForPageIndex(pageIndex);
                final days = List<DateTime>.generate(
                  7,
                  (i) => monday.add(Duration(days: i)),
                );
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: List.generate(7, (index) {
                    final day = days[index];
                    final d = _dateOnly(day);
                    final isToday = d == _dateOnly(DateTime.now());
                    final isSelected = d == sel;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3.w),
                        child: GestureDetector(
                          onTap: () => widget.onSelect(d),
                          behavior: HitTestBehavior.opaque,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14.r),
                              gradient: isSelected
                                  ? const LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [AppColors.c842D5F, AppColors.c55004D],
                                    )
                                  : null,
                              color: isSelected
                                  ? null
                                  : Colors.white.withValues(alpha: 0.03),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.3)
                                    : (isToday
                                        ? AppColors.c842D5F.withValues(alpha: 0.45)
                                        : Colors.white.withValues(alpha: 0.10)),
                                width: isSelected ? 1.6 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  week[index],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.body11w5.copyWith(
                                    fontSize: 10.sp,
                                    color: Colors.white.withValues(
                                      alpha: isSelected ? 0.95 : 0.58,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 3.h),
                                Text(
                                  '${d.day}',
                                  maxLines: 1,
                                  style: AppTextStyles.body16w6.copyWith(
                                    fontSize: 14.sp,
                                    color: Colors.white.withValues(
                                      alpha: isSelected ? 0.98 : 0.78,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 220),
                                  height: 4.w,
                                  width: 4.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? Colors.white
                                        : (isToday
                                            ? AppColors.c842D5F
                                            : Colors.transparent),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
