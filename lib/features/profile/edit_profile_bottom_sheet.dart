import 'package:bonoos/core/values/app_colors.dart';
import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:bonoos/di.dart';
import 'package:bonoos/features/profile/domain/entity/client_profile.dart';
import 'package:bonoos/features/profile/domain/entity/activity.dart';
import 'package:bonoos/features/profile/domain/entity/income_range.dart';
import 'package:bonoos/features/profile/domain/entity/region.dart';
import 'package:bonoos/features/profile/domain/repository/profile_repository.dart';
import 'package:bonoos/features/profile/profile_avatar_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfileBottomSheet extends StatefulWidget {
  const EditProfileBottomSheet({super.key, this.profile});

  final ClientProfile? profile;

  @override
  State<EditProfileBottomSheet> createState() => _EditProfileBottomSheetState();
}

class _EditProfileBottomSheetState extends State<EditProfileBottomSheet> {
  final _avatarController = ProfileAvatarController.instance;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();

  DateTime? _birthday;
  int _selectedAvatar = 0;
  bool _showNameError = false;
  bool _saving = false;
  final _picker = ImagePicker();

  String? _uploadedAvatarUrl;
  bool _uploadingAvatar = false;

  List<Region> _regions = [];
  bool _regionsLoading = true;
  Region? _selectedRegion;

  List<IncomeRange> _incomeRanges = [];
  bool _incomeLoading = true;
  IncomeRange? _selectedIncome;

  List<Activity> _activities = [];
  bool _activitiesLoading = true;
  Activity? _selectedActivity;

  @override
  void initState() {
    super.initState();
    _prefill();
    _loadRegions();
    _loadIncomeRanges();
    _loadActivities();
  }

  void _prefill() {
    final p = widget.profile;
    if (p == null) return;
    _nameController.text = p.fullName;
    _emailController.text = p.email;
    _bioController.text = p.bio;
    if (p.birthday != null && p.birthday!.isNotEmpty) {
      final parts = p.birthday!.split('-');
      if (parts.length == 3) {
        _birthday = DateTime.tryParse(p.birthday!);
      }
    }
  }

  Future<void> _loadRegions() async {
    final result = await inject<ProfileRepository>().fetchRegions();
    if (!mounted) return;
    result.fold(
      (_) => setState(() => _regionsLoading = false),
      (regions) {
        setState(() {
          _regions = regions;
          _regionsLoading = false;
          if (widget.profile?.regionId != null) {
            final match = regions.where((r) => r.id == widget.profile!.regionId);
            if (match.isNotEmpty) _selectedRegion = match.first;
          }
        });
      },
    );
  }

  Future<void> _loadIncomeRanges() async {
    final result = await inject<ProfileRepository>().fetchIncomeRanges();
    if (!mounted) return;
    result.fold(
      (_) => setState(() => _incomeLoading = false),
      (ranges) {
        setState(() {
          _incomeRanges = ranges;
          _incomeLoading = false;
          if (widget.profile?.income != null) {
            final match = ranges.where((r) => r.id == widget.profile!.income);
            if (match.isNotEmpty) _selectedIncome = match.first;
          }
        });
      },
    );
  }

  Future<void> _loadActivities() async {
    final result = await inject<ProfileRepository>().fetchActivities();
    if (!mounted) return;
    result.fold(
      (_) => setState(() => _activitiesLoading = false),
      (activities) {
        setState(() {
          _activities = activities;
          _activitiesLoading = false;
          if (widget.profile?.activityId != null) {
            final match = activities.where((a) => a.id == widget.profile!.activityId);
            if (match.isNotEmpty) _selectedActivity = match.first;
          }
        });
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final initial = _birthday ?? DateTime(now.year - 22, now.month, now.day);

    final picked = await showModalBottomSheet<DateTime?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BirthdayPickerSheet(
        initial: initial,
        firstDate: DateTime(1920, 1, 1),
        lastDate: DateTime(now.year + 1, 12, 31),
      ),
    );

    if (picked == null) return;
    setState(() => _birthday = picked);
  }

  Future<void> _openRegionPicker() async {
    if (_regions.isEmpty) return;

    final picked = await showModalBottomSheet<Region?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RegionPickerSheet(
        regions: _regions,
        selected: _selectedRegion,
      ),
    );

    if (picked == null) return;
    setState(() => _selectedRegion = picked);
  }

