import '../../../../data/local/demo_preferences_store.dart';
import '../../domain/entities/payment_method_entities.dart';
import '../../domain/repositories/payment_methods_repository.dart';

class MockPaymentMethodsRepository implements PaymentMethodsRepository {
  MockPaymentMethodsRepository([this._store]) {
    final saved = _store?.read(_key);
    if (saved is! Map) return;
    try {
      final map = Map<String, dynamic>.from(saved);
      _state = PaymentMethodsState(
        cards: (map['cards'] as List).map((value) {
          final card = Map<String, dynamic>.from(value as Map);
          return PaymentCardEntity(
            id: card['id'] as String,
            bankName: card['bankName'] as String,
            cardType: card['cardType'] as String,
            lastFour: card['lastFour'] as String,
            holderName: card['holderName'] as String,
            expiry: card['expiry'] as String,
            gradientValues: List<int>.from(card['gradientValues'] as List),
            isDefault: card['isDefault'] as bool,
          );
        }).toList(),
        momoLinked: map['momoLinked'] as bool,
        zalopayLinked: map['zalopayLinked'] as bool,
        deviceWalletEnabled: map['deviceWalletEnabled'] as bool,
      );
    } catch (_) {
      // Keep the demo fixture when a prior local snapshot is invalid.
    }
  }

  static const _key = 'demo_payment_methods_v1';
  final DemoPreferencesStore? _store;
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
  void saveState(PaymentMethodsState state) {
    _state = state;
    _store?.write(_key, {
      'cards': state.cards
          .map(
            (card) => {
              'id': card.id,
              'bankName': card.bankName,
              'cardType': card.cardType,
              'lastFour': card.lastFour,
              'holderName': card.holderName,
              'expiry': card.expiry,
              'gradientValues': card.gradientValues,
              'isDefault': card.isDefault,
            },
          )
          .toList(),
      'momoLinked': state.momoLinked,
      'zalopayLinked': state.zalopayLinked,
      'deviceWalletEnabled': state.deviceWalletEnabled,
    });
  }
}
