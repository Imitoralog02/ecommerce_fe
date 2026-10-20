import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../home/domain/entities/product_entity.dart';
import '../../domain/entities/review_entity.dart';
import '../viewmodels/review_viewmodel.dart';

class ProductReviewsScreen extends ConsumerStatefulWidget {
  final ProductEntity product;

  const ProductReviewsScreen({super.key, required this.product});

  @override
  ConsumerState<ProductReviewsScreen> createState() =>
      _ProductReviewsScreenState();
}

class _ProductReviewsScreenState extends ConsumerState<ProductReviewsScreen> {
  @override
  Widget build(BuildContext context) {
    final reviewState = ref.watch(reviewViewModelProvider(widget.product.id));
    final filtered = reviewState.filteredReviews;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cardBorder, width: 0.8),
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
          'Đánh Giá Mẫu (${reviewState.totalCount(widget.product)})',
          style: const TextStyle(
            fontSize: 17.5,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        children: [
          // 1. Overall Score & Rating Progress Card
          _buildScoreBreakdownCard(reviewState),

          const SizedBox(height: 18),

          // 2. Buyer Photo Gallery Carousel
          _buildBuyerGallery(reviewState.reviews),

          const SizedBox(height: 16),

          // 3. Filter Chips
          _buildFilterChips(),

          const SizedBox(height: 16),

          Text(
            'Đang hiển thị ${filtered.length} đánh giá mẫu của sản phẩm',
            style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),

          // 4. Reviews List
          ...filtered.map(_buildReviewCard),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildScoreBreakdownCard(ReviewState reviewState) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF502814).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left: Big Rating Number & Stars
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                reviewState.averageRating(widget.product).toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: -1,
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => const Icon(
                    Icons.star_rounded,
                    size: 18,
                    color: Color(0xFFFFA000),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${reviewState.totalCount(widget.product)} nhận xét',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),

          const SizedBox(width: 20),
          Container(width: 1, height: 80, color: const Color(0xFFEBE5DC)),
          const SizedBox(width: 20),

          // Right: Star Rating Bars
          Expanded(
            child: Column(
              children: [
                for (final star in [5, 4, 3, 2, 1])
                  _buildStarBar(
                    star,
                    reviewState.reviews.isEmpty
                        ? 0
                        : reviewState.reviews
                                  .where(
                                    (review) => review.rating.round() == star,
                                  )
                                  .length /
                              reviewState.reviews.length,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarBar(int star, double percent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.2),
      child: Row(
        children: [
          Text(
            '$star',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const Icon(Icons.star_rounded, size: 12, color: Color(0xFFFFA000)),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 5,
                backgroundColor: const Color(0xFFEFE8DF),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.coralOrange,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 28,
            child: Text(
              '${(percent * 100).toInt()}%',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuyerGallery(List<ReviewEntity> reviews) {
    final buyerImages = reviews
        .expand((review) => review.reviewImages)
        .toList();
    if (buyerImages.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ẢNH MINH HỌA CỦA SẢN PHẨM 📸',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.6,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '${buyerImages.length} ảnh',
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.coralOrange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 82,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: buyerImages.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 82,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Image.asset(
                    buyerImages[i],
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: AppColors.studioGray,
                      child: const Icon(
                        Icons.image_outlined,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    final selectedFilter = ref.watch(
      reviewViewModelProvider(
        widget.product.id,
      ).select((state) => state.selectedFilter),
    );
    const filters = [
      (filter: ReviewFilter.all, label: 'Tất cả (348)'),
      (filter: ReviewFilter.images, label: 'Có ảnh/video 📸'),
      (filter: ReviewFilter.fiveStars, label: '5 sao (296) ⭐'),
      (filter: ReviewFilter.measured, label: 'Kèm số đo 📏'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const AlwaysScrollableScrollPhysics(),
      child: Row(
        children: filters.map((item) {
          final isSelected = selectedFilter == item.filter;
          return GestureDetector(
            onTap: () => ref
                .read(reviewViewModelProvider(widget.product.id).notifier)
                .selectFilter(item.filter),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.brandBlack : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.brandBlack
                      : AppColors.cardBorder,
                ),
              ),
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReviewCard(ReviewEntity review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF502814).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar, Name, Verified Badge, Rating, Date
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.softPeach,
                child: Text(
                  review.userName.characters.first,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.coralOrange,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          review.userName,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.verified_rounded,
                          size: 14,
                          color: AppColors.mintGreen,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Row(
                          children: List.generate(
                            review.rating.toInt(),
                            (i) => const Icon(
                              Icons.star_rounded,
                              size: 13,
                              color: Color(0xFFFFA000),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          review.date,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Buyer Measurements Chip Bar
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildMiniTag(
                '📏 Cao ${review.buyerHeight} · ${review.buyerWeight}',
              ),
              _buildMiniTag(
                'Phân loại: ${review.purchasedSize} / ${review.purchasedColor}',
              ),
              _buildMiniTag('✓ ${review.fitFeedback}', isHighlight: true),
            ],
          ),

          const SizedBox(height: 10),

          // Review Comment Text
          Text(
            review.comment,
            style: const TextStyle(
              fontSize: 13,
              height: 1.45,
              color: AppColors.textPrimary,
            ),
          ),

          // Attached Images
          if (review.reviewImages.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: review.reviewImages.map((img) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(img, fit: BoxFit.cover),
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 12),

          // Helpful action button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => ref
                    .read(reviewViewModelProvider(widget.product.id).notifier)
                    .toggleHelpful(review.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: review.isHelpful
                        ? AppColors.coralOrange.withValues(alpha: 0.12)
                        : const Color(0xFFF7F4EF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: review.isHelpful
                          ? AppColors.coralOrange
                          : const Color(0xFFE2DDD8),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        review.isHelpful
                            ? Icons.thumb_up_rounded
                            : Icons.thumb_up_outlined,
                        size: 13,
                        color: review.isHelpful
                            ? AppColors.coralOrange
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Hữu ích (${review.helpfulCount})',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: review.isHelpful
                              ? AppColors.coralOrange
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Seller Reply
          if (review.sellerReply != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F4EF),
                borderRadius: BorderRadius.circular(12),
                border: const Border(
                  left: BorderSide(color: AppColors.coralOrange, width: 3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Phản hồi mẫu từ NÉORA ✨',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                      color: AppColors.coralOrange,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    review.sellerReply!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniTag(String text, {bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: isHighlight ? AppColors.mintGreenSoft : const Color(0xFFF5EEE4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isHighlight ? AppColors.mintGreen : AppColors.textSecondary,
        ),
      ),
    );
  }
}
