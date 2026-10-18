import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../di/home_providers.dart';
import '../../domain/entities/product_entity.dart';
export '../../di/home_providers.dart';

class HomeState {
  final bool isLoading;
  final List<ProductEntity> allProducts;
  final String selectedCategory;

  const HomeState({
    this.isLoading = false,
    this.allProducts = const [],
    this.selectedCategory = 'Tất cả',
  });

  List<ProductEntity> get featuredProducts {
    if (selectedCategory == 'Tất cả' ||
        selectedCategory == 'ALL FORMS' ||
        selectedCategory == 'All') {
      return allProducts;
    }
    return allProducts
        .where(
          (p) => p.category.toLowerCase() == selectedCategory.toLowerCase(),
        )
        .toList();
  }

  // Backward compatibility
  List<ProductEntity> get products => allProducts;
  List<ProductEntity> get sneakers => allProducts;

  HomeState copyWith({
    bool? isLoading,
    List<ProductEntity>? allProducts,
    String? selectedCategory,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      allProducts: allProducts ?? this.allProducts,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

class HomeViewModel extends Notifier<HomeState> {
  @override
  HomeState build() {
    Future.microtask(() => loadHomeData());
    return const HomeState(isLoading: true);
  }

  Future<void> loadHomeData() async {
    final repository = ref.read(productRepositoryProvider);
    state = state.copyWith(isLoading: true);
    final all = await repository.getFeaturedProducts();
    state = state.copyWith(isLoading: false, allProducts: all);
  }

  void selectCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }
}

final homeViewModelProvider = NotifierProvider<HomeViewModel, HomeState>(() {
  return HomeViewModel();
});
