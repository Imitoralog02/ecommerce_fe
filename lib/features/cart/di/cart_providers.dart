import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/mock_cart_repository.dart';
import '../domain/repositories/cart_repository.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return MockCartRepository();
});
