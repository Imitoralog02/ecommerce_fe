import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/mock_checkout_repository.dart';
import '../domain/repositories/checkout_repository.dart';

final checkoutRepositoryProvider = Provider<CheckoutRepository>((ref) {
  return const MockCheckoutRepository();
});
