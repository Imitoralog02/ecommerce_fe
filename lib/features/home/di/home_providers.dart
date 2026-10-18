import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/mock_product_repository.dart';
import '../domain/repositories/product_repository.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return MockProductRepository();
});
