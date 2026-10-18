import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/product_visual_widget.dart';
import '../../../cart/presentation/viewmodels/cart_viewmodel.dart';
import '../../../cart/presentation/views/cart_screen.dart';
import '../../../home/domain/entities/product_entity.dart';
import '../../../home/presentation/viewmodels/home_viewmodel.dart';
import '../../../product_detail/presentation/views/product_detail_screen.dart';

class LookbookHotspot {
  final String title;
  final String category;
  final double price;
  final double originalPrice;
  final String imageType;
  final Offset position; // Normalized 0.0 to 1.0
  final ProductEntity? product;

  const LookbookHotspot({
    required this.title,
    required this.category,
    required this.price,
    required this.originalPrice,
    required this.imageType,
    required this.position,
    this.product,
  });
}

class LookbookThemeModel {
  final String id;
  final String title;
  final String subtitle;
  final String imagePath;
  final String inspiration;
  final List<LookbookHotspot> items;

  const LookbookThemeModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.inspiration,
    required this.items,
  });

  double get totalPrice => items.fold(0, (sum, i) => sum + i.price);
  double get totalOriginalPrice =>
      items.fold(0, (sum, i) => sum + i.originalPrice);
  double get bundlePrice => totalPrice * 0.85; // 15% bundle discount
  double get savings => totalOriginalPrice - bundlePrice;
}

class LookbookScreen extends ConsumerStatefulWidget {
  const LookbookScreen({super.key});

  @override
  ConsumerState<LookbookScreen> createState() => _LookbookScreenState();
}

