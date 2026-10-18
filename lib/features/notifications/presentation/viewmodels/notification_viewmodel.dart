import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/notification_providers.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationViewModel extends Notifier<List<NotificationEntity>> {
  @override
  List<NotificationEntity> build() =>
      ref.read(notificationRepositoryProvider).getNotifications();

  void markAsRead(String id) {
    final repository = ref.read(notificationRepositoryProvider)..markAsRead(id);
    state = repository.getNotifications();
  }

  void markAllAsRead() {
    final repository = ref.read(notificationRepositoryProvider)
      ..markAllAsRead();
    state = repository.getNotifications();
  }
}

final notificationViewModelProvider =
    NotifierProvider<NotificationViewModel, List<NotificationEntity>>(
      NotificationViewModel.new,
    );

final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref
      .watch(notificationViewModelProvider)
      .where((item) => !item.isRead)
      .length;
});
