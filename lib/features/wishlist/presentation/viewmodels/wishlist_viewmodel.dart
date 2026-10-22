import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../home/domain/entities/product_entity.dart';
import '../../di/wishlist_providers.dart';
import '../../../../core/network/remote_repositories.dart';

class WishlistState {
  const WishlistState({
    this.items = const [],
    this.selectedCategory = 'Tất cả',
    this.searchQuery = '',
    this.errorMessage,
  });

  final List<ProductEntity> items;
  final String selectedCategory;
  final String searchQuery;
  final String? errorMessage;

  Set<String> get favoriteIds => items.map((item) => item.id).toSet();
  bool isFavorite(String productId) => favoriteIds.contains(productId);
  int get totalCount => items.length;

  List<ProductEntity> get filteredItems => items.where((product) {
    final query = searchQuery.toLowerCase();
    final matchesSearch =
        query.isEmpty ||
        product.title.toLowerCase().contains(query) ||
        product.category.toLowerCase().contains(query);
    if (!matchesSearch) return false;
    if (selectedCategory == 'Tất cả') return true;
    if (selectedCategory == 'Đang giảm giá') {
      return product.originalPrice != null &&
          product.originalPrice! > product.price;
    }
    return product.category.toLowerCase() == selectedCategory.toLowerCase();
  }).toList();

  WishlistState copyWith({
    List<ProductEntity>? items,
    String? selectedCategory,
    String? searchQuery,
    String? errorMessage,
  }) => WishlistState(
    items: items ?? this.items,
    selectedCategory: selectedCategory ?? this.selectedCategory,
    searchQuery: searchQuery ?? this.searchQuery,
    errorMessage: errorMessage,
  );
}

class WishlistViewModel extends Notifier<WishlistState> {
  @override
  WishlistState build() {
    final repository = ref.read(wishlistRepositoryProvider);
    if (repository is RemoteWishlistRepository) {
      Future.microtask(() => refresh());
    }
    return WishlistState(items: repository.getItems());
  }

  void _saveItems(List<ProductEntity> items) {
    final repository = ref.read(wishlistRepositoryProvider);
    if (repository is RemoteWishlistRepository) {
      repository
          .synchronize(items)
          .then((remote) {
            if (ref.mounted) state = state.copyWith(items: remote);
          })
          .catchError((Object error) {
            if (ref.mounted) state = state.copyWith(errorMessage: '$error');
          });
    } else {
      repository.saveItems(items);
    }
    state = state.copyWith(items: items);
  }

  bool toggleFavorite(ProductEntity product) {
    if (state.isFavorite(product.id)) {
      removeFromWishlist(product.id);
      return false;
    }
    _saveItems([product.copyWith(isFavorite: true), ...state.items]);
    return true;
  }

  void removeFromWishlist(String productId) => _saveItems(
    state.items.where((product) => product.id != productId).toList(),
  );

  void filterByCategory(String category) =>
      state = state.copyWith(selectedCategory: category);

  void updateSearchQuery(String query) =>
      state = state.copyWith(searchQuery: query);

  void clearAll() => _saveItems(const []);

  Future<void> refresh() async {
    try {
      final items = await ref.read(wishlistRepositoryProvider).refresh();
      if (ref.mounted) state = state.copyWith(items: items);
    } catch (error) {
      if (ref.mounted) state = state.copyWith(errorMessage: '$error');
    }
  }
}

final wishlistViewModelProvider =
    NotifierProvider<WishlistViewModel, WishlistState>(WishlistViewModel.new);
