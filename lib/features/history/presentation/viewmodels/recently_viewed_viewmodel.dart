import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/domain/entities/product_entity.dart';
import '../../di/history_providers.dart';

class RecentlyViewedState {
  final List<ProductEntity> items;

  const RecentlyViewedState({this.items = const []});

  RecentlyViewedState copyWith({List<ProductEntity>? items}) {
    return RecentlyViewedState(items: items ?? this.items);
  }
}

class RecentlyViewedViewModel extends Notifier<RecentlyViewedState> {
  @override
  RecentlyViewedState build() => RecentlyViewedState(
    items: ref.read(recentlyViewedRepositoryProvider).load(),
  );

  void _save(List<ProductEntity> items) {
    ref.read(recentlyViewedRepositoryProvider).save(items);
    state = state.copyWith(items: items);
  }

  void recordView(ProductEntity product) {
    final currentList = List<ProductEntity>.from(state.items);
    // Remove if already exists so we can move it to the front
    currentList.removeWhere((p) => p.id == product.id);
    currentList.insert(0, product);
    _save(currentList);
  }

  void removeItem(String productId) {
    final currentList = List<ProductEntity>.from(state.items);
    currentList.removeWhere((p) => p.id == productId);
    _save(currentList);
  }

  void clearAll() {
    _save(const []);
  }
}

final recentlyViewedViewModelProvider =
    NotifierProvider<RecentlyViewedViewModel, RecentlyViewedState>(
      RecentlyViewedViewModel.new,
    );
