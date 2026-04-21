import 'dart:async';
import 'dart:io';
import 'package:bonoos/core/api/dio_client.dart';
import 'package:bonoos/core/routes/app_pages.dart';
import 'package:bonoos/di.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MySmartDioInterceptor extends Interceptor {
  MySmartDioInterceptor(this._preferences);

  final SharedPreferences _preferences;

  // final Dio _dio;
  // String _refresh = '';

  final String _token = '';

  // String? _lang;
  List<Map<dynamic, dynamic>> _failedRequests = [];
  bool _isRefreshing = false;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('REQUEST[${options.method}] => PATH: ${options.path}');

    // _refresh = StorageService.to.getRefreshToken();
    // _token = _preferences.getString(ListAPI.ACCESS_TOKEN) ?? "";
    // _lang = _preferences.getString(ListAPI.LANG);

    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';
    // options.headers['accept-language'] = _lang ?? 'uz';

    if (_token.isNotEmpty) {
      options.headers["Authorization"] = "Bearer $_token";
    }
    debugPrint('REQUEST::${options.data}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if ([
      DioExceptionType.receiveTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.connectionTimeout,
      DioExceptionType.connectionError,
    ].contains(err.type)) {
      final instance = InternetConnectionChecker.createInstance();
      final hasConnection = await instance.hasConnection;
      final fullPath = RouteGenerate.router.routerDelegate.currentConfiguration.fullPath;
      final extra = RouteGenerate.router.routerDelegate.state.extra;
      await Future.delayed((Duration(milliseconds: 200)));
      if (!hasConnection) {
        // rootNavigatorKey.currentContext?.go(NoInternetScreen.routeName, extra: {'fullPath': fullPath, 'extra': extra});
        handler.next(err);
        return;
      } else {
        DioConnectivityRequestRetry(
          dio: inject<DioClient>().dio,
          connectivity: Connectivity(),
        ).scheduleRequestRetry(err.requestOptions);
        return;
      }
    }
    if (_shouldRetry(err)) {
      try {
        // DioConnectivityRequestRetry(
        //   dio: _dio,
        //   connectivity: Connectivity(),
        // ).scheduleRequestRetry(err.requestOptions);
      } catch (er) {
        handler.next(err);
      }
    }

    // if (err.response?.statusCode == 403 && _token != '') {
    //   if (!_isRefreshing) {
    //     _isRefreshing = true;
    //     await inject<SharedPreferences>().clear();
    //     rootNavigatorKey.currentContext!.go(AppRoutes.loginScreen);
    //
    //     /// refresh token after it expired and get new token
    //     // await _refreshToken();
    //   }
    //   _failedRequests.add({'err': err, 'handler': handler});
    //
    //   if (_token.isEmpty) {
    //     return;
    //   }

    /// retry request after token refreshed successfully
    //await _retryRequestsAfterTokenRefresh();


    // handler.next(err);
    handler.next(err);
  }

  /// retry all request after token refreshed successfully
  Future<void> _retryRequestsAfterTokenRefresh() async {
    final dio = Dio();
    if (_failedRequests.isNotEmpty) {
      for (int i = 0; i < _failedRequests.length; i++) {
        RequestOptions requestOptions = _failedRequests[i]['err'].requestOptions as RequestOptions;
        final options = Options(
          method: requestOptions.method,
          headers: {'Authorization': 'Token $_token', 'Content-Type': 'application/json'},
        );
        late Response cloneReq;
        try {
          cloneReq = await dio.request(
            requestOptions.path,
            data: requestOptions.data,
            queryParameters: requestOptions.queryParameters,
            options: options,
          );
        } catch (e) {
          debugPrint('EE:$e');
        }
        _failedRequests[i]['handler'].resolve(cloneReq);
      }
      _isRefreshing = false;
      _failedRequests = [];
    }
  }

  bool _shouldRetry(DioException err) {
    return err.error != null && err.error is SocketException;
  }

/// Navigate to Sign in Screen if token is fail
// Future<void> _goToLoginScreen() async {}
}

class DioConnectivityRequestRetry {
  final Dio dio;
  final Connectivity connectivity;

  DioConnectivityRequestRetry({required this.dio, required this.connectivity});

  Future<Response?> scheduleRequestRetry(RequestOptions requestOptions) async {
    // Wait until we have internet

    try {
      // Retry the original request
      return await dio.fetch(requestOptions);
    } catch (e) {
      return Future.error(e);
    }
  }
}
