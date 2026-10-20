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
          'Dạ chào bạn! Đây là phần tư vấn size mẫu. Bạn có thể xem bảng size tại trang sản phẩm để đối chiếu số đo trước khi chọn nhé ✨',
    ),
    const QuickPromptTopic(
      title: '🚚 Thời gian giao hàng',
      prompt: 'Thời gian giao hàng tiêu chuẩn mất bao lâu và phí ship thế nào?',
      reply:
          'Trong bản demo, giao tiêu chuẩn dự kiến 2–3 ngày làm việc. Bạn xem thời gian và phí của phương thức đã chọn ngay tại checkout nhé 📦',
    ),
    const QuickPromptTopic(
      title: '🔄 Chính sách đổi trả 30 ngày',
      prompt: 'Tôi muốn tìm hiểu chính sách đổi trả hàng nếu mặc không vừa?',
      reply:
          'Chính sách hiển thị trong bản demo là đổi trả trong 30 ngày. Bạn có thể tạo yêu cầu mẫu từ chi tiết đơn, nhưng chưa có xử lý đổi hàng thực tế ạ 🌿',
    ),
    const QuickPromptTopic(
      title: '🎁 Mã voucher hôm nay',
      prompt: 'Hôm nay NÉORA có voucher hoặc ưu đãi gì đặc biệt không?',
      reply:
          'Bạn hãy kiểm tra các voucher mẫu đang có trong Ví NÉORA. Điều kiện và mức giảm của từng mã được tính ngay trong giỏ hàng demo ạ ✨',
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
    _saveMessages();

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
    _saveMessages();

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
    _saveMessages();

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
    _saveMessages();
  }

  void _saveMessages() =>
      ref.read(supportRepositoryProvider).saveMessages(state.messages);
}

final chatViewModelProvider = NotifierProvider<ChatViewModel, ChatState>(() {
  return ChatViewModel();
});
