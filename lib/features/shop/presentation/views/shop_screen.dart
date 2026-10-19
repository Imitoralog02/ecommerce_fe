import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../cart/presentation/viewmodels/cart_viewmodel.dart';
import '../../../cart/presentation/views/cart_screen.dart';
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
    'Sơ mi',
    'Áo len',
    'Hoodie',
    'Túi',
    'Giày',
  ];

  String _categoryLabel(AppLocalizations strings, String category) =>
      switch (category) {
        'Đầm' => 'Nữ · ${strings.categoryDress}',
        'Hoodie' => strings.categoryHoodie,
        'Áo len' => strings.categoryKnitwear,
        'Sơ mi' => 'Nam · ${strings.categoryShirt}',
        'Túi' => 'Phụ kiện · ${strings.categoryBag}',
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
    final cartCount = ref.watch(cartViewModelProvider).totalItemCount;

    final filtered = filterState.filterProducts(allProducts, _debouncedQuery);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Top Navigation Header: ← | Khám phá | 🛍️
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 2),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                  const Expanded(
                    child: Text(
                      'Khám phá',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTypography.serifFont,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.shopping_bag_outlined,
                          size: 20,
                          color: AppColors.textPrimary,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            AppRouter.page(builder: (_) => const CartScreen()),
                          );
                        },
                      ),
                      if (cartCount > 0)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 14,
                              minHeight: 14,
                            ),
                            child: Center(
                              child: Text(
                                '$cartCount',
                                style: const TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // 2. Editorial Heading
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'KHÁM PHÁ & MUA SẮM',
                    style: AppTypography.architecturalCode.copyWith(
                      color: AppColors.primary,
                      fontSize: 9.5,
                      letterSpacing: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tủ đồ có chọn lọc.',
                    style: AppTypography.editorialHeadline,
                  ),
                ],
              ),
            ),

            // 3. Search Bar with Clear & Camera AI Lens Button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 2, 20, 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.studioGray,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: AppColors.cardBorder, width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      size: 19,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
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
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: strings.shopSearchHint,
                          hintStyle: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
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
                            Icons.close_rounded,
                            size: 17,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    GestureDetector(
                      onTap: () => AIVisualSearchDialog.show(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.softPeach,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          size: 16,
                          color: AppColors.primary,
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
              // 4. Horizontal Category Filter Chips
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = cat == filterState.selectedCategory;

                    return GestureDetector(
                      onTap: () => filterNotifier.setCategory(cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.cardBorder,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _categoryLabel(strings, cat),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
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

              // 5. Filter Strip & Results Count (Figma NẾP style)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => NeoraFilterSheet.show(
                        context,
                        totalMatching: filtered.length,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: filterState.hasActiveFilters
                              ? AppColors.primary
                              : AppColors.studioGray,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: filterState.hasActiveFilters
                                ? AppColors.primary
                                : AppColors.cardBorder,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.tune_rounded,
                              size: 14,
                              color: filterState.hasActiveFilters
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              filterState.hasActiveFilters
                                  ? 'Bộ lọc • ${filterState.activeFilterCount}'
                                  : 'Bộ lọc',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: filterState.hasActiveFilters
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _debouncedQuery.isNotEmpty
                            ? strings.searchResultsLabel(
                                _debouncedQuery,
                                filtered.length,
                              )
                            : '${filtered.length} sản phẩm',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        final nextSort = filterState.sortBy == 'priceAsc'
                            ? 'priceDesc'
                            : filterState.sortBy == 'priceDesc'
                            ? 'popular'
                            : 'priceAsc';
                        filterNotifier.setSortBy(nextSort);
                      },
                      child: Text(
                        filterState.sortBy == 'priceAsc'
                            ? 'Giá thấp → cao ⌄'
                            : filterState.sortBy == 'priceDesc'
                            ? 'Giá cao → thấp ⌄'
                            : 'Gợi ý cho bạn ⌄',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 6. 2-Column Product Grid or Empty State
              Expanded(
                child: filtered.isEmpty
                    ? _buildEmptyResults(filterNotifier)
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                        physics: const AlwaysScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.64,
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        if (filterState.recentSearches.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                strings.recentSearchesTitle,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                  letterSpacing: 0.8,
                ),
              ),
              GestureDetector(
                onTap: () => filterNotifier.clearRecentSearches(),
                child: Text(
                  strings.clearAllAction,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
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
                    color: AppColors.studioGray,
                    borderRadius: BorderRadius.circular(4),
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
        Text(
          strings.trendingSearchesTitle,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted,
            letterSpacing: 0.8,
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
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.cardBorder, width: 0.8),
                ),
                child: Text(
                  trend,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
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
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.softPeach,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Center(
                child: Icon(
                  Icons.search_off_rounded,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              strings.noMatchingProductsTitle,
              style: const TextStyle(
                fontFamily: AppTypography.serifFont,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              strings.noMatchingProductsSubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
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
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Text(strings.resetFiltersAction),
            ),
          ],
        ),
      ),
    );
  }
}
