import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../address/presentation/viewmodels/address_viewmodel.dart';
import '../../../address/presentation/views/address_book_screen.dart';
import '../../../cart/presentation/viewmodels/cart_viewmodel.dart';
import '../../../product_detail/presentation/views/product_detail_screen.dart';
import '../../domain/entities/product_entity.dart';
import '../viewmodels/home_viewmodel.dart';
import '../widgets/neora_3d_banner_stack.dart';
import '../widgets/neora_category_hub.dart';
import '../widgets/neora_flash_sale_section.dart';
import '../widgets/neora_sliding_feed_tabs.dart';
import '../widgets/neora_voucher_strip.dart';
import '../widgets/product_card_widget.dart';
import '../../../notifications/presentation/views/notifications_screen.dart';
import '../../../search/presentation/widgets/ai_visual_search_dialog.dart';
import '../../../shop/presentation/views/flash_sale_screen.dart';
import '../../../shop/presentation/views/lookbook_screen.dart';
import '../../../settings/presentation/viewmodels/settings_viewmodel.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final VoidCallback onOpenCart;
  final VoidCallback? onOpenSearch;

  const HomeScreen({super.key, required this.onOpenCart, this.onOpenSearch});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedFeedTab = 0;
  int _searchTickerIndex = 0;
  Timer? _searchTickerTimer;

  List<String> _searchQueries(AppLocalizations strings) => [
    '${strings.categoryDress} 🌸',
    '${strings.categoryShirt} 🌿',
    '${strings.categoryBag} ✨',
    '${strings.categoryShoes} 👟',
  ];

  @override
  void initState() {
    super.initState();
    _searchTickerTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        setState(() {
          _searchTickerIndex = (_searchTickerIndex + 1) % 4;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchTickerTimer?.cancel();
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

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final homeState = ref.watch(homeViewModelProvider);
    final profile = ref.watch(settingsViewModelProvider).profile;
    final selectedAddress = ref.watch(addressViewModelProvider).selectedAddress;
    final locationTitle = strings.deliverToAddress(
      selectedAddress?.shortAddress ?? strings.defaultDeliveryAddress,
    );
    final searchQueries = _searchQueries(strings);

    if (homeState.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.coralOrange),
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
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // 1. Header: Avatar + "Xin chào, Linh 👋" + Location + Bell Button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    // Avatar Image
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.14),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(23),
                        child: Image.asset(
                          'assets/images/real/onb_shopping.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.person,
                            color: AppColors.coralOrange,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Greeting & Delivery Address
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.helloUser(profile.name),
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                AppRouter.page(
                                  builder: (_) => const AddressBookScreen(
                                    isSelectMode: true,
                                  ),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  size: 13,
                                  color: AppColors.coralOrange,
                                ),
                                const SizedBox(width: 3),
                                Expanded(
                                  child: Text(
                                    locationTitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Notification Bell Button with Unread Badge
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          AppRouter.page(
                            builder: (_) => const NotificationsScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF6E4549,
                              ).withValues(alpha: 0.12),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Center(
                              child: Icon(
                                Icons.notifications_none_rounded,
                                size: 22,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            // Unread Dot
                            Positioned(
                              top: 11,
                              right: 12,
                              child: Container(
                                width: 9,
                                height: 9,
                                decoration: BoxDecoration(
                                  color: AppColors.coralOrange,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Animated Search Bar with Rotating Query Ticker & Camera Button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: widget.onOpenSearch,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 52,
                    padding: const EdgeInsets.fromLTRB(14, 0, 8, 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF50321E).withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search_rounded,
                          size: 22,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 10),

                        // Animated Ticker
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 450),
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.4),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: Align(
                              alignment: Alignment.centerLeft,
                              key: ValueKey<int>(_searchTickerIndex),
                              child: Text(
                                searchQueries[_searchTickerIndex],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Camera Button
                        GestureDetector(
                          onTap: () => AIVisualSearchDialog.show(context),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.softPeach,
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.camera_alt_outlined,
                                size: 19,
                                color: AppColors.coralOrange,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // 3. 3D Stacking Banner Carousel Stack
            SliverToBoxAdapter(
              child: Neora3dBannerStack(onBannerTap: widget.onOpenSearch),
            ),

            // 4. Horizontal Category Hub (66x66 Rounded Square Badges)
            SliverToBoxAdapter(
              child: NeoraCategoryHub(
                onSeeAll: widget.onOpenSearch,
                onCategorySelected: (cat) {
                  widget.onOpenSearch?.call();
                },
              ),
            ),

            // 5. Perforated Discount Vouchers Strip
            const SliverToBoxAdapter(child: NeoraVoucherStrip()),

            // 6. Flash Sale Section with Dark Container & Flipping Countdown
            SliverToBoxAdapter(
              child: NeoraFlashSaleSection(
                products: products,
                onProductTap: (product) {
                  Navigator.push(
                    context,
                    AppRouter.page(
                      builder: (_) => ProductDetailScreen(product: product),
                    ),
                  );
                },
                onSeeAll: () {
                  Navigator.push(
                    context,
                    AppRouter.page(builder: (_) => const FlashSaleScreen()),
                  );
                },
              ),
            ),

            // 6.5. Editorial Lookbook "Shop The Look" Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      AppRouter.page(builder: (_) => const LookbookScreen()),
                    );
                  },
                  child: Container(
                    height: 105,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF26201B), Color(0xFF141210)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF26201B,
                          ).withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -10,
                          bottom: -15,
                          top: -15,
                          width: 140,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                            child: Image.asset(
                              'assets/images/real/onb_shopping.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF141210),
                                const Color(0xFF141210).withValues(alpha: 0.85),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.65, 1.0],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.camelGold,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      strings.editorialLookbookLabel,
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.8,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    strings.lookbookSavingLabel,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.coralOrange,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                strings.shopTheLookTitle,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                strings.shopTheLookSubtitle,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFFD6CFC7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 7. Gợi Ý Hôm Nay Tabs with Sliding Indicator
            SliverToBoxAdapter(
              child: NeoraSlidingFeedTabs(
                selectedIndex: _selectedFeedTab,
                onTabSelected: (idx) {
                  setState(() {
                    _selectedFeedTab = idx;
                  });
                },
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // 8. 2-Column Staggered Masonry Product Grid with 3D Tilt
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.60,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final product = filteredProducts[index];
                  return ProductCardWidget(
                    product: product,
                    onTap: () {
                      Navigator.push(
                        context,
                        AppRouter.page(
                          builder: (_) => ProductDetailScreen(product: product),
                        ),
                      );
                    },
                    onQuickAdd: () {
                      ref
                          .read(cartViewModelProvider.notifier)
                          .addToCart(product, 'M');
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            strings.addedProductToCart(product.title),
                          ),
                          backgroundColor: AppColors.brandBlack,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  );
                }, childCount: filteredProducts.length),
              ),
            ),

            // Bottom breathing room above floating dock
            const SliverToBoxAdapter(child: SizedBox(height: 110)),
          ],
        ),
      ),
    );
  }
}
