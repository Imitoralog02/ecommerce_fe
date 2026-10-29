import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/remote_repositories.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../di/home_providers.dart';
import '../../domain/entities/product_entity.dart';
export '../../di/home_providers.dart';

class HomeState {
  final bool isLoading;
  final String? errorMessage;
  final List<ProductEntity> allProducts;
  final String selectedCategory;

  const HomeState({
    this.isLoading = false,
    this.errorMessage,
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
    String? errorMessage,
    bool clearError = false,
    List<ProductEntity>? allProducts,
    String? selectedCategory,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
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
    if (!ref.mounted) return;
    final repository = ref.read(productRepositoryProvider);
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final all = repository is RemoteProductRepository
          ? await repository.getAllProducts()
          : await repository.getFeaturedProducts();
      if (repository is RemoteProductRepository &&
          !repository.api.isAuthenticated) {
        await repository.api.restoreSession();
        if (repository.api.isAuthenticated && ref.mounted) {
          ref.invalidate(authViewModelProvider);
        }
      }
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        allProducts: all,
        clearError: true,
      );
    } catch (error) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: error is ApiException
            ? error.message
            : 'Đã xảy ra lỗi. Vui lòng thử lại.',
      );
    }
  }

  void selectCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }
}

final homeViewModelProvider = NotifierProvider<HomeViewModel, HomeState>(() {
  return HomeViewModel();
});
