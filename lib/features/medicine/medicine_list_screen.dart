import 'package:bonoos/core/values/app_colors.dart';
import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:bonoos/features/medicine/add_medicine_screen.dart';
import 'package:bonoos/features/medicine/medicine_models.dart';
import 'package:bonoos/features/medicine/medicine_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MedicineListScreen extends StatefulWidget {
  const MedicineListScreen({super.key});

  @override
  State<MedicineListScreen> createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends State<MedicineListScreen> {
  List<MedicineItem> _medicines = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  Future<void> _loadMedicines() async {
    setState(() => _loading = true);
    final list = await MedicineService.loadMedicines();
    setState(() {
      _medicines = list;
      _loading = false;
    });
  }

  Future<void> _toggleMedicine(MedicineItem item, bool val) async {
    await MedicineService.toggleMedicine(item, val);
    await _loadMedicines();
  }

  Future<void> _deleteMedicine(int id) async {
    await MedicineService.deleteMedicine(id);
    await _loadMedicines();
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
          "Dori ichish vaqti",
          style: AppTextStyles.body18w6.copyWith(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddMedicineScreen()),
              );
              if (result == true) {
                _loadMedicines();
              }
            },
            icon: Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: Icon(
                CupertinoIcons.add,
                color: Colors.white,
                size: 20.sp,
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _medicines.isEmpty
              ? _buildEmptyState()
              : _buildList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.capsule_fill,
            size: 64.sp,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          SizedBox(height: 16.h),
          Text(
            "Hozircha dorilar yo'q",
            style: AppTextStyles.body16w5.copyWith(
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Yangi dori qo'shish uchun + tugmasini bosing",
            style: AppTextStyles.body13w4.copyWith(
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
          SizedBox(height: 24.h),
          SizedBox(
            width: 180.w,
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddMedicineScreen()),
                );
                if (result == true) {
                  _loadMedicines();
                }
              },
              icon: const Icon(CupertinoIcons.add, size: 18),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.mainBgColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 12.h),
                elevation: 0,
              ),
              label: Text(
                "Yangi dori",
                style: AppTextStyles.body14w6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: _medicines.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final item = _medicines[index];
        return _MedicineCard(
          item: item,
          onToggle: (val) => _toggleMedicine(item, val),
          onDelete: () => _deleteMedicine(item.id),
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddMedicineScreen(medicine: item),
              ),
            );
            if (result == true) {
              _loadMedicines();
            }
          },
        );
      },
    );
  }
}

class _MedicineCard extends StatelessWidget {
  const _MedicineCard({
    required this.item,
    required this.onToggle,
    required this.onDelete,
    required this.onTap,
  });

  final MedicineItem item;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: const Icon(CupertinoIcons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
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
      },
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Container(
                height: 48.w,
                width: 48.w,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(CupertinoIcons.capsule, color: Colors.white),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: AppTextStyles.body16w6.copyWith(color: Colors.white),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      item.timeLabel,
                      style: AppTextStyles.body14w5.copyWith(
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              CupertinoSwitch(
                value: item.enabled,
                onChanged: onToggle,
                activeTrackColor: AppColors.c842D5F,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
