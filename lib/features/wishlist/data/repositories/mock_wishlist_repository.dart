import '../../../home/domain/entities/product_entity.dart';
import '../../domain/repositories/wishlist_repository.dart';

class MockWishlistRepository implements WishlistRepository {
  MockWishlistRepository(List<ProductEntity> catalog)
    : _items = catalog
          .where((product) => product.isFavorite)
          .map((product) => product.copyWith(isFavorite: true))
          .toList();

  List<ProductEntity> _items;

  @override
  List<ProductEntity> getItems() => List.unmodifiable(_items);

  @override
  Future<List<ProductEntity>> refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return List.unmodifiable(_items);
  }

  @override
  void saveItems(List<ProductEntity> items) {
    _items = List<ProductEntity>.from(items);
  }
}
