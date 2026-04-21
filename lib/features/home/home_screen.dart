import 'dart:async';

import 'package:bonoos/core/utils/last_listened_manager.dart';
import 'package:bonoos/core/values/app_colors.dart';
import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:bonoos/di.dart';
import 'package:bonoos/features/common/widget/audio_list_tile.dart';
import 'package:bonoos/features/common/widget/home_gradient_background.dart';
import 'package:bonoos/features/breath/breathing_practices_screen.dart';
import 'package:bonoos/features/home/audio_screen.dart';
import 'package:bonoos/features/home/message_of_day_screen.dart';
import 'package:bonoos/features/home/self_talk_topics_screen.dart';
import 'package:bonoos/features/notification/notifications_screen.dart';
import 'package:bonoos/features/playlist/domain/entity/audition.dart';
import 'package:bonoos/features/playlist/domain/repository/playlist_repository.dart';
import 'package:bonoos/features/profile/domain/entity/client_profile.dart';
import 'package:bonoos/features/profile/domain/repository/profile_repository.dart';
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
    TabBoxController.instance.setIndex(4);
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
                  onNotificationTap: () => context.push(NotificationsScreen.routeName),
                ),
                SizedBox(height: 12.h),
                _ExpandableChallenge(expanded: _expanded),
                SizedBox(height: 16.h),
                const _MessageOfDayCard(),
                SizedBox(height: 14.h),
                const _SelfTalkCard(),
                SizedBox(height: 22.h),
                Text(
                  "Breathing practices",
                  style: AppTextStyles.body20w7.copyWith(color: Colors.white.withValues(alpha: 0.95)),
                ),
                SizedBox(height: 12.h),
                _BreathingCards(),
                SizedBox(height: 18.h),
                _AudioPlaylistSection(scrollController: _homeScroll),
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
                        child: Icon(CupertinoIcons.person, color: Colors.white, size: 22),
                      ),
                      errorWidget: (_, __, ___) => Center(
                        child: Icon(CupertinoIcons.person, color: Colors.white, size: 22),
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
                    child: Icon(CupertinoIcons.person, color: Colors.white, size: 22),
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
                  style: AppTextStyles.body20w7.copyWith(color: Colors.white.withValues(alpha: 0.95)),
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
            SizedBox(width: 10.w),
            _HeaderActionTile(
              onTap: onChevronTap,
              emphasize: false,
              child: AnimatedRotation(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                turns: expanded ? 0.5 : 0,
                child: Icon(
                  CupertinoIcons.chevron_down,
                  size: 18.sp,
                  color: Colors.white.withValues(alpha: 0.72),
                ),
              ),
            ),
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
                  style: AppTextStyles.body16w7.copyWith(color: AppColors.white),
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
      onTap: () => context.push(MessageOfDayScreen.routeName, extra: UniqueKey()),
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
                "Open up\nmessage of the day",
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

/// Ichki suhbat / o‘z-o‘ziga muloyimlik — home uchun ilhom kartochkasi.
class _SelfTalkCard extends StatelessWidget {
  const _SelfTalkCard();

  static const _accent = Color(0xFFE8B4C8);
  static const _accentSoft = Color(0x66E8B4C8);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(SelfTalkTopicsScreen.routeName),
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x18842D5F),
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF2A1538).withValues(alpha: 0.95),
                    AppColors.c30215A.withValues(alpha: 0.55),
                    const Color(0xFF1A0F28).withValues(alpha: 0.9),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            right: -20.w,
            top: -24.h,
            child: IgnorePointer(
              child: Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _accentSoft,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14.r),
                        color: Colors.white.withValues(alpha: 0.08),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Icon(
                        CupertinoIcons.bubble_left_bubble_right_fill,
                        color: _accent.withValues(alpha: 0.95),
                        size: 22.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'O‘zing bilan suhbat',
                            style: AppTextStyles.body18w6.copyWith(
                              color: Colors.white.withValues(alpha: 0.96),
                              height: 1.2,
                              letterSpacing: -0.3,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'ichki tinchlik · har kuni bir qadam',
                            style: AppTextStyles.body12w4.copyWith(
                              color: _accent.withValues(alpha: 0.75),
                              letterSpacing: 0.15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Container(
                  width: 36.w,
                  height: 2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: LinearGradient(
                      colors: [
                        _accent.withValues(alpha: 0.9),
                        _accent.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 14.h),
                Text(
                  'Ichki ovozing — eng yaqin suhbatdoshing. Uni ayblamasdan tingla; muloyim gaplar o‘zingga qaytgan sayin, yengillasasan.',
                  style: AppTextStyles.body14w4.copyWith(
                    color: Colors.white.withValues(alpha: 0.78),
                    height: 1.55,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  '«Bugun o‘zimga nima deb ayta olaman?» — shu savol bilan boshla.',
                  style: AppTextStyles.body13w5.copyWith(
                    color: Colors.white.withValues(alpha: 0.55),
                    height: 1.45,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
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
                    child: Icon(CupertinoIcons.wind, color: Colors.white, size: 20),
                  ),
                ),
                const Spacer(),
                Text(
                  index == 0 ? "Breathing\npractices" : index == 1 ? "Shall we take a\nwalk by the sea?" : "A\nfocus",
                  style: AppTextStyles.body20w7.copyWith(color: AppColors.white, height: 1.05),
                ),
                SizedBox(height: 8.h),
                Text(
                  "15 minutes",
                  style: AppTextStyles.body12w6.copyWith(color: const Color(0xCCFFFFFF)),
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
      inject<PlaylistRepository>().toggleAuditionFavorite(item.id).then((either) {
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
          style: AppTextStyles.body20w7.copyWith(color: Colors.white.withValues(alpha: 0.95)),
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

