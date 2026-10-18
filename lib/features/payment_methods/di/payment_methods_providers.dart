import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/mock_payment_methods_repository.dart';
import '../domain/repositories/payment_methods_repository.dart';

final paymentMethodsRepositoryProvider = Provider<PaymentMethodsRepository>((
  ref,
) {
  return MockPaymentMethodsRepository();
});
