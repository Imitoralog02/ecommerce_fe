import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/domain/entities/product_entity.dart';
import '../../di/search_providers.dart';

class SearchFilterState {
  final List<String> recentSearches;
  final List<String> trendingSearches;
  final RangeValues priceRange;
  final List<Color> selectedColors;
  final List<String> selectedSizes;
  final String sortBy; // 'popular', 'newest', 'priceAsc', 'priceDesc'
  final String selectedCategory;

  const SearchFilterState({
    required this.recentSearches,
    required this.trendingSearches,
    required this.priceRange,
    required this.selectedColors,
    required this.selectedSizes,
    required this.sortBy,
    required this.selectedCategory,
  });

  bool get hasActiveFilters {
    return priceRange.start > 0 ||
        priceRange.end < 2000000 ||
        selectedColors.isNotEmpty ||
        selectedSizes.isNotEmpty ||
        sortBy != 'popular' ||
        selectedCategory != 'Tất cả';
  }

  int get activeFilterCount {
    int count = 0;
    if (priceRange.start > 0 || priceRange.end < 2000000) count++;
    if (selectedColors.isNotEmpty) count += selectedColors.length;
    if (selectedSizes.isNotEmpty) count += selectedSizes.length;
    if (sortBy != 'popular') count++;
    if (selectedCategory != 'Tất cả') count++;
    return count;
  }

  SearchFilterState copyWith({
    List<String>? recentSearches,
    List<String>? trendingSearches,
    RangeValues? priceRange,
    List<Color>? selectedColors,
    List<String>? selectedSizes,
    String? sortBy,
    String? selectedCategory,
  }) {
    return SearchFilterState(
      recentSearches: recentSearches ?? this.recentSearches,
      trendingSearches: trendingSearches ?? this.trendingSearches,
      priceRange: priceRange ?? this.priceRange,
      selectedColors: selectedColors ?? this.selectedColors,
      selectedSizes: selectedSizes ?? this.selectedSizes,
      sortBy: sortBy ?? this.sortBy,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }

  List<ProductEntity> filterProducts(List<ProductEntity> source, String query) {
    var result = source.where((p) {
      // 1. Text Query
      final cleanQuery = query.toLowerCase().trim();
      if (cleanQuery.isNotEmpty) {
        final matches =
            p.title.toLowerCase().contains(cleanQuery) ||
            p.description.toLowerCase().contains(cleanQuery) ||
            p.brand.toLowerCase().contains(cleanQuery) ||
            p.category.toLowerCase().contains(cleanQuery) ||
            p.subCategory.toLowerCase().contains(cleanQuery);
        if (!matches) return false;
      }

      // 2. Category
      if (selectedCategory != 'Tất cả') {
        final matchesCat =
            p.category.toLowerCase() == selectedCategory.toLowerCase() ||
            p.subCategory.toLowerCase().contains(
              selectedCategory.toLowerCase(),
            ) ||
            p.title.toLowerCase().contains(selectedCategory.toLowerCase());
        if (!matchesCat) return false;
      }

      // 3. Price Range
      if (p.price < priceRange.start || p.price > priceRange.end) {
        return false;
      }

      // 4. Color filter (if selected)
      if (selectedColors.isNotEmpty) {
        final matchesColor = p.availableColors.any(
          (c) => selectedColors.any((sc) => sc.toARGB32() == c.toARGB32()),
        );
        if (!matchesColor) return false;
      }

      // 5. Size filter (if selected)
      if (selectedSizes.isNotEmpty) {
        final matchesSize = p.availableSizes.any(
          (s) => selectedSizes.contains(s),
        );
        if (!matchesSize) return false;
      }

      return true;
    }).toList();

    // Sorting
    switch (sortBy) {
      case 'priceAsc':
        result.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'priceDesc':
        result.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'newest':
        result.sort((a, b) => (b.isNew ? 1 : 0).compareTo(a.isNew ? 1 : 0));
        break;
      case 'popular':
      default:
        result.sort(
          (a, b) =>
              (b.rating * b.reviewCount).compareTo(a.rating * a.reviewCount),
        );
        break;
    }

    return result;
  }
}

class SearchFilterViewModel extends Notifier<SearchFilterState> {
  @override
  SearchFilterState build() {
    final suggestions = ref.read(searchRepositoryProvider).loadSuggestions();
    return SearchFilterState(
      recentSearches: suggestions.recentSearches,
      trendingSearches: suggestions.trendingSearches,
      priceRange: const RangeValues(0, 2000000),
      selectedColors: const [],
      selectedSizes: const [],
      sortBy: 'popular',
      selectedCategory: 'Tất cả',
    );
  }

  void _saveRecent(List<String> searches) {
    ref.read(searchRepositoryProvider).saveRecentSearches(searches);
    state = state.copyWith(recentSearches: searches);
  }

  void addRecentSearch(String query) {
    final clean = query.trim();
    if (clean.isEmpty) return;

    final updated = [
      clean,
      ...state.recentSearches.where(
        (s) => s.toLowerCase() != clean.toLowerCase(),
      ),
    ];
    if (updated.length > 8) updated.removeLast();

    _saveRecent(updated);
  }

  void removeRecentSearch(String query) {
    _saveRecent(state.recentSearches.where((s) => s != query).toList());
  }

  void clearRecentSearches() {
    _saveRecent(const []);
  }

  void setPriceRange(RangeValues values) {
    state = state.copyWith(priceRange: values);
  }

  void toggleColor(Color color) {
    final colors = List<Color>.from(state.selectedColors);
    if (colors.any((c) => c.toARGB32() == color.toARGB32())) {
      colors.removeWhere((c) => c.toARGB32() == color.toARGB32());
    } else {
      colors.add(color);
    }
    state = state.copyWith(selectedColors: colors);
  }

  void toggleSize(String size) {
    final sizes = List<String>.from(state.selectedSizes);
    if (sizes.contains(size)) {
      sizes.remove(size);
    } else {
      sizes.add(size);
    }
    state = state.copyWith(selectedSizes: sizes);
  }

  void setSortBy(String sort) {
    state = state.copyWith(sortBy: sort);
  }

  void setCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  void resetFilters() {
    state = state.copyWith(
      priceRange: const RangeValues(0, 2000000),
      selectedColors: [],
      selectedSizes: [],
      sortBy: 'popular',
      selectedCategory: 'Tất cả',
    );
  }
}

final searchFilterViewModelProvider =
    NotifierProvider<SearchFilterViewModel, SearchFilterState>(() {
      return SearchFilterViewModel();
    });
