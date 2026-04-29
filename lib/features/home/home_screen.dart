import 'dart:async';

import 'package:bonoos/core/utils/last_listened_manager.dart';
import 'package:bonoos/core/values/app_colors.dart';
import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:bonoos/di.dart';
import 'package:bonoos/features/common/widget/audio_list_tile.dart';
import 'package:bonoos/features/common/widget/home_gradient_background.dart';
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

  void _toggleChallenge() => setState(() => _expanded = !_expanded);

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF140B2A),
      body: Stack(
        children: [
          HomeGradientBackground(),
          SafeArea(
            child: ListView(
              controller: _homeScroll,
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 22.h),
              children: [
                _Header(
                  expanded: _expanded,
                  profile: _profile,
                  onAvatarTap: _goToProfile,
                  onChevronTap: _toggleChallenge,
                  onNotificationTap: () =>
                      context.push(NotificationsScreen.routeName),
                ),
                SizedBox(height: 12.h),
                SizedBox(height: 14.h),
                const _MessageOfDayCard(),
                SizedBox(height: 14.h),
                const WeeklyListeningChartCard(
                  title: "Weekly listening (minutes)",
                  subtitle: "Static demo data",
                  values: [0, 6, 12, 8, 16, 10, 14],
                  labels: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
                ),
                SizedBox(height: 18.h),
                const _HomePlaylistFromPlaylistSection(),
                SizedBox(height: 22.h),
              ],
            ),
          ),
        ],
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
                  height: 46.w,
                  width: 46.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.c842D5F, AppColors.c55004D],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x2A842D5F),
                        blurRadius: 18,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: avatarUrl,
                      width: 46.w,
                      height: 46.w,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Center(
                        child: Icon(CupertinoIcons.person,
                            color: Colors.white, size: 22),
                      ),
                      errorWidget: (_, __, ___) => Center(
                        child: Icon(CupertinoIcons.person,
                            color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                )
              : Container(
                  height: 46.w,
                  width: 46.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.c842D5F, AppColors.c55004D],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x2A842D5F),
                        blurRadius: 18,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(CupertinoIcons.person,
                        color: Colors.white, size: 22),
                  ),
                ),
        ),
        SizedBox(width: 12.w),
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
                  style: AppTextStyles.body20w7
                      .copyWith(color: Colors.white.withValues(alpha: 0.95)),
                ),
                SizedBox(height: 2.h),
                Text(
                  "Bugungi challengeni boshlang!",
                  style: AppTextStyles.body14w4.copyWith(
                    color: Colors.white.withValues(alpha: 0.70),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _HeaderActionTile(
              onTap: onNotificationTap,
              child: Icon(
                CupertinoIcons.bell_fill,
                size: 21.sp,
                color: Colors.white.withValues(alpha: 0.92),
              ),
            ),
            // SizedBox(width: 10.w),
            // _HeaderActionTile(
            //   onTap: onChevronTap,
            //   emphasize: false,
            //   child: AnimatedRotation(
            //     duration: const Duration(milliseconds: 260),
            //     curve: Curves.easeOutCubic,
            //     turns: expanded ? 0.5 : 0,
            //     child: Icon(
            //       CupertinoIcons.chevron_down,
            //       size: 18.sp,
            //       color: Colors.white.withValues(alpha: 0.72),
            //     ),
            //   ),
            // ),
          ],
        ),
      ],
    );
  }
}

/// Bir xil o‘lcham va uslub — qo‘ng‘iroq va chevron tekis, oraliq aniq.
class _HeaderActionTile extends StatelessWidget {
  const _HeaderActionTile({
    required this.onTap,
    required this.child,
    this.emphasize = true,
  });

  final VoidCallback onTap;
  final Widget child;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final side = 44.w;
    final radius = BorderRadius.circular(13.r);
    return SizedBox(
      width: side,
      height: side,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: radius,
              color: emphasize
                  ? Colors.white.withValues(alpha: 0.09)
                  : Colors.white.withValues(alpha: 0.055),
              border: Border.all(
                color: emphasize
                    ? Colors.white.withValues(alpha: 0.14)
                    : Colors.white.withValues(alpha: 0.10),
              ),
            ),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard();

