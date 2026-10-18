import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bouncy_heart_button.dart';
import '../../../../core/widgets/product_visual_widget.dart';
import '../../../cart/presentation/viewmodels/cart_viewmodel.dart';
import '../../../cart/presentation/views/cart_screen.dart';
import '../../../home/domain/entities/product_entity.dart';
import '../../../product_detail/presentation/views/product_detail_screen.dart';
import '../viewmodels/wishlist_viewmodel.dart';

class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen> {
  final List<String> _categories = [
    'Tất cả',
    'Đầm',
    'Hoodie',
    'Giày',
    'Túi',
    'Đang giảm giá',
  ];

  String _categoryLabel(AppLocalizations strings, String category) =>
      switch (category) {
        'Đầm' => strings.categoryDress,
        'Hoodie' => strings.categoryHoodie,
        'Giày' => strings.categoryShoes,
        'Túi' => strings.categoryBag,
        'Đang giảm giá' => strings.onSaleCategory,
        _ => strings.categoryAll,
      };

  void _handleQuickAddToCart(ProductEntity product) {
    final strings = AppLocalizations.of(context);
    ref.read(cartViewModelProvider.notifier).addToCart(product);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                strings.addedWishlistProductToCart(product.title),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.brandBlack,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        action: SnackBarAction(
          label: strings.viewCartAction,
          textColor: AppColors.coralOrange,
          onPressed: () {
            Navigator.push(
              context,
              AppRouter.page(builder: (_) => const CartScreen()),
            );
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final wishlistState = ref.watch(wishlistViewModelProvider);
    final filteredItems = wishlistState.filteredItems;
    final totalCount = wishlistState.totalCount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: Center(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cardBorder, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        title: Text(
          strings.wishlistTitle,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
        actions: [
          if (totalCount > 0)
            GestureDetector(
              onTap: () {
                ref.read(wishlistViewModelProvider.notifier).clearAll();
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Center(
                  child: Text(
                    strings.clearWishlistAction,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.saleRed,
                    ),
                  ),
                ),
              ),
            ),
          // Total items count chip
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.softPeach,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder, width: 0.8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('💖', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text(
                    '$totalCount',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: AppColors.lyraWarmText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Horizontal Category Filter Chips
          Container(
            height: 48,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = wishlistState.selectedCategory == category;

                return GestureDetector(
                  onTap: () {
                    ref
                        .read(wishlistViewModelProvider.notifier)
                        .filterByCategory(category);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.brandBlack : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.brandBlack
                            : AppColors.cardBorder,
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF502814,
                          ).withValues(alpha: isSelected ? 0.12 : 0.03),
                          blurRadius: isSelected ? 10 : 4,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _categoryLabel(strings, category),
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: isSelected
                              ? FontWeight.w900
                              : FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 2. Main Content Grid or Empty State
          Expanded(
            child: filteredItems.isEmpty
                ? _buildEmptyState(
                    context,
                    isSearchEmpty: wishlistState.items.isNotEmpty,
                  )
                : RefreshIndicator(
                    color: AppColors.coralOrange,
                    onRefresh: () =>
                        ref.read(wishlistViewModelProvider.notifier).refresh(),
                    child: GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      physics: const AlwaysScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.61,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final product = filteredItems[index];
                        return _buildProductCard(context, product);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductEntity product) {
    final strings = AppLocalizations.of(context);
    final int? discountPercent =
        product.originalPrice != null && product.originalPrice! > product.price
        ? (((product.originalPrice! - product.price) / product.originalPrice!) *
                  100)
              .round()
        : null;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.cardBorder, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF14120E).withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Image Thumbnail with Heart & Tags
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      AppRouter.page(
                        builder: (_) => ProductDetailScreen(product: product),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Hero(
                      tag: 'wishlist_img_${product.id}',
                      child: product.imagePath != null
                          ? Image.asset(
                              product.imagePath!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                color: AppColors.softPeach,
                                child: Center(
                                  child: ProductVisualWidget(
                                    imageType: product.imageType,
                                    size: 80,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              color: AppColors.softPeach,
                              child: Center(
                                child: ProductVisualWidget(
                                  imageType: product.imageType,
                                  size: 80,
                                ),
                              ),
                            ),
                    ),
                  ),
                ),

                // Tag Badge (BÁN CHẠY / MỚI)
                if (product.tag.isNotEmpty)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: product.tag == 'MỚI'
                            ? AppColors.mintGreen
                            : AppColors.coralOrange,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        product.tag,
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),

                // Discount Badge (-30%)
                if (discountPercent != null)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2.5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warmYellow,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        '-$discountPercent%',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF4A2E00),
                        ),
                      ),
                    ),
                  ),

                // Bouncy Heart Button (Active state)
                Positioned(
                  top: 6,
                  right: 6,
                  child: BouncyHeartButton(
                    isFavorite: true,
                    size: 16.5,
                    backgroundColor: Colors.white.withValues(alpha: 0.95),
                    onFavoriteChanged: (val) {
                      if (!val) {
                        ref
                            .read(wishlistViewModelProvider.notifier)
                            .removeFromWishlist(product.id);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 2. Product Information
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  product.composition,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      product.formattedPrice,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.saleRed,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (product.formattedOriginalPrice != null) ...[
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          product.formattedOriginalPrice!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10.5,
                            decoration: TextDecoration.lineThrough,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 3. Quick "Thêm vào giỏ" Capsule Button
          GestureDetector(
            onTap: () => _handleQuickAddToCart(product),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.softPeach,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder, width: 0.8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_bag_outlined,
                    size: 14,
                    color: AppColors.lyraWarmText,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    strings.addToCartShortAction,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.lyraWarmText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, {required bool isSearchEmpty}) {
    final strings = AppLocalizations.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.softPeach,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cardBorder, width: 1.5),
              ),
              child: const Center(
                child: Text('💖', style: TextStyle(fontSize: 48)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isSearchEmpty
                  ? strings.wishlistNoFilterResultsTitle
                  : strings.emptyWishlistTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearchEmpty
                  ? strings.wishlistNoFilterResultsSubtitle
                  : strings.emptyWishlistSubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (isSearchEmpty) {
                  ref
                      .read(wishlistViewModelProvider.notifier)
                      .filterByCategory('Tất cả');
                } else {
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandBlack,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                isSearchEmpty
                    ? strings.viewAllWishlistAction
                    : strings.exploreCollectionAction,
                style: const TextStyle(
                  fontSize: 13.5,
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
