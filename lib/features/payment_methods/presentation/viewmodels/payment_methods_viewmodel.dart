import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/payment_methods_providers.dart';
import '../../domain/entities/payment_method_entities.dart';

class PaymentMethodsViewModel extends Notifier<PaymentMethodsState> {
  @override
  PaymentMethodsState build() =>
      ref.read(paymentMethodsRepositoryProvider).getState();

  void _save(PaymentMethodsState next) {
    ref.read(paymentMethodsRepositoryProvider).saveState(next);
    state = next;
  }

  void addCard(PaymentCardEntity card) {
    final cards =
        state.cards
            .map(
              (item) => card.isDefault ? item.copyWith(isDefault: false) : item,
            )
            .toList()
          ..add(card);
    _save(state.copyWith(cards: cards));
  }

  void deleteCard(String id) {
    final removedWasDefault = state.cards.any(
      (card) => card.id == id && card.isDefault,
    );
    final cards = state.cards.where((card) => card.id != id).toList();
    if (removedWasDefault && cards.isNotEmpty) {
      cards[0] = cards[0].copyWith(isDefault: true);
    }
    _save(state.copyWith(cards: cards));
  }

  void setDefaultCard(String id) => _save(
    state.copyWith(
      cards: state.cards
          .map((card) => card.copyWith(isDefault: card.id == id))
          .toList(),
    ),
  );

  void setMomoLinked(bool value) => _save(state.copyWith(momoLinked: value));
  void setZalopayLinked(bool value) =>
      _save(state.copyWith(zalopayLinked: value));
  void setDeviceWalletEnabled(bool value) =>
      _save(state.copyWith(deviceWalletEnabled: value));
}

final paymentMethodsViewModelProvider =
    NotifierProvider<PaymentMethodsViewModel, PaymentMethodsState>(
      PaymentMethodsViewModel.new,
    );
