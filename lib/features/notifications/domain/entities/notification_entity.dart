enum NotificationCategory { order, promotion }

class NotificationEntity {
  const NotificationEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.timeLabel,
    required this.iconEmoji,
    required this.iconBackgroundValue,
    required this.category,
    this.relatedOrderId,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String description;
  final String timeLabel;
  final String iconEmoji;
  final int iconBackgroundValue;
  final NotificationCategory category;
  final String? relatedOrderId;
  final bool isRead;

  NotificationEntity copyWith({bool? isRead}) => NotificationEntity(
    id: id,
    title: title,
    description: description,
    timeLabel: timeLabel,
    iconEmoji: iconEmoji,
    iconBackgroundValue: iconBackgroundValue,
    category: category,
    relatedOrderId: relatedOrderId,
    isRead: isRead ?? this.isRead,
  );
}
