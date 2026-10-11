import 'package:bonoos/core/api/auth_refresh_interceptor.dart';
import 'package:bonoos/core/api/list_api.dart';
import 'package:bonoos/core/api/pretty_dio_logger.dart';
import 'package:bonoos/core/utils/pref_manager.dart';
import 'package:bonoos/di.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef ResponseConverter<T> = T Function(dynamic response);

class DioClient {
  // String? _auth;
  late Dio _dio;

  DioClient(SharedPreferences preferences) {
    _dio = _createDio();

    _dio.interceptors.insert(
      0,
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          options.headers[ListAPI.headerXUuid] = ListAPI.xUuid;
          handler.next(options);
        },
      ),
    );

    _dio.interceptors.insert(
      1,
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          final token = inject<PrefManager>().token;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );

    _dio.interceptors.add(AuthRefreshInterceptor(_dio));

    try {
      _dio.interceptors.add(
        PrettyDioLogger(requestHeader: true, requestBody: true, responseBody: true, responseHeader: false, error: true),
      );
      // _dio.interceptors.add(MySmartDioInterceptor(preferences));
    } catch (e) {
      debugPrint('SE:$e');
    }
    if (kDebugMode) {
      // _dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
    }
  }

  Dio get dio {
    return _dio;
  }

  Dio _createDio() {
    final headers = <String, dynamic>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ListAPI.headerXUuid: ListAPI.xUuid,
    };
    return Dio(
      BaseOptions(
        baseUrl: inject<PrefManager>().baseUrl ?? dotenv.env['BASE_URL'] ?? '',
        receiveTimeout: const Duration(seconds: 30),
        connectTimeout: const Duration(seconds: 30),
        headers: headers,
        validateStatus: (int? status) {
          return status! > 0 && status < 300;
        },
      ),
    );
  }

  Future<dynamic> get(String url, {Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      final response = await _dio.get(url, queryParameters: queryParameters, options: options);
      if (response.statusCode != 200) {
        throw DioException(requestOptions: response.requestOptions, response: response);
      }
      return response;
    } on DioException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> delete(String url) async {
    try {
      final response = await _dio.delete(url);
      if (response.statusCode == 204) {
        return true;
      }
      return response.data;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> post(String url, {Map<String, dynamic>? headers, dynamic data, Options? options}) async {
    try {
      final response = await _dio.post(
        url,
        data: data,
        options: options ?? Options(headers: headers),
      );
      final code = response.statusCode;
      if (code == 200 || code == 201 || code == 204) {
        return response;
      } else {
        throw DioException(requestOptions: response.requestOptions, response: response);
      }
    } on DioException {
      rethrow;
    }
  }

  Future<dynamic> patch(String url, {Map<String, dynamic>? headers, dynamic data}) async {
    try {
      final response = await _dio.patch(
        url,
        data: data,
        options: Options(headers: headers),
      );
      if (response.statusCode != 200) {
        throw DioException(requestOptions: response.requestOptions, response: response);
      }
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<dynamic> put(String url, {dynamic data, Options? options}) async {
    try {
      final response = await _dio.put(url, data: data, options: options);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw DioException(requestOptions: response.requestOptions, response: response);
      }
      return response;
    } on DioException {
      rethrow;
    }
  }
}
