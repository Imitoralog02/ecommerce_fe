import '../../domain/entities/checkout_selection.dart';
import '../../domain/repositories/checkout_repository.dart';

class MockCheckoutRepository implements CheckoutRepository {
  const MockCheckoutRepository();

  @override
  Future<void> placeOrder(CheckoutSelection selection) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
  }
}
