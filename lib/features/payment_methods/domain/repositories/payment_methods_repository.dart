import '../entities/payment_method_entities.dart';

abstract class PaymentMethodsRepository {
  PaymentMethodsState getState();
  void saveState(PaymentMethodsState state);
}
