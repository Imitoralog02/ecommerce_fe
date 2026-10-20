import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../cart/presentation/viewmodels/cart_viewmodel.dart';
import '../../../product_detail/presentation/views/product_detail_screen.dart';
import '../../domain/entities/product_entity.dart';
import '../viewmodels/home_viewmodel.dart';
import '../widgets/editorial_home_story.dart';
import '../widgets/home_closing_section.dart';
import '../widgets/neora_essentials_section.dart';
import '../../../notifications/presentation/views/notifications_screen.dart';
import '../../../shop/presentation/views/lookbook_screen.dart';
import '../../../wallet/presentation/views/voucher_wallet_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final VoidCallback onOpenCart;
  final VoidCallback? onOpenSearch;

  const HomeScreen({super.key, required this.onOpenCart, this.onOpenSearch});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  int _selectedFeedTab = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<ProductEntity> _getFilteredProducts(List<ProductEntity> allProducts) {
    switch (_selectedFeedTab) {
      case 1: // Nữ
        final list = allProducts
            .where(
              (p) =>
                  p.title.toLowerCase().contains('đầm') ||
                  p.title.toLowerCase().contains('váy') ||
                  p.title.toLowerCase().contains('len') ||
                  p.title.toLowerCase().contains('nữ'),
            )
            .toList();
        return list.isNotEmpty ? list : allProducts;
      case 2: // Nam
        final list = allProducts
            .where(
              (p) =>
                  p.title.toLowerCase().contains('nam') ||
                  p.title.toLowerCase().contains('sơ mi') ||
                  p.title.toLowerCase().contains('hoodie') ||
                  p.title.toLowerCase().contains('jeans'),
            )
            .toList();
        return list.isNotEmpty ? list : allProducts;
      case 3: // Phụ kiện
        final list = allProducts
            .where(
              (p) =>
                  p.title.toLowerCase().contains('túi') ||
                  p.title.toLowerCase().contains('giày') ||
                  p.title.toLowerCase().contains('sneaker'),
            )
            .toList();
        return list.isNotEmpty ? list : allProducts;
      default:
        return allProducts;
    }
  }

  void _openLookbook() {
    _openLookbookForOccasion('Đi làm');
  }

  void _openLookbookForOccasion(String occasion) {
    Navigator.push(
      context,
      AppRouter.page(builder: (_) => LookbookScreen(initialOccasion: occasion)),
    );
  }

  void _scrollToTop() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final homeState = ref.watch(homeViewModelProvider);
    final cartCount = ref.watch(cartViewModelProvider).totalItemCount;

    if (homeState.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final products = homeState.featuredProducts;
    final filteredProducts = _getFilteredProducts(products);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // 1. NÉORA Top Header: NÉORA | MẶC ĐẸP MỖI NGÀY | Search | Cart | Notifications
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 14, 6),
                child: Row(
                  children: [
                    Text(
                      'NÉORA',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textScaler: MediaQuery.textScalerOf(
                        context,
                      ).clamp(maxScaleFactor: 1.3),
                      style: AppTypography.brandLogo,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'MẶC ĐẸP MỖI NGÀY',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.4,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: strings.discoverTab,
                      onPressed: widget.onOpenSearch,
                      icon: const Icon(
                        Icons.search_rounded,
                        size: 21,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        IconButton(
                          tooltip: strings.cartTab,
                          onPressed: widget.onOpenCart,
                          icon: const Icon(
                            Icons.shopping_bag_outlined,
                            size: 21,
                            color: AppColors.textPrimary,
                          ),
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
                                minWidth: 15,
                                minHeight: 15,
                              ),
                              child: Center(
                                child: Text(
                                  '$cartCount',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    IconButton(
                      tooltip: strings.notificationsTab,
                      onPressed: () {
                        Navigator.push(
                          context,
                          AppRouter.page(
                            builder: (_) => const NotificationsScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        size: 21,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Quick Category Strip: Nữ ↗ | Nam ↗ | Phụ kiện ↗
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: Wrap(
                  spacing: 20,
                  runSpacing: 8,
                  children: [
                    _buildQuickLink('Nữ ↗', 1),
                    _buildQuickLink('Nam ↗', 2),
                    _buildQuickLink('Phụ kiện ↗', 3),
                  ],
                ),
              ),
            ),

            // 3. Editorial Hero + Stylist Occasion Picker + Everyday Living
            SliverToBoxAdapter(
              child: EditorialHomeStory(
                onDiscover: widget.onOpenSearch,
                onLookbook: _openLookbook,
                onOccasionTap: _openLookbookForOccasion,
              ),
            ),

            // 4. "Món cơ bản mỗi ngày" editorial essentials section
            SliverToBoxAdapter(
              child: NeoraEssentialsSection(
                products: filteredProducts,
                selectedTab: _selectedFeedTab,
                onTabSelected: (idx) {
                  setState(() {
                    _selectedFeedTab = idx;
                  });
                },
                onSeeAll: widget.onOpenSearch,
                onStyleTap: _openLookbook,
                onProductTap: (product) {
                  Navigator.push(
                    context,
                    AppRouter.page(
                      builder: (_) => ProductDetailScreen(product: product),
                    ),
                  );
                },
                onQuickAdd: (product) {
                  ref.read(cartViewModelProvider.notifier).addToCart(product);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(strings.addedProductToCart(product.title)),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),

            SliverToBoxAdapter(
              child: HomeClosingSection(
                onOpenWeekendLooks: () => _openLookbookForOccasion('Đi chơi'),
                onOpenVouchers: () {
                  Navigator.push(
                    context,
                    AppRouter.page(builder: (_) => const VoucherWalletScreen()),
                  );
                },
                onBackToTop: _scrollToTop,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickLink(String label, int tabIndex) {
    final isSelected = _selectedFeedTab == tabIndex;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedFeedTab = tabIndex);
      },
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}
