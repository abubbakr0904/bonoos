import 'dart:async';
import 'dart:ui';
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
import 'package:bonoos/features/profile/security_service.dart';
import 'package:bonoos/features/profile/passcode_screen.dart';
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
    _checkPinSetup();
    _checkGiftStatus();
  }

  Future<void> _checkGiftStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final lastOpened = prefs.getString('gift_last_opened_date');
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (lastOpened == today) {
      if (mounted) setState(() => _giftOpenedToday = true);
    }
  }

  Future<void> _checkPinSetup() async {
    final prefs = await SharedPreferences.getInstance();
    final promptShown = prefs.getBool('pin_prompt_shown') ?? false;
    if (promptShown) return;

    final pinSet = await SecurityService.isPinSet();
    if (pinSet) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      
      final shouldSet = await showDialog<bool>(
        context: context,
        builder: (context) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Container(
              padding: EdgeInsets.all(28.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.mainBgColor.withValues(alpha: 0.95),
                    AppColors.c842D5F.withValues(alpha: 0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(32.r),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.lock_fill,
                      color: Colors.white,
                      size: 42.sp,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    "PIN-kod o'rnatilsinmi?",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body22w7.copyWith(
                      color: Colors.white,
                      fontFamily: 'DancingScript',
                      fontSize: 28.sp,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    "Ilovangiz xavfsizligini ta'minlash uchun 4 xonali PIN-kod o'rnatishni tavsiya qilamiz",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body14w4.copyWith(
                      color: Colors.white.withValues(alpha: 0.6),
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 32.h),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.1),
                            foregroundColor: Colors.white.withValues(alpha: 0.7),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                              side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                            ),
                          ),
                          child: Text(
                            "Keyinroq",
                            style: AppTextStyles.body15w5,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.c842D5F.withValues(alpha: 0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.mainBgColor,
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                            ),
                            child: Text(
                              "O'rnatish",
                              style: AppTextStyles.body15w7.copyWith(
                                color: AppColors.mainBgColor,
                              ),
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
      );

      await prefs.setBool('pin_prompt_shown', true);
      
      if (shouldSet == true && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PasscodeScreen(mode: PasscodeMode.setup)),
        );
      }
    });
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
      MaterialPageRoute(builder: (_) => ProfileScreen()),
    );
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
                  isDisabled: _giftOpenedToday,
                  onTap: () async {
                    if (_giftOpenedToday) return;
                    final prefs = await SharedPreferences.getInstance();
                    final today = DateTime.now().toIso8601String().substring(0, 10);
                    
                    if (context.mounted) {
                      context.push(MessageOfDayScreen.routeName).then((_) {
                        prefs.setString('gift_last_opened_date', today);
                        if (mounted) setState(() => _giftOpenedToday = true);
                      });
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 12.h),
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
                curve: const Interval(0.22, 0.65, curve: Curves.easeOutCubic),
              ),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.10),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _entryController,
                    curve: const Interval(0.22, 0.65, curve: Curves.easeOutCubic),
                  ),
                ),
                child: const _MoodSliderCard(),
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

class _MoodSliderCard extends StatefulWidget {
  const _MoodSliderCard({super.key});

  @override
  State<_MoodSliderCard> createState() => _MoodSliderCardState();
}

class _MoodSliderCardState extends State<_MoodSliderCard> {
  double _sliderValue = 3;
  bool _isSaving = false;
  bool _showSuccess = false;
  bool _moodSubmittedToday = false;

  @override
  void initState() {
    super.initState();
    _checkMoodStatus();
  }

