import 'package:bonoos/core/api/dio_client.dart';
import 'package:bonoos/core/api/list_api.dart';
import 'package:bonoos/core/error/failure.dart';
import 'package:bonoos/di.dart';
import 'package:bonoos/features/subscription/domain/entity/plan.dart';
import 'package:bonoos/features/subscription/domain/repository/subscription_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final DioClient _dio = inject<DioClient>();

  @override
  Future<Either<Failure, List<Plan>>> fetchPlans() async {
    try {
      final raw = await _dio.get(ListAPI.plans);
      final response = raw as Response<dynamic>;
      final body = response.data;
      if (body is! Map) {
        return const Left(BadResponseFailure(message: 'Javob formati noto\'g\'ri.'));
      }
      final map = Map<String, dynamic>.from(body);
      final list = map['data'];
      if (list is! List) {
        return const Left(BadResponseFailure(message: 'Rejalar ma\'lumoti yo\'q.'));
      }
      final plans = list
          .whereType<Map>()
          .map((e) => Plan.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return Right(plans);
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> subscribe(int planId) async {
    try {
      final raw = await _dio.post(
        ListAPI.plansSubscribe,
        data: {'plan_id': planId},
      );
      final response = raw as Response<dynamic>;
      final body = response.data;
      if (body is! Map) {
        return const Left(BadResponseFailure(message: 'Javob formati noto\'g\'ri.'));
      }
      final map = Map<String, dynamic>.from(body);
      final data = map['data'];
      if (data is! Map) {
        return const Left(BadResponseFailure(message: 'To\'lov ma\'lumoti yo\'q.'));
      }
      final paymentLink = data['payment_link'] as String?;
      if (paymentLink == null || paymentLink.isEmpty) {
        return const Left(BadResponseFailure(message: 'To\'lov havolasi olinmadi.'));
      }
      return Right(paymentLink);
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  Failure _mapDio(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const ConnectionFailure(
        message: 'Internet aloqasi yo\'q yoki vaqt tugadi.',
      );
    }
    final status = e.response?.statusCode;
    final data = e.response?.data;
    String? msg;
    if (data is Map) {
      final m = Map<String, dynamic>.from(data);
      msg = m['message']?.toString() ?? m['detail']?.toString();
    }
    if (status == 401) {
      return UnAuthorizedFailure(message: msg ?? 'Kirish talab qilinadi.');
    }
    return ServerFailure(message: msg ?? 'So\'rov bajarilmadi.');
  }
}
