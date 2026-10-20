import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../wishlist/presentation/viewmodels/wishlist_viewmodel.dart';
import '../../domain/entities/product_entity.dart';
import 'neora_sliding_feed_tabs.dart';

/// "Món cơ bản mỗi ngày" — the editorial essentials edit of the Home page.
///
/// Layout:
///  1. Editorial header (eyebrow, serif title, tagline, "Xem tất cả")
///  2. Filter pills
///  3. "Món của ngày" spotlight card with swatches, "mặc 3 cách" chips and CTA
///  4. Horizontal numbered carousel of the remaining essentials
///  5. Reassurance strip + "Xem thêm" button
class NeoraEssentialsSection extends ConsumerWidget {
  final List<ProductEntity> products;
  final int selectedTab;
  final ValueChanged<int> onTabSelected;
  final ValueChanged<ProductEntity> onProductTap;
  final ValueChanged<ProductEntity> onQuickAdd;
  final VoidCallback? onSeeAll;
  final VoidCallback onStyleTap;

  const NeoraEssentialsSection({
    super.key,
    required this.products,
    required this.selectedTab,
    required this.onTabSelected,
    required this.onProductTap,
    required this.onQuickAdd,
    required this.onSeeAll,
    required this.onStyleTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spotlight = products.isNotEmpty ? products.first : null;
    final rest = products.length > 1
        ? products.skip(1).take(8).toList()
        : const <ProductEntity>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 14),
        NeoraSlidingFeedTabs(
          selectedIndex: selectedTab,
          onTabSelected: onTabSelected,
        ),
        const SizedBox(height: 18),
        if (spotlight != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _SpotlightCard(
              product: spotlight,
              onTap: () => onProductTap(spotlight),
              onQuickAdd: () => onQuickAdd(spotlight),
              onStyleTap: onStyleTap,
            ),
          ),
        if (rest.isNotEmpty) ...[
          const SizedBox(height: 26),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Expanded(
                  child: Text(
                    'Phối cùng nhau',
                    style: TextStyle(
                      fontFamily: AppTypography.serifFont,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  'Vuốt để xem thêm  →',
                  style: AppTypography.bodySmall.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: MediaQuery.textScalerOf(
                context,
              ).clamp(maxScaleFactor: 1.15),
            ),
            child: SizedBox(
              height: 268,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: rest.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final product = rest[index];
                  return _EssentialMiniCard(
                    product: product,
                    number: (index + 2).toString().padLeft(2, '0'),
                    onTap: () => onProductTap(product),
                    onQuickAdd: () => onQuickAdd(product),
                  );
                },
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
        _buildReassuranceStrip(context),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton(
              onPressed: onSeeAll,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text(
                'Khám phá toàn bộ tủ đồ  →',
                style: TextStyle(
                  fontFamily: AppTypography.sansFont,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 22, height: 1, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'TỦ ĐỒ CỐT LÕI',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.architecturalCode.copyWith(
                    color: AppColors.primary,
                    fontSize: 10,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(
                child: Text(
                  'Món cơ bản\nmỗi ngày',
                  style: AppTypography.editorialHeadline,
                ),
              ),
              TextButton(
                onPressed: onSeeAll,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Xem tất cả →',
                  style: TextStyle(
                    fontFamily: AppTypography.sansFont,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Ít món, phối được nhiều cách. Mặc hoài không chán.',
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }

  Widget _buildReassuranceStrip(BuildContext context) {
    const items = [
      (Icons.autorenew_rounded, 'Đổi trả', '30 ngày'),
      (Icons.local_shipping_outlined, 'Giao hàng', 'dự kiến tại checkout'),
      (Icons.spa_outlined, 'Chất liệu', 'tự nhiên'),
    ];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.studioGray,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final largeText = MediaQuery.textScalerOf(context).scale(1) >= 1.4;
          final itemWidth = largeText || constraints.maxWidth < 280
              ? constraints.maxWidth
              : (constraints.maxWidth - 16) / 2;
          return Wrap(
            alignment: WrapAlignment.spaceAround,
            spacing: 16,
            runSpacing: 12,
            children: [
              for (final item in items)
                SizedBox(
                  width: itemWidth,
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE6EBE3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          item.$1,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.$2,
                              style: const TextStyle(
                                fontFamily: AppTypography.sansFont,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              item.$3,
                              softWrap: true,
                              style: const TextStyle(
                                fontFamily: AppTypography.sansFont,
                                fontSize: 10.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

Widget _productImage(ProductEntity product) {
  final path = product.imagePath;
  if (path == null) {
    return const ColoredBox(color: AppColors.studioGray);
  }
  return Image.asset(
    path,
    fit: BoxFit.cover,
    errorBuilder: (_, _, _) => const ColoredBox(color: AppColors.studioGray),
  );
}

class _SpotlightCard extends ConsumerWidget {
  final ProductEntity product;
  final VoidCallback onTap;
  final VoidCallback onQuickAdd;
  final VoidCallback onStyleTap;

  const _SpotlightCard({
    required this.product,
    required this.onTap,
    required this.onQuickAdd,
    required this.onStyleTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorite = ref
        .watch(wishlistViewModelProvider)
        .isFavorite(product.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _productImage(product),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.55, 1.0],
                        colors: [Colors.transparent, Color(0x991A1D17)],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 11,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'MÓN CỦA NGÀY',
                            style: TextStyle(
                              fontFamily: AppTypography.sansFont,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: SizedBox(
                      width: 34,
                      height: 34,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        tooltip: favorite ? 'Bỏ yêu thích' : 'Yêu thích',
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.background.withValues(
                            alpha: 0.92,
                          ),
                        ),
                        onPressed: () => ref
                            .read(wishlistViewModelProvider.notifier)
                            .toggleFavorite(product),
                        icon: Icon(
                          favorite ? Icons.favorite : Icons.favorite_border,
                          size: 17,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    bottom: 6,
                    child: Text(
                      '01',
                      style: TextStyle(
                        fontFamily: AppTypography.serifFont,
                        fontSize: 58,
                        fontWeight: FontWeight.w400,
                        height: 1.0,
                        color: Colors.white.withValues(alpha: 0.92),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (product.subCategory.isNotEmpty
                            ? product.subCategory
                            : product.category)
                        .toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: AppTypography.sansFont,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.editorialTitle.copyWith(fontSize: 19),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              product.formattedPrice,
              style: const TextStyle(
                fontFamily: AppTypography.sansFont,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          product.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.body.copyWith(fontSize: 12.5),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            ...product.availableColors
                .take(4)
                .map(
                  (c) => Container(
                    width: 14,
                    height: 14,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.cardBorder, width: 1),
                    ),
                  ),
                ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                'Size ${product.sizeRange}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySmall,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.studioGray,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MẶC 3 CÁCH',
                style: TextStyle(
                  fontFamily: AppTypography.sansFont,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _StyleChip(
                    icon: Icons.work_outline_rounded,
                    label: 'Đi làm',
                    onTap: onStyleTap,
                  ),
                  _StyleChip(
                    icon: Icons.local_cafe_outlined,
                    label: 'Đi chơi',
                    onTap: onStyleTap,
                  ),
                  _StyleChip(
                    icon: Icons.flight_takeoff_rounded,
                    label: 'Du lịch',
                    onTap: onStyleTap,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: onQuickAdd,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text(
                    'Thêm vào giỏ',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTypography.sansFont,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 46,
              child: OutlinedButton(
                onPressed: onTap,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.cardBorder),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text(
                  'Chi tiết',
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: AppTypography.sansFont,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StyleChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _StyleChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.primary),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                fontFamily: AppTypography.sansFont,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EssentialMiniCard extends ConsumerWidget {
  final ProductEntity product;
  final String number;
  final VoidCallback onTap;
  final VoidCallback onQuickAdd;

  const _EssentialMiniCard({
    required this.product,
    required this.number,
    required this.onTap,
    required this.onQuickAdd,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorite = ref
        .watch(wishlistViewModelProvider)
        .isFavorite(product.id);

    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  InkWell(onTap: onTap, child: _productImage(product)),
                  const IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0.6, 1.0],
                          colors: [Colors.transparent, Color(0x8C1A1D17)],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    bottom: 6,
                    child: IgnorePointer(
                      child: Text(
                        number,
                        style: TextStyle(
                          fontFamily: AppTypography.serifFont,
                          fontSize: 30,
                          fontWeight: FontWeight.w400,
                          height: 1.0,
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        tooltip: favorite ? 'Bỏ yêu thích' : 'Yêu thích',
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.background.withValues(
                            alpha: 0.92,
                          ),
                        ),
                        onPressed: () => ref
                            .read(wishlistViewModelProvider.notifier)
                            .toggleFavorite(product),
                        icon: Icon(
                          favorite ? Icons.favorite : Icons.favorite_border,
                          size: 15,
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
            product.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: AppTypography.sansFont,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              const Icon(
                Icons.star_rounded,
                size: 13,
                color: Color(0xFFB08A3E),
              ),
              const SizedBox(width: 2),
              Text(
                product.rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontFamily: AppTypography.sansFont,
                  fontSize: 10.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              ...product.availableColors
                  .take(3)
                  .map(
                    (c) => Container(
                      width: 9,
                      height: 9,
                      margin: const EdgeInsets.only(left: 3),
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.cardBorder,
                          width: 0.8,
                        ),
                      ),
                    ),
                  ),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Expanded(
                child: Text(
                  product.formattedPrice,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppTypography.sansFont,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              SizedBox(
                width: 26,
                height: 26,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  tooltip: 'Thêm vào giỏ',
                  onPressed: onQuickAdd,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  icon: const Icon(Icons.add, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
