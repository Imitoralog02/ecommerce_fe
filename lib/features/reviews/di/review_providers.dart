import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/mock_review_repository.dart';
import '../domain/repositories/review_repository.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return MockReviewRepository();
});
