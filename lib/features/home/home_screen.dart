import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:bonoos/core/api/dio_client.dart';
import 'package:bonoos/core/api/list_api.dart';
import 'package:bonoos/core/utils/last_listened_manager.dart';
import 'package:bonoos/core/values/app_colors.dart';
import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:bonoos/di.dart';
import 'package:dio/dio.dart';
import 'package:bonoos/features/common/widget/audio_list_tile.dart';
import 'package:bonoos/features/common/widget/custom_button.dart';
import 'package:bonoos/features/common/widget/weekly_listening_chart_card.dart';
import 'package:bonoos/features/breath/breathing_practices_screen.dart';
import 'package:bonoos/features/home/audio_screen.dart';
import 'package:bonoos/features/home/domain/entity/client_banner_dto.dart';
import 'package:bonoos/features/home/domain/repository/banners_repository.dart';
import 'package:bonoos/features/home/message_of_day_screen.dart';
import 'package:bonoos/features/notification/notifications_screen.dart';
import 'package:bonoos/features/playlist/domain/entity/audition.dart';
import 'package:bonoos/features/playlist/domain/entity/category.dart';
import 'package:bonoos/features/playlist/domain/repository/playlist_repository.dart';
import 'package:bonoos/features/profile/domain/entity/client_profile.dart';
import 'package:bonoos/features/profile/domain/repository/profile_repository.dart';
import 'package:bonoos/features/profile/profile_screen.dart';
import 'package:bonoos/features/tabbox/tabbox_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool _expanded = false;
  ClientProfile? _profile;
  final ScrollController _homeScroll = ScrollController();
  late final AnimationController _entryController;
  bool _moodSheetShown = false;
  bool _giftOpenedToday = false;

  void _toggleChallenge() => setState(() => _expanded = !_expanded);

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..forward();
    _loadProfile();
    _showMoodSheetOnOpen();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _homeScroll.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final result = await inject<ProfileRepository>().fetchMe();
    if (!mounted) return;
    result.fold(
      (_) {},
      (p) => setState(() => _profile = p),
    );
  }

  void _goToProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  void _showMoodSheetOnOpen() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _moodSheetShown) return;
      _moodSheetShown = true;
      showModalBottomSheet<void>(
        context: context,
        isDismissible: true,
        enableDrag: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withOpacity(0.42),
        builder: (_) => const _MoodCheckinSheet(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBgColor,
      body: SafeArea(
        child: ListView(
          controller: _homeScroll,
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 22.h),
          children: [
            FadeTransition(
              opacity: CurvedAnimation(
                parent: _entryController,
                curve: const Interval(0.0, 0.35, curve: Curves.easeOutCubic),
              ),
              child: _Header(
                expanded: _expanded,
                profile: _profile,
                onAvatarTap: _goToProfile,
                onChevronTap: _toggleChallenge,
                onNotificationTap: () => context.push(NotificationsScreen.routeName),
              ),
            ),
            SizedBox(height: 16.h),
            if (!_giftOpenedToday) ...[
              FadeTransition(
                opacity: CurvedAnimation(
                  parent: _entryController,
                  curve: const Interval(0.10, 0.50, curve: Curves.easeOutCubic),
                ),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.10),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _entryController,
                      curve: const Interval(0.10, 0.50, curve: Curves.easeOutCubic),
                    ),
                  ),
                  child: _DailyGiftCard(
                    onTap: () {
                      context.push(MessageOfDayScreen.routeName).then((_) {
                        if (mounted) setState(() => _giftOpenedToday = true);
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 12.h),
            ],
            FadeTransition(
              opacity: CurvedAnimation(
                parent: _entryController,
                curve: const Interval(0.18, 0.60, curve: Curves.easeOutCubic),
              ),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.10),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _entryController,
                    curve: const Interval(0.18, 0.60, curve: Curves.easeOutCubic),
                  ),
                ),
                child: const WeeklyListeningChartCard(
                  title: "Haftalik tinglash (daqiqa)",
                  subtitle: "Statistik ma'lumotlar",
                  values: [0, 6, 12, 8, 16, 10, 14],
                  labels: ["Du", "Se", "Ch", "Pa", "Ju", "Sha", "Ya"],
                ),
              ),
            ),
            SizedBox(height: 20.h),
            FadeTransition(
              opacity: CurvedAnimation(
                parent: _entryController,
                curve: const Interval(0.26, 0.75, curve: Curves.easeOutCubic),
              ),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.10),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _entryController,
                    curve: const Interval(0.26, 0.75, curve: Curves.easeOutCubic),
                  ),
                ),
                child: const _HomePlaylistFromPlaylistSection(),
              ),
            ),
            SizedBox(height: 22.h),
          ],
        ),
      ),
    );
  }
}

