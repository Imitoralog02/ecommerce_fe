import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bouncy_heart_button.dart';
import '../../../../core/widgets/fly_to_cart_animation.dart';
import '../../../../core/widgets/product_visual_widget.dart';
import '../../../cart/presentation/viewmodels/cart_viewmodel.dart';
import '../../../cart/presentation/views/cart_screen.dart';
import '../../../checkout/presentation/views/checkout_screen.dart';
import '../../../home/domain/entities/product_entity.dart';
import '../../../wishlist/presentation/viewmodels/wishlist_viewmodel.dart';
import '../../../support/presentation/views/live_chat_screen.dart';
import '../../../history/presentation/viewmodels/recently_viewed_viewmodel.dart';
import '../widgets/size_guide_sheet.dart';
import '../../../reviews/presentation/views/product_reviews_screen.dart';
import '../../../shop/presentation/views/lookbook_screen.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final ProductEntity product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen>
    with TickerProviderStateMixin {
  int _selectedColorIndex = 0;
  String _selectedSize = 'M';

  late AnimationController _orbitFloatController;
  late AnimationController _orbitResetController;
  late AnimationController _cartBadgeController;
  late Animation<double> _cartBadgeAnimation;
  final GlobalKey _stageImageKey = GlobalKey();
  final GlobalKey _cartIconKey = GlobalKey();
  Offset _dragOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    if (widget.product.availableSizes.isNotEmpty) {
      _selectedSize = widget.product.availableSizes.first;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(recentlyViewedViewModelProvider.notifier)
          .recordView(widget.product);
    });

    _orbitFloatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _orbitResetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _cartBadgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _cartBadgeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.45,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.45,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
    ]).animate(_cartBadgeController);
  }

  @override
  void dispose() {
    _orbitFloatController.dispose();
    _orbitResetController.dispose();
    _cartBadgeController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _orbitFloatController
        ..stop()
        ..value = 0.5;
    } else if (!_orbitFloatController.isAnimating) {
      _orbitFloatController.repeat(reverse: true);
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
      _dragOffset = Offset(
        _dragOffset.dx.clamp(-45.0, 45.0),
        _dragOffset.dy.clamp(-35.0, 35.0),
      );
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (MediaQuery.disableAnimationsOf(context)) {
      setState(() => _dragOffset = Offset.zero);
      return;
    }
    final start = _dragOffset;
    final animation = Tween<Offset>(begin: start, end: Offset.zero).animate(
      CurvedAnimation(parent: _orbitResetController, curve: Curves.easeOutBack),
    );
    animation.addListener(() {
      setState(() {
        _dragOffset = animation.value;
      });
    });
    _orbitResetController.forward(from: 0.0);
  }

  void _handleAddToCart() {
    final strings = AppLocalizations.of(context);
    ref
        .read(cartViewModelProvider.notifier)
        .addToCart(widget.product, _selectedSize);

    // Parabolic Arc Fly To Cart
    FlyToCartHelper.run(
      context,
      startKey: _stageImageKey,
      targetKey: _cartIconKey,
      thumbnail: widget.product.imagePath != null
          ? Image.asset(widget.product.imagePath!, fit: BoxFit.cover)
          : ProductVisualWidget(imageType: widget.product.imageType, size: 50),
      onComplete: () {
        _cartBadgeController.forward(from: 0.0);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.addedSizeToCart(_selectedSize)),
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
  }

  void _handleBuyNow() {
    ref
        .read(cartViewModelProvider.notifier)
        .addToCart(widget.product, _selectedSize);
    Navigator.push(
      context,
      AppRouter.page(builder: (_) => const CheckoutScreen()),
    );
  }

  Future<void> _handleShareProduct() async {
    final strings = AppLocalizations.of(context);
    final product = widget.product;
    await Clipboard.setData(
      ClipboardData(
        text: '${product.title} · ${product.price.toStringAsFixed(0)}₫ · NÉORA',
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(strings.productShareCopied),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.brandBlack,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final product = widget.product;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          strings.productDetailTitle,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
            color: AppColors.brandBlack,
          ),
        ),
        leading: Center(
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: AppColors.brandBlack,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.share_outlined,
              size: 20,
              color: AppColors.brandBlack,
            ),
            tooltip: strings.shareProductTooltip,
            onPressed: _handleShareProduct,
          ),
          Consumer(
            builder: (context, ref, _) {
              final isFav = ref
                  .watch(wishlistViewModelProvider)
                  .isFavorite(widget.product.id);
              return BouncyHeartButton(
                isFavorite: isFav,
                size: 20,
                onFavoriteChanged: (val) {
                  ref
                      .read(wishlistViewModelProvider.notifier)
                      .toggleFavorite(widget.product);
                },
              );
            },
          ),
          Container(
            key: _cartIconKey,
            margin: const EdgeInsets.only(right: 8, left: 4),
            child: ScaleTransition(
              scale: _cartBadgeAnimation,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.shopping_bag_outlined,
                      size: 22,
                      color: AppColors.brandBlack,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        AppRouter.page(builder: (_) => const CartScreen()),
                      );
                    },
                  ),
                  Consumer(
                    builder: (context, ref, _) {
                      final count = ref
                          .watch(cartViewModelProvider)
                          .totalItemCount;
                      if (count == 0) return const SizedBox.shrink();
                      return Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.coralOrange,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Center(
                            child: Text(
                              '$count',
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Interactive 3D Showcase Stage
            LayoutBuilder(
              builder: (context, constraints) {
                final stageWidth = constraints.maxWidth;
                return MouseRegion(
                  onHover: (event) {
                    final centerX = stageWidth / 2;
                    final centerY = 190.0;
                    final dx =
                        ((event.localPosition.dx - centerX) / centerX) * 35.0;
                    final dy =
                        ((event.localPosition.dy - centerY) / centerY) * 25.0;
                    setState(() {
                      _dragOffset = Offset(
                        dx.clamp(-45.0, 45.0),
                        dy.clamp(-35.0, 35.0),
                      );
                    });
                  },
                  onExit: (_) {
                    final start = _dragOffset;
                    final animation =
                        Tween<Offset>(begin: start, end: Offset.zero).animate(
                          CurvedAnimation(
                            parent: _orbitResetController,
                            curve: Curves.easeOutBack,
                          ),
                        );
                    animation.addListener(() {
                      setState(() {
                        _dragOffset = animation.value;
                      });
                    });
                    _orbitResetController.forward(from: 0.0);
                  },
                  child: GestureDetector(
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: _onPanEnd,
                    child: Container(
                      width: double.infinity,
                      height: 380,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F4F6),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Dynamic Floor Shadow
                          Positioned(
                            bottom: 40,
                            child: AnimatedBuilder(
                              animation: _dragOffset == Offset.zero
                                  ? _orbitFloatController
                                  : _orbitResetController,
                              builder: (context, child) {
                                final scale =
                                    1.0 - (_dragOffset.dy.abs() / 150.0);
                                return Container(
                                  width: 170 * scale,
                                  height: 22 * scale,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                );
                              },
                            ),
                          ),

                          // Garment Image / 3D Rotating Canvas
                          AnimatedBuilder(
                            animation: _dragOffset == Offset.zero
                                ? _orbitFloatController
                                : _orbitResetController,
                            builder: (context, child) {
                              final floatY =
                                  math.sin(
                                    _orbitFloatController.value * 2 * math.pi,
                                  ) *
                                  6.0;
                              return Transform.translate(
                                offset: Offset(0.0, floatY),
                                child: Transform(
                                  transform: Matrix4.identity()
                                    ..setEntry(3, 2, 0.001)
                                    ..rotateY(_dragOffset.dx * 0.007)
                                    ..rotateX(-_dragOffset.dy * 0.007),
                                  alignment: FractionalOffset.center,
                                  child: KeyedSubtree(
                                    key: _stageImageKey,
                                    child: Hero(
                                      tag: 'product_image_${product.id}',
                                      child: product.imagePath != null
                                          ? Image.asset(
                                              product.imagePath!,
                                              width: 250,
                                              height: 300,
                                              fit: BoxFit.contain,
                                              filterQuality: FilterQuality.high,
                                              errorBuilder: (_, _, _) =>
                                                  ProductVisualWidget(
                                                    imageType:
                                                        product.imageType,
                                                    width: 250,
                                                    height: 300,
                                                  ),
                                            )
                                          : ProductVisualWidget(
                                              imageType: product.imageType,
                                              width: 250,
                                              height: 300,
                                            ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          // Tag
                          if (product.tag.isNotEmpty)
                            Positioned(
                              top: 18,
                              left: 18,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  product.tag,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                    color: AppColors.saleRed,
                                  ),
                                ),
                              ),
                            ),

                          // 3D Orbit Badge
                          Positioned(
                            top: 18,
                            right: 18,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4.5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.threed_rotation_rounded,
                                    size: 15,
                                    color: AppColors.coralOrange,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    strings.touchToRotate3d,
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.coralOrange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Image indicator (1/4)
                          Positioned(
                            bottom: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.55),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                strings.authenticImageIndicator,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // 2. Product Title, Rating & Price
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.brandBlack,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            product.formattedPrice,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: product.originalPrice != null
                                  ? AppColors.saleRed
                                  : AppColors.coralOrange,
                            ),
                          ),
                          if (product.formattedOriginalPrice != null)
                            Text(
                              product.formattedOriginalPrice!,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textMuted,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Rating row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Row(
                      children: [
                        Text(
                          '${product.brand} · ',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              AppRouter.page(
                                builder: (_) =>
                                    ProductReviewsScreen(product: product),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 18,
                                color: Color(0xFFFFA000),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${product.rating}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                strings.reviewCountLabel(product.reviewCount),
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: AppColors.coralOrange,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 1,
                          height: 12,
                          color: const Color(0xFFE5E5EA),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          strings.soldCountLabel(product.soldCount),
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Friendly Trust Perks Strip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.softPeach,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      runAlignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.local_shipping_outlined,
                              size: 15,
                              color: AppColors.coralOrange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              strings.freeShippingThresholdPerk,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.brandBlack,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.verified_outlined,
                              size: 15,
                              color: AppColors.mintGreen,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              strings.authenticPhotoPerk,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.brandBlack,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.cached_rounded,
                              size: 15,
                              color: AppColors.coralOrange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              strings.returnsPerk,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.brandBlack,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    product.description,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.55,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    strings.materialLabel(product.composition),
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brandBlack,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Shop The Look Callout Card
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        AppRouter.page(builder: (_) => const LookbookScreen()),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1A17),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.camelGold,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 2,
                                  children: [
                                    Text(
                                      strings.styleWithNeoraLabel,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.8,
                                        color: AppColors.camelGold,
                                      ),
                                    ),
                                    Text(
                                      strings.saveFifteenPercentLabel,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.coralOrange,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  strings.styleSuggestionLabel,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white70,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // 3. Color Selection Swatches
                  Text(
                    strings.colorSection,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: AppColors.brandBlack,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(product.availableColors.length, (
                      index,
                    ) {
                      final isSelected = _selectedColorIndex == index;
                      final color = product.availableColors[index];
                      final name = index < product.colorNames.length
                          ? product.colorNames[index]
                          : '';

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedColorIndex = index;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 14),
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.coralOrange
                                  : Colors.transparent,
                              width: 2.2,
                            ),
                          ),
                          child: Tooltip(
                            message: name,
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFE5E5EA),
                                  width: 0.8,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  // 4. Size Selection Pills
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          strings.sizeSection,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: AppColors.brandBlack,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: () {
                          SizeGuideSheet.show(
                            context,
                            onSelectSize: (size) {
                              setState(() {
                                _selectedSize = size;
                              });
                            },
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          strings.sizeGuideAction,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.coralOrange,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: product.availableSizes.map((size) {
                      final isSelected = _selectedSize == size;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedSize = size;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.coralOrange
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.coralOrange
                                  : const Color(0xFFE5E5EA),
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.coralOrange.withValues(
                                        alpha: 0.25,
                                      ),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            size,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.brandBlack,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Fixed Bottom Action Bar: THÊM VÀO GIỎ & MUA NGAY
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: Color(0xFFE5E5EA))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              // Chat với Stylist button
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    AppRouter.page(
                      builder: (_) =>
                          LiveChatScreen(initialProduct: widget.product),
                    ),
                  );
                },
                child: Container(
                  width: 50,
                  height: 50,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE5E5EA),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('💬', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ),

              // Outlined THÊM VÀO GIỎ button
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _handleAddToCart,
                    icon: const Icon(
                      Icons.shopping_bag_outlined,
                      size: 18,
                      color: AppColors.coralOrange,
                    ),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        strings.addToCartAction,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: AppColors.coralOrange,
                        ),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: AppColors.coralOrange,
                        width: 1.5,
                      ),
                      shape: const StadiumBorder(),
                      backgroundColor: AppColors.softPeach,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Coral capsule MUA NGAY button
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _handleBuyNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.coralOrange,
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      elevation: 2,
                      shadowColor: AppColors.coralOrange.withValues(alpha: 0.4),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        strings.buyNowAction,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