  @override
  Widget build(BuildContext context) {
    const primary = AppColors.c842D5F;
    const primaryDark = AppColors.c55004D;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.r),
        color: Colors.white.withValues(alpha: 0.06),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x20842D5F),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 14.h),
            child: Text(
              "Start meditating and we’ll mark the days completed in the tracker.",
              style: AppTextStyles.body14w4.copyWith(
                color: Colors.white.withValues(alpha: 0.72),
                height: 1.45,
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    primary.withValues(alpha: 0.88),
                    primaryDark.withValues(alpha: 0.88),
                  ],
                ),
              ),
              child: Center(
                child: Text(
                  "Start the challenge",
                  style:
                      AppTextStyles.body16w7.copyWith(color: AppColors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageOfDayCard extends StatelessWidget {
  const _MessageOfDayCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          context.push(MessageOfDayScreen.routeName, extra: UniqueKey()),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22.r),
          color: Colors.white.withValues(alpha: 0.06),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x20842D5F),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                "Bonoo\$ ilovasi \nkun sovg'asi",
                style: AppTextStyles.body20w7.copyWith(
                  color: Colors.white.withValues(alpha: 0.95),
                  height: 1.05,
                ),
              ),
            ),
            Container(
              height: 42.w,
              width: 42.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.10),
              ),
              child: Center(
                child: Icon(
                  CupertinoIcons.cube_box,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandableChallenge extends StatelessWidget {
  const _ExpandableChallenge({required this.expanded});
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22.r),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        heightFactor: expanded ? 1 : 0,
        child: Padding(
          padding: EdgeInsets.only(bottom: 2.h),
          child: const _ChallengeCard(),
        ),
      ),
    );
  }
}

class _HomePlaylistFromPlaylistSection extends StatefulWidget {
  const _HomePlaylistFromPlaylistSection();

  @override
  State<_HomePlaylistFromPlaylistSection> createState() =>
      _HomePlaylistFromPlaylistSectionState();
}

