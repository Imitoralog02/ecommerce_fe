import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/data/repositories/mock_product_repository.dart';
import '../data/repositories/mock_order_repository.dart';
import '../domain/repositories/order_repository.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return MockOrderRepository(MockProductRepository.mockCatalog);
});
