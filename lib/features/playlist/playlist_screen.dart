import 'dart:async';

import 'package:bonoos/core/utils/last_listened_manager.dart';
import 'package:bonoos/core/values/app_colors.dart';
import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:bonoos/di.dart';
import 'package:bonoos/features/common/widget/audio_list_tile.dart';
import 'package:bonoos/features/common/widget/playlist_category_chips.dart';
import 'package:bonoos/features/home/audio_screen.dart';
import 'package:bonoos/features/playlist/domain/entity/audition.dart';
import 'package:bonoos/features/playlist/domain/entity/category.dart';
import 'package:bonoos/features/playlist/domain/repository/playlist_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({super.key});
  static const String routeName = "/playlist";

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen>
    with SingleTickerProviderStateMixin {
  bool _categoriesLoading = true;
  String? _categoriesError;
  List<Category> _categories = [];
  int _selectedIndex = 0;

  bool _auditionsLoading = false;
  String? _auditionsError;
  List<Audition> _auditions = [];
  late final AnimationController _entryController;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..forward();
    _loadCategories();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
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

  Future<void> _loadAuditions(int categoryId, {bool silent = false}) async {
    if (!silent) {
      setState(() {
        _auditionsLoading = true;
        _auditionsError = null;
        _auditions = [];
      });
    }
    final result = await inject<PlaylistRepository>().fetchAuditions(categoryId);
    if (!mounted) return;
    result.fold(
      (f) {
        if (!silent) {
          setState(() {
            _auditionsLoading = false;
            _auditionsError = f.message ?? 'Xatolik';
          });
        }
      },
      (list) => setState(() {
        if (!silent) _auditionsLoading = false;
        _auditionsError = null;
        _auditions = list;
      }),
    );
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
      inject<PlaylistRepository>().toggleAuditionFavorite(item.id).then((either) {
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

  void _onCategorySelected(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
    if (index < _categories.length) {
      _loadAuditions(_categories[index].id);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBgColor,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _entryController,
                      curve: const Interval(0.0, 0.40, curve: Curves.easeOutCubic),
                    ),
                    child: const _PlaylistHeader(),
                  ),
                  SizedBox(height: 14.h),
                  FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _entryController,
                      curve: const Interval(0.10, 0.52, curve: Curves.easeOutCubic),
                    ),
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.10),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _entryController,
                          curve:
                              const Interval(0.10, 0.52, curve: Curves.easeOutCubic),
                        ),
                      ),
                      child: const _LastListenedCard(),
                    ),
                  ),
                  SizedBox(height: 18.h),

                  if (_categoriesLoading)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const PlaylistCategoriesShimmer(),
                        SizedBox(height: 20.h),
                        const PlaylistAuditionsShimmer(),
                      ],
                    )
                  else if (_categoriesError != null)
                    Expanded(
                      child: PlaylistCategoriesError(
                        error: _categoriesError!,
                        onRetry: _loadCategories,
                      ),
                    )
                  else ...[
                    FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _entryController,
                        curve:
                            const Interval(0.20, 0.62, curve: Curves.easeOutCubic),
                      ),
                      child: PlaylistCategoryChipRow(
                        categories: _categories,
                        selectedIndex: _selectedIndex,
                        onSelected: _onCategorySelected,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Expanded(
                      child: _auditionsLoading
                          ? const PlaylistAuditionsShimmer()
                          : _auditionsError != null
                              ? _AuditionsError(
                                  error: _auditionsError!,
                                  onRetry: () {
                                    if (_selectedIndex < _categories.length) {
                                      _loadAuditions(_categories[_selectedIndex].id);
                                    }
                                  },
                                )
                              : _auditions.isEmpty
                                  ? Center(
                                      child: Padding(
                                        padding: EdgeInsets.only(top: 40.h),
                                        child: Text(
                                          'Bu kategoriyada hozircha audio yo\'q',
                                          style: AppTextStyles.body14w5.copyWith(
                                            color: Colors.white.withValues(alpha: 0.5),
                                          ),
                                        ),
                                      ),
                                    )
                                  : SingleChildScrollView(
                                      physics: const BouncingScrollPhysics(),
                                      child: Column(
                                        children: [
                                          ListView.separated(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemCount: _auditions.length,
                                            separatorBuilder: (_, __) => SizedBox(height: 10.h),
                                            itemBuilder: (context, index) {
                                              final item = _auditions[index];
                                              final colors = const [Colors.white, Colors.white];
                                              final categoryName = _selectedIndex < _categories.length
                                                  ? _categories[_selectedIndex].name
                                                  : '';
                                              final categoryId = _selectedIndex < _categories.length
                                                  ? _categories[_selectedIndex].id
                                                  : null;
                                              final start =
                                                  (0.28 + index * 0.08).clamp(0.0, 0.92);
                                              final end =
                                                  (start + 0.28).clamp(0.2, 1.0);
                                              final anim = CurvedAnimation(
                                                parent: _entryController,
                                                curve: Interval(
                                                  start,
                                                  end,
                                                  curve: Curves.easeOutCubic,
                                                ),
                                              );
                                              return FadeTransition(
                                                opacity: anim,
                                                child: SlideTransition(
                                                  position: Tween<Offset>(
                                                    begin: const Offset(0, 0.10),
                                                    end: Offset.zero,
                                                  ).animate(anim),
                                                  child: AudioListTile(
                                                    title: item.text,
                                                    subtitle: categoryName,
                                                    tag: item.formattedDuration,
                                                    duration: item.durationLabel,
                                                    colors: colors,
                                                    onTap: () {
                                                      LastListenedManager.save(
                                                        prefs:
                                                            inject<SharedPreferences>(),
                                                        title: item.text,
                                                        durationLabel:
                                                            item.durationLabel,
                                                        audioUrl: item.fullAudioUrl,
                                                        formattedDuration:
                                                            item.formattedDuration,
                                                      );
                                                      context.push(
                                                        AudioScreen.routeName,
                                                        extra: AudioScreenArgs(
                                                          title: item.text,
                                                          durationLabel:
                                                              item.durationLabel,
                                                          audioUrl:
                                                              item.fullAudioUrl,
                                                          auditionId: item.id,
                                                          auditionType: item.type,
                                                          durationSeconds:
                                                              item.duration,
                                                          initialFavorited:
                                                              item.favorited,
                                                          categoryIdForSync:
                                                              categoryId,
                                                          onAuditionsSynced:
                                                              categoryId == null
                                                                  ? null
                                                                  : (List<Audition>
                                                                      list) {
                                                                      if (!mounted) {
                                                                        return;
                                                                      }
                                                                      if (_selectedIndex >=
                                                                          _categories
                                                                              .length) {
                                                                        return;
                                                                      }
                                                                      if (_categories[
                                                                                  _selectedIndex]
                                                                              .id !=
                                                                          categoryId) {
                                                                        return;
                                                                      }
                                                                      setState(() =>
                                                                          _auditions =
                                                                              list);
                                                                    },
                                                        ),
                                                      );
                                                    },
                                                    isFavorite: item.favorited,
                                                    onFavoriteTap: () =>
                                                        _onFavoriteTapAudition(
                                                            index),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                          SizedBox(height: 90.h),
                                        ],
                                      ),
                                    ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuditionsError extends StatelessWidget {
  const _AuditionsError({required this.error, required this.onRetry});

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.exclamationmark_triangle,
            size: 32.sp,
            color: Colors.white.withValues(alpha: 0.5),
          ),
          SizedBox(height: 10.h),
          Text(
            error,
            textAlign: TextAlign.center,
            style: AppTextStyles.body13w5.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 12.h),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'Qayta urinish',
              style: AppTextStyles.body14w6.copyWith(color: AppColors.c842D5F),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaylistHeader extends StatelessWidget {
  const _PlaylistHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 42.w,
              height: 42.w,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12.r),
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      color: Colors.white.withValues(alpha: 0.08),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        CupertinoIcons.back,
                        size: 20.sp,
                        color: Colors.white.withValues(alpha: 0.92),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                "Pleylist",
                style: AppTextStyles.body22w7.copyWith(
                  color: Colors.white.withValues(alpha: 0.95),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          "Tinch kunlar uchun tanlangan audiolar",
          style: AppTextStyles.body13w4.copyWith(
            color: Colors.white.withValues(alpha: 0.70),
          ),
        ),
      ],
    );
  }
}

class _LastListenedCard extends StatelessWidget {
  const _LastListenedCard();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<LastListenedItem?>(
      valueListenable: LastListenedManager.notifier,
      builder: (context, item, _) {
        if (item == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () {
            context.push(
              AudioScreen.routeName,
              extra: AudioScreenArgs(
                title: item.title,
                durationLabel: item.durationLabel,
                audioUrl: item.audioUrl,
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              color: Colors.white.withValues(alpha: 0.1),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  height: 48.w,
                  width: 48.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0x26FFFFFF),
                  ),
                  child: const Center(
                    child: Icon(
                      CupertinoIcons.headphones,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Oxirgi tinglangan",
                        style: AppTextStyles.body11w5.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body16w7.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        item.formattedDuration.isNotEmpty
                            ? item.formattedDuration
                            : item.durationLabel,
                        style: AppTextStyles.body11w5.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 42.w,
                  width: 42.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFFFFFFF),
                  ),
                  child: const Center(
                    child: Icon(
                      CupertinoIcons.play_fill,
                      color: AppColors.mainBgColor,
                      size: 22,
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