class _HomePlaylistFromPlaylistSectionState
    extends State<_HomePlaylistFromPlaylistSection> {
  bool _categoriesLoading = true;
  String? _categoriesError;
  List<Category> _categories = [];
  int _selectedIndex = 0;

  bool _auditionsLoading = false;
  String? _auditionsError;
  List<Audition> _auditions = [];

  static const _gradientPalette = <List<Color>>[
    [Color(0xFFB77BCB), Color(0xFF8F5FB0)],
    [Color(0xFFA883CF), Color(0xFF6F5AB6)],
    [Color(0xFFC78DB7), Color(0xFF8C66A7)],
    [Color(0xFF8A8CD6), Color(0xFF5F6BB8)],
    [Color(0xFFD27DA8), Color(0xFF9A5B90)],
    [Color(0xFFC48ABF), Color(0xFF7A5AA0)],
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _categoriesLoading = true;
      _categoriesError = null;
    });
    final result = await inject<PlaylistRepository>().fetchCategories();
    if (!mounted) return;
    result.fold(
      (f) => setState(() {
        _categoriesLoading = false;
        _categoriesError = f.message ?? 'Xatolik';
      }),
      (cats) {
        setState(() {
          _categoriesLoading = false;
          _categories = cats;
          _selectedIndex = 0;
        });
        if (cats.isNotEmpty) {
          _loadAuditions(cats.first.id);
        }
      },
    );
  }

  Future<void> _loadAuditions(int categoryId) async {
    setState(() {
      _auditionsLoading = true;
      _auditionsError = null;
      _auditions = [];
    });
    final result =
        await inject<PlaylistRepository>().fetchAuditions(categoryId);
    if (!mounted) return;
    result.fold(
      (f) => setState(() {
        _auditionsLoading = false;
        _auditionsError = f.message ?? 'Xatolik';
      }),
      (list) => setState(() {
        _auditionsLoading = false;
        _auditionsError = null;
        _auditions = list;
      }),
    );
  }

  void _onCategorySelected(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
    if (index < _categories.length) {
      _loadAuditions(_categories[index].id);
    }
  }

  void _onFavoriteTapAudition(int index) {
    if (index < 0 || index >= _auditions.length) return;
    final item = _auditions[index];
    final next = !item.favorited;
    setState(() {
      _auditions = List<Audition>.from(_auditions);
      _auditions[index] = item.copyWith(favorited: next);
    });
    unawaited(
      inject<PlaylistRepository>()
          .toggleAuditionFavorite(item.id)
          .then((either) {
        if (!mounted) return;
        either.fold(
          (_) => setState(() {
            _auditions = List<Audition>.from(_auditions);
            _auditions[index] = item;
          }),
          (_) {},
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_categoriesLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Center(
          child: SizedBox(
            width: 26.w,
            height: 26.w,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
        ),
      );
    }

    if (_categoriesError != null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _categoriesError!,
              style: AppTextStyles.body14w5.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            TextButton(
              onPressed: _loadCategories,
              child: Text(
                'Qayta urinish',
                style: AppTextStyles.body14w6.copyWith(
                  color: AppColors.c842D5F,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final selectedCategoryName = _selectedIndex < _categories.length
        ? _categories[_selectedIndex].name
        : '';
    final selectedCategoryId = _selectedIndex < _categories.length
        ? _categories[_selectedIndex].id
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(_categories.length, (index) {
              final selected = index == _selectedIndex;
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: GestureDetector(
                  onTap: () => _onCategorySelected(index),
                  child: _HomeCategoryChip(
                    label: _categories[index].name,
                    selected: selected,
                  ),
                ),
              );
            }),
          ),
        ),
        SizedBox(height: 12.h),
        if (_auditionsLoading)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: Center(
              child: SizedBox(
                width: 24.w,
                height: 24.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white.withValues(alpha: 0.45),
                ),
              ),
            ),
          )
        else if (_auditionsError != null)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _auditionsError!,
                  style: AppTextStyles.body14w5.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (selectedCategoryId != null) {
                      _loadAuditions(selectedCategoryId);
                    }
                  },
                  child: Text(
                    'Qayta urinish',
                    style: AppTextStyles.body14w6.copyWith(
                      color: AppColors.c842D5F,
                    ),
                  ),
                ),
              ],
            ),
          )
        else if (_auditions.isEmpty)
          Padding(
            padding: EdgeInsets.only(top: 8.h, bottom: 6.h),
            child: Text(
              "Bu kategoriyada hozircha audio yo'q",
              style: AppTextStyles.body13w5.copyWith(
                color: Colors.white.withValues(alpha: 0.55),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _auditions.length,
            separatorBuilder: (_, __) => SizedBox(height: 10.h),
            itemBuilder: (context, index) {
              final item = _auditions[index];
              final colors = _gradientPalette[index % _gradientPalette.length];
              return AudioListTile(
                title: item.text,
                subtitle: selectedCategoryName,
                tag: item.formattedDuration,
                duration: item.durationLabel,
                colors: colors,
                onTap: () {
                  LastListenedManager.save(
                    prefs: inject<SharedPreferences>(),
                    title: item.text,
                    durationLabel: item.durationLabel,
                    audioUrl: item.fullAudioUrl,
                    formattedDuration: item.formattedDuration,
                  );
                  context.push(
                    AudioScreen.routeName,
                    extra: AudioScreenArgs(
                      title: item.text,
                      durationLabel: item.durationLabel,
                      audioUrl: item.fullAudioUrl,
                      auditionId: item.id,
                      auditionType: item.type,
                      durationSeconds: item.duration,
                      initialFavorited: item.favorited,
                    ),
                  );
                },
                isFavorite: item.favorited,
                onFavoriteTap: () => _onFavoriteTapAudition(index),
              );
            },
          ),
      ],
    );
  }
}

class _HomeCategoryChip extends StatelessWidget {
  const _HomeCategoryChip({
    required this.label,
    this.selected = false,
  });

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: selected
            ? Colors.white.withValues(alpha: 0.14)
            : Colors.white.withValues(alpha: 0.06),
        border: Border.all(
          color: selected
              ? Colors.white.withValues(alpha: 0.14)
              : Colors.white.withValues(alpha: 0.10),
        ),
        boxShadow: selected
            ? const [
                BoxShadow(
                  color: Color(0x20842D5F),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Text(
        label,
        style: AppTextStyles.body12w5.copyWith(
          color: selected
              ? Colors.white.withValues(alpha: 0.92)
              : Colors.white.withValues(alpha: 0.70),
        ),
      ),
    );
  }
}

