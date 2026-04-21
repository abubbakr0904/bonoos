import 'dart:developer';
import 'package:bonoos/core/routes/app_pages.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'error_model.dart';
import 'failure.dart';

class ServerException implements Exception {}

class CacheException implements Exception {}

class UltimateFailureConverter implements Exception {
  const UltimateFailureConverter._();

  static Failure fromException(Object? exception) {
    log('Error: $exception,\n', stackTrace: StackTrace.current);
    if (exception is DioException) {
      return DioExceptions.fromDioError(exception);
    } else {
      return UnknownFailure(message: exception.toString());
    }
  }
}

enum E {
  e500,
  e502,
  e400,
  e401,
  e403,
  e413,
  e422,
  e404,
  eUnknown,
  eCancelled,
  eConnectionTimeout,
  eReceiveTimeout,
  eSendTimeout,
  eConnectionError,
  eBadCertificate,
}

class DioExceptions implements Exception {
  DioExceptions();

  static const Map<E, String> mapUz = {
    E.e500: "Server xatosi",
    E.e502: "Bir daqiqa",
    E.e400: "Noto‘g‘ri so‘rov",
    E.e401: "Ruxsat yo‘q",
    E.e403: "Taqiqlangan",
    E.e413: "Yuk juda katta",
    E.e422: "Qayta ishlash mumkin emas",
    E.e404: "Topilmadi",
    E.eUnknown: "Noma’lum xato",
    E.eCancelled: "So‘rov bekor qilindi",
    E.eConnectionTimeout: "Ulanish vaqti tugadi",
    E.eReceiveTimeout: "Qabul qilish vaqti tugadi",
    E.eSendTimeout: "Yuborish vaqti tugadi",
    E.eConnectionError: "Ulanish xatosi",
    E.eBadCertificate: "Yaroqsiz sertifikat",
  };

  static const Map<E, String> mapUzCyrl = {
    E.e500: "Сервер хатоси",
    E.e502: "Ёмон шлюз",
    E.e400: "Нотўғри сўров",
    E.e401: "Рухсат йўқ",
    E.e403: "Тақиқланган",
    E.e413: "Юк жуда катта",
    E.e422: "Қайта ишлаб бўлмайдиган",
    E.e404: "Топилмади",
    E.eUnknown: "Номаълум хато",
    E.eCancelled: "Сўров бекор қилинди",
    E.eConnectionTimeout: "Уланиш вақти тугади",
    E.eReceiveTimeout: "Қабул қилиш вақти тугади",
    E.eSendTimeout: "Юбориш вақти тугади",
    E.eConnectionError: "Уланиш хатоси",
    E.eBadCertificate: "Яроқсиз сертификат",
  };

  static const Map<E, String> mapRu = {
    E.e500: "Внутренняя ошибка сервера",
    E.e502: "Плохой шлюз",
    E.e400: "Некорректный запрос",
    E.e401: "Нет авторизации",
    E.e403: "Доступ запрещён",
    E.e413: "Слишком большой запрос",
    E.e422: "Невозможно обработать данные",
    E.e404: "Не найдено",
    E.eUnknown: "Неизвестная ошибка",
    E.eCancelled: "Запрос отменён",
    E.eConnectionTimeout: "Таймаут соединения",
    E.eReceiveTimeout: "Таймаут при получении",
    E.eSendTimeout: "Таймаут при отправке",
    E.eConnectionError: "Ошибка соединения",
    E.eBadCertificate: "Недействительный сертификат",
  };

  static const Map<E, String> mapEn = {
    E.e500: "Internal server error",
    E.e502: "Bad gateway",
    E.e400: "Bad request",
    E.e401: "Unauthorized",
    E.e403: "Forbidden",
    E.e413: "Payload too large",
    E.e422: "Unprocessable entity",
    E.e404: "Not found",
    E.eUnknown: "Unknown error",
    E.eCancelled: "Request cancelled",
    E.eConnectionTimeout: "Connection timeout",
    E.eReceiveTimeout: "Receive timeout",
    E.eSendTimeout: "Send timeout",
    E.eConnectionError: "Connection error",
    E.eBadCertificate: "Invalid certificate",
  };

  static Map<E, String> determineLocaleAndGiveMap() {
    final context = rootNavigatorKey.currentContext;

    if (context == null) {
      return mapEn;
    }
    final locale = Localizations.localeOf(context);
    switch (locale.languageCode) {
      case 'uz':
        if ((locale.countryCode ?? '').toLowerCase() == 'cyrl' || (locale.scriptCode ?? '').toLowerCase() == 'cyrl') {
          return mapUzCyrl;
        }
        return mapUz;
      case 'ru':
        return mapRu;
      case 'en':
        return mapEn;
      case 'uz_Cyrl':
        return mapUzCyrl;
      default:
        return mapEn;
    }
  }

  static Failure fromDioError(DioException dioError) {
    final map = determineLocaleAndGiveMap();
    switch (dioError.type) {
      case DioExceptionType.cancel:
        return ConnectionFailure(message: map[E.eCancelled]);

      case DioExceptionType.connectionTimeout:
        return ConnectionFailure(message: map[E.eConnectionTimeout]);

      case DioExceptionType.receiveTimeout:
        return ConnectionFailure(message: map[E.eReceiveTimeout]);

      case DioExceptionType.sendTimeout:
        return ConnectionFailure(message: map[E.eSendTimeout]);

      case DioExceptionType.badResponse:
        return handleError(
          dioError.response?.statusCode,
          getErrorMessage(dioError.response?.data, dioError.response?.statusCode),
          map,
        );

      case DioExceptionType.connectionError:
        return ConnectionFailure(message: map[E.eConnectionError]);

      case DioExceptionType.badCertificate:
        return BadResponseFailure(message: map[E.eBadCertificate]);

      case DioExceptionType.unknown:
        return UnknownFailure(message: map[E.eUnknown]);
    }
  }

  static Failure handleError(int? statusCode, String error, Map<E, String> map) {
    switch (statusCode) {
      case 400:
        return BadResponseFailure(message: error.isNotEmpty ? error : map[E.e400]);
      case 401:
        return UnAuthorizedFailure(message: error.isNotEmpty ? error : map[E.e401]);
      case 403:
        return UnAuthorizedFailure(message: error.isNotEmpty ? error : map[E.e403]);
      case 413:
        return ForbiddenFailure(message: error.isNotEmpty ? error : map[E.e413]);
      case 422:
        return ForbiddenFailure(message: error.isNotEmpty ? error : map[E.e422]);
      case 404:
        return UrlNotFoundFailure(message: error.isNotEmpty ? error : map[E.e404]);
      case 500:
        return ServerFailure(message: error.isNotEmpty ? error : map[E.e500]);
      case 502:
        return BadResponseFailure(message: error.isNotEmpty ? error : map[E.e502]);
      default:
        return UnknownFailure(message: error.isNotEmpty ? error : map[E.eUnknown]);
    }
  }

  static String getErrorMessage(dynamic data, int? statusCode) {
    try {
      if (data is Map<String, dynamic>) {
        return ErrorModel.fromJson(data).detail ?? '';
      } else {
        return "";
      }
    } catch (e) {
      return "";
    }
  }
}
