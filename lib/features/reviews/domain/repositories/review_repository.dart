import '../entities/review_entity.dart';

abstract class ReviewRepository {
  List<ReviewEntity> load(String productId);
  void save(String productId, List<ReviewEntity> reviews);
  bool addIfAbsent({
    required String productId,
    required String submissionKey,
    required ReviewEntity review,
  });
}
