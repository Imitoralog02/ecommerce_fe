import '../entities/checkout_selection.dart';

abstract interface class CheckoutRepository {
  Future<void> placeOrder(CheckoutSelection selection);
}
