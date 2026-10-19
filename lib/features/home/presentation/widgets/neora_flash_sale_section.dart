import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/product_entity.dart';
import '../../../shop/domain/entities/flash_sale_campaign.dart';

class NeoraFlashSaleSection extends StatefulWidget {
  final List<ProductEntity> products;
  final ValueChanged<ProductEntity>? onProductTap;
  final VoidCallback? onSeeAll;

  const NeoraFlashSaleSection({
    super.key,
    required this.products,
    this.onProductTap,
    this.onSeeAll,
  });

  @override
  State<NeoraFlashSaleSection> createState() => _NeoraFlashSaleSectionState();
}

class _NeoraFlashSaleSectionState extends State<NeoraFlashSaleSection> {
  DateTime _now = DateTime.now();
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  String _formatNumber(int n) => n.toString().padLeft(2, '0');

  String _formatVnd(double price) {
    final intPrice = price.toInt();
    final s = intPrice.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(s[i]);
    }
    return '${buffer.toString()}₫';
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final cardHeight = 232.0 + ((textScale - 1) * 32).clamp(0, 32);
    final slot = FlashSaleCampaign.currentOrNext(_now);
    final remainingSeconds = slot.untilBoundary(_now).inSeconds;
    final hours = remainingSeconds ~/ 3600;
    final minutes = (remainingSeconds % 3600) ~/ 60;
    final seconds = remainingSeconds % 60;

    final displayProducts = widget.products
        .where((product) => FlashSaleCampaign.offers.containsKey(product.id))
        .take(6)
        .toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E1C1A), Color(0xFF2E2822)],
        ),
        boxShadow: const [],
      ),
      padding: const EdgeInsets.only(top: 14, bottom: 16),
      child: Column(
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('⚡', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'FLASH SALE',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                          letterSpacing: 0.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: widget.onSeeAll,
                      child: const Text(
                        'Xem tất cả ›',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.coralOrange,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  slot.isActiveAt(_now)
                      ? 'Kết thúc lúc ${slot.endHour == 24 ? '00' : slot.endHour.toString().padLeft(2, '0')}:00'
                      : 'Bắt đầu lúc ${slot.label}',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDigitBox(_formatNumber(hours)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3),
                      child: Text(
                        ':',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _buildDigitBox(_formatNumber(minutes)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3),
                      child: Text(
                        ':',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _buildDigitBox(_formatNumber(seconds)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Horizontal Flash Product Cards
          SizedBox(
            height: cardHeight,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: displayProducts.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final product = displayProducts[index];
                final offer = FlashSaleCampaign.offers[product.id]!;
                final soldPercent = (offer.soldFractionAt(_now, slot) * 100)
                    .round();
                final remaining = offer.remainingAt(_now, slot);
                final discount = FlashSaleCampaign.discountPercent(product);

                return GestureDetector(
                  onTap: () => widget.onProductTap?.call(product),
                  child: Container(
                    width: 132,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: const [],
                    ),
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image with discount tag
                        Stack(
                          children: [
                            Container(
                              height: 136,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                color: const Color(0xFFF5EEE4),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: product.imagePath != null
                                    ? Image.asset(
                                        product.imagePath!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) => const Icon(
                                          Icons.image,
                                          color: Colors.black26,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.image,
                                        color: Colors.black26,
                                      ),
                              ),
                            ),
                            // Discount badge
                            if (discount > 0)
                              Positioned(
                                top: 6,
                                left: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.saleRed,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '-$discount%',
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

                        const SizedBox(height: 8),

                        // Flash Price
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            _formatVnd(product.price),
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.saleRed,
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Sold Progress Bar (sbarw)
                        Container(
                          height: 16,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAE4DC),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Stack(
                            children: [
                              FractionallySizedBox(
                                widthFactor: (soldPercent / 100).clamp(
                                  0.1,
                                  1.0,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFDFC59E),
                                        Color(0xFFC8A97E),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Center(
                                child: Text(
                                  slot.isUpcomingAt(_now)
                                      ? 'Còn $remaining suất'
                                      : remaining == 0
                                      ? 'Đã hết suất'
                                      : '🔥 Đã bán $soldPercent%',
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A1815),
                                    height: 1.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDigitBox(String text) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: AppColors.coralOrange,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0E0E0E),
          ),
        ),
      ),
    );
  }
}
