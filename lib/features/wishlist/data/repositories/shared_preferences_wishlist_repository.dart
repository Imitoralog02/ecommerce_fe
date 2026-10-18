import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../home/domain/entities/product_entity.dart';
import '../../domain/repositories/wishlist_repository.dart';

class SharedPreferencesWishlistRepository implements WishlistRepository {
  SharedPreferencesWishlistRepository(this._preferences, this._catalog);

  static const _key = 'demo_wishlist_ids_v1';
  final SharedPreferences _preferences;
  final List<ProductEntity> _catalog;

  @override
  List<ProductEntity> getItems() {
    final ids = _preferences.getStringList(_key);
    if (ids == null) {
      return List.unmodifiable(
        _catalog
            .where((product) => product.isFavorite)
            .map((product) => product.copyWith(isFavorite: true)),
      );
    }
    final byId = {for (final product in _catalog) product.id: product};
    return List.unmodifiable(
      ids
          .map((id) => byId[id])
          .whereType<ProductEntity>()
          .map((product) => product.copyWith(isFavorite: true)),
    );
  }

  @override
  Future<List<ProductEntity>> refresh() async => getItems();

  @override
  void saveItems(List<ProductEntity> items) {
    unawaited(
      _preferences.setStringList(_key, items.map((item) => item.id).toList()),
    );
  }
}
