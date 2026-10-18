import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/data/repositories/mock_product_repository.dart';
import '../data/repositories/mock_wishlist_repository.dart';
import '../domain/repositories/wishlist_repository.dart';

final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  return MockWishlistRepository(MockProductRepository.mockCatalog);
});
