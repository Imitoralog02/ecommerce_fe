import '../../../home/domain/entities/product_entity.dart';
import '../../domain/entities/support_message_entity.dart';
import '../../domain/repositories/support_repository.dart';

class MockSupportRepository implements SupportRepository {
  const MockSupportRepository();

  @override
  List<SupportMessageEntity> initialMessages() {
    final now = DateTime.now();
    return [
      SupportMessageEntity(
        id: 'welcome_1',
        text:
            'Xin chào bạn! Mình là Linh Chi — Senior Stylist tại NÉORA Concierge ✨',
        timestamp: now.subtract(const Duration(minutes: 5)),
        isUser: false,
      ),
      SupportMessageEntity(
        id: 'welcome_2',
        text:
            'Rất vui được đồng hành cùng bạn hôm nay. Bạn cần tư vấn về phối đồ, chọn size hay thông tin đơn hàng nào không ạ?',
        timestamp: now.subtract(const Duration(minutes: 4)),
        isUser: false,
      ),
    ];
  }

  @override
  Future<String> replyToProduct(ProductEntity product) async {
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    return 'Thiết kế "${product.title}" là một trong những best-seller của NÉORA mùa này đó ạ! '
        'Chất liệu cao cấp, đứng phom cực kỳ sang trọng. Bạn đang băn khoăn về kích cỡ hay cách phối màu để Chi tư vấn chi tiết nha ✨';
  }

  @override
  Future<String> replyToQuickPrompt(QuickPromptTopic prompt) async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    return prompt.reply;
  }

  @override
  Future<String> replyToMessage(String text) async {
    await Future<void>.delayed(const Duration(milliseconds: 1300));
    final cleanText = text.toLowerCase();
    if (_containsAny(cleanText, ['size', 'kích', 'kg', 'cao', 'mặc'])) {
      return 'Với phom dáng may đo NÉORA, bạn cho Chi xin thêm số đo chiều cao và cân nặng để Chi chọn size vừa vặn tôn dáng nhất cho bạn nhé!';
    }
    if (_containsAny(cleanText, ['đơn', 'ship', 'giao', 'vận chuyển'])) {
      return 'Đơn hàng được NÉORA đóng gói hộp quà thơm sang trọng và giao tận tay. Bạn có thể tra cứu hành trình trực tiếp trong mục "Theo dõi đơn hàng" ạ 🚚';
    }
    if (_containsAny(cleanText, ['đổi', 'trả', 'lỗi', 'hoàn'])) {
      return 'NÉORA hỗ trợ đổi trả miễn phí trong 30 ngày tận nhà. Bạn chỉ cần giữ nguyên tem mác là shipper sẽ mang đồ mới đến đổi ngay ạ 🔄';
    }
    if (_containsAny(cleanText, ['voucher', 'giảm', 'mã', 'xu'])) {
      return 'Bạn nhớ kiểm tra "Ví Voucher" để áp dụng các mã freeship và giảm giá độc quyền nhé. Đừng quên điểm danh hàng ngày nhận +50 xu nha 🎁';
    }
    if (_containsAny(cleanText, ['chào', 'hi', 'hello'])) {
      return 'Chi chào bạn ạ! Rất vui được hỗ trợ bạn tạo nên phong cách thời trang ấn tượng hôm nay ✨';
    }
    return 'Cảm ơn bạn đã chia sẻ! Chi đã ghi nhận thông tin và sẽ hỗ trợ ngay cho bạn ạ ✨';
  }

  bool _containsAny(String source, List<String> values) =>
      values.any(source.contains);
}
