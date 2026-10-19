import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/product_visual_widget.dart';
import '../../../wishlist/presentation/viewmodels/wishlist_viewmodel.dart';
import '../../domain/entities/product_entity.dart';

class ProductCardWidget extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final favorite = ref
        .watch(wishlistViewModelProvider)
        .isFavorite(product.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Semantics(
                  button: true,
                  label: product.title,
                  child: InkWell(
                    onTap: onTap,
                    child: Hero(
                      tag: 'product_image_${product.id}',
                      child: product.imagePath != null
                          ? Image.asset(
                              product.imagePath!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => _fallback(),
                            )
                          : _fallback(),
                    ),
                  ),
                ),
                if (product.tag.isNotEmpty)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        product.tag,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      tooltip: favorite ? 'Bỏ yêu thích' : 'Yêu thích',
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.background.withValues(
                          alpha: 0.9,
                        ),
                      ),
                      onPressed: () => ref
                          .read(wishlistViewModelProvider.notifier)
                          .toggleFavorite(product),
                      icon: Icon(
                        favorite ? Icons.favorite : Icons.favorite_border,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          product.subCategory.isNotEmpty
              ? product.subCategory.toUpperCase()
              : product.category.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 2),
        InkWell(
          onTap: onTap,
          child: Text(
            product.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.cardTitle.copyWith(
              fontFamily: AppTypography.sansFont,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 3),
        Row(
          children: [
            Expanded(
              child: Text(
                product.formattedPrice,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.price.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (product.availableColors.isNotEmpty)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: product.availableColors.take(3).map((c) {
                  return Container(
                    width: 9,
                    height: 9,
                    margin: const EdgeInsets.only(left: 4),
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.cardBorder,
                        width: 0.8,
                      ),
                    ),
                  );
                }).toList(),
              ),
            if (onQuickAdd != null) ...[
              const SizedBox(width: 4),
              SizedBox(
                width: 24,
                height: 24,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  tooltip: 'Thêm vào giỏ',
                  onPressed: onQuickAdd,
                  icon: const Icon(
                    Icons.add_shopping_cart_outlined,
                    size: 15,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _fallback() => ColoredBox(
    color: AppColors.studioGray,
    child: Center(
      child: ProductVisualWidget(imageType: product.imageType, size: 90),
    ),
  );
}
