import '../../../home/domain/entities/product_entity.dart';
import '../../../../data/local/demo_preferences_store.dart';
import '../../domain/repositories/recently_viewed_repository.dart';

class MockRecentlyViewedRepository implements RecentlyViewedRepository {
  MockRecentlyViewedRepository(List<ProductEntity> catalog, [this._store])
    : _items = catalog.take(4).toList() {
    final saved = _store?.read(_key);
    if (saved is List) {
      final byId = {for (final product in catalog) product.id: product};
      _items = saved
          .whereType<String>()
          .map((id) => byId[id])
          .whereType<ProductEntity>()
          .toList();
    }
  }

  static const _key = 'demo_recently_viewed_v1';
  final DemoPreferencesStore? _store;

  List<ProductEntity> _items;

  @override
  List<ProductEntity> load() => List.unmodifiable(_items);

  @override
  void save(List<ProductEntity> items) {
    _items = List<ProductEntity>.from(items);
    _store?.write(_key, _items.map((item) => item.id).toList());
  }
}
