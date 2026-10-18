import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bouncy_heart_button.dart';
import '../../../../core/widgets/product_visual_widget.dart';
import '../../../wishlist/presentation/viewmodels/wishlist_viewmodel.dart';
import '../../domain/entities/product_entity.dart';

class ProductCardWidget extends ConsumerStatefulWidget {
  final ProductEntity product;
  final VoidCallback onTap;
  final VoidCallback? onQuickAdd;

  const ProductCardWidget({
    super.key,
    required this.product,
    required this.onTap,
    this.onQuickAdd,
  });

  @override
  ConsumerState<ProductCardWidget> createState() => _ProductCardWidgetState();
}

class _ProductCardWidgetState extends ConsumerState<ProductCardWidget> {
  double _tiltX = 0.0;
  double _tiltY = 0.0;
  bool _isInteracting = false;

  void _handlePanUpdate(DragUpdateDetails details, Size size) {
    setState(() {
      _isInteracting = true;
      _tiltY = ((details.localPosition.dx / size.width) - 0.5) * 0.22;
      _tiltX = -((details.localPosition.dy / size.height) - 0.5) * 0.22;
    });
  }

  void _handlePanEnd() {
    setState(() {
      _isInteracting = false;
      _tiltX = 0.0;
      _tiltY = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final int? discountPercent =
        product.originalPrice != null && product.originalPrice! > product.price
        ? (((product.originalPrice! - product.price) / product.originalPrice!) *
                  100)
              .round()
        : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final reduceMotion = MediaQuery.disableAnimationsOf(context);

        return Semantics(
          container: true,
          button: true,
          label: '${product.title}, ${product.formattedPrice}',
          onTap: widget.onTap,
          child: MouseRegion(
            onHover: (event) {
              setState(() {
                _isInteracting = !reduceMotion;
                _tiltY = ((event.localPosition.dx / size.width) - 0.5) * 0.24;
                _tiltX = -((event.localPosition.dy / size.height) - 0.5) * 0.24;
              });
            },
            onExit: (_) => _handlePanEnd(),
            child: GestureDetector(
              onTap: widget.onTap,
              onPanDown: (_) => setState(() => _isInteracting = !reduceMotion),
              onPanUpdate: reduceMotion
                  ? null
                  : (d) => _handlePanUpdate(d, size),
              onPanEnd: (_) => _handlePanEnd(),
              onPanCancel: _handlePanEnd,
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: reduceMotion
                    ? Duration.zero
                    : Duration(milliseconds: _isInteracting ? 80 : 350),
                curve: Curves.easeOutCubic,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(_tiltX)
                  ..rotateY(_tiltY)
                  ..scaleByDouble(
                    _isInteracting ? 0.98 : 1.0,
                    _isInteracting ? 0.98 : 1.0,
                    1.0,
                    1.0,
                  ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.cardBorder, width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0xFF14120E,
                      ).withValues(alpha: _isInteracting ? 0.10 : 0.04),
                      blurRadius: _isInteracting ? 20 : 12,
                      offset: Offset(0, _isInteracting ? 10 : 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Image Container with Badges & Heart
                    Expanded(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(17),
                            child: Hero(
                              tag: 'product_image_${product.id}',
                              child: product.imagePath != null
                                  ? Image.asset(
                                      product.imagePath!,
                                      fit: BoxFit.cover,
                                      filterQuality: FilterQuality.high,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                color: AppColors.softPeach,
                                                child: Center(
                                                  child: ProductVisualWidget(
                                                    imageType:
                                                        product.imageType,
                                                    size: 90,
                                                  ),
                                                ),
                                              ),
                                    )
                                  : Container(
                                      color: AppColors.softPeach,
                                      child: Center(
                                        child: ProductVisualWidget(
                                          imageType: product.imageType,
                                          size: 90,
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
                                      color: Colors.black.withValues(
                                        alpha: 0.12,
                                      ),
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

                          // Discount Ribbon (-30%)
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

                          // Heart Button with Bouncy scale & particle burst
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Consumer(
                              builder: (context, ref, _) {
                                final isFav = ref
                                    .watch(wishlistViewModelProvider)
                                    .isFavorite(product.id);
                                return BouncyHeartButton(
                                  isFavorite: isFav,
                                  size: 16.5,
                                  backgroundColor: Colors.white.withValues(
                                    alpha: 0.92,
                                  ),
                                  onFavoriteChanged: (val) {
                                    ref
                                        .read(
                                          wishlistViewModelProvider.notifier,
                                        )
                                        .toggleFavorite(product);
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // 2. Title & Product Info
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              height: 1.35,
                              color: AppColors.friendlyText,
                            ),
                          ),
                          const SizedBox(height: 5),

                          // Price Row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Flexible(
                                child: Text(
                                  product.formattedPrice,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.coralOrange,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w900,
                                  ),
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
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textMuted,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),

                          // Rating & Sold count
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 13,
                                color: AppColors.warmYellow,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${product.rating}',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.friendlyText,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '· Đã bán ${product.soldCount > 1000 ? "${(product.soldCount / 1000).toStringAsFixed(1)}k" : product.soldCount}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.friendlySubText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
