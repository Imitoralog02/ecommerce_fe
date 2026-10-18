import '../../../address/domain/repositories/address_repository.dart';
import '../../../cart/domain/entities/cart_snapshot.dart';
import '../../../cart/domain/services/cart_pricing.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../payment_methods/domain/entities/payment_method_entities.dart';
import '../../../wallet/domain/entities/wallet_snapshot.dart';
import '../entities/checkout_quote.dart';
import '../entities/checkout_request.dart';
import '../entities/checkout_selection.dart';
import '../repositories/checkout_repository.dart';

enum PlaceOrderFailure {
  emptyCart,
  missingAddress,
  invalidCoupon,
  paymentUnavailable,
}

class PlaceOrderException implements Exception {
  const PlaceOrderException(this.failure);

  final PlaceOrderFailure failure;
}

class PlaceOrderUseCase {
  const PlaceOrderUseCase(this._repository);

  final CheckoutRepository _repository;

  Future<OrderEntity> call({
    required CartSnapshot cart,
    required AddressBookSnapshot addressBook,
    required CheckoutSelection selection,
    required PaymentMethodsState paymentMethods,
    WalletSnapshot? wallet,
    bool firstOrder = false,
  }) {
    if (cart.items.isEmpty) {
      throw const PlaceOrderException(PlaceOrderFailure.emptyCart);
    }

    final address =
        addressBook.addresses
            .where((item) => item.id == addressBook.selectedAddressId)
            .firstOrNull ??
        addressBook.addresses.where((item) => item.isDefault).firstOrNull ??
        addressBook.addresses.firstOrNull;
    if (address == null) {
      throw const PlaceOrderException(PlaceOrderFailure.missingAddress);
    }

    final paymentAvailable = switch (selection.paymentType) {
      PaymentType.cashOnDelivery => true,
      PaymentType.applePay => paymentMethods.deviceWalletEnabled,
      PaymentType.momo => paymentMethods.momoLinked,
      PaymentType.zalopay => paymentMethods.zalopayLinked,
      PaymentType.creditCard =>
        selection.paymentCardLastFour != null &&
            paymentMethods.cards.any(
              (card) => card.lastFour == selection.paymentCardLastFour,
            ),
    };
    if (!paymentAvailable) {
      throw const PlaceOrderException(PlaceOrderFailure.paymentUnavailable);
    }

    final subtotal = cart.items.fold<double>(
      0,
      (sum, item) => sum + item.totalPrice,
    );
    if (cart.appliedCoupon != null) {
      final promotion = CartPricing.evaluate(
        cart.appliedCoupon,
        subtotal: subtotal,
        items: cart.items,
        voucher: wallet?.vouchers
            .where((voucher) => voucher.code == cart.appliedCoupon)
            .firstOrNull,
        memberTier: wallet?.memberTier ?? '',
        firstOrder: firstOrder,
        isExpressShipping: selection.shippingType == ShippingType.express,
        shippingFee: selection.shippingFee,
        requireShippingBenefit: true,
      );
      if (!promotion.isValid) {
        throw const PlaceOrderException(PlaceOrderFailure.invalidCoupon);
      }
    }

    return _repository.placeOrder(
      CheckoutRequest(
        items: List.unmodifiable(cart.items),
        address: address,
        selection: selection,
        quote: CheckoutQuote.calculate(
          cart,
          selection,
          wallet: wallet,
          firstOrder: firstOrder,
        ),
        couponCode: cart.appliedCoupon,
      ),
    );
  }
}
