import 'dart:convert';

import 'package:bonoos/core/api/dio_client.dart';
import 'package:bonoos/core/api/list_api.dart';
import 'package:bonoos/core/error/failure.dart';
import 'package:bonoos/core/utils/device_session_helper.dart';
import 'package:bonoos/core/utils/pref_manager.dart';
import 'package:bonoos/di.dart';
import 'package:flutter/foundation.dart';
import 'package:bonoos/features/auth/domain/entity/verify_otp_result.dart';
import 'package:bonoos/features/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepositoryImpl implements AuthRepository {
  final DioClient _dio = inject<DioClient>();

  @override
  Future<Either<Failure, Unit>> sendOtp({required String phoneDigits}) async {
    try {
      await _dio.post(
        ListAPI.authSendOtp,
        data: <String, dynamic>{'phone': phoneDigits},
      );
      return const Right(unit);
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, VerifyOtpResult>> verifyOtp({
    required String phoneDigits,
    required String code,
  }) =>
      _exchangeForTokens(
        ListAPI.authVerifyOtp,
        <String, dynamic>{'phone': phoneDigits, 'code': code},
        phoneDigits: phoneDigits,
      );

  @override
  Future<Either<Failure, VerifyOtpResult>> telegramVerify({required String code}) =>
      _exchangeForTokens(ListAPI.authTelegramVerify, <String, dynamic>{'code': code});

  /// Kodni tokenlarga almashtiradi va sessiyani saqlaydi (verify-otp va telegram/verify javobi bir xil).
  Future<Either<Failure, VerifyOtpResult>> _exchangeForTokens(
    String path,
    Map<String, dynamic> body, {
    String? phoneDigits,
  }) async {
    try {
      final response = await _dio.post(path, data: body);
      final resBody = response.data;
      if (resBody is! Map) {
        return const Left(BadResponseFailure(message: 'Javob formati noto‘g‘ri.'));
      }
      final map = Map<String, dynamic>.from(resBody);
      final raw = map['data'];
      if (raw is! Map) {
        return const Left(BadResponseFailure(message: 'Javobda data yo‘q.'));
      }
      final dataMap = Map<String, dynamic>.from(raw);
      final result = VerifyOtpResult.fromJson(dataMap);
      if (result.accessToken.isEmpty) {
        return const Left(BadResponseFailure(message: 'Access token qaytmadi.'));
      }
      await inject<PrefManager>().persistAuthSession(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
        expiresIn: result.expiresIn,
        userId: result.userId,
        isNewUser: result.isNewUser,
        phoneDigits: phoneDigits,
        rawDataJson: jsonEncode(dataMap),
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> registerClientSession() async {
    try {
      final prefs = inject<SharedPreferences>();
      final payload = await DeviceSessionHelper.buildSessionPayload(prefs);
      await _dio.post(ListAPI.authClientSession, data: payload);
      return const Right(unit);
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    final pref = inject<PrefManager>();
    final prefs = inject<SharedPreferences>();
    
    final refreshToken = pref.refresh ?? '';
    final deviceId = prefs.getString(SharedModel.deviceClientId) ?? '';

    // 1. Clear local session IMMEDIATELY for instant UI feedback
    await pref.logout();

    // 2. Trigger API logout in background (with short timeout)
    if (refreshToken.isNotEmpty) {
      try {
        await _dio.post(
          ListAPI.authClientLogout,
          data: <String, dynamic>{
            'refresh_token': refreshToken,
            'device_id': deviceId,
          },
        ).timeout(const Duration(seconds: 2));
      } catch (e) {
        debugPrint('Logout API background error (ignoring): $e');
      }
    }

    return const Right(unit);
  }

  Failure _mapDio(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const ConnectionFailure(
        message: 'Internet aloqasi yo‘q yoki vaqt tugadi. Qayta urinib ko‘ring.',
      );
    }

    final status = e.response?.statusCode;
    final data = e.response?.data;
    String? msg = _messageFromBody(data);
    msg ??= e.message;

    if (status == 401) {
      return UnAuthorizedFailure(message: msg ?? 'Ruxsat yo‘q.');
    }
    if (status == 403) {
      return ForbiddenFailure(message: msg ?? 'Kirish taqiqlangan.');
    }
    if (status == 429) {
      return const TooManyRequestsFailure(
        message: 'Juda ko‘p urinish. Birozdan keyin qayta urinib ko‘ring.',
      );
    }
    if (status == 404) {
      return UrlNotFoundFailure(message: msg ?? 'Manzil topilmadi.');
    }
    if (status != null && status >= 500) {
      return ServerFailure(message: msg ?? 'Server xatosi. Keyinroq urinib ko‘ring.');
    }
    return ServerFailure(message: msg ?? 'So‘rov bajarilmadi. Qayta urinib ko‘ring.');
  }

  String? _messageFromBody(dynamic data) {
    if (data is Map) {
      final m = Map<String, dynamic>.from(data);
      final direct = m['message'] ?? m['detail'] ?? m['error'];
      if (direct != null) return direct.toString();

      final errors = m['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) {
          return first.first.toString();
        }
        return errors.values.first.toString();
      }
    }
    if (data is String && data.isNotEmpty) return data;
    return null;
  }
}