/// Abumarket bannerlar (`ListAPI.abuMarketBaseUrl` + `.../banners/all?type=1`) — asosiy `BASE_URL` dan mustaqil.
class _HomeBannersCarousel extends StatefulWidget {
  const _HomeBannersCarousel();

  @override
  State<_HomeBannersCarousel> createState() => _HomeBannersCarouselState();
}

class _HomeBannersCarouselState extends State<_HomeBannersCarousel> {
  final PageController _pageController = PageController();
  List<ClientBannerDto> _items = [];
  bool _loading = true;
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final r = await inject<BannersRepository>().fetchAbuMarketBanners();
    if (!mounted) return;
    r.fold(
      (_) => setState(() {
        _loading = false;
        _items = [];
      }),
      (list) => setState(() {
        _loading = false;
        _items = list;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return SizedBox(
        height: 132.h,
        child: Center(
          child: SizedBox(
            width: 26.w,
            height: 26.w,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
        ),
      );
    }
    if (_items.isEmpty) return const SizedBox.shrink();

    final locale = Localizations.localeOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: SizedBox(
            height: 132.h,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _items.length,
              onPageChanged: (i) => setState(() => _pageIndex = i),
              itemBuilder: (context, i) {
                final url = _items[i].imageUrlForLocale(locale);
                if (url.isEmpty) {
                  return ColoredBox(
                      color: Colors.white.withValues(alpha: 0.06));
                }
                return CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      ColoredBox(color: Colors.white.withValues(alpha: 0.06)),
                  errorWidget: (_, __, ___) =>
                      ColoredBox(color: Colors.white.withValues(alpha: 0.06)),
                );
              },
            ),
          ),
        ),
        if (_items.length > 1) ...[
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_items.length, (i) {
              final active = i == _pageIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                width: active ? 18.w : 6.w,
                height: 6.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(99),
                  color: active
                      ? AppColors.c842D5F.withValues(alpha: 0.95)
                      : Colors.white.withValues(alpha: 0.22),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class _BreathingCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          final card = Container(
            width: 210.w,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22.r),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: index == 0
                    ? [
                        AppColors.c842D5F.withValues(alpha: 0.82),
                        AppColors.c55004D.withValues(alpha: 0.82),
                      ]
                    : index == 1
                        ? [
                            AppColors.c30215A.withValues(alpha: 0.82),
                            AppColors.c55004D.withValues(alpha: 0.82),
                          ]
                        : [
                            AppColors.c55004D.withValues(alpha: 0.82),
                            AppColors.c842D5F.withValues(alpha: 0.82),
                          ],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x24842D5F),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 44.w,
                  width: 44.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0x1EFFFFFF),
                  ),
                  child: const Center(
                    child: Icon(CupertinoIcons.wind,
                        color: Colors.white, size: 20),
                  ),
                ),
                const Spacer(),
                Text(
                  index == 0
                      ? "Breathing\npractices"
                      : index == 1
                          ? "Shall we take a\nwalk by the sea?"
                          : "A\nfocus",
                  style: AppTextStyles.body20w7
                      .copyWith(color: AppColors.white, height: 1.05),
                ),
                SizedBox(height: 8.h),
                Text(
                  "15 minutes",
                  style: AppTextStyles.body12w6
                      .copyWith(color: const Color(0xCCFFFFFF)),
                ),
              ],
            ),
          );

          if (index == 0) {
            return GestureDetector(
              onTap: () => context.push(BreathingPracticesScreen.routeName),
              child: card,
            );
          }

          return card;
        },
      ),
    );
  }
}

class _AudioPlaylistSection extends StatefulWidget {
  const _AudioPlaylistSection({required this.scrollController});

  final ScrollController scrollController;

  @override
  State<_AudioPlaylistSection> createState() => _AudioPlaylistSectionState();
}

class _AudioPlaylistSectionState extends State<_AudioPlaylistSection> {
  static const int _pageSize = 20;

