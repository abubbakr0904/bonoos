import 'package:bonoos/core/api/dio_client.dart';
import 'package:bonoos/core/api/list_api.dart';
import 'package:bonoos/core/error/failure.dart';
import 'package:bonoos/di.dart';
import 'package:bonoos/features/notification/domain/entity/client_notification.dart';
import 'package:bonoos/features/notification/domain/repository/notifications_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final DioClient _dio = inject<DioClient>();

  @override
  Future<Either<Failure, List<ClientNotification>>> fetchNotifications() async {
    try {
      final raw = await _dio.get(ListAPI.clientNotifications);
      final response = raw as Response<dynamic>;
      final body = response.data;
      if (body is! Map) {
        return const Left(BadResponseFailure(message: 'Javob formati noto\'g\'ri.'));
      }
      final map = Map<String, dynamic>.from(body);
      final list = map['data'];
      if (list is! List) {
        return const Right([]);
      }
      final items = list
          .whereType<Map>()
          .map((e) => ClientNotification.fromJson(Map<String, dynamic>.from(e)))
          .toList()
        ..sort((a, b) {
          final ta = a.createdAt;
          final tb = b.createdAt;
          if (ta == null && tb == null) return b.id.compareTo(a.id);
          if (ta == null) return 1;
          if (tb == null) return -1;
          return tb.compareTo(ta);
        });
      return Right(items);
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<bool> markNotificationRead({
    required int notificationId,
    required int scope,
  }) async {
    try {
      await _dio.post(
        ListAPI.clientNotificationsRead,
        data: <String, dynamic>{
          'notification_id': notificationId,
          'scope': scope,
        },
      );
      return true;
    } catch (_) {
      return false;
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