class _MoodOption {
  const _MoodOption({
    required this.label,
    required this.assetPath,
  });

  final String label;
  final String assetPath;
}

class _MoodCheckinSheet extends StatefulWidget {
  const _MoodCheckinSheet();

  @override
  State<_MoodCheckinSheet> createState() => _MoodCheckinSheetState();
}

class _MoodCheckinSheetState extends State<_MoodCheckinSheet> with SingleTickerProviderStateMixin {
  static const List<_MoodOption> _moods = [
    _MoodOption(label: 'Zo\'r', assetPath: 'assets/images/mood1.jpg'),
    _MoodOption(label: 'Yaxshi', assetPath: 'assets/images/mood2.jpg'),
    _MoodOption(label: 'Oddiy', assetPath: 'assets/images/mood3.jpg'),
    _MoodOption(label: 'Yomonroq', assetPath: 'assets/images/mood4.jpg'),
    _MoodOption(label: 'Yomon', assetPath: 'assets/images/mood5.jpg'),
  ];

  int? _selectedIndex;
  bool _isSaving = false;
  late final AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _saveMood() async {
    if (_selectedIndex == null) return;
    final moodValue = 5 - _selectedIndex!;
    setState(() => _isSaving = true);
    try {
      final dio = inject<DioClient>();
      await dio.post(
        ListAPI.clientGratitudeDiaryMood,
        data: {'mood': moodValue},
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } on DioException catch (e) {
      if (!mounted) return;
      final message = e.response?.data is Map ? Map<String, dynamic>.from(e.response!.data)['message']?.toString() : null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message ?? 'Kayfiyat saqlanmadi')),
      );
      setState(() => _isSaving = false);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kayfiyat saqlanmadi')),
      );
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.65,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
              color: AppColors.mainBgColor,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 14.h),
            child: Column(
              children: [
                Container(
                  width: 42.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    _TopIconButton(
                      icon: CupertinoIcons.back,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    const Spacer(),
                    _TopIconButton(
                      icon: CupertinoIcons.xmark,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Text(
                  "Bugungi kayfiyatingiz?",
                  style: AppTextStyles.body24w7.copyWith(
                    color: Colors.white,
                    fontFamily: 'DancingScript',
                    fontSize: 34.sp,
                  ),
                ),
                SizedBox(height: 24.h),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        runAlignment: WrapAlignment.center,
                        spacing: 18.w,
                        runSpacing: 18.h,
                        children: List.generate(_moods.length, (index) {
                          final mood = _moods[index];
                          final selected = _selectedIndex == index;
                          return TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0, end: 1),
                            duration: Duration(milliseconds: 400 + (index * 100)),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) => Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, (1 - value) * 18),
                                child: child,
                              ),
                            ),
                            child: SizedBox(
                              width: 96.w,
                              height: 96.w,
                              child: _MoodItem(
                                option: mood,
                                selected: selected,
                                floatController: _floatController,
                                onTap: () => setState(() => _selectedIndex = index),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: "Saqlash",
                    onTap: _saveMood,
                    isEnabled: _selectedIndex != null && !_isSaving,
                    isLoading: _isSaving,
                    height: 50.h,
                    radius: BorderRadius.circular(16.r),
                    bgColor: Colors.white,
                    textColor: AppColors.mainBgColor,
                    disabledBgColor: Colors.white.withOpacity(0.1),
                    disabledTextColor: Colors.white.withOpacity(0.3),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
                SizedBox(height: 12.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopIconButton extends StatelessWidget {
  const _TopIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38.w,
      width: 38.w,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              color: Colors.black.withOpacity(0.12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20.sp,
            ),
          ),
        ),
      ),
    );
  }
}

