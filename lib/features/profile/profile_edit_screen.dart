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

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key, this.profile});

  final ClientProfile? profile;

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
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

    return Scaffold(
      backgroundColor: AppColors.mainBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Profilni tahrirlash",
          style: AppTextStyles.body18w6.copyWith(color: Colors.white),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h + 20.h),
        children: [
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
          SizedBox(height: 24.h),
          SizedBox(
            width: double.infinity,
            height: 54.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                backgroundColor: AppColors.white,
              ),
              onPressed: _saving ? null : _save,
              child: _saving
                  ? SizedBox(
                      height: 20.h,
                      width: 20.h,
                      child: const CircularProgressIndicator(
                        color: AppColors.mainBgColor,
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Picker Sheets (Internal)
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.mainBgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h + 20.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(CupertinoIcons.xmark, color: Colors.white, size: 18),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.06),
              prefixIcon: const Icon(CupertinoIcons.search, color: Colors.white54),
              hintText: "Qidirish...",
              hintStyle: const TextStyle(color: Colors.white30),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 400.h),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final region = _filtered[index];
                final isSelected = _picked?.id == region.id;
                return ListTile(
                  onTap: () => Navigator.of(context).pop(region),
                  title: Text(region.nameUz, style: TextStyle(color: isSelected ? AppColors.c842D5F : Colors.white)),
                  trailing: isSelected ? const Icon(CupertinoIcons.check_mark, color: AppColors.c842D5F) : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.mainBgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h + 20.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(CupertinoIcons.xmark, color: Colors.white, size: 18),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 400.h),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: widget.activities.length,
              itemBuilder: (context, index) {
                final activity = widget.activities[index];
                final isSelected = _picked?.id == activity.id;
                return ListTile(
                  onTap: () => Navigator.of(context).pop(activity),
                  title: Text(activity.nameUz, style: TextStyle(color: isSelected ? AppColors.c842D5F : Colors.white)),
                  trailing: isSelected ? const Icon(CupertinoIcons.check_mark, color: AppColors.c842D5F) : null,
                );
              },
            ),
          ),
        ],
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
  DateTime? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350.h,
      decoration: BoxDecoration(
        color: AppColors.mainBgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h + 20.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Bekor qilish", style: TextStyle(color: Colors.white54)),
              ),
              const Text("Sanani tanlang", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () => Navigator.pop(context, _selected),
                child: const Text("Tayyor", style: TextStyle(color: AppColors.c842D5F)),
              ),
            ],
          ),
          Expanded(
            child: CupertinoTheme(
              data: const CupertinoThemeData(
                textTheme: CupertinoTextThemeData(
                  dateTimePickerTextStyle: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: widget.initial,
                minimumDate: widget.firstDate,
                maximumDate: widget.lastDate,
                onDateTimeChanged: (DateTime dt) {
                  setState(() => _selected = dt);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Components
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
        ),
        child: Center(
          child: avatar.filePath != null && avatar.filePath!.isNotEmpty
              ? ClipOval(
                  child: Image.file(
                    File(avatar.filePath!),
                    height: 86.h,
                    width: 86.h,
                    fit: BoxFit.cover,
                  ),
                )
              : Icon(
                  CupertinoIcons.photo_on_rectangle,
                  color: Colors.white.withValues(alpha: 0.95),
                  size: 32.sp,
                ),
        ),
      ),
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
      child: Container(
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
            color: selected ? Colors.white : Colors.white10,
            width: selected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Icon(
            CupertinoIcons.person,
            color: Colors.white,
            size: 34.sp,
          ),
        ),
      ),
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
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white30),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: hasError ? const BorderSide(color: Colors.redAccent) : BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: hasError ? const BorderSide(color: Colors.redAccent) : BorderSide.none,
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
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Text(value, style: const TextStyle(color: Colors.white)),
            const Spacer(),
            const Icon(CupertinoIcons.calendar, color: Colors.white54, size: 20),
          ],
        ),
      ),
    );
  }
}

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
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Expanded(child: Text(value, style: TextStyle(color: isSelected ? Colors.white : Colors.white30))),
            if (isLoading)
              const CupertinoActivityIndicator(radius: 8, color: Colors.white)
            else
              const Icon(CupertinoIcons.chevron_down, color: Colors.white54, size: 18),
          ],
        ),
      ),
    );
  }
}
