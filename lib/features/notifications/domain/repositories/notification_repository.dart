import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  List<NotificationEntity> getNotifications();
  void markAsRead(String id);
  void markAllAsRead();
}
