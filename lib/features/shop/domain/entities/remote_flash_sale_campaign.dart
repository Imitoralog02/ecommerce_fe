import '../../../home/domain/entities/product_entity.dart';

class RemoteFlashSaleCampaign {
  const RemoteFlashSaleCampaign({
    required this.id,
    required this.title,
    required this.startsAt,
    required this.endsAt,
    required this.products,
  });

  final String id;
  final String title;
  final DateTime startsAt;
  final DateTime endsAt;
  final List<ProductEntity> products;
}
