import '../../../home/domain/entities/product_entity.dart';

class VisualSearchResult {
  const VisualSearchResult({
    required this.detectedLabel,
    required this.confidence,
    required this.products,
  });

  final String detectedLabel;
  final double confidence;
  final List<ProductEntity> products;
}