  Future<void> _openIncomePicker() async {
    if (_incomeRanges.isEmpty) return;

    final picked = await showModalBottomSheet<IncomeRange?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _IncomePickerSheet(
        ranges: _incomeRanges,
        selected: _selectedIncome,
      ),
    );

    if (picked == null) return;
    setState(() => _selectedIncome = picked);
  }

  Future<void> _openActivityPicker() async {
    if (_activities.isEmpty) return;

    final picked = await showModalBottomSheet<Activity?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ActivityPickerSheet(
        activities: _activities,
        selected: _selectedActivity,
      ),
    );

    if (picked == null) return;
    setState(() => _selectedActivity = picked);
  }

  Future<void> _save() async {
    final nameOk = _nameController.text.trim().isNotEmpty;
    setState(() => _showNameError = !nameOk);
    if (!nameOk) return;

    if (_saving) return;
    setState(() => _saving = true);

    final birthdayStr = _birthday != null
        ? '${_birthday!.year}-${_birthday!.month.toString().padLeft(2, '0')}-${_birthday!.day.toString().padLeft(2, '0')}'
        : '';

    final result = await inject<ProfileRepository>().updateProfile(
      email: _emailController.text.trim(),
      fullName: _nameController.text.trim(),
      birthday: birthdayStr,
      avatar: _uploadedAvatarUrl ?? widget.profile?.avatar ?? 'no-photo.jpg',
      bio: _bioController.text.trim(),
      regionId: _selectedRegion?.id ?? 0,
      incomeId: _selectedIncome?.id ?? 0,
      activityId: _selectedActivity?.id ?? 0,
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message ?? 'Xatolik yuz berdi'),
            backgroundColor: const Color(0xFFFF5B7A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
      (updatedProfile) {
        setState(() => _saving = false);
        Navigator.of(context).pop(updatedProfile);
      },
    );
  }

  Future<void> _pickFromGallery() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );
    if (file == null) return;

    _avatarController.setFile(file.path);
    if (!mounted) return;
    setState(() => _uploadingAvatar = true);

    final result = await inject<ProfileRepository>().uploadAvatar(file.path);
    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() => _uploadingAvatar = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message ?? 'Rasm yuklanmadi'),
            backgroundColor: const Color(0xFFFF5B7A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
      (url) {
        setState(() {
          _uploadedAvatarUrl = url;
          _uploadingAvatar = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final birthdayLabel = _birthday == null
        ? "Tug'ilgan kunni tanlang"
        : "${_birthday!.day.toString().padLeft(2, '0')}.${_birthday!.month.toString().padLeft(2, '0')}.${_birthday!.year}";

    final regionLabel = _selectedRegion != null
        ? _selectedRegion!.nameUz
        : "Viloyatni tanlang";

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.70,
      maxChildSize: 0.95,
      builder: (context, controller) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.mainBgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h + 10.h),
            child: ListView(
              controller: controller,
              physics: const BouncingScrollPhysics(),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Profilni tahrirlash",
                        style: AppTextStyles.body20w7.copyWith(
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: SizedBox(
                        height: 40.w,
                        width: 40.w,
                        child: const Center(
                          child: Icon(CupertinoIcons.xmark, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                Row(
                  children: [
                    Expanded(
                      child: _SectionCaption(title: "Rasm yuklang"),
                    ),
                    Container(
                      height: 26.h,
                      width: 1,
                      color: Colors.white.withValues(alpha: 0.10),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 12.w),
                        child: _SectionCaption(title: "Yoki avatar tanlang"),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Stack(
                      children: [
                        _UploadAvatarButton(
                          avatar: _avatarController.avatar.value,
                          onTap: _uploadingAvatar ? () {} : _pickFromGallery,
                        ),
                        if (_uploadingAvatar)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withValues(alpha: 0.45),
                              ),
                              child: const Center(
                                child: SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: SizedBox(
                        height: 92.h,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: 6,
                          separatorBuilder: (_, __) => SizedBox(width: 10.w),
                          itemBuilder: (context, index) {
                            return _AvatarOption(
                              index: index,
                              selected: _selectedAvatar == index,
                              onTap: () {
                                setState(() => _selectedAvatar = index);
                                _avatarController.setGradient(index);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 18.h),
                _FieldLabel("Ism va familiya*"),
                SizedBox(height: 8.h),
                _DarkTextField(
                  controller: _nameController,
                  hintText: "To'liq ismingiz",
                  hasError: _showNameError,
                ),
                if (_showNameError) ...[
                  SizedBox(height: 6.h),
                  Text(
                    "Bu maydon majburiy",
                    style: AppTextStyles.body12w4.copyWith(
                      color: const Color(0xFFFF5B7A),
                    ),
                  ),
                ],
                SizedBox(height: 14.h),
                _FieldLabel("Tug'ilgan kun"),
                SizedBox(height: 8.h),
                _DateField(
                  value: birthdayLabel,
                  onTap: _pickBirthday,
                ),
                SizedBox(height: 14.h),
                _FieldLabel("Viloyat"),
                SizedBox(height: 8.h),
                _SelectField(
                  value: regionLabel,
                  isLoading: _regionsLoading,
                  isSelected: _selectedRegion != null,
                  onTap: _openRegionPicker,
                ),
                SizedBox(height: 14.h),
                _FieldLabel("Faoliyat turi"),
                SizedBox(height: 8.h),
                _SelectField(
                  value: _selectedActivity != null
                      ? _selectedActivity!.nameUz
                      : "Faoliyat turini tanlang",
                  isLoading: _activitiesLoading,
                  isSelected: _selectedActivity != null,
                  onTap: _openActivityPicker,
                ),
                SizedBox(height: 14.h),
                _FieldLabel("Bio"),
                SizedBox(height: 8.h),
                _DarkTextField(
                  controller: _bioController,
                  hintText: "O'zingiz haqingizda yozing",
                  minLines: 5,
                  maxLines: 8,
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: AppColors.white,
                    ),
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? SizedBox(
                            height: 20.h,
                            width: 20.h,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            "Saqlash",
                            style: AppTextStyles.body16w7.copyWith(color: AppColors.mainBgColor),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Region Picker Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _RegionPickerSheet extends StatefulWidget {
  const _RegionPickerSheet({
    required this.regions,
    required this.selected,
  });

  final List<Region> regions;
  final Region? selected;

  @override
  State<_RegionPickerSheet> createState() => _RegionPickerSheetState();
}

class _RegionPickerSheetState extends State<_RegionPickerSheet> {
  final _searchController = TextEditingController();
  List<Region> _filtered = [];
  Region? _picked;

  @override
  void initState() {
    super.initState();
    _filtered = widget.regions;
    _picked = widget.selected;
    _searchController.addListener(_onSearch);
  }

  void _onSearch() {
    final q = _searchController.text.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filtered = widget.regions;
      } else {
        _filtered = widget.regions.where((r) {
          return r.nameUz.toLowerCase().contains(q) ||
              r.nameRu.toLowerCase().contains(q) ||
              r.nameEn.toLowerCase().contains(q);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.50,
      maxChildSize: 0.92,
      builder: (context, controller) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.mainBgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h + 10.h),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Viloyatni tanlang",
                        style: AppTextStyles.body18w7.copyWith(
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop<Region?>(null),
                      child: Container(
                        height: 38.w,
                        width: 38.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.08),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                        ),
                        child: const Center(
                          child: Icon(CupertinoIcons.xmark, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18.r),
                    color: Colors.white.withValues(alpha: 0.06),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.search,
                        size: 18.sp,
                        color: Colors.white.withValues(alpha: 0.45),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: AppTextStyles.body14w4.copyWith(
                            color: Colors.white.withValues(alpha: 0.90),
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            hintText: "Qidirish...",
                            hintStyle: AppTextStyles.body14w4.copyWith(
                              color: Colors.white.withValues(alpha: 0.35),
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                Expanded(
                  child: ListView.builder(
                    controller: controller,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) {
                      final region = _filtered[index];
                      final isSelected = _picked?.id == region.id;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _picked = region);
                          Navigator.of(context).pop<Region?>(region);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: EdgeInsets.only(bottom: 6.h),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14.r),
                            color: isSelected
                                ? AppColors.c842D5F.withValues(alpha: 0.25)
                                : Colors.white.withValues(alpha: 0.04),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.c842D5F.withValues(alpha: 0.60)
                                  : Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.location_solid,
                                size: 18.sp,
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.92)
                                    : Colors.white.withValues(alpha: 0.45),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      region.nameUz,
                                      style: AppTextStyles.body14w6.copyWith(
                                        color: isSelected
                                            ? Colors.white.withValues(alpha: 0.95)
                                            : Colors.white.withValues(alpha: 0.78),
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      region.nameRu,
                                      style: AppTextStyles.body11w4.copyWith(
                                        color: Colors.white.withValues(alpha: 0.40),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  CupertinoIcons.checkmark_circle_fill,
                                  size: 22.sp,
                                  color: AppColors.c842D5F,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Income Range Picker Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _IncomePickerSheet extends StatefulWidget {
  const _IncomePickerSheet({
    required this.ranges,
    required this.selected,
  });

  final List<IncomeRange> ranges;
  final IncomeRange? selected;

  @override
  State<_IncomePickerSheet> createState() => _IncomePickerSheetState();
}

class _IncomePickerSheetState extends State<_IncomePickerSheet> {
  IncomeRange? _picked;

  @override
  void initState() {
    super.initState();
    _picked = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.50,
      minChildSize: 0.35,
      maxChildSize: 0.80,
      builder: (context, controller) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.mainBgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h + 10.h),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Daromad oralig'ini tanlang",
                        style: AppTextStyles.body18w7.copyWith(
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop<IncomeRange?>(null),
                      child: Container(
                        height: 38.w,
                        width: 38.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.08),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                        ),
                        child: const Center(
                          child: Icon(CupertinoIcons.xmark, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Expanded(
                  child: ListView.builder(
                    controller: controller,
                    physics: const BouncingScrollPhysics(),
                    itemCount: widget.ranges.length,
                    itemBuilder: (context, index) {
                      final range = widget.ranges[index];
                      final isSelected = _picked?.id == range.id;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _picked = range);
                          Navigator.of(context).pop<IncomeRange?>(range);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: EdgeInsets.only(bottom: 6.h),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14.r),
                            color: isSelected
                                ? AppColors.c842D5F.withValues(alpha: 0.25)
                                : Colors.white.withValues(alpha: 0.04),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.c842D5F.withValues(alpha: 0.60)
                                  : Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  range.nameUz,
                                  style: AppTextStyles.body14w6.copyWith(
                                    color: isSelected
                                        ? Colors.white.withValues(alpha: 0.95)
                                        : Colors.white.withValues(alpha: 0.78),
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  CupertinoIcons.checkmark_circle_fill,
                                  size: 22.sp,
                                  color: AppColors.c842D5F,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Activity Picker Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _ActivityPickerSheet extends StatefulWidget {
  const _ActivityPickerSheet({
    required this.activities,
    required this.selected,
  });

  final List<Activity> activities;
  final Activity? selected;

  @override
  State<_ActivityPickerSheet> createState() => _ActivityPickerSheetState();
}

class _ActivityPickerSheetState extends State<_ActivityPickerSheet> {
  Activity? _picked;

  @override
  void initState() {
    super.initState();
    _picked = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      builder: (context, controller) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.mainBgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h + 10.h),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Faoliyat turini tanlang",
                        style: AppTextStyles.body18w7.copyWith(
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop<Activity?>(null),
                      child: Container(
                        height: 38.w,
                        width: 38.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.08),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                        ),
                        child: const Center(
                          child: Icon(CupertinoIcons.xmark, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Expanded(
                  child: ListView.builder(
                    controller: controller,
                    physics: const BouncingScrollPhysics(),
                    itemCount: widget.activities.length,
                    itemBuilder: (context, index) {
                      final activity = widget.activities[index];
                      final isSelected = _picked?.id == activity.id;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _picked = activity);
                          Navigator.of(context).pop<Activity?>(activity);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: EdgeInsets.only(bottom: 6.h),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14.r),
                            color: isSelected
                                ? AppColors.c842D5F.withValues(alpha: 0.25)
                                : Colors.white.withValues(alpha: 0.04),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.c842D5F.withValues(alpha: 0.60)
                                  : Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  activity.nameUz,
                                  style: AppTextStyles.body14w6.copyWith(
                                    color: isSelected
                                        ? Colors.white.withValues(alpha: 0.95)
                                        : Colors.white.withValues(alpha: 0.78),
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  CupertinoIcons.checkmark_circle_fill,
                                  size: 22.sp,
                                  color: AppColors.c842D5F,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Select Field Widget
// ─────────────────────────────────────────────────────────────────────────────

class _SelectField extends StatelessWidget {
  const _SelectField({
    required this.value,
    required this.isLoading,
    required this.isSelected,
    required this.onTap,
  });

  final String value;
  final bool isLoading;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.r),
          color: Colors.white.withValues(alpha: 0.06),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: AppTextStyles.body14w5.copyWith(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.90)
                      : Colors.white.withValues(alpha: 0.35),
                ),
              ),
            ),
            if (isLoading)
              SizedBox(
                height: 16.h,
                width: 16.h,
                child: const CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: AppColors.c842D5F,
                ),
              )
            else
              Icon(
                CupertinoIcons.chevron_down,
                size: 18.sp,
                color: Colors.white.withValues(alpha: 0.45),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable Widgets (unchanged from original)
// ─────────────────────────────────────────────────────────────────────────────

class _SectionCaption extends StatelessWidget {
  const _SectionCaption({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.body12w4.copyWith(
        color: Colors.white.withValues(alpha: 0.62),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.body13w6.copyWith(
        color: Colors.white.withValues(alpha: 0.78),
      ),
    );
  }
}

class _UploadAvatarButton extends StatelessWidget {
  const _UploadAvatarButton({
    required this.avatar,
    required this.onTap,
  });

  final ProfileAvatar avatar;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gradients = <List<Color>>[
      const [Color(0xFF6C62FF), Color(0xFF3C2FDB)],
      const [AppColors.c842D5F, AppColors.c55004D],
      const [Color(0xFFB76BFF), Color(0xFF6E2FB8)],
      const [Color(0xFFEA5B76), Color(0xFFB8215E)],
      const [Color(0xFF40D9B0), Color(0xFF1C9B7B)],
      const [Color(0xFF58B7FF), Color(0xFF1D4FD8)],
    ];

    final ringColors = avatar.gradientIndex == null
        ? const [AppColors.c842D5F, AppColors.c55004D]
        : gradients[avatar.gradientIndex! % gradients.length];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 92.h,
        width: 92.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: ringColors,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x2A842D5F),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Center(child: _CurrentAvatarPreview(avatar: avatar)),
      ),
    );
  }
}

class _CurrentAvatarPreview extends StatelessWidget {
  const _CurrentAvatarPreview({required this.avatar});

  final ProfileAvatar avatar;

  @override
  Widget build(BuildContext context) {
    if (avatar.filePath != null && avatar.filePath!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: Image.file(
          File(avatar.filePath!),
          height: 86.h,
          width: 86.h,
          fit: BoxFit.cover,
        ),
      );
    }

    return Icon(
      CupertinoIcons.photo_on_rectangle,
      color: Colors.white.withValues(alpha: 0.95),
      size: 32.sp,
    );
  }
}

class _AvatarOption extends StatelessWidget {
  const _AvatarOption({
    required this.index,
    required this.selected,
    required this.onTap,
  });

  final int index;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gradients = <List<Color>>[
      const [Color(0xFF6C62FF), Color(0xFF3C2FDB)],
      const [AppColors.c842D5F, AppColors.c55004D],
      const [Color(0xFFB76BFF), Color(0xFF6E2FB8)],
      const [Color(0xFFEA5B76), Color(0xFFB8215E)],
      const [Color(0xFF40D9B0), Color(0xFF1C9B7B)],
      const [Color(0xFF58B7FF), Color(0xFF1D4FD8)],
    ];

    final g = gradients[index % gradients.length];

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        height: 92.h,
        width: 92.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: g,
          ),
          border: Border.all(
            color: selected ? Colors.white.withValues(alpha: 0.60) : Colors.white.withValues(alpha: 0.10),
            width: selected ? 2.2 : 1,
          ),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x3D842D5F),
                    blurRadius: 22,
                    offset: Offset(0, 12),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: AnimatedScale(
            duration: const Duration(milliseconds: 180),
            scale: selected ? 1.05 : 1.0,
            child: Icon(
              CupertinoIcons.person,
              color: Colors.white.withValues(alpha: 0.92),
              size: 34.sp,
            ),
          ),
        ),
      ),
    );
  }
}

class _BirthdayPickerSheet extends StatefulWidget {
  const _BirthdayPickerSheet({
    required this.initial,
    required this.firstDate,
    required this.lastDate,
  });

  final DateTime initial;
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  State<_BirthdayPickerSheet> createState() => _BirthdayPickerSheetState();
}

class _BirthdayPickerSheetState extends State<_BirthdayPickerSheet> {
  late DateTime _month;
  DateTime? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
    _month = DateTime(widget.initial.year, widget.initial.month, 1);
  }

  void _prevMonth() {
    final prev = DateTime(_month.year, _month.month - 1, 1);
    if (prev.isBefore(DateTime(widget.firstDate.year, widget.firstDate.month, 1))) return;
    setState(() => _month = prev);
  }

  void _nextMonth() {
    final next = DateTime(_month.year, _month.month + 1, 1);
    if (next.isAfter(DateTime(widget.lastDate.year, widget.lastDate.month, 1))) return;
    setState(() => _month = next);
  }

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  bool _inRange(DateTime d) => !d.isBefore(widget.firstDate) && !d.isAfter(widget.lastDate);

  @override
  Widget build(BuildContext context) {
    final title = "${_uzMonth(_month.month)} ${_month.year}";

    return DraggableScrollableSheet(
      initialChildSize: 0.62,
      minChildSize: 0.55,
      maxChildSize: 0.80,
      builder: (context, controller) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.mainBgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h + 10.h),
            child: ListView(
              controller: controller,
              physics: const BouncingScrollPhysics(),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Sanani tanlang",
                        style: AppTextStyles.body18w7.copyWith(
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop<DateTime?>(null),
                      child: Container(
                        height: 38.w,
                        width: 38.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.08),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                        ),
                        child: const Center(
                          child: Icon(CupertinoIcons.xmark, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                _Glass(
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _prevMonth,
                        icon: Icon(CupertinoIcons.chevron_left, color: Colors.white.withValues(alpha: 0.85)),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            title,
                            style: AppTextStyles.body14w7.copyWith(
                              color: Colors.white.withValues(alpha: 0.92),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _nextMonth,
                        icon: Icon(CupertinoIcons.chevron_right, color: Colors.white.withValues(alpha: 0.85)),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                _Glass(
                  padding: EdgeInsets.fromLTRB(10.w, 12.h, 10.w, 10.h),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          _Dow("Du"),
                          _Dow("Se"),
                          _Dow("Ch"),
                          _Dow("Pa"),
                          _Dow("Ju"),
                          _Dow("Sh"),
                          _Dow("Ya"),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      _CalendarGrid(
                        month: _month,
                        selected: _selected,
                        isSameDay: _isSameDay,
                        inRange: _inRange,
                        onSelect: (d) => setState(() => _selected = d),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop<DateTime?>(null),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                          backgroundColor: Colors.white.withValues(alpha: 0.06),
                        ),
                        child: Text(
                          "Bekor qilish",
                          style: AppTextStyles.body14w6.copyWith(color: Colors.white.withValues(alpha: 0.86)),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _selected == null ? null : () => Navigator.of(context).pop<DateTime?>(_selected),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                          backgroundColor: AppColors.c842D5F,
                          disabledBackgroundColor: Colors.white.withValues(alpha: 0.12),
                        ),
                        child: Text(
                          "Tanlash",
                          style: AppTextStyles.body14w7.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _uzMonth(int month) {
    const months = [
      "Yanvar",
      "Fevral",
      "Mart",
      "Aprel",
      "May",
      "Iyun",
      "Iyul",
      "Avgust",
      "Sentabr",
      "Oktabr",
      "Noyabr",
      "Dekabr",
    ];
    return months[(month - 1).clamp(0, 11)];
  }
}

class _Glass extends StatelessWidget {
  const _Glass({required this.child, this.padding});

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        color: Colors.white.withValues(alpha: 0.06),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: child,
    );
  }
}

class _Dow extends StatelessWidget {
  const _Dow(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34.w,
      child: Center(
        child: Text(
          text,
          style: AppTextStyles.body11w6.copyWith(
            color: Colors.white.withValues(alpha: 0.55),
          ),
        ),
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.month,
    required this.selected,
    required this.isSameDay,
    required this.inRange,
    required this.onSelect,
  });

  final DateTime month;
  final DateTime? selected;
  final bool Function(DateTime a, DateTime b) isSameDay;
  final bool Function(DateTime d) inRange;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final firstOfMonth = DateTime(month.year, month.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final weekday = firstOfMonth.weekday;
    final leadingEmpty = weekday - 1;
    final totalCells = ((leadingEmpty + daysInMonth) <= 35) ? 35 : 42;

    return Wrap(
      spacing: 6.w,
      runSpacing: 8.h,
      children: List.generate(totalCells, (i) {
        final dayNum = i - leadingEmpty + 1;
        if (dayNum < 1 || dayNum > daysInMonth) {
          return SizedBox(width: 34.w, height: 34.w);
        }

        final date = DateTime(month.year, month.month, dayNum);
        final enabled = inRange(date);
        final isSelected = selected != null && isSameDay(date, selected!);

        final bg = isSelected
            ? const LinearGradient(colors: [AppColors.c842D5F, AppColors.c55004D])
            : null;

        return GestureDetector(
          onTap: enabled ? () => onSelect(date) : null,
          child: Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: bg,
              color: bg == null ? Colors.white.withValues(alpha: enabled ? 0.06 : 0.03) : null,
              border: Border.all(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.18)
                    : Colors.white.withValues(alpha: enabled ? 0.10 : 0.06),
              ),
            ),
            child: Center(
              child: Text(
                "$dayNum",
                style: AppTextStyles.body12w6.copyWith(
                  color: enabled
                      ? (isSelected ? Colors.white : Colors.white.withValues(alpha: 0.82))
                      : Colors.white.withValues(alpha: 0.25),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _DarkTextField extends StatelessWidget {
  const _DarkTextField({
    required this.controller,
    required this.hintText,
    this.minLines = 1,
    this.maxLines = 1,
    this.hasError = false,
  });

  final TextEditingController controller;
  final String hintText;
  final int minLines;
  final int maxLines;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        color: Colors.white.withValues(alpha: 0.06),
        border: Border.all(
          color: hasError ? const Color(0xFFFF5B7A) : Colors.white.withValues(alpha: 0.10),
        ),
      ),
      child: TextField(
        controller: controller,
        minLines: minLines,
        maxLines: maxLines,
        style: AppTextStyles.body14w5.copyWith(
          color: Colors.white.withValues(alpha: 0.90),
        ),
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14.h),
          hintText: hintText,
          hintStyle: AppTextStyles.body14w4.copyWith(
            color: Colors.white.withValues(alpha: 0.35),
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.value, required this.onTap});
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.r),
          color: Colors.white.withValues(alpha: 0.06),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: AppTextStyles.body14w5.copyWith(
                  color: Colors.white.withValues(alpha: 0.78),
                ),
              ),
            ),
            Icon(
              CupertinoIcons.calendar,
              size: 18.sp,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ],
        ),
      ),
    );
  }
}
