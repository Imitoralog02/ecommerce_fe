import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/domain/entities/product_entity.dart';
import '../../di/support_providers.dart';
import '../../domain/entities/support_message_entity.dart';

class ChatState {
  final List<SupportMessageEntity> messages;
  final bool isStylistTyping;
  final ProductEntity? attachedProduct;
  final String? attachedOrderId;

  const ChatState({
    required this.messages,
    this.isStylistTyping = false,
    this.attachedProduct,
    this.attachedOrderId,
  });

  ChatState copyWith({
    List<SupportMessageEntity>? messages,
    bool? isStylistTyping,
    ProductEntity? attachedProduct,
    String? attachedOrderId,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isStylistTyping: isStylistTyping ?? this.isStylistTyping,
      attachedProduct: attachedProduct ?? this.attachedProduct,
      attachedOrderId: attachedOrderId ?? this.attachedOrderId,
    );
  }
}

class ChatViewModel extends Notifier<ChatState> {
  static final List<QuickPromptTopic> quickPrompts = [
    const QuickPromptTopic(
      title: '📏 Tư vấn size chuẩn',
      prompt:
          'Bạn có thể tư vấn chọn size chuẩn theo vóc dáng giúp tôi được không?',
      reply:
          'Dạ chào bạn! Các thiết kế NÉORA được cắt rập theo tỷ lệ người Việt. Bạn cho Chi xin chiều cao, cân nặng để Chi gợi ý chuẩn size tôn dáng nhất cho bạn nhé ✨',
    ),
    const QuickPromptTopic(
      title: '🚚 Thời gian giao hàng',
      prompt: 'Thời gian giao hàng tiêu chuẩn mất bao lâu và phí ship thế nào?',
      reply:
          'NÉORA hỗ trợ giao hỏa tốc 2h tại TP.HCM & Hà Nội. Toàn quốc giao từ 2-3 ngày làm việc. Đơn từ 300K luôn được miễn phí vận chuyển toàn quốc ạ! 📦',
    ),
    const QuickPromptTopic(
      title: '🔄 Chính sách đổi trả 30 ngày',
      prompt: 'Tôi muốn tìm hiểu chính sách đổi trả hàng nếu mặc không vừa?',
      reply:
          'Bạn hoàn toàn an tâm nhé! NÉORA hỗ trợ đổi size, đổi mẫu miễn phí tận nhà trong 30 ngày, shipper sẽ mang hàng mới đến đổi và lấy hàng cũ về rất tiện lợi ạ 🌿',
    ),
    const QuickPromptTopic(
      title: '🎁 Mã voucher hôm nay',
      prompt: 'Hôm nay NÉORA có voucher hoặc ưu đãi gì đặc biệt không?',
      reply:
          'Hiện bạn đang có mã GIAM30K cho đơn từ 299K và Freeship toàn quốc trong Ví Voucher. Đặc biệt điểm danh hôm nay bạn còn nhận thêm +50 xu NÉORA nữa đó ạ! ✨',
    ),
  ];

  @override
  ChatState build() {
    return ChatState(
      messages: ref.read(supportRepositoryProvider).initialMessages(),
      isStylistTyping: false,
    );
  }

  Future<void> attachProduct(ProductEntity product) async {
    if (state.attachedProduct?.id == product.id) return;

    final now = DateTime.now();
    final productBubble = SupportMessageEntity(
      id: 'attach_${DateTime.now().millisecondsSinceEpoch}',
      text:
          'Tôi đang quan tâm đến sản phẩm "${product.title}" này, nhờ Stylist tư vấn thêm giúp tôi nhé!',
      timestamp: now,
      isUser: true,
      attachedProduct: product,
    );

    state = state.copyWith(
      attachedProduct: product,
      messages: [...state.messages, productBubble],
      isStylistTyping: true,
    );

    final replyText = await ref
        .read(supportRepositoryProvider)
        .replyToProduct(product);
    if (!ref.mounted) return;
    _appendReply(replyText);
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final now = DateTime.now();
    final userMsg = SupportMessageEntity(
      id: 'usr_${now.millisecondsSinceEpoch}',
      text: text.trim(),
      timestamp: now,
      isUser: true,
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isStylistTyping: true,
    );

    final replyText = await ref
        .read(supportRepositoryProvider)
        .replyToMessage(text);
    if (!ref.mounted) return;
    _appendReply(replyText);
  }

  Future<void> sendQuickPrompt(QuickPromptTopic prompt) async {
    final now = DateTime.now();
    final userMsg = SupportMessageEntity(
      id: 'usr_prompt_${now.millisecondsSinceEpoch}',
      text: prompt.prompt,
      timestamp: now,
      isUser: true,
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isStylistTyping: true,
    );

    final replyText = await ref
        .read(supportRepositoryProvider)
        .replyToQuickPrompt(prompt);
    if (!ref.mounted) return;
    _appendReply(replyText);
  }

  void _appendReply(String text) {
    final reply = SupportMessageEntity(
      id: 'reply_${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      timestamp: DateTime.now(),
      isUser: false,
    );
    state = state.copyWith(
      messages: [...state.messages, reply],
      isStylistTyping: false,
    );
  }
}

final chatViewModelProvider = NotifierProvider<ChatViewModel, ChatState>(() {
  return ChatViewModel();
});