class _MoodItem extends StatelessWidget {
  const _MoodItem({
    required this.option,
    required this.selected,
    required this.floatController,
    required this.onTap,
  });

  final _MoodOption option;
  final bool selected;
  final AnimationController floatController;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999.r),
        onTap: onTap,
        child: Center(
          child: AnimatedBuilder(
            animation: floatController,
            builder: (context, child) {
              final offsetY = selected ? (-5.0 * floatController.value) : 0.0;
              return Transform.translate(
                offset: Offset(0, offsetY),
                child: AnimatedScale(
                  scale: selected ? 1.25 : 1,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  child: child,
                ),
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              height: 96.w,
              width: 96.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: selected ? Border.all(color: Colors.white, width: 2) : null,
                boxShadow: [
                  BoxShadow(
                    color: selected ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.2),
                    blurRadius: selected ? 20 : 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                option.assetPath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.black.withOpacity(0.1),
                  child: const Icon(CupertinoIcons.smiley, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.expanded,
    required this.profile,
    required this.onAvatarTap,
    required this.onChevronTap,
    required this.onNotificationTap,
  });

  final bool expanded;
  final ClientProfile? profile;
  final VoidCallback onAvatarTap;
  final VoidCallback onChevronTap;
  final VoidCallback onNotificationTap;

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
    final name = profile?.fullName.trim() ?? '';
    final displayName = name.isNotEmpty ? name : 'Salom!';
    final avatarUrl = _avatarUrl(profile);

    return Row(
      children: [
        GestureDetector(
          onTap: onAvatarTap,
          child: avatarUrl.isNotEmpty
              ? Container(
                  height: 48.w,
                  width: 48.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: avatarUrl,
                      width: 48.w,
                      height: 48.w,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const Center(
                        child: Icon(CupertinoIcons.person, color: Colors.white, size: 22),
                      ),
                      errorWidget: (_, __, ___) => const Center(
                        child: Icon(CupertinoIcons.person, color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                )
              : Container(
                  height: 48.w,
                  width: 48.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                    border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                  ),
                  child: const Center(
                    child: Icon(CupertinoIcons.person, color: Colors.white, size: 22),
                  ),
                ),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: GestureDetector(
            onTap: onAvatarTap,
            behavior: HitTestBehavior.opaque,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body22w7.copyWith(
                    color: Colors.white,
                    fontFamily: 'DancingScript',
                    fontSize: 28.sp,
                  ),
                ),
                Text(
                  "Bugungi challengeni boshlang!",
                  style: AppTextStyles.body13w4.copyWith(
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 10.w),
        _HeaderActionTile(
          onTap: onNotificationTap,
          child: Icon(
            CupertinoIcons.bell_fill,
            size: 20.sp,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }
}

class _HeaderActionTile extends StatelessWidget {
  const _HeaderActionTile({
    required this.onTap,
    required this.child,
  });

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final side = 44.w;
    return SizedBox(
      width: side,
      height: side,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14.r),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.r),
              color: Colors.black.withOpacity(0.12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

class _DailyGiftCard extends StatelessWidget {
  const _DailyGiftCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.15),
              Colors.white.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20.r),
      
        ),
        child: Row(
          children: [
            // Gift Icon with Glow
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.15),
           
              ),
              child: Icon(CupertinoIcons.gift_fill, color: Colors.white, size: 28.sp),
            ),
            SizedBox(width: 18.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Kun sovg'asi",
                    style: AppTextStyles.body20w7.copyWith(
                      color: Colors.white,
                      fontSize: 16.sp,
                      height: 1.1,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "Siz uchun maxsus motivatsiya",
                    style: AppTextStyles.body14w4.copyWith(
                      color: Colors.white.withOpacity(0.65),
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
            // Interactive button-like indicator
     
          ],
        ),
      ),
    );
  }
}

class _HomePlaylistFromPlaylistSection extends StatefulWidget {
  const _HomePlaylistFromPlaylistSection();

  @override
  State<_HomePlaylistFromPlaylistSection> createState() => _HomePlaylistFromPlaylistSectionState();
}

class _HomePlaylistFromPlaylistSectionState extends State<_HomePlaylistFromPlaylistSection> {
  final List<Audition> _items = [];
  bool _loadingInitial = true;
  bool _loadingMore = false;
  String? _error;
  int _nextOffset = 0;
  bool _hasMore = true;
  static const int _pageSize = 10;

  static const List<List<Color>> _gradientPalette = [
    [Color(0xFF8E44AD), Color(0xFF9B59B6)],
    [Color(0xFF2980B9), Color(0xFF3498DB)],
    [Color(0xFF16A085), Color(0xFF1ABC9C)],
    [Color(0xFFD35400), Color(0xFFE67E22)],
  ];

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    setState(() {
      _loadingInitial = true;
      _error = null;
      _items.clear();
      _nextOffset = 0;
      _hasMore = true;
    });
    final r = await inject<PlaylistRepository>().fetchAuditionsPage(limit: _pageSize, offset: 0);
    if (!mounted) return;
    r.fold(
      (f) => setState(() {
        _loadingInitial = false;
        _error = f.message ?? 'Xatolik';
      }),
      (page) => setState(() {
        _loadingInitial = false;
        _error = null;
        _items.addAll(page.items);
        _nextOffset = page.offset + page.items.length;
        _hasMore = page.hasMore;
      }),
    );
  }

  void _onFavoriteTap(int index) {
    if (index < 0 || index >= _items.length) return;
    final item = _items[index];
    final next = !item.favorited;
    setState(() => _items[index] = item.copyWith(favorited: next));
    unawaited(inject<PlaylistRepository>().toggleAuditionFavorite(item.id).then((either) {
      if (!mounted) return;
      either.fold((_) => setState(() => _items[index] = item), (_) {});
    }));
  }

  void _mergeSynced(List<Audition> fresh) {
    if (!mounted) return;
    setState(() {
      for (final a in fresh) {
        final i = _items.indexWhere((x) => x.id == a.id);
        if (i >= 0) _items[i] = a;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Sizning pleylistingiz",
          style: AppTextStyles.body20w7.copyWith(color: Colors.white, fontFamily: 'DancingScript', fontSize: 26.sp),
        ),
        SizedBox(height: 2.h),
        Text(
          "Kayfiyatingizga mos taronalar",
          style: AppTextStyles.body13w4.copyWith(color: Colors.white.withOpacity(0.6)),
        ),
        SizedBox(height: 14.h),
        if (_loadingInitial)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 32.h),
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
          )
        else if (_error != null)
          Text(_error!, style: AppTextStyles.body14w5.copyWith(color: Colors.white.withOpacity(0.6)))
        else ...[
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _items.length,
            separatorBuilder: (_, __) => SizedBox(height: 10.h),
            itemBuilder: (context, index) {
              final item = _items[index];
              final colors = _gradientPalette[index % _gradientPalette.length];
              void openAudio() {
                LastListenedManager.save(
                  prefs: inject<SharedPreferences>(),
                  title: item.text,
                  durationLabel: item.durationLabel,
                  audioUrl: item.fullAudioUrl,
                  formattedDuration: item.formattedDuration,
                );
                context.push(AudioScreen.routeName, extra: AudioScreenArgs(
                  title: item.text,
                  durationLabel: item.durationLabel,
                  audioUrl: item.fullAudioUrl,
                  auditionId: item.id,
                  auditionType: item.type,
                  durationSeconds: item.duration,
                  initialFavorited: item.favorited,
                  syncHomeAuditionsAfterFavorite: true,
                  onAuditionsSynced: _mergeSynced,
                ));
              }
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 320 + (index * 50)),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) => Opacity(
                  opacity: value,
                  child: Transform.translate(offset: Offset(0, (1 - value) * 14), child: child),
                ),
                child: GestureDetector(
                  onTap: openAudio,
                  child: AudioListTile(
                    title: item.text,
                    subtitle: item.durationLabel,
                    tag: item.formattedDuration,
                    duration: item.durationLabel,
                    colors: colors,
                    onTap: openAudio,
                    isFavorite: item.favorited,
                    onFavoriteTap: () => _onFavoriteTap(index),
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}
