import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/media/di/media_picker_providers.dart';
import '../../../../core/media/domain/media_picker_repository.dart';
import '../../../home/di/home_providers.dart';
import '../../../home/domain/entities/product_entity.dart';
import '../../di/review_providers.dart';
import '../../domain/entities/review_entity.dart';

enum ReviewFilter { all, images, fiveStars, measured }

class ReviewState {
  const ReviewState({
    this.reviews = const [],
    this.selectedFilter = ReviewFilter.all,
  });

  final List<ReviewEntity> reviews;
  final ReviewFilter selectedFilter;

  int totalCount(ProductEntity product) =>
      product.reviewCount +
      reviews
          .where(
            (review) =>
                !review.id.startsWith('rev_') && !review.id.startsWith('seed_'),
          )
          .length;

  double averageRating(ProductEntity product) {
    final submitted = reviews
        .where(
          (review) =>
              !review.id.startsWith('rev_') && !review.id.startsWith('seed_'),
        )
        .toList();
    if (submitted.isEmpty) return product.rating;
    return (product.rating * product.reviewCount +
            submitted.fold<double>(0, (sum, review) => sum + review.rating)) /
        (product.reviewCount + submitted.length);
  }

  List<ReviewEntity> get filteredReviews => switch (selectedFilter) {
    ReviewFilter.images =>
      reviews.where((review) => review.reviewImages.isNotEmpty).toList(),
    ReviewFilter.fiveStars =>
      reviews.where((review) => review.rating >= 5).toList(),
    ReviewFilter.measured =>
      reviews.where((review) => review.buyerHeight.isNotEmpty).toList(),
    ReviewFilter.all => reviews,
  };

  ReviewState copyWith({
    List<ReviewEntity>? reviews,
    ReviewFilter? selectedFilter,
  }) => ReviewState(
    reviews: reviews ?? this.reviews,
    selectedFilter: selectedFilter ?? this.selectedFilter,
  );
}

class ReviewViewModel extends Notifier<ReviewState> {
  ReviewViewModel(this.productId);

  final String productId;

  @override
  ReviewState build() =>
      ReviewState(reviews: ref.read(reviewRepositoryProvider).load(productId));

  void _save(List<ReviewEntity> reviews) {
    ref.read(reviewRepositoryProvider).save(productId, reviews);
    state = state.copyWith(reviews: reviews);
  }

  void selectFilter(ReviewFilter filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  void toggleHelpful(String reviewId) {
    _save(
      state.reviews.map((review) {
        if (review.id != reviewId) return review;
        final isHelpful = !review.isHelpful;
        return review.copyWith(
          isHelpful: isHelpful,
          helpfulCount: review.helpfulCount + (isHelpful ? 1 : -1),
        );
      }).toList(),
    );
  }

  bool submitReview({
    required ReviewEntity review,
    required String submissionKey,
  }) {
    final repository = ref.read(reviewRepositoryProvider);
    final added = repository.addIfAbsent(
      productId: productId,
      submissionKey: submissionKey,
      review: review,
    );
    if (added) state = state.copyWith(reviews: repository.load(productId));
    return added;
  }

  Future<String?> pickReviewImage() async {
    final product = await ref
        .read(productRepositoryProvider)
        .getProductById(productId);
    if (!ref.mounted) return null;
    return ref
        .read(mediaPickerRepositoryProvider)
        .pickImage(
          MediaPickerPurpose.review,
          suggestedAsset: product?.imagePath,
        );
  }
}

final reviewViewModelProvider = NotifierProvider.autoDispose
    .family<ReviewViewModel, ReviewState, String>(ReviewViewModel.new);
