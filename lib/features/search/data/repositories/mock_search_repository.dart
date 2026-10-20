import '../../domain/entities/search_suggestions.dart';
import '../../../../data/local/demo_preferences_store.dart';
import '../../../home/domain/repositories/product_repository.dart';
import '../../domain/entities/visual_search_result.dart';
import '../../domain/repositories/search_repository.dart';

class MockSearchRepository implements SearchRepository {
  MockSearchRepository(this._productRepository, [this._store]) {
    final saved = _store?.read(_recentKey);
    if (saved is List) {
      _recent = saved.whereType<String>().toList();
    }
  }

  final ProductRepository _productRepository;
  final DemoPreferencesStore? _store;
  static const _recentKey = 'demo_recent_searches_v1';

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
    _store?.write(_recentKey, _recent);
  }

  @override
  Future<VisualSearchResult> searchByImage(String imagePath) async {
    final products = await _productRepository.getFeaturedProducts();
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final matching = products
        .where((product) => product.imagePath == imagePath)
        .toList();
    return VisualSearchResult(
      detectedLabel: matching.isEmpty
          ? 'Không có sản phẩm phù hợp'
          : matching.first.title,
      confidence: matching.isEmpty ? 0 : 1,
      products: List.unmodifiable(matching),
    );
  }
}