  Future<void> _checkMoodStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSubmitted = prefs.getString('mood_last_submitted_date');
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (lastSubmitted == today) {
      if (mounted) setState(() => _moodSubmittedToday = true);
    }
  }

  Future<void> _submitMood(int moodValue) async {
    if (_moodSubmittedToday || _isSaving) return;
    setState(() => _isSaving = true);
    try {
      final dio = inject<DioClient>();
      await dio.post(
        ListAPI.clientGratitudeDiaryMood,
        data: {'mood': moodValue},
      );
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().substring(0, 10);
      await prefs.setString('mood_last_submitted_date', today);

      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _showSuccess = true;
      });

      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _showSuccess = false;
            _moodSubmittedToday = true;
          });
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kayfiyat saqlanmadi, internet aloqasini tekshiring.')),
      );
    }
  }

  String _getEmoji(double value) {
    if (value == 1) return '😔';
    if (value == 2) return '😕';
    if (value == 3) return '😐';
    if (value == 4) return '🙂';
    return '🤩';
  }

  String _getLabel(double value) {
    if (value == 1) return 'Yomon';
    if (value == 2) return 'Yomonroq';
    if (value == 3) return 'Oddiy';
    if (value == 4) return 'Yaxshi';
    return "Zo'r";
  }

  @override
  Widget build(BuildContext context) {
    if (_moodSubmittedToday) {
      return const SizedBox.shrink();
    }

    if (_showSuccess) {
      return ZoomIn(
        duration: const Duration(milliseconds: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElasticIn(
              child: Container(
                height: 48.w,
                width: 48.w,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                ),
                child: Icon(CupertinoIcons.checkmark_alt, color: Colors.white, size: 24.sp),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Saqlandi! ✨",
              style: AppTextStyles.body14w6.copyWith(color: Colors.white),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Bugungi kayfiyatingiz qanday?  ${_getEmoji(_sliderValue)} ${_getLabel(_sliderValue)}",
              style: AppTextStyles.body14w5.copyWith(color: Colors.white.withOpacity(0.9)),
            ),
            if (_isSaving) ...[
              SizedBox(width: 8.w),
              SizedBox(
                width: 14.w,
                height: 14.w,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 1.5,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 8.h),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: Colors.white.withOpacity(0.8),
            inactiveTrackColor: Colors.white.withOpacity(0.15),
            thumbColor: Colors.white,
            overlayColor: Colors.white.withOpacity(0.1),
            trackHeight: 4.h,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            activeTickMarkColor: Colors.transparent,
            inactiveTickMarkColor: Colors.transparent,
          ),
          child: Slider(
            value: _sliderValue,
            min: 1,
            max: 5,
            divisions: 4,
            onChanged: _isSaving
                ? null
                : (val) {
                    setState(() {
                      _sliderValue = val;
                    });
                  },
            onChangeEnd: _isSaving
                ? null
                : (val) {
                    _submitMood(val.toInt());
                  },
          ),
        ),
        SizedBox(height: 4.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSmallTick('😔', 1),
              _buildSmallTick('😕', 2),
              _buildSmallTick('😐', 3),
              _buildSmallTick('🙂', 4),
              _buildSmallTick('🤩', 5),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSmallTick(String emoji, double stepValue) {
    final isSelected = _sliderValue == stepValue;
    return GestureDetector(
      onTap: _isSaving
          ? null
          : () {
              setState(() {
                _sliderValue = stepValue;
              });
              _submitMood(stepValue.toInt());
            },
      child: AnimatedScale(
        scale: isSelected ? 1.25 : 0.9,
        duration: const Duration(milliseconds: 200),
        child: AnimatedOpacity(
          opacity: isSelected ? 1.0 : 0.4,
          duration: const Duration(milliseconds: 200),
          child: Text(
            emoji,
            style: TextStyle(fontSize: 16.sp),
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
  const _DailyGiftCard({required this.onTap, this.isDisabled = false});

  final VoidCallback onTap;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
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
                child: Icon(isDisabled ? CupertinoIcons.checkmark_alt : CupertinoIcons.gift_fill, color: Colors.white, size: 28.sp),
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
                      isDisabled ? "Har bir kun uchun alohida sovg'a oling" : "Siz uchun maxsus motivatsiya",
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
  List<Category> _categories = [];
  int _selectedCategoryIndex = -1; // -1 means "Barchasi" (All)
  bool _categoriesLoading = true;
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
    _loadCategoriesAndInitial();
  }

  Future<void> _loadCategoriesAndInitial() async {
    if (!mounted) return;
    setState(() {
      _categoriesLoading = true;
      _loadingInitial = true;
      _error = null;
      _items.clear();
      _nextOffset = 0;
      _hasMore = true;
    });

    final catsResult = await inject<PlaylistRepository>().fetchCategories();
    List<Category> loadedCats = [];
    catsResult.fold(
      (_) {},
      (cats) => loadedCats = cats,
    );

    final auditionsResult = await inject<PlaylistRepository>().fetchAuditionsPage(limit: _pageSize, offset: 0);
    
    if (!mounted) return;

    setState(() {
      _categoriesLoading = false;
      _categories = loadedCats;
      
      auditionsResult.fold(
        (f) {
          _loadingInitial = false;
          _error = f.message ?? 'Xatolik';
        },
        (page) {
          _loadingInitial = false;
          _error = null;
          _items.addAll(page.items);
          _nextOffset = page.offset + page.items.length;
          _hasMore = page.hasMore;
        },
      );
    });
  }

  Future<void> _selectCategory(int index) async {
    if (index == _selectedCategoryIndex) return;
    setState(() {
      _selectedCategoryIndex = index;
      _loadingInitial = true;
      _error = null;
      _items.clear();
    });

    if (index == -1) {
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
    } else {
      final catId = _categories[index].id;
      final r = await inject<PlaylistRepository>().fetchAuditions(catId);
      if (!mounted) return;
      r.fold(
        (f) => setState(() {
          _loadingInitial = false;
          _error = f.message ?? 'Xatolik';
        }),
        (list) => setState(() {
          _loadingInitial = false;
          _error = null;
          _items.addAll(list);
          _hasMore = false;
        }),
      );
    }
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

  Widget _buildCategoriesRow() {
    if (_categoriesLoading) {
      return Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Row(
            children: List.generate(4, (i) {
              return Container(
                margin: EdgeInsets.only(right: 8.w),
                width: 80.w,
                height: 32.h,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(999),
                ),
              );
            }),
          ),
        ),
      );
    }

    if (_categories.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _selectCategory(-1),
              child: _buildCategoryChip(
                label: "Barchasi",
                selected: _selectedCategoryIndex == -1,
              ),
            ),
            SizedBox(width: 8.w),
            ...List.generate(_categories.length, (index) {
              final cat = _categories[index];
              final selected = index == _selectedCategoryIndex;
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: GestureDetector(
                  onTap: () => _selectCategory(index),
                  child: _buildCategoryChip(
                    label: cat.name,
                    selected: selected,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip({required String label, required bool selected}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: selected
            ? Colors.white.withValues(alpha: 0.16)
            : Colors.white.withValues(alpha: 0.06),
        border: Border.all(
          color: selected
              ? Colors.white.withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.body12w5.copyWith(
          color: selected
              ? Colors.white.withValues(alpha: 0.95)
              : Colors.white.withValues(alpha: 0.65),
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
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
        _buildCategoriesRow(),
        if (_loadingInitial)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 32.h),
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
          )
        else if (_error != null)
          Text(_error!, style: AppTextStyles.body14w5.copyWith(color: Colors.white.withOpacity(0.6)))
        else if (_items.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 40.h),
            child: Center(
              child: Text(
                'Bu ruknda hozircha audio yo\'q',
                style: AppTextStyles.body13w5.copyWith(color: Colors.white.withOpacity(0.5)),
              ),
            ),
          )
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
