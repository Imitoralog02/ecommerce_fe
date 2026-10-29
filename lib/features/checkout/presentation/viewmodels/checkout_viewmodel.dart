import 'dart:async';

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
import '../../../../core/network/remote_repositories.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/checkout_quote.dart';
export '../../di/checkout_providers.dart';

class CheckoutState {
  final CheckoutQuote? serverQuote;
  final ShippingType shippingType;
  final PaymentType paymentType;
  final double shippingFee;
  final bool isProcessing;
  final String? errorMessage;

  const CheckoutState({
    this.serverQuote,
    this.shippingType = ShippingType.express,
    this.paymentType = PaymentType.cashOnDelivery,
    this.shippingFee = 30000,
    this.isProcessing = false,
    this.errorMessage,
  });

  CheckoutState copyWith({
    CheckoutQuote? serverQuote,
    bool clearServerQuote = false,
    ShippingType? shippingType,
    PaymentType? paymentType,
    double? shippingFee,
    bool? isProcessing,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CheckoutState(
      serverQuote: clearServerQuote ? null : serverQuote ?? this.serverQuote,
      shippingType: shippingType ?? this.shippingType,
      paymentType: paymentType ?? this.paymentType,
      shippingFee: shippingFee ?? this.shippingFee,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class CheckoutViewModel extends Notifier<CheckoutState> {
  int _quoteGeneration = 0;
  @override
  CheckoutState build() {
    return const CheckoutState();
  }

  void setShipping(ShippingType type) {
    final fee = CheckoutSelection(
      shippingType: type,
      paymentType: state.paymentType,
    ).shippingFee;
    state = state.copyWith(
      shippingType: type,
      shippingFee: fee,
      clearServerQuote: true,
    );
    refreshQuote();
  }

  void setPayment(PaymentType type) {
    if (ref.read(checkoutRepositoryProvider) is RemoteCheckoutRepository &&
        type != PaymentType.cashOnDelivery) {
      return;
    }
    state = state.copyWith(paymentType: type);
  }

  Future<void> refreshQuote() async {
    final repository = ref.read(checkoutRepositoryProvider);
    if (repository is! RemoteCheckoutRepository) return;
    final generation = ++_quoteGeneration;
    final shipping = state.shippingType;
    try {
      final data = await repository.quote(shipping);
      if (ref.mounted &&
          generation == _quoteGeneration &&
          shipping == state.shippingType) {
        state = state.copyWith(
          serverQuote: CheckoutQuote(
            subtotal: (data['subtotal'] as num).toDouble(),
            shippingFee: (data['shippingFee'] as num).toDouble(),
            discount: (data['discount'] as num).toDouble(),
            total: (data['total'] as num).toDouble(),
          ),
        );
      }
    } catch (error) {
      if (ref.mounted) state = state.copyWith(errorMessage: '$error');
    }
  }

  Future<OrderEntity?> placeOrder() async {
    if (state.isProcessing) return null;
    state = state.copyWith(isProcessing: true, clearError: true);
    try {
      final checkoutRepository = ref.read(checkoutRepositoryProvider);
      final remote = checkoutRepository is RemoteCheckoutRepository;
      if (checkoutRepository is RemoteCheckoutRepository) {
        final recovered = await checkoutRepository.recoverPendingOrder();
        if (recovered != null) {
          if (!ref.mounted) return null;
          ref.read(orderViewModelProvider.notifier).addOrder(recovered);
          ref.read(orderViewModelProvider.notifier).refresh();
          if (recovered.status == OrderStatus.cancelled) {
            state = state.copyWith(
              errorMessage:
                  'Đơn hàng trước đã bị hủy. Giỏ hàng vẫn được giữ; vui lòng kiểm tra lịch sử đơn.',
            );
            return null;
          }
          unawaited(
            ref
                .read(cartViewModelProvider.notifier)
                .reconcilePurchasedItems(
                  recovered.items.map((item) => item.serverId),
                ),
          );
          return recovered;
        }
      }
      final cartRepository = ref.read(cartRepositoryProvider);
      final addressRepository = ref.read(addressRepositoryProvider);
      final cart = remote && cartRepository is RemoteCartRepository
          ? await cartRepository.refresh()
          : cartRepository.load();
      final addresses = remote && addressRepository is RemoteAddressRepository
          ? await addressRepository.refresh()
          : addressRepository.load();
      if (remote && state.paymentType != PaymentType.cashOnDelivery) {
        throw const PlaceOrderException(PlaceOrderFailure.paymentUnavailable);
      }
      final paymentMethods = ref.read(paymentMethodsViewModelProvider);
      final selectedCard =
          paymentMethods.cards.where((card) => card.isDefault).firstOrNull ??
          paymentMethods.cards.firstOrNull;
      final order = await ref.read(placeOrderUseCaseProvider)(
        cart: cart,
        addressBook: addresses,
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
      if (remote && order.status == OrderStatus.cancelled) {
        state = state.copyWith(
          errorMessage:
              'Đơn hàng bị hủy do không đủ tồn kho. Giỏ hàng vẫn được giữ.',
        );
        return null;
      }
      ref.read(orderViewModelProvider.notifier).addOrder(order);
      if (!remote) {
        ref
            .read(walletViewModelProvider.notifier)
            .completeOrderVoucher(order.id, order.couponCode, order.coinReward);
        ref.read(cartViewModelProvider.notifier).clearCart();
      } else {
        ref.read(orderViewModelProvider.notifier).refresh();
        unawaited(
          ref
              .read(cartViewModelProvider.notifier)
              .reconcilePurchasedItems(
                order.items.map((item) => item.serverId),
              ),
        );
      }
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
    } on ApiException catch (error) {
      if (!ref.mounted) return null;
      state = state.copyWith(errorMessage: error.message);
      return null;
    } catch (_) {
      if (!ref.mounted) return null;
      state = state.copyWith(
        errorMessage:
            'Chưa xác minh được kết quả đặt hàng. Vui lòng kiểm tra kết nối rồi thử lại; ứng dụng sẽ tra cứu đơn cũ trước.',
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
