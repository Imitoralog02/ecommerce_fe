import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/viewmodels/home_viewmodel.dart';
import '../../../home/presentation/widgets/product_card_widget.dart';
import '../../../product_detail/presentation/views/product_detail_screen.dart';
import '../../../search/presentation/viewmodels/search_filter_viewmodel.dart';
import '../../../search/presentation/widgets/neora_filter_sheet.dart';
import '../../../search/presentation/widgets/ai_visual_search_dialog.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchingFocused = false;
  Timer? _searchDebounce;
  String _debouncedQuery = '';

  final List<String> _categories = [
    'Tất cả',
    'Đầm',
    'Hoodie',
    'Áo len',
    'Sơ mi',
    'Túi',
    'Giày',
  ];

  String _categoryLabel(AppLocalizations strings, String category) =>
      switch (category) {
        'Đầm' => strings.categoryDress,
        'Hoodie' => strings.categoryHoodie,
        'Áo len' => strings.categoryKnitwear,
        'Sơ mi' => strings.categoryShirt,
        'Túi' => strings.categoryBag,
        'Giày' => strings.categoryShoes,
        _ => strings.categoryAll,
      };

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_handleSearchFocusChanged);
  }

  void _handleSearchFocusChanged() {
    if (!mounted) return;

    final hasFocus = _searchFocusNode.hasFocus;
    if (_isSearchingFocused == hasFocus) return;

    setState(() {
      _isSearchingFocused = hasFocus;
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchFocusNode.removeListener(_handleSearchFocusChanged);
    _searchFocusNode.unfocus();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSelectKeyword(String keyword) {
    _searchDebounce?.cancel();
    _searchController.text = keyword;
    _debouncedQuery = keyword;
    ref.read(searchFilterViewModelProvider.notifier).addRecentSearch(keyword);
    _searchFocusNode.unfocus();
    setState(() {});
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted || value != _searchController.text) return;
      setState(() => _debouncedQuery = value);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final homeState = ref.watch(homeViewModelProvider);
    final allProducts = homeState.allProducts;
    final filterState = ref.watch(searchFilterViewModelProvider);
    final filterNotifier = ref.read(searchFilterViewModelProvider.notifier);

    final filtered = filterState.filterProducts(allProducts, _debouncedQuery);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Search Bar with Clear & Camera AI Lens Button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      size: 22,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        onSubmitted: (val) {
                          _searchDebounce?.cancel();
                          _debouncedQuery = val;
                          if (val.trim().isNotEmpty) {
                            filterNotifier.addRecentSearch(val.trim());
                          }
                          setState(() {});
                        },
                        onChanged: _onSearchChanged,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brandBlack,
                        ),
                        decoration: InputDecoration(
                          hintText: strings.shopSearchHint,
                          hintStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          _searchDebounce?.cancel();
                          _debouncedQuery = '';
                          setState(() {});
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(right: 6),
                          child: Icon(
                            Icons.cancel_rounded,
                            size: 18,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    GestureDetector(
                      onTap: () => AIVisualSearchDialog.show(context),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppColors.softPeach,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          size: 18,
                          color: AppColors.coralOrange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // If user has focused search with empty query, show Recent & Trending
            if (_isSearchingFocused && _searchController.text.isEmpty)
              Expanded(
                child: _buildSearchSuggestions(filterState, filterNotifier),
              )
            else ...[
              // 2. Horizontal Category Filter Chips
              Container(
                height: 40,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = cat == filterState.selectedCategory;

                    return GestureDetector(
                      onTap: () => filterNotifier.setCategory(cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.brandBlack
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.brandBlack
                                : AppColors.cardBorder,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isSelected ? 0.1 : 0.02,
                              ),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _categoryLabel(strings, cat),
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 3. Results Count & NÉORA Filter Button
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _debouncedQuery.isNotEmpty
                            ? strings.searchResultsLabel(
                                _debouncedQuery,
                                filtered.length,
                              )
                            : strings.categoryProductsLabel(
                                _categoryLabel(
                                  strings,
                                  filterState.selectedCategory,
                                ),
                                filtered.length,
                              ),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => NeoraFilterSheet.show(
                        context,
                        totalMatching: filtered.length,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: filterState.hasActiveFilters
                              ? AppColors.brandBlack
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: filterState.hasActiveFilters
                                ? AppColors.brandBlack
                                : AppColors.cardBorder,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.tune_rounded,
                              size: 15,
                              color: filterState.hasActiveFilters
                                  ? Colors.white
                                  : AppColors.brandBlack,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              filterState.hasActiveFilters
                                  ? strings.activeFiltersAction(
                                      filterState.activeFilterCount,
                                    )
                                  : strings.filtersAction,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: filterState.hasActiveFilters
                                    ? Colors.white
                                    : AppColors.brandBlack,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 4. 2-Column Product Grid or Empty State
              Expanded(
                child: filtered.isEmpty
                    ? _buildEmptyResults(filterNotifier)
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        physics: const AlwaysScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 14,
                              childAspectRatio: 0.65,
                            ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final product = filtered[index];
                          return ProductCardWidget(
                            product: product,
                            onTap: () {
                              Navigator.push(
                                context,
                                AppRouter.page(
                                  builder: (_) =>
                                      ProductDetailScreen(product: product),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSuggestions(
    SearchFilterState filterState,
    SearchFilterViewModel filterNotifier,
  ) {
    final strings = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        // Recent Searches
        if (filterState.recentSearches.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                strings.recentSearchesTitle,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMuted,
                  letterSpacing: 0.6,
                ),
              ),
              GestureDetector(
                onTap: () => filterNotifier.clearRecentSearches(),
                child: Text(
                  strings.clearAllAction,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.saleRed,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: filterState.recentSearches.map((query) {
              return GestureDetector(
                onTap: () => _onSelectKeyword(query),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder, width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.history_rounded,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        query,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => filterNotifier.removeRecentSearch(query),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],

        // Trending Searches
        Text(
          strings.trendingSearchesTitle,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: AppColors.textMuted,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: filterState.trendingSearches.map((trend) {
            return GestureDetector(
              onTap: () => _onSelectKeyword(
                trend.replaceAll(RegExp(r'[^a-zA-Z0-9\sÀ-ỹ]'), '').trim(),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.softPeach,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder, width: 0.8),
                ),
                child: Text(
                  trend,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.lyraWarmText,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEmptyResults(SearchFilterViewModel filterNotifier) {
    final strings = AppLocalizations.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.softPeach,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cardBorder, width: 1.5),
              ),
              child: const Center(
                child: Icon(
                  Icons.search_off_rounded,
                  size: 36,
                  color: AppColors.coralOrange,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              strings.noMatchingProductsTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              strings.noMatchingProductsSubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                _searchDebounce?.cancel();
                _debouncedQuery = '';
                filterNotifier.resetFilters();
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandBlack,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                strings.resetFiltersAction,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
