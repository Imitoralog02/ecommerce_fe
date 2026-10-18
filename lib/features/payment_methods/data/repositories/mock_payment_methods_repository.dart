import '../../domain/entities/payment_method_entities.dart';
import '../../domain/repositories/payment_methods_repository.dart';

class MockPaymentMethodsRepository implements PaymentMethodsRepository {
  PaymentMethodsState _state = const PaymentMethodsState(
    cards: [
      PaymentCardEntity(
        id: 'sample-card-4242',
        bankName: 'NÉORA Mock Bank',
        cardType: 'Visa',
        lastFour: '4242',
        holderName: 'NEORA TEST',
        expiry: '12/30',
        gradientValues: [0xFF2C241E, 0xFF16120E],
        isDefault: true,
      ),
    ],
    momoLinked: true,
    zalopayLinked: true,
    deviceWalletEnabled: true,
  );

  @override
  PaymentMethodsState getState() => _state;

  @override
  void saveState(PaymentMethodsState state) => _state = state;
}
