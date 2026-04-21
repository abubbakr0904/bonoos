import 'package:bonoos/core/error/failure.dart';
import 'package:bonoos/features/notification/domain/entity/client_notification.dart';
import 'package:dartz/dartz.dart';

abstract class NotificationsRepository {
  Future<Either<Failure, List<ClientNotification>>> fetchNotifications();

  /// POST `/client/notifications/read` — body: `{ notification_id, scope }`.
  Future<bool> markNotificationRead({
    required int notificationId,
    required int scope,
  });
}
