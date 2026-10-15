import 'dart:async';
import 'dart:developer';

import 'package:bonoos/core/api/list_api.dart';
import 'package:bonoos/core/routes/app_pages.dart';
import 'package:bonoos/core/utils/pref_manager.dart';
import 'package:bonoos/di.dart';
import 'package:bonoos/features/auth/telegram_login_screen.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 401 (Bearer bilan yuborilgan so‘rovda) → `auth/client/refresh-token` →
/// yangi tokenlarni saqlab, asl so‘rovni bir marta qayta yuboradi.
///
/// Bir vaqtda kelgan bir nechta 401 bitta refresh so‘rovini kutadi.
/// Refresh muvaffaqiyatsiz bo‘lsa (backend 401/500 qaytaradi) — logout va login ekrani.
class AuthRefreshInterceptor extends Interceptor {
  AuthRefreshInterceptor(this._dio);

  final Dio _dio;

  /// Joriy refresh jarayoni; `null` — hozir refresh qilinmayapti.
  Future<String?>? _refreshing;

  static const _retriedKey = 'auth_retried';

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final req = err.requestOptions;
    final hadBearer = (req.headers['Authorization'] as String?)?.startsWith('Bearer ') ?? false;

    if (err.response?.statusCode != 401 ||
        !hadBearer ||
        req.path.contains(ListAPI.authClientRefreshToken) ||
        req.extra[_retriedKey] == true) {
      return handler.next(err);
    }

    final newToken = await (_refreshing ??= _refresh().whenComplete(() => _refreshing = null));
    if (newToken == null) {
      return handler.next(err);
    }

    try {
      req.headers['Authorization'] = 'Bearer $newToken';
      req.extra[_retriedKey] = true;
      handler.resolve(await _dio.fetch(req));
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  /// Yangi access token yoki `null` (sessiya tugagan).
  Future<String?> _refresh() async {
    final prefs = inject<PrefManager>();
    final refresh = prefs.refresh?.trim() ?? '';
    final deviceId = inject<SharedPreferences>().getString(SharedModel.deviceClientId) ?? '';
    if (refresh.isEmpty || deviceId.isEmpty) {
      await _logout();
      return null;
    }

    try {
      // Alohida Dio — bu interceptor'lar zanjiriga qaytib kirmaslik uchun.
      final res = await Dio(BaseOptions(
        baseUrl: _dio.options.baseUrl,
        connectTimeout: _dio.options.connectTimeout,
        receiveTimeout: _dio.options.receiveTimeout,
        headers: {ListAPI.headerXUuid: ListAPI.xUuid, 'Accept': 'application/json'},
      )).post(ListAPI.authClientRefreshToken, data: {
        'refresh_token': refresh,
        'device_id': deviceId,
      });

      final tokens = (res.data as Map?)?['data']?['tokens'] as Map?;
      final access = tokens?['access_token'] as String?;
      final newRefresh = tokens?['refresh_token'] as String?;
      if (access == null || access.isEmpty) {
        await _logout();
        return null;
      }
      prefs.token = access;
      if (newRefresh != null && newRefresh.isNotEmpty) prefs.refresh = newRefresh;
      if (tokens?['expires_in'] is int) {
        await inject<SharedPreferences>().setInt(SharedModel.authExpiresIn, tokens!['expires_in'] as int);
      }
      return access;
    } on DioException catch (e) {
      // Tarmoq xatosida sessiyani o‘chirmaymiz — keyingi urinishda yana refresh qilinadi.
      if (e.response == null) return null;
      log('refresh-token failed: ${e.response?.statusCode}', name: 'AuthRefresh');
      await _logout();
      return null;
    }
  }

  Future<void> _logout() async {
    await inject<PrefManager>().logout();
    final ctx = rootNavigatorKey.currentContext;
    if (ctx != null && ctx.mounted) ctx.go(TelegramLoginScreen.routeName);
  }
}
