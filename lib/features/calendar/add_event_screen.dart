import 'package:bonoos/core/values/app_colors.dart';
import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:bonoos/di.dart';
import 'package:bonoos/features/calendar/domain/entity/calendar_event.dart';
import 'package:bonoos/features/calendar/domain/entity/event_type.dart';
import 'package:bonoos/features/calendar/domain/repository/calendar_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({
    super.key,
    required this.selectedDate,
    this.eventToEdit,
  });

  final DateTime selectedDate;
  final CalendarEvent? eventToEdit;

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final CalendarRepository _repository = inject<CalendarRepository>();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();

  List<EventType> _eventTypes = [];
  EventType? _selectedEventType;
  bool _isLoading = true;
  String? _error;

  DateTime _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isSubmitting = false;
  bool _isEventTypeExpanded = false;

  _AddEventScreenState() : _selectedDate = DateTime.now();

  bool get _isEditMode => widget.eventToEdit != null;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _loadEventTypes();
  }

  void _initializeEditMode() {
    if (_isEditMode) {
      final event = widget.eventToEdit!;
      _titleController.text = event.title;
      _noteController.text = event.note ?? '';

      // Parse event date
      final eventDate = DateTime.tryParse(event.eventDate);
      if (eventDate != null) {
        _selectedDate = eventDate;
      }

      // Parse event time
      if (event.eventTime != null && event.eventTime!.isNotEmpty) {
        final timeParts = event.eventTime!.split(':');
        if (timeParts.length == 2) {
          final hour = int.tryParse(timeParts[0]) ?? 0;
          final minute = int.tryParse(timeParts[1]) ?? 0;
          _selectedTime = TimeOfDay(hour: hour, minute: minute);
        }
      }

      // Find and select the correct event type
      final eventType =
          _eventTypes.where((t) => t.id == event.typeId).firstOrNull;
      if (eventType != null) {
        _selectedEventType = eventType;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadEventTypes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _repository.fetchEventTypes();

    result.fold(
      (failure) {
        setState(() {
          _error = failure.message;
          _isLoading = false;
        });
      },
      (types) {
        setState(() {
          _eventTypes = types;
          if (_isEditMode) {
            _initializeEditMode();
          } else if (types.isNotEmpty) {
            _selectedEventType = types.first;
          }
          _isLoading = false;
        });
      },
    );
  }

  Future<void> _selectDate() async {
    final date = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CalendarPickerDialog(
        initialDate: _selectedDate,
      ),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showModalBottomSheet<TimeOfDay>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CupertinoTimePickerDialog(
        initialTime: _selectedTime ?? TimeOfDay.now(),
      ),
    );

    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  Future<void> _submit() async {
    if (_selectedEventType == null) {
      _showError('Event turini tanlang');
      return;
    }

    if (_titleController.text.trim().isEmpty) {
      _showError('Sarlavhani kiriting');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final eventDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final eventTime = _selectedTime != null
        ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
        : null;

    final result = _isEditMode
        ? await _repository.updateEvent(
            eventId: widget.eventToEdit!.id,
            typeId: _selectedEventType!.id,
            title: _titleController.text.trim(),
            eventDate: eventDate,
            eventTime: eventTime,
            note: _noteController.text.trim().isNotEmpty
                ? _noteController.text.trim()
                : null,
          )
        : await _repository.createEvent(
            typeId: _selectedEventType!.id,
            title: _titleController.text.trim(),
            eventDate: eventDate,
            eventTime: eventTime,
            note: _noteController.text.trim().isNotEmpty
                ? _noteController.text.trim()
                : null,
          );

    setState(() {
      _isSubmitting = false;
    });

    result.fold(
      (failure) {
        _showError(failure.message ?? 'Xatolik yuz berdi');
      },
      (event) {
        Navigator.of(context).pop(event);
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
        ),
        title: Text(
          _isEditMode ? 'Taskni tahrirlash' : 'Task qo\'shish',
          style: AppTextStyles.body18w6.copyWith(color: Colors.white),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : _error != null
              ? _buildError()
              : _buildForm(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.exclamationmark_circle,
            size: 48.sp,
            color: Colors.red,
          ),
          SizedBox(height: 12.h),
          Text(
            _error!,
            style: AppTextStyles.body14w5.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: _loadEventTypes,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.mainBgColor,
            ),
            child: const Text('Qayta yuklash'),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Type Dropdown
              _buildLabel('Event turi'),
              SizedBox(height: 6.h),
              _buildEventTypeDropdown(),
              SizedBox(height: 16.h),

              // Title
              _buildLabel('Sarlavha'),
              SizedBox(height: 6.h),
              _buildTextField(
                controller: _titleController,
                hintText: 'Masalan: Uchrashuv',
              ),
              SizedBox(height: 16.h),

              // Date picker
              _buildLabel('Sana'),
              SizedBox(height: 6.h),
              _buildDatePicker(),
              SizedBox(height: 16.h),

              // Time picker
              _buildLabel('Vaqt (ixtiyoriy)'),
              SizedBox(height: 6.h),
              _buildTimePicker(),
              SizedBox(height: 16.h),

              // Note
              _buildLabel('Izoh (ixtiyoriy)'),
              SizedBox(height: 6.h),
              _buildTextField(
                controller: _noteController,
                hintText: 'Izoh qo\'shish...',
                maxLines: 2,
              ),
              SizedBox(height: 24.h),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 44.h,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.mainBgColor,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    disabledBackgroundColor:
                        Colors.white.withValues(alpha: 0.5),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            color: AppColors.mainBgColor,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Saqlash',
                          style: AppTextStyles.body14w6,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.body13w5.copyWith(
        color: Colors.white.withValues(alpha: 0.7),
      ),
    );
  }

  Widget _buildEventTypeDropdown() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isEventTypeExpanded = !_isEventTypeExpanded;
            });
          },
          child: Container(
            height: 44.h,
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: _isEventTypeExpanded
                    ? Colors.white.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedEventType?.name ?? 'Turini tanlash',
                    style: AppTextStyles.body14w5.copyWith(color: Colors.white),
                  ),
                ),
                AnimatedRotation(
                  duration: const Duration(milliseconds: 200),
                  turns: _isEventTypeExpanded ? 0.5 : 0,
                  child: Icon(
                    CupertinoIcons.chevron_down,
                    color: Colors.white.withValues(alpha: 0.5),
                    size: 16.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isEventTypeExpanded) ...[
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              children: _eventTypes.map((type) {
                final isSelected = _selectedEventType?.id == type.id;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedEventType = type;
                      _isEventTypeExpanded = false;
                    });
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            type.name,
                            style: AppTextStyles.body13w5.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            CupertinoIcons.checkmark_alt,
                            color: Colors.white,
                            size: 16.sp,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 40.h,
        maxHeight: maxLines > 1 ? 80.h : 40.h,
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: AppTextStyles.body13w5.copyWith(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.body13w4.copyWith(
            color: Colors.white.withValues(alpha: 0.45),
          ),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.06),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: const BorderSide(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    final dateText = DateFormat('dd MMMM yyyy', 'uz').format(_selectedDate);
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        height: 40.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.calendar,
              color: Colors.white.withValues(alpha: 0.6),
              size: 18.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              dateText,
              style: AppTextStyles.body13w5.copyWith(color: Colors.white),
            ),
            const Spacer(),
            Icon(
              CupertinoIcons.chevron_down,
              color: Colors.white.withValues(alpha: 0.5),
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    final timeText = _selectedTime != null
        ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
        : 'Vaqt tanlash';

    return GestureDetector(
      onTap: _selectTime,
      child: Container(
        height: 40.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.clock,
              color: Colors.white.withValues(alpha: 0.6),
              size: 18.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              timeText,
              style: AppTextStyles.body13w5.copyWith(
                color: _selectedTime != null
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.45),
              ),
            ),
            const Spacer(),
            if (_selectedTime != null)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTime = null;
                  });
                },
                child: Icon(
                  CupertinoIcons.xmark_circle_fill,
                  color: Colors.white.withValues(alpha: 0.5),
                  size: 18.sp,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Custom Calendar Picker Dialog
class _CalendarPickerDialog extends StatefulWidget {
  final DateTime initialDate;

  const _CalendarPickerDialog({
    required this.initialDate,
  });

  @override
  State<_CalendarPickerDialog> createState() => _CalendarPickerDialogState();
}

class _CalendarPickerDialogState extends State<_CalendarPickerDialog> {
  late DateTime _selectedDate;
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _displayedMonth =
        DateTime(widget.initialDate.year, widget.initialDate.month);
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final daysInMonth = lastDay.day;

    // Weekday of first day (0 = Monday for our calendar)
    final firstWeekday = firstDay.weekday;

    final days = <DateTime>[];

    // Add empty slots for days before first day of month
    for (var i = 1; i < firstWeekday; i++) {
      days.add(DateTime(0)); // placeholder
    }

    // Add actual days
    for (var i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(month.year, month.month, i));
    }

    return days;
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
      margin: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.mainBgColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _previousMonth,
                  icon: Icon(
                    CupertinoIcons.chevron_left,
                    color: Colors.white,
                    size: 22.sp,
                  ),
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
                    size: 22.sp,
                  ),
                ),
              ],
            ),
          ),

          // Week day headers
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: weekDays.map((day) {
                return SizedBox(
                  width: 36.w,
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
          SizedBox(height: 8.h),

          // Calendar grid
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 7,
              mainAxisSpacing: 8.h,
              crossAxisSpacing: 4.w,
              children: days.map((date) {
                if (date.year == 0) {
                  return const SizedBox.shrink();
                }

                final isSelected = date.year == _selectedDate.year &&
                    date.month == _selectedDate.month &&
                    date.day == _selectedDate.day;
                final isToday = date.year == DateTime.now().year &&
                    date.month == DateTime.now().month &&
                    date.day == DateTime.now().day;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                  child: Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? Colors.white
                          : isToday
                              ? Colors.white.withValues(alpha: 0.3)
                              : Colors.transparent,
                      border: isToday && !isSelected
                          ? Border.all(color: Colors.white, width: 1)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '${date.day}',
                        style: AppTextStyles.body14w5.copyWith(
                          color: isSelected
                              ? AppColors.mainBgColor
                              : isToday
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 20.h),

          // Actions
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Bekor qilish',
                      style: AppTextStyles.body14w6.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(_selectedDate),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.mainBgColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: const Text('Tanlash'),
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

/// Custom Cupertino Time Picker Dialog
class _CupertinoTimePickerDialog extends StatefulWidget {
  final TimeOfDay initialTime;

  const _CupertinoTimePickerDialog({
    required this.initialTime,
  });

  @override
  State<_CupertinoTimePickerDialog> createState() =>
      _CupertinoTimePickerDialogState();
}

class _CupertinoTimePickerDialogState
    extends State<_CupertinoTimePickerDialog> {
  late int _selectedHour;
  late int _selectedMinute;

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.initialTime.hour;
    _selectedMinute = widget.initialTime.minute;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.mainBgColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Text(
              'Vaqtni tanlang',
              style: AppTextStyles.body16w6.copyWith(color: Colors.white),
            ),
          ),

          // Time pickers
          Container(
            height: 200.h,
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Row(
              children: [
                // Hour picker
                Expanded(
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                      initialItem: _selectedHour,
                    ),
                    itemExtent: 40.h,
                    magnification: 1.2,
                    squeeze: 0.9,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        _selectedHour = index;
                      });
                    },
                    children: List.generate(24, (index) {
                      return Center(
                        child: Text(
                          index.toString().padLeft(2, '0'),
                          style: AppTextStyles.body18w6.copyWith(
                            color: _selectedHour == index
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                // Separator
                Text(
                  ':',
                  style: AppTextStyles.body24w5.copyWith(color: Colors.white),
                ),

                // Minute picker
                Expanded(
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                      initialItem: _selectedMinute,
                    ),
                    itemExtent: 40.h,
                    magnification: 1.2,
                    squeeze: 0.9,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        _selectedMinute = index;
                      });
                    },
                    children: List.generate(60, (index) {
                      return Center(
                        child: Text(
                          index.toString().padLeft(2, '0'),
                          style: AppTextStyles.body18w6.copyWith(
                            color: _selectedMinute == index
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // Actions
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Bekor qilish',
                      style: AppTextStyles.body14w6.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(
                        TimeOfDay(hour: _selectedHour, minute: _selectedMinute),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.mainBgColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: const Text('Tanlash'),
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
