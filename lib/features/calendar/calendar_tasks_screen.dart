import 'package:bonoos/core/values/app_colors.dart';
import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:bonoos/di.dart';
import 'package:bonoos/features/calendar/add_event_screen.dart';
import 'package:bonoos/features/calendar/domain/entity/calendar_event.dart';
import 'package:bonoos/features/calendar/domain/repository/calendar_repository.dart';
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
  final CalendarRepository _repository = inject<CalendarRepository>();
  DateTime _selectedDate = DateTime.now();
  List<CalendarEvent> _events = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final day = _toApiDay(_selectedDate);
    final result = await _repository.fetchEventsByDay(day);

    result.fold(
      (failure) {
        setState(() {
          _error = failure.message ?? 'Xatolik yuz berdi';
          _isLoading = false;
        });
      },
      (events) {
        setState(() {
          _events = events;
          _isLoading = false;
        });
      },
    );
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _loadEvents();
  }

  Future<void> _openAddEventScreen() async {
    final result = await Navigator.of(context).push<CalendarEvent>(
      MaterialPageRoute(
        builder: (_) => AddEventScreen(selectedDate: _selectedDate),
      ),
    );

    if (result != null) {
      _loadEvents();
    }
  }

  String _toApiDay(DateTime d) {
    final y = d.year.toString();
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBgColor,

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
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
                    // IconButton(
                    //   onPressed: () {
                    //     Navigator.of(context).push(
                    //       MaterialPageRoute(
                    //         builder: (_) => const StatisticsScreen(),
                    //       ),
                    //     );
                    //   },
                    //   icon: const Icon(
                    //     CupertinoIcons.chart_bar_alt_fill,
                    //     color: Colors.white,
                    //   ),
                    //   tooltip: "Statistika",
                    // ),
                  ],
                ),
                Text(
                  "${_events.length} ta elsatma",
                  style: AppTextStyles.body13w4.copyWith(
                    color: Colors.white.withValues(alpha: 0.68),
                  ),
                ),
                SizedBox(height: 12.h),
                _TableCalendar(
                  selectedDate: _selectedDate,
                  onSelect: _onDateSelected,
                  events: _events,
                ),
                SizedBox(height: 16.h),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.2),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: _buildBody(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        key: ValueKey('loading'),
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_error != null) {
      return _CalendarErrorState(
        key: ValueKey('error'),
        message: _error!,
        onRetry: _loadEvents,
        onAdd: _openAddEventScreen,
      );
    }

    if (_events.isEmpty) {
      return _CalendarEmptyState(
        key: ValueKey('empty'),
        onAdd: _openAddEventScreen,
      );
    }

    return Column(
      key: ValueKey('events_${_selectedDate.day}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _events.map((event) {
        return Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: _EventCard(
            event: event,
            onEdit: () => _editEvent(event),
            onDelete: () => _deleteEvent(event),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _editEvent(CalendarEvent event) async {
    final result = await Navigator.of(context).push<CalendarEvent>(
      MaterialPageRoute(
        builder: (_) => AddEventScreen(
          selectedDate: _selectedDate,
          eventToEdit: event,
        ),
      ),
    );

    if (result != null) {
      _loadEvents();
    }
  }

  Future<void> _deleteEvent(CalendarEvent event) async {
    final confirmed = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(
            opacity: anim1.value,
            child: Center(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 40.w),
                padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 20.h),
                decoration: BoxDecoration(
                  color: AppColors.mainBgColor,
                  borderRadius: BorderRadius.circular(24.r),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.12)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 54.w,
                        width: 54.w,
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          CupertinoIcons.trash_fill,
                          color: Colors.redAccent,
                          size: 26.sp,
                        ),
                      ),
                      SizedBox(height: 18.h),
                      Text(
                        'Taskni o\'chirish',
                        style: AppTextStyles.body18w6
                            .copyWith(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'Rostdan ham bu elsatmani o\'chirmoqchimisiz?',
                        style: AppTextStyles.body14w4.copyWith(
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24.h),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).pop(false),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(14.r),
                                ),
                                child: Text(
                                  'Bekor',
                                  style: AppTextStyles.body14w6.copyWith(
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).pop(true),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(14.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.redAccent
                                          .withValues(alpha: 0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  'O\'chirish',
                                  style: AppTextStyles.body14w6
                                      .copyWith(color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    final result = await _repository.deleteEvent(event.id);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message ?? 'O\'chirishda xatolik'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      },
      (_) {
        _loadEvents();
      },
    );
  }
}

class _CalendarEmptyState extends StatelessWidget {
  const _CalendarEmptyState({super.key, required this.onAdd});

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
            "Bu kunda elsatma yo'q",
            style: AppTextStyles.body16w6.copyWith(
              color: Colors.white.withValues(alpha: 0.84),
            ),
          ),
          SizedBox(height: 6.h),
          TextButton(
            onPressed: onAdd,
            child: Text(
              "Eslatma qo'shish",
              style: AppTextStyles.body14w6.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarErrorState extends StatelessWidget {
  const _CalendarErrorState({
    super.key,
    required this.message,
    required this.onRetry,
    required this.onAdd,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.exclamationmark_circle,
            size: 46.sp,
            color: Colors.red.withValues(alpha: 0.7),
          ),
          SizedBox(height: 10.h),
          Text(
            message,
            style: AppTextStyles.body14w5.copyWith(
              color: Colors.white.withValues(alpha: 0.84),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Qayta yuklash'),
              ),
              SizedBox(width: 10.w),
              TextButton(
                onPressed: onAdd,
                child: Text(
                  "Task qo'shish",
                  style:
                      AppTextStyles.body14w6.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.event,
    required this.onEdit,
    required this.onDelete,
  });

  final CalendarEvent event;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  event.title,
                  style: AppTextStyles.body14w5.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: onEdit,
                    child: Icon(
                      CupertinoIcons.pencil,
                      size: 18.sp,
                      color: Colors.white.withValues(alpha: 0.62),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  GestureDetector(
                    onTap: onDelete,
                    child: Icon(
                      CupertinoIcons.delete_simple,
                      size: 18.sp,
                      color: Colors.white.withValues(alpha: 0.62),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (event.eventTime != null && event.eventTime!.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(
                  CupertinoIcons.clock,
                  size: 14.sp,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                SizedBox(width: 6.w),
                Text(
                  event.eventTime!,
                  style: AppTextStyles.body12w4.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
          if (event.note != null && event.note!.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Text(
              event.note!,
              style: AppTextStyles.body12w4.copyWith(
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TableCalendar extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelect;
  final List<CalendarEvent> events;

  const _TableCalendar({
    required this.selectedDate,
    required this.onSelect,
    required this.events,
  });

  @override
  State<_TableCalendar> createState() => _TableCalendarState();
}

class _TableCalendarState extends State<_TableCalendar> {
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    _displayedMonth =
        DateTime(widget.selectedDate.year, widget.selectedDate.month);
  }

  @override
  void didUpdateWidget(_TableCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate.month != widget.selectedDate.month ||
        oldWidget.selectedDate.year != widget.selectedDate.year) {
      _displayedMonth =
          DateTime(widget.selectedDate.year, widget.selectedDate.month);
    }
  }

  void _previousMonth() {
    setState(() {
      _displayedMonth =
          DateTime(_displayedMonth.year, _displayedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth =
          DateTime(_displayedMonth.year, _displayedMonth.month + 1);
    });
  }

  List<DateTime?> _getDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final daysInMonth = lastDay.day;
    final firstWeekday = firstDay.weekday;

    final days = <DateTime?>[];

    for (var i = 1; i < firstWeekday; i++) {
      days.add(null);
    }

    for (var i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(month.year, month.month, i));
    }

    return days;
  }

  @override
  Widget build(BuildContext context) {
    final days = _getDaysInMonth(_displayedMonth);
    final monthNames = [
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
      'Dekabr'
    ];
    final weekDays = ['Du', 'Se', 'Cho', 'Pa', 'Ju', 'Sha', 'Ya'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with month navigation
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _previousMonth,
                  icon: Icon(
                    CupertinoIcons.chevron_left,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                Text(
                  '${monthNames[_displayedMonth.month - 1]} ${_displayedMonth.year}',
                  style: AppTextStyles.body16w6.copyWith(color: Colors.white),
                ),
                IconButton(
                  onPressed: _nextMonth,
                  icon: Icon(
                    CupertinoIcons.chevron_right,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          Divider(
            color: Colors.white.withValues(alpha: 0.08),
            height: 1,
          ),

          // Week day headers
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: weekDays.map((day) {
                return Expanded(
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body12w5.copyWith(
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Calendar grid
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 16.h),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 7,
              mainAxisSpacing: 6.h,
              crossAxisSpacing: 0,
              childAspectRatio: 1,
              children: days.map((date) {
                if (date == null) {
                  return const SizedBox.shrink();
                }

                final isSelected = date.year == widget.selectedDate.year &&
                    date.month == widget.selectedDate.month &&
                    date.day == widget.selectedDate.day;
                final isToday = date.year == DateTime.now().year &&
                    date.month == DateTime.now().month &&
                    date.day == DateTime.now().day;
                final hasEvents = widget.events.any((e) {
                  final eventDate = DateTime.tryParse(e.eventDate);
                  if (eventDate == null) return false;
                  return eventDate.year == date.year &&
                      eventDate.month == date.month &&
                      eventDate.day == date.day;
                });

                return GestureDetector(
                  onTap: () => widget.onSelect(date),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? Colors.white
                          : isToday
                              ? Colors.white.withValues(alpha: 0.25)
                              : Colors.transparent,
                      border: isToday && !isSelected
                          ? Border.all(
                              color: Colors.white.withValues(alpha: 0.6),
                              width: 1.5,
                            )
                          : null,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Center(
                          child: Text(
                            '${date.day}',
                            style: AppTextStyles.body14w5.copyWith(
                              color: isSelected
                                  ? AppColors.mainBgColor
                                  : Colors.white,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (hasEvents && !isSelected)
                          Positioned(
                            bottom: 4.h,
                            child: Container(
                              width: 4.w,
                              height: 4.w,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
