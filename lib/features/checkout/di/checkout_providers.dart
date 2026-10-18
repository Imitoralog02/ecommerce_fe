import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/mock_checkout_repository.dart';
import '../domain/repositories/checkout_repository.dart';
import '../domain/usecases/place_order_use_case.dart';

final checkoutRepositoryProvider = Provider<CheckoutRepository>((ref) {
  return MockCheckoutRepository();
});

final placeOrderUseCaseProvider = Provider<PlaceOrderUseCase>((ref) {
  return PlaceOrderUseCase(ref.read(checkoutRepositoryProvider));
});
