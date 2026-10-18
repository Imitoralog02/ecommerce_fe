import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/mock_notification_repository.dart';
import '../domain/repositories/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return MockNotificationRepository();
});
