import 'dart:async';

import 'package:bonoos/core/values/app_colors.dart';
import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:bonoos/di.dart';
import 'package:bonoos/features/playlist/domain/entity/category.dart';
import 'package:bonoos/features/playlist/domain/repository/playlist_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

/// Pullik to‘plamni ochish oynasi. `true` — to‘plam ochildi (ro‘yxatni qayta yuklash kerak).
Future<bool> showCategoryPurchaseSheet(BuildContext context, Category category) async {
  final unlocked = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CategoryPurchaseSheet(category: category),
  );
  return unlocked ?? false;
}

enum _Stage { idle, creating, waitingPayment, checking }

class _CategoryPurchaseSheet extends StatefulWidget {
  const _CategoryPurchaseSheet({required this.category});

  final Category category;

  @override
  State<_CategoryPurchaseSheet> createState() => _CategoryPurchaseSheetState();
}

class _CategoryPurchaseSheetState extends State<_CategoryPurchaseSheet>
    with WidgetsBindingObserver {
  _Stage _stage = _Stage.idle;
  String? _error;
  int? _paymentId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Payme'dan ilovaga qaytganda holatni avtomatik tekshiramiz.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _stage == _Stage.waitingPayment) {
      _checkPayment();
    }
  }

  Future<void> _purchase() async {
    setState(() {
      _stage = _Stage.creating;
      _error = null;
    });
    final result = await inject<PlaylistRepository>().purchaseCategory(widget.category.id);
    if (!mounted) return;

    await result.fold(
      (failure) async {
        if (failure is AlreadyOwnedFailure) {
          Navigator.of(context).pop(true);
          return;
        }
        setState(() {
          _stage = _Stage.idle;
          _error = failure.message ?? 'Xatolik yuz berdi';
        });
      },
      (purchase) async {
        _paymentId = purchase.paymentId;
        final uri = Uri.tryParse(purchase.paymentLink.trim());
        final opened = uri != null &&
            await launchUrl(uri, mode: LaunchMode.externalApplication).catchError((_) => false);
        if (!mounted) return;
        setState(() {
          _stage = opened ? _Stage.waitingPayment : _Stage.idle;
          _error = opened ? null : 'To\'lov sahifasini ochib bo\'lmadi.';
        });
      },
    );
  }

  Future<void> _checkPayment() async {
    final id = _paymentId;
    if (id == null || _stage == _Stage.checking) return;
    setState(() {
      _stage = _Stage.checking;
      _error = null;
    });
    final result = await inject<PlaylistRepository>().fetchPaymentStatus(id);
    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _stage = _Stage.waitingPayment;
        _error = failure.message ?? 'To\'lov holatini olib bo\'lmadi.';
      }),
      (status) {
        switch (status) {
          case 'completed':
            Navigator.of(context).pop(true);
          case 'failed':
          case 'cancelled':
            setState(() {
              _stage = _Stage.idle;
              _paymentId = null;
              _error = 'To\'lov amalga oshmadi. Qaytadan urinib ko\'ring.';
            });
          default:
            setState(() {
              _stage = _Stage.waitingPayment;
              _error = 'To\'lov hali tasdiqlanmadi. Bir ozdan so\'ng tekshiring.';
            });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.category;
    final waiting = _stage == _Stage.waitingPayment || _stage == _Stage.checking;
    final busy = _stage == _Stage.creating || _stage == _Stage.checking;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.mainBgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      padding: EdgeInsets.fromLTRB(
        16.w,
        10.h,
        16.w,
        16.h + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
                ),
                child: const Center(
                  child: Icon(CupertinoIcons.lock_fill, color: Colors.white, size: 22),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: AppTextStyles.body18w7.copyWith(
                        color: Colors.white.withValues(alpha: 0.95),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "Pullik to'plam. Bir marta to'lang — barcha audiolar doim ochiq bo'ladi.",
                      style: AppTextStyles.body13w4.copyWith(
                        color: Colors.white.withValues(alpha: 0.70),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Text(
                category.formattedPrice,
                style: AppTextStyles.body22w7.copyWith(
                  color: Colors.white.withValues(alpha: 0.95),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                "/ bir martalik",
                style: AppTextStyles.body13w4.copyWith(
                  color: Colors.white.withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
          if (category.description.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              category.description,
              style: AppTextStyles.body13w4.copyWith(
                color: Colors.white.withValues(alpha: 0.75),
                height: 1.35,
              ),
            ),
          ],
          if (waiting) ...[
            SizedBox(height: 14.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14.r),
                color: Colors.white.withValues(alpha: 0.06),
                border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
              ),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.clock,
                    size: 18,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      "To'lovni Payme'da yakunlang va ilovaga qayting — holat avtomatik tekshiriladi.",
                      style: AppTextStyles.body12w4.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_error != null) ...[
            SizedBox(height: 12.h),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: AppTextStyles.body12w6.copyWith(color: AppColors.cff8989),
            ),
          ],
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: busy ? null : (waiting ? _checkPayment : _purchase),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.white,
                foregroundColor: AppColors.mainBgColor,
                disabledBackgroundColor: Colors.white.withValues(alpha: 0.12),
                minimumSize: Size(double.infinity, 54.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: busy
                  ? SizedBox(
                      width: 22.w,
                      height: 22.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      waiting ? "To'lovni tekshirish" : "Ochish — ${category.formattedPrice}",
                      style: AppTextStyles.body16w7,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tanlangan to‘plam yopiq bo‘lsa ro‘yxat ustida ko‘rinadigan karta.
class LockedCategoryBanner extends StatelessWidget {
  const LockedCategoryBanner({super.key, required this.category, required this.onTap});

  final Category category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.c55004D.withValues(alpha: 0.55),
              Colors.white.withValues(alpha: 0.06),
            ],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            Container(
              height: 38.w,
              width: 38.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.14),
              ),
              child: const Icon(CupertinoIcons.lock_fill, color: Colors.white, size: 18),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Pullik to'plam",
                    style: AppTextStyles.body14w6.copyWith(
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "Barcha audiolarni ${category.formattedPrice} evaziga oching",
                    style: AppTextStyles.body12w4.copyWith(
                      color: Colors.white.withValues(alpha: 0.72),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                "Ochish",
                style: AppTextStyles.body13w6.copyWith(color: AppColors.mainBgColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
