import 'package:bonoos/core/utils/external_payments.dart';
import 'package:bonoos/core/values/app_colors.dart';
import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:bonoos/di.dart';
import 'package:bonoos/features/playlist/domain/entity/category.dart';
import 'package:bonoos/features/playlist/domain/repository/playlist_repository.dart';
import 'package:bonoos/features/playlist/playlist_screen.dart';
import 'package:bonoos/features/playlist/widget/category_purchase_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// «To‘plamlar» tabi: pullik kategoriyalar — sotib olish yoki ochilganini tinglash.
/// Obuna (tarif) o‘rniga: kontent faqat kategoriya sotib olish orqali ochiladi.
class CollectionsScreen extends StatefulWidget {
  const CollectionsScreen({super.key});

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  bool _loading = true;
  String? _error;
  List<Category> _paid = [];
  int _freeCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    final result = await inject<PlaylistRepository>().fetchCategories();
    if (!mounted) return;
    result.fold(
      (f) => setState(() {
        _loading = false;
        _error = f.message ?? 'Xatolik yuz berdi';
      }),
      (cats) => setState(() {
        _loading = false;
        _error = null;
        // Avval sotib olinmaganlar, keyin ochilganlar; har birida server tartibi saqlanadi.
        _paid = cats.where((c) => c.isPaid).toList()
          ..sort((a, b) => (a.unlocked ? 1 : 0).compareTo(b.unlocked ? 1 : 0));
        _freeCount = cats.length - cats.where((c) => c.isPaid).length;
      }),
    );
  }

  Future<void> _onTap(Category c) async {
    if (!c.isLocked) {
      context.push(PlaylistScreen.routeName, extra: c.id);
      return;
    }
    final unlocked = await showCategoryPurchaseSheet(context, c);
    if (!unlocked || !mounted) return;
    await _load(silent: true);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("«${c.name}» to'plami ochildi")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locked = _paid.where((c) => c.isLocked).toList();
    final owned = _paid.where((c) => !c.isLocked).toList();

    return Scaffold(
      backgroundColor: AppColors.mainBgColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "To'plamlar",
                style: AppTextStyles.body22w7.copyWith(
                  color: Colors.white.withValues(alpha: 0.95),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                hideExternalPayments()
                    ? "Maxsus audio to'plamlar."
                    : "Bir marta to'lang — to'plam doim siz bilan.",
                style: AppTextStyles.body13w4.copyWith(
                  color: Colors.white.withValues(alpha: 0.70),
                ),
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : _error != null
                        ? _ErrorState(message: _error!, onRetry: _load)
                        : RefreshIndicator(
                            color: AppColors.mainBgColor,
                            onRefresh: () => _load(silent: true),
                            child: ListView(
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              padding: EdgeInsets.only(bottom: 120.h),
                              children: [
                                if (_paid.isEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(top: 60.h),
                                    child: Center(
                                      child: Text(
                                        "Hozircha pullik to'plamlar yo'q",
                                        style: AppTextStyles.body14w5.copyWith(
                                          color: Colors.white.withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ),
                                  ),
                                if (owned.isNotEmpty) ...[
                                  const _SectionTitle("Mening to'plamlarim"),
                                  for (final c in owned) _CollectionTile(category: c, onTap: () => _onTap(c)),
                                  SizedBox(height: 14.h),
                                ],
                                if (locked.isNotEmpty) ...[
                                  if (owned.isNotEmpty) const _SectionTitle("Yangi to'plamlar"),
                                  for (final c in locked) _CollectionTile(category: c, onTap: () => _onTap(c)),
                                ],
                                if (_freeCount > 0) ...[
                                  SizedBox(height: 10.h),
                                  _FreeLink(
                                    count: _freeCount,
                                    onTap: () => context.push(PlaylistScreen.routeName),
                                  ),
                                ],
                              ],
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Text(
        text,
        style: AppTextStyles.body16w6.copyWith(color: Colors.white.withValues(alpha: 0.92)),
      ),
    );
  }
}

class _CollectionTile extends StatelessWidget {
  const _CollectionTile({required this.category, required this.onTap});

  final Category category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locked = category.isLocked;
    final reviewMode = hideExternalPayments();

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            color: Colors.white.withValues(alpha: 0.08),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Container(
                height: 46.w,
                width: 46.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.c842D5F, AppColors.c55004D],
                  ),
                ),
                child: Center(
                  child: Icon(
                    locked ? CupertinoIcons.lock_fill : CupertinoIcons.headphones,
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
                      category.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body16w6.copyWith(
                        color: Colors.white.withValues(alpha: 0.92),
                      ),
                    ),
                    if (category.description.isNotEmpty) ...[
                      SizedBox(height: 3.h),
                      Text(
                        category.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body12w4.copyWith(
                          color: Colors.white.withValues(alpha: 0.70),
                          height: 1.3,
                        ),
                      ),
                    ],
                    SizedBox(height: 8.h),
                    if (!locked)
                      const _Pill(icon: CupertinoIcons.checkmark_alt, text: "Ochilgan")
                    else if (!reviewMode)
                      Text(
                        category.formattedPrice,
                        style: AppTextStyles.body17wb.copyWith(
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                      )
                    else
                      const _Pill(icon: CupertinoIcons.clock, text: "Tez orada"),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                CupertinoIcons.chevron_right,
                color: Colors.white.withValues(alpha: 0.60),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withValues(alpha: 0.14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white.withValues(alpha: 0.9)),
          SizedBox(width: 4.w),
          Text(
            text,
            style: AppTextStyles.body10w6.copyWith(color: Colors.white.withValues(alpha: 0.9)),
          ),
        ],
      ),
    );
  }
}

class _FreeLink extends StatelessWidget {
  const _FreeLink({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Icon(CupertinoIcons.gift, size: 20, color: Colors.white.withValues(alpha: 0.85)),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                "$count ta bepul to'plam — Pleylistda",
                style: AppTextStyles.body13w5.copyWith(color: Colors.white.withValues(alpha: 0.85)),
              ),
            ),
            Icon(CupertinoIcons.chevron_right, size: 16, color: Colors.white.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(CupertinoIcons.exclamationmark_triangle, size: 36.sp, color: Colors.white.withValues(alpha: 0.5)),
          SizedBox(height: 12.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.body14w5.copyWith(color: Colors.white.withValues(alpha: 0.7)),
          ),
          SizedBox(height: 12.h),
          TextButton(
            onPressed: onRetry,
            child: Text('Qayta urinish', style: AppTextStyles.body14w6.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
