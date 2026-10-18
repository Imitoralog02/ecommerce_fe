import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/data/repositories/mock_product_repository.dart';
import '../data/repositories/mock_recently_viewed_repository.dart';
import '../domain/repositories/recently_viewed_repository.dart';

final recentlyViewedRepositoryProvider = Provider<RecentlyViewedRepository>((
  ref,
) {
  return MockRecentlyViewedRepository(MockProductRepository.mockCatalog);
});
