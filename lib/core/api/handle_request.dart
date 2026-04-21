import 'dart:async';

import 'package:bonoos/core/error/dio_exceptions_wrapper.dart';
import 'package:bonoos/core/error/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

enum HttpMethod { GET, POST, PUT, PATCH, DELETE }

Future<Either<Failure, T>> handleRequest<T>({
  required String endpoint,
  required Dio dioClient,
  required HttpMethod method,
  dynamic data,
  ResponseType? responseType,
  Map<String, dynamic>? queryParameters,
  Map<String, String>? headers,
  required FutureOr<T> Function(Response) onSuccess,
  int expectedStatusCode = 200,
  Duration? timeout,
}) async {
  try {
    if (kDebugMode) {
      debugPrint("🚀 $method $endpoint");
      if (data != null) debugPrint("📦 Body: $data");
      if (queryParameters != null) debugPrint("🔍 Query: $queryParameters");
    }

    Response response;

    final options = Options(
      headers: headers,
      responseType: responseType,
      receiveTimeout: timeout ?? const Duration(seconds: 30),
      sendTimeout: timeout ?? const Duration(seconds: 30),
    );

    switch (method) {
      case HttpMethod.GET:
        response = await dioClient.get(endpoint, queryParameters: queryParameters ?? data, options: options);
        break;
      case HttpMethod.POST:
        response = await dioClient.post(endpoint, data: data, queryParameters: queryParameters, options: options);
        break;
      case HttpMethod.PUT:
        response = await dioClient.put(endpoint, data: data, queryParameters: queryParameters, options: options);
        break;
      case HttpMethod.PATCH:
        response = await dioClient.patch(endpoint, data: data, queryParameters: queryParameters, options: options);
        break;
      case HttpMethod.DELETE:
        response = await dioClient.delete(endpoint, data: data, queryParameters: queryParameters, options: options);
        break;
    }

    if (kDebugMode) {
      debugPrint("✅ $method $endpoint: ${response.statusCode}");
      if (response.statusCode != expectedStatusCode) {
        debugPrint("⚠️  Expected: $expectedStatusCode, Got: ${response.statusCode}");
      }
    }

    // Check if response status code matches expected
    if (response.statusCode != expectedStatusCode) {
      // Create a DioException for unexpected status codes
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        message: 'Unexpected status code: ${response.statusCode}',
      );
    }

    return Right(await onSuccess(response));
  } catch (e) {
    if (kDebugMode) {
      debugPrint("❌ DioException caught in handleRequest");
    }
    final failure = UltimateFailureConverter.fromException(e);
    return Left(failure);
  }
}
