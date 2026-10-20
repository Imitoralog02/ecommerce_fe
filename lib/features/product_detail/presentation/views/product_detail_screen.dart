import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
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
import '../../../reviews/presentation/viewmodels/review_viewmodel.dart';
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
  int _selectedThumbIndex = 0;
  String _selectedSize = 'M';

  String get _selectedColorName =>
      _selectedColorIndex < widget.product.colorNames.length
      ? widget.product.colorNames[_selectedColorIndex]
      : 'Trắng ngà';

  late AnimationController _cartBadgeController;
  late Animation<double> _cartBadgeAnimation;
  final GlobalKey _stageImageKey = GlobalKey();
  final GlobalKey _cartIconKey = GlobalKey();

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
    _cartBadgeController.dispose();
    super.dispose();
  }

  void _handleAddToCart() {
    final strings = AppLocalizations.of(context);
    ref
        .read(cartViewModelProvider.notifier)
        .addToCart(widget.product, _selectedSize, _selectedColorName);

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
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
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
        .addToCart(widget.product, _selectedSize, _selectedColorName);
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
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final product = widget.product;
    final reviewState = ref.watch(reviewViewModelProvider(product.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text(
          'Chi tiết sản phẩm',
          style: TextStyle(
            fontFamily: AppTypography.serifFont,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            size: 20,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.share_outlined,
              size: 19,
              color: AppColors.textPrimary,
            ),
            tooltip: strings.shareProductTooltip,
            onPressed: _handleShareProduct,
          ),
          Container(
            key: _cartIconKey,
            margin: const EdgeInsets.only(right: 8),
            child: ScaleTransition(
              scale: _cartBadgeAnimation,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.shopping_bag_outlined,
                      size: 21,
                      color: AppColors.textPrimary,
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
                            color: AppColors.primary,
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
        padding: const EdgeInsets.only(bottom: 130),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Main Image + 1/4 Counter + 4 Thumbnail Strip
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: AspectRatio(
                      aspectRatio: 0.86,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          KeyedSubtree(
                            key: _stageImageKey,
                            child: Hero(
                              tag: 'product_image_${product.id}',
                              child: _buildProductImage(product, size: 240),
                            ),
                          ),
                          Positioned(
                            right: 12,
                            bottom: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.background.withValues(
                                  alpha: 0.9,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_selectedThumbIndex + 1} / 4',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(4, (idx) {
                      final active = _selectedThumbIndex == idx;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: idx == 3 ? 0 : 8),
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedThumbIndex = idx),
                            child: Container(
                              height: 64,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: active
                                      ? AppColors.primary
                                      : AppColors.cardBorder,
                                  width: active ? 1.8 : 1.0,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: _buildProductImage(product, size: 48),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            // 2. Product Info Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'THỜI TRANG NÉORA / ${product.subCategory.toUpperCase()}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                      Consumer(
                        builder: (context, ref, _) {
                          final isFav = ref
                              .watch(wishlistViewModelProvider)
                              .isFavorite(widget.product.id);
                          return BouncyHeartButton(
                            isFavorite: isFav,
                            size: 20,
                            onFavoriteChanged: (_) {
                              ref
                                  .read(wishlistViewModelProvider.notifier)
                                  .toggleFavorite(widget.product);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.title,
                    style: AppTypography.editorialHeadline.copyWith(
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Price & Rating Row
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            product.formattedPrice,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                          if (product.formattedOriginalPrice != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              product.formattedOriginalPrice!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textMuted,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: AppColors.starYellow,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              reviewState
                                  .averageRating(product)
                                  .toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${reviewState.totalCount(product)} đánh giá)',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Text(
                    product.description,
                    style: const TextStyle(
                      fontSize: 13.5,
                      height: 1.55,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 3. Color Selection Swatches
                  Text(
                    'Màu sắc: $_selectedColorName',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: List.generate(product.availableColors.length, (
                      index,
                    ) {
                      final isSelected = _selectedColorIndex == index;
                      final color = product.availableColors[index];
                      final name = index < product.colorNames.length
                          ? product.colorNames[index]
                          : '';

                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedColorIndex = index),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Tooltip(
                            message: name,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.cardBorder,
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),

                  // 4. Size Selection Pills
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Kích cỡ: $_selectedSize',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
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
                        child: const Text(
                          'Bảng size +',
                          style: TextStyle(
                            fontFamily: AppTypography.sansFont,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: product.availableSizes.map((size) {
                      final isSelected = _selectedSize == size;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedSize = size),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.cardBorder,
                            ),
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
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '● Còn hàng • Người mẫu cao 1m68, mặc cỡ M',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.liveGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 5. Stylist Outfit Callout Card (Figma Screen 10)
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        AppRouter.page(
                          builder: (_) =>
                              const LookbookScreen(initialShowDetail: true),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.softPeach,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.auto_awesome_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Trong outfit "Đi làm, thật nhẹ nhàng"',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Xem cách phối 3 món • 1.770.000 ₫ ›',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 6. Chất liệu & chăm sóc
                  const Divider(height: 1, color: AppColors.divider),
                  const SizedBox(height: 16),
                  const Text(
                    'Chất liệu & chăm sóc',
                    style: AppTypography.editorialTitle,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• ${product.composition}\n'
                    '• Giặt nhẹ ở nhiệt độ thường, lộn trái khi phơi\n'
                    '• Ủi hơi nước ở nhiệt độ thấp để giữ phom tự nhiên',
                    style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.6,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 7. Bảng size tham khảo
                  const Divider(height: 1, color: AppColors.divider),
                  const SizedBox(height: 16),
                  const Text(
                    'Bảng size tham khảo',
                    style: AppTypography.editorialTitle,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.studioGray,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      children: [
                        _buildSizeRow(
                          'Cỡ',
                          'Vòng ngực',
                          'Dài áo',
                          header: true,
                        ),
                        const Divider(height: 14, color: AppColors.divider),
                        _buildSizeRow('S', '88 - 92 cm', '66 cm'),
                        const SizedBox(height: 6),
                        _buildSizeRow('M', '92 - 96 cm', '68 cm'),
                        const SizedBox(height: 6),
                        _buildSizeRow('L', '96 - 100 cm', '70 cm'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 8. Giao hàng & đổi trả
                  const Divider(height: 1, color: AppColors.divider),
                  const SizedBox(height: 16),
                  const Text(
                    'Giao hàng & đổi trả',
                    style: AppTypography.editorialTitle,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Giao tiêu chuẩn dự kiến 2–3 ngày làm việc\n'
                    '• Đổi trả trong 30 ngày nếu sản phẩm còn nguyên tem mác',
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.6,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
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
                  width: 48,
                  height: 48,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: AppColors.studioGray,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 19,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: _handleAddToCart,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: AppColors.primary,
                        width: 1.4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      backgroundColor: AppColors.softPeach,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        strings.addToCartAction,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _handleBuyNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        strings.buyNowAction,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
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

  Widget _buildProductImage(ProductEntity product, {required double size}) {
    if (product.imagePath != null) {
      return Image.asset(
        product.imagePath!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
            ProductVisualWidget(imageType: product.imageType, size: size),
      );
    }
    return ProductVisualWidget(imageType: product.imageType, size: size);
  }

  Widget _buildSizeRow(
    String col1,
    String col2,
    String col3, {
    bool header = false,
  }) {
    final style = TextStyle(
      fontSize: 12,
      fontWeight: header ? FontWeight.w700 : FontWeight.w500,
      color: header ? AppColors.textPrimary : AppColors.textSecondary,
    );
    return Row(
      children: [
        Expanded(child: Text(col1, style: style)),
        Expanded(child: Text(col2, style: style)),
        Expanded(
          child: Text(col3, textAlign: TextAlign.right, style: style),
        ),
      ],
    );
  }
}