  static const List<List<Color>> _gradientPalette = [
    [Color(0xFFB77BCB), Color(0xFF8F5FB0)],
    [Color(0xFFA883CF), Color(0xFF6F5AB6)],
    [Color(0xFFC78DB7), Color(0xFF8C66A7)],
    [Color(0xFF8A8CD6), Color(0xFF5F6BB8)],
    [Color(0xFFD27DA8), Color(0xFF9A5B90)],
    [Color(0xFFC48ABF), Color(0xFF7A5AA0)],
  ];

  final List<Audition> _items = [];
  bool _loadingInitial = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  String? _error;
  int _nextOffset = 0;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
    _loadInitial();
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (!widget.scrollController.hasClients) return;
    if (_loadingInitial || _loadingMore || !_hasMore) return;
    final pos = widget.scrollController.position;
    if (pos.pixels + 380 >= pos.maxScrollExtent) {
      _loadMore();
    }
  }

  Future<void> _loadInitial() async {
    setState(() {
      _loadingInitial = true;
      _error = null;
      _items.clear();
      _nextOffset = 0;
      _hasMore = true;
    });
    final r = await inject<PlaylistRepository>().fetchAuditionsPage(
      limit: _pageSize,
      offset: 0,
    );
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

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    final r = await inject<PlaylistRepository>().fetchAuditionsPage(
      limit: _pageSize,
      offset: _nextOffset,
    );
    if (!mounted) return;
    r.fold(
      (_) => setState(() => _loadingMore = false),
      (page) => setState(() {
        _loadingMore = false;
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
    setState(() {
      _items[index] = item.copyWith(favorited: next);
    });
    unawaited(
      inject<PlaylistRepository>()
          .toggleAuditionFavorite(item.id)
          .then((either) {
        if (!mounted) return;
        either.fold(
          (_) => setState(() => _items[index] = item),
          (_) {},
        );
      }),
    );
  }

  void _mergeSynced(List<Audition> fresh) {
    if (!mounted) return;
    setState(() {
      for (final a in fresh) {
        final i = _items.indexWhere((x) => x.id == a.id);
        if (i >= 0) {
          _items[i] = a;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Your playlist",
          style: AppTextStyles.body20w7
              .copyWith(color: Colors.white.withValues(alpha: 0.95)),
        ),
        SizedBox(height: 2.h),
        Text(
          "Soft sessions for your mood",
          style: AppTextStyles.body13w4.copyWith(
            color: Colors.white.withValues(alpha: 0.70),
          ),
        ),
        SizedBox(height: 10.h),
        if (_loadingInitial)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 24.h),
            child: Center(
              child: SizedBox(
                width: 28.w,
                height: 28.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ),
          )
        else if (_error != null)
          Padding(
            padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _error!,
                  style: AppTextStyles.body14w5.copyWith(
                    color: Colors.white.withValues(alpha: 0.65),
                  ),
                ),
                TextButton(
                  onPressed: _loadInitial,
                  child: Text(
                    'Qayta urinish',
                    style: AppTextStyles.body14w6.copyWith(
                      color: AppColors.c842D5F,
                    ),
                  ),
                ),
              ],
            ),
          )
        else if (_items.isEmpty)
          Padding(
            padding: EdgeInsets.only(top: 16.h, bottom: 8.h),
            child: Text(
              'Hozircha audio yo‘q',
              style: AppTextStyles.body14w5.copyWith(
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          )
        else ...[
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _items.length,
            separatorBuilder: (_, __) => SizedBox(height: 8.h),
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
                context.push(
                  AudioScreen.routeName,
                  extra: AudioScreenArgs(
                    title: item.text,
                    durationLabel: item.durationLabel,
                    audioUrl: item.fullAudioUrl,
                    auditionId: item.id,
                    auditionType: item.type,
                    durationSeconds: item.duration,
                    initialFavorited: item.favorited,
                    syncHomeAuditionsAfterFavorite: true,
                    onAuditionsSynced: _mergeSynced,
                  ),
                );
              }

              return GestureDetector(
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
              );
            },
          ),
          if (_loadingMore)
            Padding(
              padding: EdgeInsets.only(top: 12.h, bottom: 8.h),
              child: Center(
                child: SizedBox(
                  width: 22.w,
                  height: 22.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white.withValues(alpha: 0.45),
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }
}
