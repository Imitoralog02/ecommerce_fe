import '../../../home/domain/entities/product_entity.dart';

abstract class WishlistRepository {
  List<ProductEntity> getItems();
  Future<List<ProductEntity>> refresh();
  void saveItems(List<ProductEntity> items);
}
