import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/notification_providers.dart';
import '../../domain/entities/notification_entity.dart';
import '../../../../core/network/remote_repositories.dart';

class NotificationViewModel extends Notifier<List<NotificationEntity>> {
  @override
  List<NotificationEntity> build() {
    final repository = ref.read(notificationRepositoryProvider);
    if (repository is RemoteNotificationRepository) {
      Future.microtask(refresh);
    }
    return repository.getNotifications();
  }

  Future<void> refresh() async {
    final repository = ref.read(notificationRepositoryProvider);
    if (repository is! RemoteNotificationRepository ||
        !repository.api.isAuthenticated) {
      return;
    }
    try {
      final items = await repository.refresh();
      if (ref.mounted) {
        state = items;
        ref.read(notificationErrorProvider.notifier).setError(null);
      }
    } catch (error) {
      if (ref.mounted) {
        ref.read(notificationErrorProvider.notifier).setError('$error');
      }
    }
  }

  Future<bool> markAsRead(String id) async {
    final remote = ref.read(notificationRepositoryProvider);
    if (remote is RemoteNotificationRepository) {
      try {
        final items = await remote.read(id);
        if (ref.mounted) {
          state = items;
          ref.read(notificationErrorProvider.notifier).setError(null);
        }
        return true;
      } catch (error) {
        if (ref.mounted) {
          ref.read(notificationErrorProvider.notifier).setError('$error');
        }
        return false;
      }
    }
    final repository = ref.read(notificationRepositoryProvider)..markAsRead(id);
    state = repository.getNotifications();
    return true;
  }

  Future<bool> markAllAsRead() async {
    final remote = ref.read(notificationRepositoryProvider);
    if (remote is RemoteNotificationRepository) {
      try {
        final items = await remote.readAll();
        if (ref.mounted) {
          state = items;
          ref.read(notificationErrorProvider.notifier).setError(null);
        }
        return true;
      } catch (error) {
        if (ref.mounted) {
          ref.read(notificationErrorProvider.notifier).setError('$error');
        }
        return false;
      }
    }
    final repository = ref.read(notificationRepositoryProvider)
      ..markAllAsRead();
    state = repository.getNotifications();
    return true;
  }
}

class NotificationError extends Notifier<String?> {
  @override
  String? build() => null;

  void setError(String? error) => state = error;
}

final notificationErrorProvider = NotifierProvider<NotificationError, String?>(
  NotificationError.new,
);

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
