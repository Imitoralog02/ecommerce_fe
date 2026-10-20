import '../../../../data/local/demo_preferences_store.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';

class MockNotificationRepository implements NotificationRepository {
  MockNotificationRepository([this._store]) {
    final saved = _store?.read(_readKey);
    if (saved is List) {
      final readIds = saved.whereType<String>().toSet();
      _items = _items
          .map((item) => item.copyWith(isRead: readIds.contains(item.id)))
          .toList();
    }
  }

  static const _readKey = 'demo_read_notifications_v1';
  final DemoPreferencesStore? _store;
  List<NotificationEntity> _items = const [
    NotificationEntity(
      id: 'notif_1',
      title: 'Đơn mẫu #NEO-2094 đang giao',
      description:
          'Trạng thái vận chuyển mô phỏng đã được cập nhật. Chưa có kiện hàng thật.',
      timeLabel: '10 phút trước',
      iconEmoji: '🚚',
      iconBackgroundValue: 0xFFFBF4EB,
      category: NotificationCategory.order,
      relatedOrderId: 'NEO-2094',
    ),
    NotificationEntity(
      id: 'notif_2',
      title: 'Voucher mẫu 50K cho Hội Viên Vàng ✨',
      description:
          'Dùng voucher trong bản demo để thử tính giá đơn đủ điều kiện.',
      timeLabel: '2 giờ trước',
      iconEmoji: '🎟️',
      iconBackgroundValue: 0xFFEDF4ED,
      category: NotificationCategory.promotion,
    ),
    NotificationEntity(
      id: 'notif_3',
      title: 'Điểm danh nhận +50 Xu hôm nay',
      description:
          'Bạn chưa điểm danh hôm nay! Vào ví NÉORA ngay để nhận thêm 50 xu tích lũy thăng hạng Kim Cương nhé.',
      timeLabel: '5 giờ trước',
      iconEmoji: '🪙',
      iconBackgroundValue: 0xFFFFF7EB,
      category: NotificationCategory.promotion,
    ),
    NotificationEntity(
      id: 'notif_4',
      title: 'Đơn mẫu #NEO-3841 đã giao',
      description:
          'Đơn hàng đã được đánh dấu là đã giao trong bản demo. Bạn có thể thử viết đánh giá để nhận xu mẫu.',
      timeLabel: 'Hôm qua',
      iconEmoji: '📦',
      iconBackgroundValue: 0xFFEDF2ED,
      category: NotificationCategory.order,
      relatedOrderId: 'NEO-3841',
      isRead: true,
    ),
    NotificationEntity(
      id: 'notif_5',
      title: 'BST Thu Đông 2026 chính thức ra mắt',
      description:
          'Khám phá ngay các thiết kế áo len dệt kim, trench coat cao cấp phong cách Parisienne mới nhất tuần này.',
      timeLabel: '2 ngày trước',
      iconEmoji: '✨',
      iconBackgroundValue: 0xFFF7EFF5,
      category: NotificationCategory.promotion,
      isRead: true,
    ),
  ];

  @override
  List<NotificationEntity> getNotifications() => List.unmodifiable(_items);

  @override
  void markAsRead(String id) {
    _items = _items
        .map((item) => item.id == id ? item.copyWith(isRead: true) : item)
        .toList();
    _persistReadState();
  }

  @override
  void markAllAsRead() {
    _items = _items.map((item) => item.copyWith(isRead: true)).toList();
    _persistReadState();
  }

  void _persistReadState() {
    _store?.write(
      _readKey,
      _items.where((item) => item.isRead).map((item) => item.id).toList(),
    );
  }
}
