import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../address/di/address_providers.dart';
import '../../../cart/di/cart_providers.dart';
import '../../../cart/presentation/viewmodels/cart_viewmodel.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/presentation/viewmodels/order_viewmodel.dart';
import '../../../payment_methods/presentation/viewmodels/payment_methods_viewmodel.dart';
import '../../../wallet/di/wallet_providers.dart';
import '../../../wallet/presentation/viewmodels/wallet_viewmodel.dart';
import '../../di/checkout_providers.dart';
import '../../domain/entities/checkout_selection.dart';
import '../../domain/usecases/place_order_use_case.dart';
export '../../di/checkout_providers.dart';

class CheckoutState {
  final ShippingType shippingType;
  final PaymentType paymentType;
  final double shippingFee;
  final bool isProcessing;
  final String? errorMessage;

  const CheckoutState({
    this.shippingType = ShippingType.express,
    this.paymentType = PaymentType.cashOnDelivery,
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

  Future<OrderEntity?> placeOrder() async {
    if (state.isProcessing) return null;
    state = state.copyWith(isProcessing: true, clearError: true);
    try {
      final paymentMethods = ref.read(paymentMethodsViewModelProvider);
      final selectedCard =
          paymentMethods.cards.where((card) => card.isDefault).firstOrNull ??
          paymentMethods.cards.firstOrNull;
      final order = await ref.read(placeOrderUseCaseProvider)(
        cart: ref.read(cartRepositoryProvider).load(),
        addressBook: ref.read(addressRepositoryProvider).load(),
        selection: CheckoutSelection(
          shippingType: state.shippingType,
          paymentType: state.paymentType,
          paymentCardLastFour: state.paymentType == PaymentType.creditCard
              ? selectedCard?.lastFour
              : null,
        ),
        paymentMethods: paymentMethods,
        wallet: ref.read(walletRepositoryProvider).load(),
        firstOrder: !ref
            .read(orderViewModelProvider)
            .orders
            .any((order) => order.isUserPlaced),
      );
      if (!ref.mounted) return null;
      ref.read(orderViewModelProvider.notifier).addOrder(order);
      ref
          .read(walletViewModelProvider.notifier)
          .completeOrderVoucher(order.id, order.couponCode, order.coinReward);
      ref.read(cartViewModelProvider.notifier).clearCart();
      return order;
    } on PlaceOrderException catch (error) {
      if (!ref.mounted) return null;
      state = state.copyWith(
        errorMessage: switch (error.failure) {
          PlaceOrderFailure.emptyCart => 'Giỏ hàng đang trống.',
          PlaceOrderFailure.missingAddress =>
            'Vui lòng chọn địa chỉ giao hàng.',
          PlaceOrderFailure.invalidCoupon =>
            'Mã ưu đãi không còn hợp lệ. Vui lòng kiểm tra lại giỏ hàng.',
          PlaceOrderFailure.paymentUnavailable =>
            'Phương thức thanh toán chưa được thiết lập.',
        },
      );
      return null;
    } catch (_) {
      if (!ref.mounted) return null;
      state = state.copyWith(
        errorMessage: 'Không thể đặt hàng. Vui lòng thử lại.',
      );
      return null;
    } finally {
      if (ref.mounted) state = state.copyWith(isProcessing: false);
    }
  }
}

final checkoutViewModelProvider =
    NotifierProvider<CheckoutViewModel, CheckoutState>(() {
      return CheckoutViewModel();
    });
