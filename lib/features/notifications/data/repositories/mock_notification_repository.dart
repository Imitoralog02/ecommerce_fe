import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';

class MockNotificationRepository implements NotificationRepository {
  List<NotificationEntity> _items = const [
    NotificationEntity(
      id: 'notif_1',
      title: 'Đơn hàng #NEO-2094 đang được vận chuyển',
      description:
          'Kiện hàng thời trang NÉORA của bạn đã xuất kho Tân Bình và đang trên đường giao hỏa tốc.',
      timeLabel: '10 phút trước',
      iconEmoji: '🚚',
      iconBackgroundValue: 0xFFFBF4EB,
      category: NotificationCategory.order,
      relatedOrderId: 'NEO-2094',
    ),
    NotificationEntity(
      id: 'notif_2',
      title: 'Tặng bạn Voucher 50K mừng Hội Viên Vàng ✨',
      description:
          'Đặc quyền dành riêng cho khách hàng VIP: Giảm ngay 50.000₫ cho mọi đơn hàng từ 599.000₫ trong tháng này.',
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
      title: 'Đơn hàng #NEO-3841 đã giao thành công',
      description:
          'Đơn hàng của bạn đã được giao tận tay. Hãy để lại đánh giá để nhận ngay +50 Xu NÉORA.',
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
  }

  @override
  void markAllAsRead() {
    _items = _items.map((item) => item.copyWith(isRead: true)).toList();
  }
}
