import '../../domain/entities/search_suggestions.dart';
import '../../../home/domain/repositories/product_repository.dart';
import '../../domain/entities/visual_search_result.dart';
import '../../domain/repositories/search_repository.dart';

class MockSearchRepository implements SearchRepository {
  MockSearchRepository(this._productRepository);

  final ProductRepository _productRepository;

  List<String> _recent = const [
    'Đầm hoa midi',
    'Hoodie lavender',
    'Túi da khoá vàng',
    'Sneaker trắng',
  ];

  static const _trending = [
    'Đầm hoa midi 🌸',
    'Hoodie lavender 💜',
    'Áo blazer cream 🧥',
    'Sneaker da trắng 👟',
    'Túi da quai đeo ✨',
    'Flash Sale -50% 🔥',
  ];

  @override
  SearchSuggestions loadSuggestions() => SearchSuggestions(
    recentSearches: List.unmodifiable(_recent),
    trendingSearches: _trending,
  );

  @override
  void saveRecentSearches(List<String> searches) {
    _recent = List<String>.from(searches);
  }

  @override
  Future<VisualSearchResult> searchByImage(String imagePath) async {
    final products = await _productRepository.getFeaturedProducts();
    await Future<void>.delayed(const Duration(milliseconds: 2200));
    return VisualSearchResult(
      detectedLabel: 'Đầm hoa midi',
      confidence: 0.98,
      products: List.unmodifiable(products.take(2)),
    );
  }
}
