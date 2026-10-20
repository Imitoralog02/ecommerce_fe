import '../../../home/domain/entities/product_entity.dart';
import '../entities/support_message_entity.dart';

abstract class SupportRepository {
  List<SupportMessageEntity> initialMessages();
  void saveMessages(List<SupportMessageEntity> messages);
  Future<String> replyToMessage(String text);
  Future<String> replyToProduct(ProductEntity product);
  Future<String> replyToQuickPrompt(QuickPromptTopic prompt);
}
