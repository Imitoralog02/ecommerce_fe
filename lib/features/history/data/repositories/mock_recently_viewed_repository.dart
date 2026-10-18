import '../../../home/domain/entities/product_entity.dart';
import '../../domain/repositories/recently_viewed_repository.dart';

class MockRecentlyViewedRepository implements RecentlyViewedRepository {
  MockRecentlyViewedRepository(List<ProductEntity> catalog)
    : _items = catalog.take(4).toList();

  List<ProductEntity> _items;

  @override
  List<ProductEntity> load() => List.unmodifiable(_items);

  @override
  void save(List<ProductEntity> items) {
    _items = List<ProductEntity>.from(items);
  }
}
