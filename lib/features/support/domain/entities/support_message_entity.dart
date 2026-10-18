import '../../../home/domain/entities/product_entity.dart';

class SupportMessageEntity {
  final String id;
  final String text;
  final DateTime timestamp;
  final bool isUser;
  final ProductEntity? attachedProduct;
  final String? attachedOrderId;
  final bool isTypingIndicator;

  const SupportMessageEntity({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.isUser,
    this.attachedProduct,
    this.attachedOrderId,
    this.isTypingIndicator = false,
  });

  String get timeFormatted {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  SupportMessageEntity copyWith({
    String? id,
    String? text,
    DateTime? timestamp,
    bool? isUser,
    ProductEntity? attachedProduct,
    String? attachedOrderId,
    bool? isTypingIndicator,
  }) {
    return SupportMessageEntity(
      id: id ?? this.id,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      isUser: isUser ?? this.isUser,
      attachedProduct: attachedProduct ?? this.attachedProduct,
      attachedOrderId: attachedOrderId ?? this.attachedOrderId,
      isTypingIndicator: isTypingIndicator ?? this.isTypingIndicator,
    );
  }
}

class QuickPromptTopic {
  final String title;
  final String prompt;
  final String reply;

  const QuickPromptTopic({
    required this.title,
    required this.prompt,
    required this.reply,
  });
}
