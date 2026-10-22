import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/notification_providers.dart';
import '../../domain/entities/notification_entity.dart';
import '../../../../core/network/remote_repositories.dart';

class NotificationViewModel extends Notifier<List<NotificationEntity>> {
  @override
  List<NotificationEntity> build() {
    final repository = ref.read(notificationRepositoryProvider);
    if (repository is RemoteNotificationRepository) {
      Future.microtask(() async {
        try {
          final items = await repository.refresh();
          if (ref.mounted) state = items;
        } catch (_) {}
      });
    }
    return repository.getNotifications();
  }

  void markAsRead(String id) {
    final remote = ref.read(notificationRepositoryProvider);
    if (remote is RemoteNotificationRepository) {
      remote
          .read(id)
          .then((items) {
            if (ref.mounted) state = items;
          })
          .catchError((Object _) {});
      return;
    }
    final repository = ref.read(notificationRepositoryProvider)..markAsRead(id);
    state = repository.getNotifications();
  }

  void markAllAsRead() {
    final remote = ref.read(notificationRepositoryProvider);
    if (remote is RemoteNotificationRepository) {
      remote
          .readAll()
          .then((items) {
            if (ref.mounted) state = items;
          })
          .catchError((Object _) {});
      return;
    }
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
