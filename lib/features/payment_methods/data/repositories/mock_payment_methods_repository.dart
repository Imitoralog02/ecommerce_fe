import '../../domain/entities/payment_method_entities.dart';
import '../../domain/repositories/payment_methods_repository.dart';

class MockPaymentMethodsRepository implements PaymentMethodsRepository {
  PaymentMethodsState _state = const PaymentMethodsState(
    cards: [
      PaymentCardEntity(
        id: 'card-1',
        bankName: 'Techcombank Priority',
        cardType: 'Visa',
        lastFour: '8821',
        holderName: 'NGUYEN LINH',
        expiry: '08/28',
        gradientValues: [0xFF1E1C1A, 0xFF38322B],
        isDefault: true,
      ),
      PaymentCardEntity(
        id: 'card-2',
        bankName: 'Vietcombank Signature',
        cardType: 'Mastercard',
        lastFour: '4256',
        holderName: 'NGUYEN LINH',
        expiry: '11/27',
        gradientValues: [0xFF1A2634, 0xFF2E3E50],
      ),
      PaymentCardEntity(
        id: 'card-3',
        bankName: 'TPBank LiveBank',
        cardType: 'Napas',
        lastFour: '9012',
        holderName: 'NGUYEN LINH',
        expiry: '04/29',
        gradientValues: [0xFF321E36, 0xFF522E58],
      ),
    ],
  );

  @override
  PaymentMethodsState getState() => _state;

  @override
  void saveState(PaymentMethodsState state) => _state = state;
}
