import 'package:bonoos/core/values/app_colors.dart';
import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:bonoos/core/resources/assets/images/app_images.dart';
import 'package:bonoos/di.dart';
import 'package:bonoos/features/auth/domain/repository/auth_repository.dart';
import 'package:bonoos/features/auth/login_phone_screen.dart';
import 'package:bonoos/features/profile/domain/entity/client_profile.dart';
import 'package:bonoos/features/profile/domain/repository/profile_repository.dart';
import 'package:bonoos/features/tabbox/tabbox_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:bonoos/features/profile/profile_edit_screen.dart';
import 'package:bonoos/features/profile/profile_avatar_controller.dart';
import 'package:bonoos/features/profile/passcode_screen.dart';
import 'package:bonoos/features/profile/security_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loading = true;
  String? _error;
  ClientProfile? _profile;

  bool _pinEnabled = false;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _checkSecurity();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() => _appVersion = info.version);
    } catch (_) {}
  }

  Future<void> _checkSecurity() async {
    final enabled = await SecurityService.isPinEnabled();
    setState(() => _pinEnabled = enabled);
  }

  Future<void> _togglePin(bool val) async {
    if (val) {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const PasscodeScreen(mode: PasscodeMode.setup)),
      );
      if (result == true) {
        setState(() => _pinEnabled = true);
      }
    } else {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const PasscodeScreen(mode: PasscodeMode.verify)),
      );
      if (result == true) {
        await SecurityService.setPinEnabled(false);
        setState(() => _pinEnabled = false);
      }
    }
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await inject<ProfileRepository>().fetchMe();
    if (!mounted) return;
    result.fold(
      (f) {
        setState(() {
          _loading = false;
          _error = f.message ?? 'Xatolik';
          _profile = null;
        });
      },
      (p) {
        setState(() {
          _loading = false;
          _error = null;
          _profile = p;
        });
      },
    );
  }

  String _avatarUrl(ClientProfile? p) {
    if (p == null || p.avatar.trim().isEmpty) return '';
    final a = p.avatar.trim();
    if (a.startsWith('http://') || a.startsWith('https://')) return a;
    final base = dotenv.env['BASE_URL'] ?? '';
    if (base.isEmpty) return a;
    final b = base.replaceAll(RegExp(r'/$'), '');
    final path = a.startsWith('/') ? a : '/$a';
    return '$b$path';
  }

  @override
  Widget build(BuildContext context) {
    void openLanguageSheet() {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const _LanguageBottomSheet(),
      );
    }

    void openInfoSheet({required String title, required String body}) {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _InfoBottomSheet(title: title, body: body),
      );
    }

    void openFeedbackSheet() {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const _FeedbackBottomSheet(),
      );
    }

    Future<void> openRateDialog() async {
      await showDialog<void>(
        context: context,
        builder: (context) {
          return _ConfirmDialog(
            title: "Ilovani baholash",
            description: "Rahmat! Do'konga o'tib baho qo'ymoqchimisiz?",
            primaryLabel: "O'tish",
            secondaryLabel: "Keyinroq",
            onPrimary: () => Navigator.of(context).pop(),
            onSecondary: () => Navigator.of(context).pop(),
          );
        },
      );
    }

    Future<void> openLogoutDialog() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          return _ConfirmDialog(
            title: "Hisobdan chiqish",
            description: "Haqiqatan ham chiqmoqchimisiz? Istalgan vaqtda qayta kirishingiz mumkin.",
            primaryLabel: "Chiqish",
            secondaryLabel: "Bekor qilish",
            onPrimary: () => Navigator.of(ctx).pop(true),
            onSecondary: () => Navigator.of(ctx).pop(false),
            primaryIsDestructive: true,
          );
        },
      );
      if (confirmed != true || !mounted) return;

      setState(() => _loading = true);
      await inject<AuthRepository>().logout();
      if (!mounted) return;
      context.go(LoginPhoneScreen.routeName);
    }

    Future<void> openDeleteAccountDialog() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          return _ConfirmDialog(
            title: "Hisobni o'chirish",
            description: "Haqiqatan ham akkountni o'chirmoqchimisiz? Istalgan vaqtda qayta kirishingiz mumkin.",
            primaryLabel: "O'chirish",
            secondaryLabel: "Bekor qilish",
            onPrimary: () => Navigator.of(ctx).pop(true),
            onSecondary: () => Navigator.of(ctx).pop(false),
            primaryIsDestructive: true,
          );
        },
      );
      if (confirmed != true || !mounted) return;

      setState(() => _loading = true);
      await inject<AuthRepository>().logout();
      if (!mounted) return;
      context.go(LoginPhoneScreen.routeName);
    }

    void openRestoreSheet() {
      openInfoSheet(
        title: "Xaridlarni tiklash",
        body: "Xaridlaringizni tiklashga harakat qilamiz. (Demo ekran)",
      );
    }

    final p = _profile;
    final bio = p?.bio.trim() ?? '';
    final emailStr = p?.email.trim() ?? '';
    final phoneStr = p?.phone ?? '';
    final contactDisplay =
        emailStr.isNotEmpty ? emailStr : (phoneStr.isNotEmpty ? '+998 $phoneStr' : '');
    final isEmailContact = emailStr.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.mainBgColor,
      body: Stack(
        children: [
          const _ProfileBackground(),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 18.h),
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _TopBar(
                    title: "Profil",
                    onEdit: () async {
                      final result = await Navigator.push<ClientProfile?>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProfileEditScreen(profile: _profile),
                        ),
                      );
                      if (result != null && mounted) {
                        _loadProfile();
                      }
                    },
                  ),
                  if (_error != null && !_loading && p == null) ...[
                    SizedBox(height: 12.h),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body13w5.copyWith(color: AppColors.red),
                    ),
                    SizedBox(height: 8.h),
                    Center(
                      child: TextButton(
                        onPressed: _loadProfile,
                        child: Text(
                          'Qayta urinib ko‘ring',
                          style: AppTextStyles.body14w6.copyWith(color: AppColors.c842D5F),
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: 18.h),
                  Center(
                    child: Column(
                      children: [
                        _Avatar(networkAvatarUrl: _avatarUrl(p)),
                        SizedBox(height: 14.h),
                        _ContactPill(
                          value: contactDisplay.isEmpty ? '—' : contactDisplay,
                          isEmail: isEmailContact,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 22.h),
                  _SectionLabel(title: "Xavfsizlik"),
                  SizedBox(height: 10.h),
                  _SecurityCard(
                    pinEnabled: _pinEnabled,
                    onTogglePin: _togglePin,
                    onChangePin: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PasscodeScreen(mode: PasscodeMode.change)),
                      );
                    },
                  ),
                  SizedBox(height: 24.h),
                  _SectionLabel(title: "Sozlamalar"),
                  SizedBox(height: 8.h),
                  _AboutMeCard(
                    hasText: bio.isNotEmpty,
                    text: bio,
                    onClose: () {},
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      // _SupportCard(onTap: () {}),
                      // SizedBox(width: 12.w),
                      // Expanded(
                      //   child: _LinkCard(
                      //     title: "Где нас искать?",
                      //     onTap: () {},
                      //   ),
                      // ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  _SettingsListCard(
                    items: [
                      if (TabBoxController.isSubscriptionVisible)
                        const _SettingsItem(title: "Mening to'plamlarim"),
                      const _SettingsItem(title: "Hisobdan chiqish", isDestructive: true),
                      const _SettingsItem(title: "Hisobni o'chirish", isDestructive: true),
                    ],
                    onTap: (item) {
                      switch (item.title) {
                        case "Ilova tilini tanlash":
                          openLanguageSheet();
                          break;
                        case "Mening to'plamlarim":
                          Navigator.of(context).pop();
                          TabBoxController.instance.setTab(AppTab.subscription);
                          break;
                        case "Xaridlarni tiklash":
                          openRestoreSheet();
                          break;
                        case "Ilova paroli":
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const PasscodeScreen()),
                          );
                          break;
                        case "Ilovani baholash":
                          openRateDialog();
                          break;
                        case "Fikr-mulohaza":
                          openFeedbackSheet();
                          break;
                        case "Sashadan yana":
                          openInfoSheet(
                            title: "Sashadan yana",
                            body: "Materiallar va yangi amaliyotlar to'plami. (Demo ekran)",
                          );
                          break;
                        case "Bizni qayerdan topish mumkin?":
                          openInfoSheet(
                            title: "Bizni qayerdan topish mumkin?",
                            body: "Instagram / Telegram / Veb-sayt (Demo ekran)",
                          );
                          break;
                        case "Hisobdan chiqish":
                          openLogoutDialog();
                          break;
                        case "Hisobni o'chirish":
                          openDeleteAccountDialog();
                          break;
                      }
                    },
                  ),
                  SizedBox(height: 14.h),
                  if (_appVersion.isNotEmpty)
                    Text(
                      "Ilova versiyasi: $_appVersion",
                      style: AppTextStyles.body12w4.copyWith(
                        color: Colors.white.withValues(alpha: 0.55),
                      ),
                    ),
                  SizedBox(height: 10.h),
           
                ],
              ),
            ),
          ),
          if (_loading)
            Positioned.fill(
              child: Container(
                color: AppColors.mainBgColor.withValues(alpha: 0.78),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        color: AppColors.c842D5F,
                        strokeWidth: 2.5,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Profil yuklanmoqda…',
                        style: AppTextStyles.body14w5.copyWith(
                          color: Colors.white.withValues(alpha: 0.88),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProfileBackground extends StatelessWidget {
  const _ProfileBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF26114B),
                Color(0xFF1B0F38),
                AppColors.mainBgColor,
              ],
            ),
          ),
        ),
        Positioned(
          top: -90.h,
          left: -70.w,
          child: Container(
            height: 220.w,
            width: 220.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0x3A842D5F), Color(0x00842D5F)],
              ),
            ),
          ),
        ),
        Positioned(
          top: 140.h,
          right: -90.w,
          child: Container(
            height: 260.w,
            width: 260.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0x2A55004D), Color(0x0055004D)],
              ),
            ),
          ),
        ),
        Positioned.fill(  
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.03),
                  Colors.white.withValues(alpha: 0.00),
                  Colors.black.withValues(alpha: 0.08),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, required this.onEdit});

  final String title;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: (){
            Navigator.pop(context);
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 40.w,
            width: 40.w,
            // decoration: BoxDecoration(
            //   shape: BoxShape.circle,
            //   color: Colors.white.withValues(alpha: 0.08),
            //   border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            // ),
            child: const Center(
              child: Icon(
                CupertinoIcons.arrow_left,
                size: 18,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w,),
        Text(
          title,
          style: AppTextStyles.body22w7.copyWith(
            color: Colors.white,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onEdit,
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 40.w,
            width: 40.w,
            // decoration: BoxDecoration(
            //   shape: BoxShape.circle,
            //   color: Colors.white.withValues(alpha: 0.08),
            //   border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            // ),
            child: const Center(
              child: Icon(
                CupertinoIcons.pencil,
                size: 18,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({this.networkAvatarUrl});

  final String? networkAvatarUrl;

  @override
  Widget build(BuildContext context) {
    final url = networkAvatarUrl?.trim() ?? '';
    if (url.isNotEmpty) {
      return Container(
        height: 118.w,
        width: 118.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.c842D5F, AppColors.c55004D],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3D842D5F),
              blurRadius: 30,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: url,
            width: 118.w,
            height: 118.w,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              width: 118.w,
              height: 118.w,
              color: Colors.white.withValues(alpha: 0.08),
              alignment: Alignment.center,
              child: SizedBox(
                width: 28.w,
                height: 28.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.c842D5F,
                ),
              ),
            ),
            errorWidget: (_, __, ___) => Container(
              width: 118.w,
              height: 118.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.c842D5F, AppColors.c55004D],
                ),
              ),
              alignment: Alignment.center,
              child: Icon(CupertinoIcons.person_fill, size: 44.sp, color: Colors.white.withValues(alpha: 0.9)),
            ),
          ),
        ),
      );
    }

    final controller = ProfileAvatarController.instance;

    return Container(
      height: 118.w,
      width: 118.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.c842D5F, AppColors.c55004D],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3D842D5F),
            blurRadius: 30,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Center(
        child: ValueListenableBuilder<ProfileAvatar>(
          valueListenable: controller.avatar,
          builder: (context, avatar, _) {
            if (avatar.filePath != null && avatar.filePath!.isNotEmpty) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Image.file(
                  File(avatar.filePath!),
                  height: 118.w,
                  width: 118.w,
                  fit: BoxFit.cover,
                ),
              );
            }

            final gradients = <List<Color>>[
              const [Color(0xFF6C62FF), Color(0xFF3C2FDB)],
              const [AppColors.c842D5F, AppColors.c55004D],
              const [Color(0xFFB76BFF), Color(0xFF6E2FB8)],
              const [Color(0xFFEA5B76), Color(0xFFB8215E)],
              const [Color(0xFF40D9B0), Color(0xFF1C9B7B)],
              const [Color(0xFF58B7FF), Color(0xFF1D4FD8)],
            ];
            final idx = (avatar.gradientIndex ?? 1) % gradients.length;

            return Container(
              height: 118.w,
              width: 118.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradients[idx],
                ),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    height: 100.w,
                    width: 100.w,
                    padding: EdgeInsets.all(10.w),
                    color: Colors.white.withValues(alpha: 0.12),
                    child: Image.asset(
                      AppImages.splashImage,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ContactPill extends StatelessWidget {
  const _ContactPill({required this.value, required this.isEmail});

  final String value;
  final bool isEmail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withValues(alpha: 0.07),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isEmail ? CupertinoIcons.at : CupertinoIcons.phone,
            size: 16.sp,
            color: Colors.white.withValues(alpha: 0.70),
          ),
          SizedBox(width: 8.w),
          Text(
            value,
            style: AppTextStyles.body14w5.copyWith(
              color: Colors.white.withValues(alpha: 0.78),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.body18w7.copyWith(
        color: Colors.white.withValues(alpha: 0.95),
      ),
    );
  }
}

class _AboutMeCard extends StatelessWidget {
  const _AboutMeCard({
    required this.hasText,
    required this.text,
    required this.onClose,
  });

  final bool hasText;
  final String text;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        color: Colors.white.withValues(alpha: 0.06),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Profil tavsifini yashirish",
                      style: AppTextStyles.body12w4.copyWith(
                        color: Colors.white.withValues(alpha: 0.55),
                      ),
                    ),
                    SizedBox(height: 8.h),
                  ],
                ),
              ),

            ],
          ),
          Text(
            hasText ? text : "O'zingiz haqingizda hech narsa yozmadingiz",
            style: AppTextStyles.body14w4.copyWith(
              color: Colors.white.withValues(alpha: 0.70),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 175.w,
        padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.r),
          color: Colors.white.withValues(alpha: 0.08),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "🙋🏻‍♀️",
              style: TextStyle(fontSize: 18.sp),
            ),
            SizedBox(height: 12.h),
            Text(
              "Texnik yordam\nbilan suhbat",
              style: AppTextStyles.body14w7.copyWith(
                color: Colors.white.withValues(alpha: 0.92),
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.body14w6.copyWith(
                  color: Colors.white.withValues(alpha: 0.70),
                ),
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              size: 18.sp,
              color: Colors.white.withValues(alpha: 0.55),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinkCard extends StatelessWidget {
  const _LinkCard({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 88.h,
        padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.r),
          color: Colors.white.withValues(alpha: 0.08),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.body14w7.copyWith(
                  color: Colors.white.withValues(alpha: 0.92),
                  height: 1.15,
                ),
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              size: 18.sp,
              color: Colors.white.withValues(alpha: 0.55),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsItem {
  const _SettingsItem({required this.title, this.isDestructive = false});

  final String title;
  final bool isDestructive;
}

class _SecurityCard extends StatelessWidget {
  const _SecurityCard({
    required this.pinEnabled,
    required this.onTogglePin,
    required this.onChangePin,
  });

  final bool pinEnabled;
  final ValueChanged<bool> onTogglePin;
  final VoidCallback onChangePin;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          _SecurityTile(
            title: "Ilova paroli",
            icon: CupertinoIcons.lock_fill,
            trailing: CupertinoSwitch(
              value: pinEnabled,
              onChanged: onTogglePin,
              activeTrackColor: AppColors.c842D5F,
            ),
          ),
          if (pinEnabled) ...[
            Container(height: 1, color: Colors.white.withValues(alpha: 0.05), margin: EdgeInsets.symmetric(horizontal: 16.w)),
            _SecurityTile(
              title: "Parolni o'zgartirish",
              icon: CupertinoIcons.padlock,
              onTap: onChangePin,
            ),
          ],
        ],
      ),
    );
  }
}