class _LookbookScreenState extends ConsumerState<LookbookScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentLookIndex = 0;
  int? _selectedHotspotIndex;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _pulseController
        ..stop()
        ..value = 0.5;
    } else if (!_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    }
  }

  String _formatVnd(double price) {
    final intPrice = price.toInt();
    final s = intPrice.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
      buffer.write(s[i]);
    }
    return '${buffer.toString()}₫';
  }

  List<LookbookThemeModel> _getThemes(List<ProductEntity> catalog) {
    ProductEntity findProd(String type) {
      return catalog.firstWhere(
        (p) => p.imageType == type || p.category.toLowerCase().contains(type),
        orElse: () => catalog.isNotEmpty
            ? catalog.first
            : const ProductEntity(
                id: 'default',
                pieceNumber: '01',
                title: 'Trang phục NÉORA',
                subCategory: 'THỜI TRANG',
                category: 'Đầm',
                price: 490000,
                composition: 'Chất liệu cao cấp',
                description: 'Thiết kế độc quyền',
                availableSizes: ['S', 'M', 'L'],
                imageType: 'dress',
              ),
      );
    }

    final dressProd = findProd('dress');
    final knitProd = findProd('knit_sweater');
    final hoodieProd = findProd('hoodie');
    final shirtProd = findProd('shirt');
    final bagProd = findProd('bag');
    final sneakerProd = findProd('sneaker');

    return [
      LookbookThemeModel(
        id: 'look-1',
        title: 'Dạo Phố Cuối Tuần Parisian',
        subtitle: 'Thanh lịch chuẩn phong cách Pháp cổ điển',
        imagePath: 'assets/images/real/onb_shopping.jpg',
        inspiration:
            'Sự kết hợp giữa chất liệu len dệt kim mềm mịn và áo thun basic mang lại sự thoải mái tuyệt đối cho những buổi trà chiều.',
        items: [
          LookbookHotspot(
            title: 'Áo len cổ lọ dệt kim mềm mịn',
            category: 'Áo len · Tone Yến Mạch',
            price: 389000,
            originalPrice: 520000,
            imageType: 'knit_sweater',
            position: const Offset(0.50, 0.40),
            product: knitProd,
          ),
          LookbookHotspot(
            title: 'Túi đeo vai da khoá vàng sang trọng',
            category: 'Phụ kiện · Da bê Nâu Bò',
            price: 590000,
            originalPrice: 790000,
            imageType: 'bag',
            position: const Offset(0.68, 0.55),
            product: bagProd,
          ),
          LookbookHotspot(
            title: 'Giày sneaker da trắng basic',
            category: 'Giày · Da thật 100%',
            price: 690000,
            originalPrice: 890000,
            imageType: 'sneaker',
            position: const Offset(0.50, 0.88),
            product: sneakerProd,
          ),
        ],
      ),
      LookbookThemeModel(
        id: 'look-2',
        title: 'Thơ Mộng Mùa Hạ Floral Muse',
        subtitle: 'Bay bổng, dịu dàng giữa vườn hoa sớm',
        imagePath: 'assets/images/real/banner_summer.jpg',
        inspiration:
            'Chiếc đầm hoa wrap nhẹ nhàng ôm lấy đường cong cơ thể, kết hợp cùng túi xách da tạo nên vẻ đẹp thuần khiết.',
        items: [
          LookbookHotspot(
            title: 'Đầm hoa wrap dáng midi nữ tính',
            category: 'Đầm · Voan tơ Kem Be',
            price: 459000,
            originalPrice: 659000,
            imageType: 'dress',
            position: const Offset(0.52, 0.48),
            product: dressProd,
          ),
          LookbookHotspot(
            title: 'Túi đeo vai da khoá vàng sang trọng',
            category: 'Phụ kiện · Da bê Nâu Bò',
            price: 590000,
            originalPrice: 790000,
            imageType: 'bag',
            position: const Offset(0.70, 0.60),
            product: bagProd,
          ),
        ],
      ),
      LookbookThemeModel(
        id: 'look-3',
        title: 'Năng Động Đường Phố Athleisure',
        subtitle: 'Trẻ trung, hiện đại và tràn đầy năng lượng',
        imagePath: 'assets/images/real/onb_browsing.jpg',
        inspiration:
            'Tone màu tím lavender ngọt ngào hòa quyện cùng form dáng oversize thoải mái cho mọi hoạt động năng động hàng ngày.',
        items: [
          LookbookHotspot(
            title: 'Áo hoodie oversize màu lavender',
            category: 'Hoodie · Nỉ bông cotton',
            price: 329000,
            originalPrice: 480000,
            imageType: 'hoodie',
            position: const Offset(0.50, 0.42),
            product: hoodieProd,
          ),
          LookbookHotspot(
            title: 'Áo sơ mi lụa tơ tằm cổ điển',
            category: 'Sơ mi · Lụa cao cấp',
            price: 420000,
            originalPrice: 550000,
            imageType: 'shirt',
            position: const Offset(0.48, 0.65),
            product: shirtProd,
          ),
          LookbookHotspot(
            title: 'Giày sneaker da trắng basic',
            category: 'Giày · Da thật 100%',
            price: 690000,
            originalPrice: 890000,
            imageType: 'sneaker',
            position: const Offset(0.50, 0.88),
            product: sneakerProd,
          ),
        ],
      ),
    ];
  }

  void _addBundleToCart(LookbookThemeModel look) {
    final notifier = ref.read(cartViewModelProvider.notifier);
    for (var item in look.items) {
      if (item.product != null) {
        notifier.addToCart(item.product!, 'M');
      }
    }

    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.camelGold,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Đã thêm trọn bộ ${look.items.length} món (${look.title}) vào giỏ hàng! 🛍️',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.brandBlack,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        action: SnackBarAction(
          label: 'XEM GIỎ',
          textColor: AppColors.coralOrange,
          onPressed: () {
            Navigator.push(
              context,
              AppRouter.page(builder: (_) => const CartScreen()),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeViewModelProvider);
    final themes = _getThemes(homeState.allProducts);
    final currentLook = themes[_currentLookIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. Scrollable Content
          CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Top Editorial Look Image with Hotspots
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 480,
                  child: Stack(
                    children: [
                      // PageView of Looks
                      PageView.builder(
                        controller: _pageController,
                        itemCount: themes.length,
                        onPageChanged: (idx) {
                          setState(() {
                            _currentLookIndex = idx;
                            _selectedHotspotIndex = null;
                          });
                        },
                        itemBuilder: (context, index) {
                          final look = themes[index];
                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                look.imagePath,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  color: const Color(0xFF262220),
                                  child: const Center(
                                    child: Icon(
                                      Icons.style_outlined,
                                      color: Colors.white,
                                      size: 60,
                                    ),
                                  ),
                                ),
                              ),
                              // Bottom gradient vignette
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withValues(alpha: 0.5),
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.75),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    stops: const [0.0, 0.4, 1.0],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      // Interactive Hotspot Pins over Current Look
                      ...List.generate(currentLook.items.length, (idx) {
                        final item = currentLook.items[idx];
                        final isSelected = _selectedHotspotIndex == idx;

                        return Positioned(
                          left:
                              item.position.dx *
                                  MediaQuery.of(context).size.width -
                              20,
                          top: item.position.dy * 460 - 20,
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _selectedHotspotIndex = isSelected ? null : idx;
                              });
                            },
                            child: AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Outer pulsing ripple
                                    Container(
                                      width:
                                          40 *
                                          (isSelected
                                              ? 1.3
                                              : _pulseAnimation.value),
                                      height:
                                          40 *
                                          (isSelected
                                              ? 1.3
                                              : _pulseAnimation.value),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.coralOrange.withValues(
                                          alpha: isSelected ? 0.45 : 0.25,
                                        ),
                                      ),
                                    ),
                                    // Inner white pin dot
                                    Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected
                                            ? AppColors.coralOrange
                                            : Colors.white,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.3,
                                            ),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: isSelected
                                          ? const Icon(
                                              Icons.check,
                                              size: 12,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        );
                      }),

                      // Look Title Banner overlay on image
                      Positioned(
                        bottom: 24,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.camelGold,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'LOOK 0${_currentLookIndex + 1} / 0${themes.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentLook.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currentLook.subtitle,
                              style: const TextStyle(
                                color: Color(0xFFF0EBE5),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Indicators dot
                      Positioned(
                        top: 60,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Row(
                            children: List.generate(themes.length, (idx) {
                              return Container(
                                width: idx == _currentLookIndex ? 18 : 6,
                                height: 6,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 2.5,
                                ),
                                decoration: BoxDecoration(
                                  color: idx == _currentLookIndex
                                      ? AppColors.coralOrange
                                      : Colors.white54,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Inspiration Description Box
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.softPeach,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.format_quote_rounded,
                          color: AppColors.coralOrange,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'CẢM HỨNG PHỐI ĐỒ NÉORA',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: AppColors.camelGold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currentLook.inspiration,
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Items Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'CÁC MÓN TRONG SET (${currentLook.items.length})',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: AppColors.brandBlack,
                        ),
                      ),
                      const Text(
                        'Chạm điểm ghim để chọn',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Outfit Breakdown Items
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = currentLook.items[index];
                    final isSelected = _selectedHotspotIndex == index;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.coralOrange
                              : AppColors.cardBorder,
                          width: isSelected ? 1.8 : 1.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.coralOrange.withValues(
                                    alpha: 0.15,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: InkWell(
                        onTap: () {
                          if (item.product != null) {
                            Navigator.push(
                              context,
                              AppRouter.page(
                                builder: (_) =>
                                    ProductDetailScreen(product: item.product!),
                              ),
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(18),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  color: const Color(0xFFF7F4EF),
                                  child: ProductVisualWidget(
                                    imageType: item.imageType,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.category,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.camelGold,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      item.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          _formatVnd(item.price),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.primaryBurgundy,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _formatVnd(item.originalPrice),
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                            color: AppColors.textMuted,
                                            decoration:
                                                TextDecoration.lineThrough,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: AppColors.textMuted,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }, childCount: currentLook.items.length),
                ),
              ),

              // Bottom Breathing Room above floating bar
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),

          // Floating Transparent Top Navigation
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.black.withValues(alpha: 0.5),
                      radius: 20,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const Text(
                      'LOOKBOOK NÉORA',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.black.withValues(alpha: 0.5),
                      radius: 20,
                      child: IconButton(
                        icon: const Icon(
                          Icons.shopping_bag_outlined,
                          size: 18,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            AppRouter.page(builder: (_) => const CartScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Floating Bottom Bundle Purchase Dock
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(26),
                  topRight: Radius.circular(26),
                ),
                border: const Border(top: BorderSide(color: Color(0xFFEBE5DC))),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'TRỌN BỘ OUTFIT',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.softPeach,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'TIẾT KIỆM 15%',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.coralOrange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                _formatVnd(currentLook.bundlePrice),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primaryBurgundy,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatVnd(currentLook.totalOriginalPrice),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        'Tiết kiệm ${_formatVnd(currentLook.savings)}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.liveGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => _addBundleToCart(currentLook),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandBlack,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            size: 18,
                            color: AppColors.camelGold,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'MUA TRỌN BỘ OUTFIT (TIẾT KIỆM 15%)',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.3,
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
        ],
      ),
    );
  }
}
