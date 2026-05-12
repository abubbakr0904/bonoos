import 'package:bonoos/core/values/app_colors.dart';
import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:bonoos/di.dart';
import 'package:bonoos/features/common/widget/home_gradient_background.dart';
import 'package:bonoos/features/notification/domain/entity/client_notification.dart';
import 'package:bonoos/features/notification/domain/repository/notifications_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  static const String routeName = '/notifications';

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _loading = true;
  String? _error;
  List<ClientNotification> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await inject<NotificationsRepository>().fetchNotifications();
    if (!mounted) return;
    result.fold(
      (f) => setState(() {
        _loading = false;
        _error = f.message ?? 'Xatolik';
      }),
      (list) => setState(() {
        _loading = false;
        _error = null;
        _items = list;
      }),
    );
  }

  Future<void> _silentRefresh() async {
    final result = await inject<NotificationsRepository>().fetchNotifications();
    if (!mounted) return;
    result.fold((_) {}, (list) {
      setState(() => _items = list);
    });
  }

  void _onNotificationTap(ClientNotification n) {
    if (n.read) return;
    final id = n.id;
    final scope = n.scope;
    setState(() {
      _items = _items.map((e) => e.id == id ? e.copyWith(read: true) : e).toList();
    });
    inject<NotificationsRepository>()
        .markNotificationRead(notificationId: id, scope: scope)
        .then((ok) async {
      if (!mounted) return;
      if (!ok) {
        setState(() {
          _items = _items.map((e) => e.id == id ? e.copyWith(read: false) : e).toList();
        });
        return;
      }
      await _silentRefresh();
    });
  }

  int get _unreadCount => _items.where((e) => !e.read).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBgColor,
      body: Stack(
        children: [
          const HomeGradientBackground(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(4.w, 6.h, 20.w, 16.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.06),
                          padding: EdgeInsets.all(10.w),
                          minimumSize: Size(40.w, 40.w),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () => context.pop(),
                        icon: Icon(
                          CupertinoIcons.chevron_back,
                          color: Colors.white.withValues(alpha: 0.9),
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bildirishnomalar',
                              style: AppTextStyles.body18w6.copyWith(
                                color: Colors.white.withValues(alpha: 0.96),
                                letterSpacing: -0.2,
                              ),
                            ),
                            if (!_loading && _error == null && _items.isNotEmpty && _unreadCount > 0)
                              Padding(
                                padding: EdgeInsets.only(top: 4.h),
                                child: Text(
                                  '$_unreadCount ta o‘qilmagan',
                                  style: AppTextStyles.body12w4.copyWith(
                                    color: Colors.white.withValues(alpha: 0.42),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _loading
                      ? const _NotificationsLoading()
                      : RefreshIndicator(
                          color: const Color(0xFFD4A5C4),
                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                          displacement: 48,
                          onRefresh: _load,
                          child: CustomScrollView(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            slivers: [
                              if (_error != null)
                                SliverFillRemaining(
                                  hasScrollBody: false,
                                  child: _NotificationsError(
                                    message: _error!,
                                    onRetry: _load,
                                  ),
                                )
                              else if (_items.isEmpty)
                                const SliverFillRemaining(
                                  hasScrollBody: false,
                                  child: _NotificationsEmpty(),
                                )
                              else
                                SliverPadding(
                                  padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 40.h),
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        if (index.isOdd) {
                                          return SizedBox(height: 10.h);
                                        }
                                        final i = index ~/ 2;
                                        return _NotificationCard(
                                          n: _items[i],
                                          onTap: () => _onNotificationTap(_items[i]),
                                        );
                                      },
                                      childCount: _items.length * 2 - 1,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationsLoading extends StatelessWidget {
  const _NotificationsLoading();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 24.h),
      child: Shimmer.fromColors(
        baseColor: Colors.white.withValues(alpha: 0.05),
        highlightColor: Colors.white.withValues(alpha: 0.1),
        period: const Duration(milliseconds: 1100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(5, (i) {
            return Padding(
              padding: EdgeInsets.only(bottom: i == 4 ? 0 : 12.h),
              child: Container(
                height: 76.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14.r),
                  color: Colors.white,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NotificationsEmpty extends StatelessWidget {
  const _NotificationsEmpty();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 36.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72.w,
            height: 72.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.r),
              color: Colors.white.withValues(alpha: 0.05),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Icon(
              CupertinoIcons.bell,
              size: 30.sp,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
          SizedBox(height: 22.h),
          Text(
            'Xabar yo‘q',
            textAlign: TextAlign.center,
            style: AppTextStyles.body17w5.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              letterSpacing: -0.15,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Bu yerda yangiliklar va eslatmalar chiqadi.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body14w4.copyWith(
              color: Colors.white.withValues(alpha: 0.48),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationsError extends StatelessWidget {
  const _NotificationsError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.wifi_slash,
              size: 36.sp,
              color: Colors.white.withValues(alpha: 0.38),
            ),
            SizedBox(height: 18.h),
            Text(
              'Yuklanmadi',
              style: AppTextStyles.body17w5.copyWith(
                color: Colors.white.withValues(alpha: 0.88),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body13w4.copyWith(
                color: Colors.white.withValues(alpha: 0.48),
                height: 1.4,
              ),
            ),
            SizedBox(height: 24.h),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white.withValues(alpha: 0.9),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.22)),
                padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Qayta urinish',
                style: AppTextStyles.body14w6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.n,
    required this.onTap,
  });

  final ClientNotification n;
  final VoidCallback onTap;

  static String _title(String t) {
    final s = t.trim();
    if (s.isEmpty || s == '.') return 'Bildirishnoma';
    return s;
  }

  static String _body(String c) {
    final s = c.trim();
    if (s.isEmpty || s == '.') return '';
    return s;
  }

  static String _time(DateTime? d) {
    if (d == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dDay = DateTime(d.year, d.month, d.day);
    final y = today.subtract(const Duration(days: 1));
    if (dDay == today) {
      return 'Bugun · ${DateFormat.Hm().format(d)}';
    }
    if (dDay == y) {
      return 'Kecha · ${DateFormat.Hm().format(d)}';
    }
    return DateFormat('d MMM, HH:mm').format(d);
  }

  @override
  Widget build(BuildContext context) {
    final unread = !n.read;
    final body = _body(n.content);
    final radius = 14.r;
    const accent = Color(0xFFC98FB8);
    final stripW = 3.w;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        splashColor: Colors.white.withValues(alpha: 0.06),
        highlightColor: Colors.white.withValues(alpha: 0.04),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            color: unread
                ? Colors.white.withValues(alpha: 0.065)
                : Colors.white.withValues(alpha: 0.038),
            border: Border.all(
              color: unread
                  ? accent.withValues(alpha: 0.26)
                  : Colors.white.withValues(alpha: 0.07),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              fit: StackFit.passthrough,
              children: [
                if (unread)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: stripW,
                    child: ColoredBox(color: accent.withValues(alpha: 0.88)),
                  ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    (unread ? stripW : 0) + 14.w,
                    13.h,
                    14.w,
                    13.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              _title(n.title),
                              style: AppTextStyles.body15w6.copyWith(
                                color: Colors.white.withValues(alpha: 0.93),
                                height: 1.28,
                                letterSpacing: -0.15,
                              ),
                            ),
                          ),
                          if (unread)
                            Padding(
                              padding: EdgeInsets.only(left: 8.w, top: 1.h),
                              child: Text(
                                'Yangi',
                                style: AppTextStyles.body11w5.copyWith(
                                  color: accent.withValues(alpha: 0.95),
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (body.isNotEmpty) ...[
                        SizedBox(height: 7.h),
                        Text(
                          body,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.body14w4.copyWith(
                            color: Colors.white.withValues(alpha: 0.58),
                            height: 1.42,
                          ),
                        ),
                      ],
                      SizedBox(height: 9.h),
                      Text(
                        _time(n.createdAt).toUpperCase(),
                        style: AppTextStyles.body11w4.copyWith(
                          color: Colors.white.withValues(alpha: 0.35),
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
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
