import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<List<ProductEntity>> getFeaturedProducts();
  Future<List<ProductEntity>> getSneakers();
  Future<ProductEntity?> getProductById(String id);
  Future<List<ProductEntity>> getProductsByCategory(String category);
}