class _SecurityTile extends StatelessWidget {
  const _SecurityTile({
    required this.title,
    required this.icon,
    this.trailing,
    this.onTap,
  });

  final String title;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 18.sp),
      ),
      title: Text(
        title,
        style: AppTextStyles.body15w5.copyWith(color: Colors.white.withValues(alpha: 0.9)),
      ),
      trailing: trailing ?? Icon(CupertinoIcons.chevron_right, color: Colors.white.withValues(alpha: 0.2), size: 16.sp),
    );
  }
}

class _SettingsListCard extends StatelessWidget {
  const _SettingsListCard({
    required this.items,
    required this.onTap,
  });

  final List<_SettingsItem> items;
  final ValueChanged<_SettingsItem> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.circular(18.r),
      //   color: Colors.white.withValues(alpha: 0.06),
      //   border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      // ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _SettingsTile(
              title: items[i].title,
              isDestructive: items[i].isDestructive,
              onTap: () => onTap(items[i]),
            ),
            if (i != items.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                color: Colors.white.withValues(alpha: 0.08),
                indent: 14.w,
                endIndent: 14.w,
              ),
          ],
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.title,
    required this.onTap,
    required this.isDestructive,
  });

  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 14.h),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.body14w6.copyWith(
                  color: isDestructive
                      ? const Color(0xFFFF7A92)
                      : Colors.white.withValues(alpha: 0.82),
                ),
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              size: 18.sp,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterLinks extends StatelessWidget {
  const _FooterLinks({required this.items, required this.onTap});

  final List<String> items;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final text in items) ...[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onTap(text),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 3.h),
              child: Text(
                text,
                style: AppTextStyles.body10w4.copyWith(
                  color: Colors.white.withValues(alpha: 0.45),
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white.withValues(alpha: 0.30),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({
    required this.title,
    required this.description,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.onPrimary,
    required this.onSecondary,
    this.primaryIsDestructive = false,
  });

  final String title;
  final String description;
  final String primaryLabel;
  final String secondaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;
  final bool primaryIsDestructive;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          color: AppColors.mainBgColor,
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x30842D5F),
              blurRadius: 24,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.body18w7.copyWith(
                color: Colors.white.withValues(alpha: 0.95),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              description,
              style: AppTextStyles.body13w4.copyWith(
                color: Colors.white.withValues(alpha: 0.70),
                height: 1.35,
              ),
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onSecondary,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                      backgroundColor: Colors.white.withValues(alpha: 0.06),
                    ),
                    child: Text(
                      secondaryLabel,
                      style: AppTextStyles.body14w6.copyWith(
                        color: Colors.white.withValues(alpha: 0.86),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onPrimary,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      backgroundColor: primaryIsDestructive ? const Color(0xFFFF4D6D) : AppColors.c842D5F,
                    ),
                    child: Text(
                      primaryLabel,
                      style: AppTextStyles.body14w7.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBottomSheet extends StatelessWidget {
  const _InfoBottomSheet({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.40,
      maxChildSize: 0.90,
      builder: (context, controller) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.mainBgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
            child: ListView(
              controller: controller,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.body18w7.copyWith(
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
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
                SizedBox(height: 10.h),
                Text(
                  body,
                  style: AppTextStyles.body14w4.copyWith(
                    color: Colors.white.withValues(alpha: 0.72),
                    height: 1.4,
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

class _FeedbackBottomSheet extends StatefulWidget {
  const _FeedbackBottomSheet();

  @override
  State<_FeedbackBottomSheet> createState() => _FeedbackBottomSheetState();
}

class _FeedbackBottomSheetState extends State<_FeedbackBottomSheet> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.55,
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
            child: ListView(
              controller: controller,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Fikr-mulohaza",
                        style: AppTextStyles.body18w7.copyWith(
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
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
                SizedBox(height: 8.h),
                Text(
                  "Nimani yaxshilash kerak yoki nimalar yoqdi, yozing.",
                  style: AppTextStyles.body13w4.copyWith(
                    color: Colors.white.withValues(alpha: 0.70),
                    height: 1.35,
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18.r),
                    color: Colors.white.withValues(alpha: 0.06),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                  ),
                  child: TextField(
                    controller: _textController,
                    minLines: 5,
                    maxLines: 8,
                    style: AppTextStyles.body14w4.copyWith(color: Colors.white.withValues(alpha: 0.90)),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: "Xabaringiz...",
                      hintStyle: AppTextStyles.body14w4.copyWith(color: Colors.white.withValues(alpha: 0.45)),
                    ),
                  ),
                ),
                SizedBox(height: 14.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      backgroundColor: AppColors.c842D5F,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      "Yuborish",
                      style: AppTextStyles.body16w7.copyWith(
                        color: Colors.white,
                      ),
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

class _LanguageBottomSheet extends StatelessWidget {
  const _LanguageBottomSheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.74,
      minChildSize: 0.55,
      maxChildSize: 0.90,
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
                        "Ilova tili va\nversiyasini tanlang",
                        style: AppTextStyles.body20w7.copyWith(
                          color: Colors.white.withValues(alpha: 0.95),
                          height: 1.05,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        height: 40.w,
                        width: 40.w,
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
                SizedBox(height: 10.h),
                Text(
                  "Ruscha versiya — bu siz odatlangan AB.MONEY ilovasi, ichki imkoniyatlari, meditatsiyalari, darslari va videolari bilan.\n\n"
                  "Inglizcha versiya — bu ingliz tili uchun moslashtirilgan AB.MONEY ilovasi, cheklangan funksiyalar va kontent bilan.",
                  style: AppTextStyles.body13w4.copyWith(
                    color: Colors.white.withValues(alpha: 0.65),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: _LangOptionCard(
                        title: "Ruscha\nversiya",
                        subtitle: "Tanlangan",
                        flag: "🇷🇺",
                        selected: true,
                        onTap: () {},
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _LangOptionCard(
                        title: "Inglizcha\nversiya",
                        subtitle: "Tanlash >",
                        flag: "🇺🇸",
                        selected: false,
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      backgroundColor: AppColors.c842D5F,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      "Til versiyasini o'zgartirish",
                      style: AppTextStyles.body16w7.copyWith(
                        color: Colors.white,
                      ),
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

class _LangOptionCard extends StatelessWidget {
  const _LangOptionCard({
    required this.title,
    required this.subtitle,
    required this.flag,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String flag;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? Colors.white.withValues(alpha: 0.10) : Colors.white.withValues(alpha: 0.06);
    final border = selected ? Colors.white.withValues(alpha: 0.16) : Colors.white.withValues(alpha: 0.10);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160.h,
        padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 12.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.r),
          color: bg,
          border: Border.all(color: border),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x20842D5F),
                    blurRadius: 16,
                    offset: Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.body14w7.copyWith(
                      color: Colors.white.withValues(alpha: selected ? 0.92 : 0.72),
                      height: 1.1,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: Text(
                    subtitle,
                    style: AppTextStyles.body12w6.copyWith(
                      color: Colors.white.withValues(alpha: selected ? 0.70 : 0.55),
                    ),
                  ),
                ),
                Text(flag, style: TextStyle(fontSize: 18.sp)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

