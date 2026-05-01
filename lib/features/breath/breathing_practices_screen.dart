import 'dart:async';

import 'package:bonoos/core/values/app_colors.dart';
import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:bonoos/di.dart';
import 'package:bonoos/features/breath/breath_session_screen.dart';
import 'package:bonoos/features/common/widget/audio_list_tile.dart';
import 'package:bonoos/features/home/audio_screen.dart';
import 'package:bonoos/features/playlist/domain/entity/audition.dart';
import 'package:bonoos/features/playlist/domain/repository/playlist_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class BreathingPracticesScreen extends StatefulWidget {
  const BreathingPracticesScreen({
    super.key,
    this.openFavoritesOnStart = false,
  });

  static const String routeName = "/breathing_practices";
  final bool openFavoritesOnStart;

  @override
  State<BreathingPracticesScreen> createState() =>
      _BreathingPracticesScreenState();
}

class _BreathingPracticesScreenState extends State<BreathingPracticesScreen>
    with SingleTickerProviderStateMixin {
  /// 0 = Meditations, 1 = Melodies, 2 = Zen meditation, 3 = Breath
  int _filterIndex = 3;
  int _selectedCardIndex = 0; // 4 tadan 1 tasi select
  bool _showFavorites = false;
  bool _favoritesLoading = false;
  String? _favoritesError;
  List<Audition> _favoriteAuditions = const [];
  late final AnimationController _cardsEntryController;

  @override
  void initState() {
    super.initState();
    _cardsEntryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    if (widget.openFavoritesOnStart) {
      _showFavorites = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_loadFavoriteAuditions());
      });
    }
  }

  Future<void> _onFavoritesTap() async {
    final next = !_showFavorites;
    setState(() {
      _showFavorites = next;
      _selectedCardIndex = 0;
      if (next) _favoritesError = null;
    });
    if (!next) return;
    await _loadFavoriteAuditions();
  }

  Future<void> _loadFavoriteAuditions() async {
    setState(() {
      _favoritesLoading = true;
      _favoritesError = null;
    });
    final result = await inject<PlaylistRepository>().fetchFavoriteAuditions();
    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _favoritesLoading = false;
        _favoritesError = failure.message ?? 'Xatolik';
      }),
      (items) => setState(() {
        _favoritesLoading = false;
        _favoritesError = null;
        _favoriteAuditions = items;
      }),
    );
  }

  @override
  void dispose() {
    _cardsEntryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.c30215A,
              AppColors.c55004D,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.h),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(
                        CupertinoIcons.back,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  "Meditations and melodies",
                  style: AppTextStyles.body24w7.copyWith(
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 18.h),
                _TopSegmented(
                  selectedIndex: _filterIndex,
                  showFavorites: _showFavorites,
                  onFavoritesTap: () => unawaited(_onFavoritesTap()),
                  onChanged: (i) => setState(() {
                    _filterIndex = i;
                    _selectedCardIndex = 0;
                    _showFavorites = false;
                  }),
                ),
                SizedBox(height: 12.h),
                _CategoryChips(
                  selectedIndex: _filterIndex,
                  onChanged: (i) => setState(() {
                    _filterIndex = i;
                    _selectedCardIndex = 0;
                    _showFavorites = false;
                  }),
                ),
                SizedBox(height: 18.h),
                Expanded(
                  child: _BreathingList(
                    entryAnimation: _cardsEntryController,
                    categoryIndex: _filterIndex,
                    showFavorites: _showFavorites,
                    favoriteAuditions: _favoriteAuditions,
                    favoritesLoading: _favoritesLoading,
                    favoritesError: _favoritesError,
                    selectedIndex: _selectedCardIndex,
                    onSelect: (i) => setState(() => _selectedCardIndex = i),
                    onRetryFavorites: _loadFavoriteAuditions,
                    onRefreshFavorites: () =>
                        unawaited(_loadFavoriteAuditions()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopSegmented extends StatelessWidget {
  const _TopSegmented({
    required this.selectedIndex,
    required this.onChanged,
    required this.showFavorites,
    required this.onFavoritesTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final bool showFavorites;
  final VoidCallback onFavoritesTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AnimatedScale(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            scale: selectedIndex == 0 ? 1.02 : 1.0,
            child: GestureDetector(
              onTap: () => onChanged(0),
              child: _PillButton(
                label: "Meditations",
                selected: selectedIndex == 0,
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: AnimatedScale(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            scale: selectedIndex == 1 ? 1.02 : 1.0,
            child: GestureDetector(
              onTap: () => onChanged(1),
              child: _PillButton(
                label: "Melodies",
                selected: selectedIndex == 1,
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onFavoritesTap,
            customBorder: const CircleBorder(),
            child: Container(
              height: 38.h,
              width: 44.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: showFavorites
                    ? Colors.white.withValues(alpha: 0.22)
                    : Colors.white.withValues(alpha: 0.10),
              ),
              child: Center(
                child: Icon(
                  CupertinoIcons.heart_fill,
                  color: showFavorites ? const Color(0xFFFF9EB5) : Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.selected,
  });

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeInOutCubic,
      height: 38.h,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: selected ? Colors.white : Colors.white.withValues(alpha: 0.08),
      ),
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOutCubic,
          style: AppTextStyles.body14w6.copyWith(
            color: selected ? AppColors.c30215A : Colors.white,
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedScale(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          scale: selectedIndex == 2 ? 1.03 : 1.0,
          child: GestureDetector(
            onTap: () => onChanged(2),
            child: _PillButton(
              label: "Zen meditation",
              selected: selectedIndex == 2,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        AnimatedScale(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          scale: selectedIndex == 3 ? 1.03 : 1.0,
          child: GestureDetector(
            onTap: () => onChanged(3),
            child: _PillButton(
              label: "Breath",
              selected: selectedIndex == 3,
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryStyle {
  const _CategoryStyle({
    required this.cardColor,
    required this.iconGradient,
    required this.icon,
  });

  final Color cardColor;
  final List<Color> iconGradient;
  final IconData icon;
}

class _BreathingList extends StatelessWidget {
  const _BreathingList({
    required this.entryAnimation,
    required this.categoryIndex,
    required this.showFavorites,
    required this.favoriteAuditions,
    required this.favoritesLoading,
    required this.favoritesError,
    required this.selectedIndex,
    required this.onSelect,
    required this.onRetryFavorites,
    required this.onRefreshFavorites,
  });

  final Animation<double> entryAnimation;
  final int categoryIndex;
  final bool showFavorites;
  final List<Audition> favoriteAuditions;
  final bool favoritesLoading;
  final String? favoritesError;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onRetryFavorites;
  final VoidCallback onRefreshFavorites;

  static const _favoriteStyle = _CategoryStyle(
    cardColor: Color(0xFF3D2430),
    iconGradient: [
      Color(0xFFFF7B9C),
      Color(0xFF9A4D62),
    ],
    icon: CupertinoIcons.heart_fill,
  );

  static const List<_CategoryStyle> _kCategoryStyles = [
    _CategoryStyle(
      cardColor: Color(0xFF2A1F4A),
      iconGradient: [
        Color(0xFF9B8CFF),
        Color(0xFF4A3A8C),
      ],
      icon: CupertinoIcons.moon_stars_fill,
    ),
    _CategoryStyle(
      cardColor: Color(0xFF1A3340),
      iconGradient: [
        Color(0xFF3ED0E0),
        Color(0xFF1A6B78),
      ],
      icon: CupertinoIcons.music_note_2,
    ),
    _CategoryStyle(
      cardColor: Color(0xFF1F3D2C),
      iconGradient: [
        Color(0xFF7BC99A),
        Color(0xFF2F6B4A),
      ],
      icon: CupertinoIcons.sparkles,
    ),
    _CategoryStyle(
      cardColor: Color(0xFF23173F),
      iconGradient: [
        AppColors.c842D5F,
        AppColors.c55004D,
      ],
      icon: CupertinoIcons.wind,
    ),
  ];

  static const List<List<Color>> _favoriteAudioPalette = [
    [Color(0xFFB77BCB), Color(0xFF8F5FB0)],
    [Color(0xFFA883CF), Color(0xFF6F5AB6)],
    [Color(0xFFC78DB7), Color(0xFF8C66A7)],
    [Color(0xFF8A8CD6), Color(0xFF5F6BB8)],
  ];

  static const List<_BreathItem> _meditationItems = [
    _BreathItem(
      title: "Morning calm",
      duration: "10 minutes",
      minutes: 10,
      themeKey: 0,
      details: [
        "Gentle guidance to start the day with a clear mind.",
        "Focus on breath and body sensations at your own pace.",
      ],
    ),
    _BreathItem(
      title: "Body scan",
      duration: "15 minutes",
      minutes: 15,
      themeKey: 0,
      details: [
        "Move attention slowly from head to toe.",
        "Use whenever you want to reconnect with your body.",
      ],
    ),
    _BreathItem(
      title: "Loving kindness",
      duration: "12 minutes",
      minutes: 12,
      themeKey: 0,
      details: [
        "Soft phrases of care toward yourself and others.",
        "Practice in a quiet space where you will not be disturbed.",
      ],
    ),
    _BreathItem(
      title: "Evening release",
      duration: "8 minutes",
      minutes: 8,
      themeKey: 0,
      details: [
        "Let go of the day’s tension before sleep.",
        "Keep the pace slow and comfortable.",
      ],
    ),
  ];

  static const List<_BreathItem> _melodiesItems = [
    _BreathItem(
      title: "Soft piano",
      duration: "20 minutes",
      minutes: 20,
      themeKey: 1,
      details: [
        "Minimal piano layers for deep focus or rest.",
        "Adjust volume so it feels soothing, not loud.",
      ],
    ),
    _BreathItem(
      title: "Ocean waves",
      duration: "30 minutes",
      minutes: 30,
      themeKey: 1,
      details: [
        "Rhythmic waves to steady your breathing.",
        "Use with headphones for the best experience.",
      ],
    ),
    _BreathItem(
      title: "Forest rain",
      duration: "25 minutes",
      minutes: 25,
      themeKey: 1,
      details: [
        "Rain and distant birds for a cozy atmosphere.",
        "Ideal for reading or winding down.",
      ],
    ),
    _BreathItem(
      title: "Night ambient",
      duration: "45 minutes",
      minutes: 45,
      themeKey: 1,
      details: [
        "Low drones and soft pads for overnight play.",
        "Set a sleep timer if you prefer.",
      ],
    ),
  ];

  static const List<_BreathItem> _zenItems = [
    _BreathItem(
      title: "Empty mind",
      duration: "5 minutes",
      minutes: 5,
      themeKey: 2,
      details: [
        "Sit comfortably and notice thoughts without chasing them.",
        "Return to breath whenever the mind wanders.",
      ],
    ),
    _BreathItem(
      title: "Stone garden",
      duration: "12 minutes",
      minutes: 12,
      themeKey: 2,
      details: [
        "Visualize stillness like stones in a quiet garden.",
        "Keep shoulders soft and jaw relaxed.",
      ],
    ),
    _BreathItem(
      title: "Single breath",
      duration: "7 minutes",
      minutes: 7,
      themeKey: 2,
      details: [
        "One slow cycle of inhale and exhale at a time.",
        "No rush—length matters more than depth.",
      ],
    ),
    _BreathItem(
      title: "Mountain still",
      duration: "18 minutes",
      minutes: 18,
      themeKey: 2,
      details: [
        "Stable posture, steady attention.",
        "Use a cushion or chair that supports an upright spine.",
      ],
    ),
  ];

  static const List<_BreathItem> _breathItems = [
    _BreathItem(
      title: "Deep relaxation",
      duration: "2 minutes",
      minutes: 2,
      themeKey: 3,
      details: [
        "This practice will help your body and mind unwind after a long day.",
        "During the exercise you gently slow down your breathing, letting the body relax step by step.",
        "Use this when you feel tension in your shoulders, jaw, or stomach and want to soften it.",
      ],
    ),
    _BreathItem(
      title: "Deep sleep breath",
      duration: "3 minutes",
      minutes: 3,
      themeKey: 3,
      details: [
        "This practice prepares your body for a deep and restorative sleep.",
        "Slow, rhythmic breathing calms the nervous system and helps the mind let go of the day.",
        "Use it before going to bed or when you wake up at night and cannot fall asleep.",
      ],
    ),
    _BreathItem(
      title: "Stress relief",
      duration: "4 minutes",
      minutes: 4,
      themeKey: 3,
      details: [
        "This practice is designed to reduce feelings of stress and inner pressure.",
        "By combining slightly deeper inhales with longer exhales, it signals safety to your body.",
        "You can use it during a short break, in between tasks, or whenever you feel overwhelmed.",
      ],
    ),
    _BreathItem(
      title: "Energy boost",
      duration: "1 minute",
      minutes: 1,
      themeKey: 3,
      details: [
        "This practice will help you quickly fill up with energy and feel the power in your body.",
        "You don't need to focus during the exercise. It is a quick practice that will help you get energized and feel strong in a short time. We recommend not doing it several times in a row to avoid causing dizziness. Also make sure that your breathes in and out are not too deep.",
        "In this practice, the tempo is fast and the lungs are filled to capacity.",
        "This is due to the combination of fast and yet deep breathing, which is a good stimulant and helps better than any cup of coffee.",
        "IMPORTANT: Breathing practices are serious practices that require attention.",
        "For your safety we do not recommend performing these exercises during the first trimester of pregnancy, if you have a chronic medical condition, or if you are not feeling well. If you have low blood pressure, we suggest performing this practice in a ventilated room or outdoors. In case you feel dizzy during the practice, stop it immediately.",
      ],
    ),
  ];

  List<_BreathItem> get _items {
    if (showFavorites) {
      return favoriteAuditions
          .map((audition) => _BreathItem.fromFavoriteAudition(audition))
          .toList();
    }
    switch (categoryIndex) {
      case 0:
        return _meditationItems;
      case 1:
        return _melodiesItems;
      case 2:
        return _zenItems;
      default:
        return _breathItems;
    }
  }

  _CategoryStyle get _style {
    if (showFavorites) return _favoriteStyle;
    return _kCategoryStyles[categoryIndex.clamp(0, 3)];
  }

  @override
  Widget build(BuildContext context) {
    if (showFavorites && favoritesLoading) {
      return Center(
        child: SizedBox(
          width: 26.w,
          height: 26.w,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white.withValues(alpha: 0.55),
          ),
        ),
      );
    }
    if (showFavorites && favoritesError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              favoritesError!,
              textAlign: TextAlign.center,
              style: AppTextStyles.body14w5.copyWith(
                color: Colors.white.withValues(alpha: 0.72),
              ),
            ),
            SizedBox(height: 8.h),
            TextButton(
              onPressed: onRetryFavorites,
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

    final items = _items;
    if (showFavorites && items.isEmpty) {
      return Center(
        child: Text(
          "Hozircha sevimli audio yo'q",
          style: AppTextStyles.body14w5.copyWith(
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
      );
    }

    final style = _style;
    final safeSelected =
        selectedIndex.clamp(0, items.isEmpty ? 0 : items.length - 1);

    return ListView.separated(
      padding: EdgeInsets.only(top: 4.h, bottom: 16.h),
      itemCount: items.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final item = items[index];
        final start = (0.08 + index * 0.08).clamp(0.0, 0.9);
        final end = (start + 0.28).clamp(0.2, 1.0);
        final anim = CurvedAnimation(
          parent: entryAnimation,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        );
        if (showFavorites && item.isAudio) {
          void openAudio() {
            onSelect(index);
            context
                .push(
                  AudioScreen.routeName,
                  extra: AudioScreenArgs(
                    title: item.title,
                    durationLabel: item.duration,
                    audioUrl: item.audioUrl,
                    auditionId: item.auditionId,
                    auditionType: item.auditionType,
                    durationSeconds: item.durationSeconds,
                    initialFavorited: true,
                  ),
                )
                .then((_) => onRefreshFavorites());
          }

          void openDetail() {
            onSelect(index);
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => BreathDetailScreen(item: item),
              ),
            );
          }

          void toggleFavorite() {
            final id = item.auditionId;
            if (id == null) return;
            onSelect(index);
            unawaited(
              inject<PlaylistRepository>().toggleAuditionFavorite(id).then((_) {
                onRefreshFavorites();
              }),
            );
          }

          return FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.10),
                end: Offset.zero,
              ).animate(anim),
              child: AudioListTile(
                title: item.title,
                subtitle: item.categoryLabel,
                tag: item.formattedDuration,
                duration: item.duration,
                colors:
                    _favoriteAudioPalette[index % _favoriteAudioPalette.length],
                onTap: openAudio,
                onMoreTap: openDetail,
                isFavorite: true,
                onFavoriteTap: toggleFavorite,
              ),
            ),
          );
        }
        return FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.10),
              end: Offset.zero,
            ).animate(anim),
            child: _BreathingTile(
              item: item,
              style: style,
              selected: index == safeSelected,
              onTap: () => onSelect(index),
              onRefreshFavorites: onRefreshFavorites,
            ),
          ),
        );
      },
    );
  }
}

class _BreathItem {
  final String title;
  final String duration;
  final List<String> details;
  final int minutes;
  final int themeKey;
  final bool isAudio;
  final String audioUrl;
  final int? auditionId;
  final int? auditionType;
  final int durationSeconds;
  final String categoryLabel;
  final String formattedDuration;

  const _BreathItem({
    required this.title,
    required this.duration,
    required this.details,
    required this.minutes,
    required this.themeKey,
    this.isAudio = false,
    this.audioUrl = '',
    this.auditionId,
    this.auditionType,
    this.durationSeconds = 0,
    this.categoryLabel = 'Breath',
    this.formattedDuration = '',
  });

  factory _BreathItem.fromFavoriteAudition(Audition audition) {
    final minutes = (audition.duration / 60).ceil().clamp(1, 999);
    final themeByCategory = <int, int>{1: 0, 2: 1, 3: 2, 4: 3};
    final categoryById = <int, String>{
      1: 'Meditations',
      2: 'Melodies',
      3: 'Zen meditation',
      4: 'Breath',
    };
    return _BreathItem(
      title: audition.text,
      duration: audition.durationLabel,
      details: [
        "Audio detail",
        "Davomiyligi: ${audition.durationLabel}",
        "Ushbu audioga o'tish uchun play tugmasini bosing.",
      ],
      minutes: minutes,
      themeKey: themeByCategory[audition.categoryId] ?? 3,
      isAudio: true,
      audioUrl: audition.fullAudioUrl,
      auditionId: audition.id,
      auditionType: audition.type,
      durationSeconds: audition.duration,
      categoryLabel: categoryById[audition.categoryId] ?? 'Breath',
      formattedDuration: audition.formattedDuration,
    );
  }
}

class _BreathingTile extends StatelessWidget {
  const _BreathingTile({
    required this.item,
    required this.style,
    required this.selected,
    required this.onTap,
    required this.onRefreshFavorites,
  });

  final _BreathItem item;
  final _CategoryStyle style;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onRefreshFavorites;

  void _openItem(BuildContext context) {
    onTap();
    if (item.isAudio) {
      context
          .push(
            AudioScreen.routeName,
            extra: AudioScreenArgs(
              title: item.title,
              durationLabel: item.duration,
              audioUrl: item.audioUrl,
              auditionId: item.auditionId,
              auditionType: item.auditionType,
              durationSeconds: item.durationSeconds,
              initialFavorited: true,
            ),
          )
          .then((_) => onRefreshFavorites());
      return;
    }
    context.push(
      BreathSessionScreen.routeName,
      extra: BreathSessionArgs(
        title: item.title,
        duration: item.minutes,
        themeKey: item.themeKey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openItem(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeInOutCubic,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22.r),
          gradient: selected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.c842D5F,
                    AppColors.c55004D,
                  ],
                )
              : null,
          color: selected ? null : const Color(0xFF23173F),
          border: Border.all(
            color: selected
                ? AppColors.c842D5F.withValues(alpha: 0.9)
                : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.c842D5F.withValues(alpha: 0.30),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              height: 50.w,
              width: 50.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18.r),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: style.iconGradient,
                ),
              ),
              child: Center(
                child: Icon(
                  style.icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOutCubic,
                    style: AppTextStyles.body16w6.copyWith(
                      color: Colors.white,
                    ),
                    child: Text(item.title),
                  ),
                  SizedBox(height: 4.h),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOutCubic,
                    style: AppTextStyles.body12w4.copyWith(
                      color:
                          Colors.white.withValues(alpha: selected ? 0.95 : 0.7),
                    ),
                    child: Text(item.duration),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                _openItem(context);
              },
              icon: Icon(
                CupertinoIcons.info_circle,
                color: Colors.white.withValues(alpha: 0.9),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BreathDetailScreen extends StatelessWidget {
  const BreathDetailScreen({super.key, required this.item});

  final _BreathItem item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.c30215A,
              AppColors.c55004D,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.h),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(
                        CupertinoIcons.back,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  "Breath",
                  style: AppTextStyles.body16w6.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  item.title,
                  style: AppTextStyles.body24w7.copyWith(
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 18.h),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: 24.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final paragraph in item.details) ...[
                          Text(
                            paragraph,
                            style: AppTextStyles.body14w4.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              height: 1.45,
                            ),
                          ),
                          SizedBox(height: 12.h),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
