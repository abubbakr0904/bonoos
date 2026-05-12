import 'package:bonoos/core/values/app_colors.dart';
import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:bonoos/features/medicine/medicine_models.dart';
import 'package:bonoos/features/medicine/medicine_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key, this.medicine});

  final MedicineItem? medicine;

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  late final TextEditingController _nameController;
  late TimeOfDay _selectedTime;
  bool _saving = false;

  bool get _isEdit => widget.medicine != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.medicine?.name ?? '');
    _selectedTime = _isEdit
        ? TimeOfDay(hour: widget.medicine!.hour, minute: widget.medicine!.minute)
        : TimeOfDay.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    TimeOfDay? tempTime = _selectedTime;
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.mainBgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return Container(
          height: 340.h,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(CupertinoIcons.xmark, color: Colors.white54),
                  ),
                  Text(
                    "Vaqtni tanlang",
                    style: AppTextStyles.body18w6.copyWith(color: Colors.white),
                  ),
                  IconButton(
                    onPressed: () {
                      if (tempTime != null) {
                        setState(() => _selectedTime = tempTime!);
                      }
                      Navigator.pop(context);
                    },
                    icon: const Icon(CupertinoIcons.check_mark, color: AppColors.white
                    ),
                  ),
                ],
              ),
              Expanded(
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: AppTextStyles.body22w7.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    use24hFormat: true,
                    initialDateTime: DateTime(2024, 1, 1, _selectedTime.hour, _selectedTime.minute),
                    onDateTimeChanged: (DateTime dt) {
                      tempTime = TimeOfDay(hour: dt.hour, minute: dt.minute);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Dori nomini kiriting")),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      if (_isEdit) {
        await MedicineService.updateMedicine(
          widget.medicine!,
          MedicineDraft(
            name: name,
            hour: _selectedTime.hour,
            minute: _selectedTime.minute,
          ),
        );
      } else {
        await MedicineService.createMedicine(
          MedicineDraft(
            name: name,
            hour: _selectedTime.hour,
            minute: _selectedTime.minute,
          ),
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Xatolik yuz berdi: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: AppColors.mainBgColor,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 56.w,
                width: 56.w,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(CupertinoIcons.trash, color: Colors.redAccent),
              ),
              SizedBox(height: 20.h),
              Text(
                "O'chirish",
                style: AppTextStyles.body18w7.copyWith(color: Colors.white),
              ),
              SizedBox(height: 12.h),
              Text(
                "Haqiqatan ham ushbu eslatmani o'chirmoqchimisiz?",
                textAlign: TextAlign.center,
                style: AppTextStyles.body14w4.copyWith(
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        "Bekor qilish",
                        style: AppTextStyles.body14w6.copyWith(color: Colors.white54),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "O'chirish",
                        style: AppTextStyles.body14w7.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      setState(() => _saving = true);
      await MedicineService.deleteMedicine(widget.medicine!.id);
      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEdit ? "O'zgartirish" : "Dori qo'shish",
          style: AppTextStyles.body18w6.copyWith(color: Colors.white),
        ),
        actions: [
          if (_isEdit)
            IconButton(
              icon: const Icon(CupertinoIcons.trash, color: Colors.redAccent),
              onPressed: _delete,
            ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Dori nomi",
              style: AppTextStyles.body14w5.copyWith(
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.06),
                hintText: "Masalan: Paratsetamol",
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              "Qabul qilish vaqti",
              style: AppTextStyles.body14w5.copyWith(
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: 8.h),
            GestureDetector(
              onTap: _selectTime,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.time, color: Colors.white),
                    SizedBox(width: 12.w),
                    Text(
                      _selectedTime.format(context),
                      style: AppTextStyles.body16w6.copyWith(color: Colors.white),
                    ),
                    const Spacer(),
                    Icon(
                      CupertinoIcons.chevron_right,
                      color: Colors.white.withValues(alpha: 0.3),
                      size: 18.sp,
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            if (_isEdit) ...[
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: OutlinedButton(
                  onPressed: _delete,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: Text(
                    "O'chirish",
                    style: AppTextStyles.body16w6.copyWith(color: Colors.redAccent),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
            ],
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                child: _saving
                    ? const CircularProgressIndicator(color: AppColors.mainBgColor)
                    : Text(
                        "Saqlash",
                        style: AppTextStyles.body16w6.copyWith(color: AppColors.mainBgColor),
                      ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
