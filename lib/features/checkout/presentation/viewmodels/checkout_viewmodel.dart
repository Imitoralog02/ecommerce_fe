import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/checkout_providers.dart';
import '../../domain/entities/checkout_selection.dart';
export '../../di/checkout_providers.dart';

class CheckoutState {
  final ShippingType shippingType;
  final PaymentType paymentType;
  final double shippingFee;
  final bool isProcessing;
  final String? errorMessage;

  const CheckoutState({
    this.shippingType = ShippingType.express,
    this.paymentType = PaymentType.applePay,
    this.shippingFee = 30000,
    this.isProcessing = false,
    this.errorMessage,
  });

  CheckoutState copyWith({
    ShippingType? shippingType,
    PaymentType? paymentType,
    double? shippingFee,
    bool? isProcessing,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CheckoutState(
      shippingType: shippingType ?? this.shippingType,
      paymentType: paymentType ?? this.paymentType,
      shippingFee: shippingFee ?? this.shippingFee,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class CheckoutViewModel extends Notifier<CheckoutState> {
  @override
  CheckoutState build() {
    return const CheckoutState();
  }

  void setShipping(ShippingType type) {
    final fee = CheckoutSelection(
      shippingType: type,
      paymentType: state.paymentType,
    ).shippingFee;
    state = state.copyWith(shippingType: type, shippingFee: fee);
  }

  void setPayment(PaymentType type) {
    state = state.copyWith(paymentType: type);
  }

  Future<bool> placeOrder() async {
    if (state.isProcessing) return false;
    state = state.copyWith(isProcessing: true, clearError: true);
    try {
      await ref
          .read(checkoutRepositoryProvider)
          .placeOrder(
            CheckoutSelection(
              shippingType: state.shippingType,
              paymentType: state.paymentType,
            ),
          );
      return true;
    } catch (_) {
      state = state.copyWith(
        errorMessage: 'Không thể đặt hàng. Vui lòng thử lại.',
      );
      return false;
    } finally {
      state = state.copyWith(isProcessing: false);
    }
  }
}

final checkoutViewModelProvider =
    NotifierProvider<CheckoutViewModel, CheckoutState>(() {
      return CheckoutViewModel();
    });
