import '../../../orders/domain/entities/order_entity.dart';
import '../../domain/entities/checkout_request.dart';
import '../../domain/entities/checkout_selection.dart';
import '../../domain/repositories/checkout_repository.dart';

class MockCheckoutRepository implements CheckoutRepository {
  @override
  Future<OrderEntity> placeOrder(CheckoutRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    final quote = request.quote;
    return OrderEntity(
      id: 'NEO-${DateTime.now().microsecondsSinceEpoch}',
      orderDate: DateTime.now(),
      status: OrderStatus.pendingConfirmation,
      items: request.items,
      subtotal: quote.subtotal,
      shippingFee: quote.shippingFee,
      discountAmount: quote.discount,
      totalAmount: quote.total,
      shippingAddress: request.address,
      estimatedDelivery: request.selection.shippingType == ShippingType.express
          ? 'Ngày mai lúc 14:00'
          : 'Trong 2–3 ngày tới',
      paymentMethod: switch (request.selection.paymentType) {
        PaymentType.applePay => 'Apple Pay / Google Pay (mô phỏng)',
        PaymentType.creditCard =>
          'Thẻ •••• ${request.selection.paymentCardLastFour} (mô phỏng)',
        PaymentType.momo => 'MoMo (mô phỏng)',
        PaymentType.zalopay => 'ZaloPay (mô phỏng)',
        PaymentType.cashOnDelivery => 'Thanh toán khi nhận hàng (COD)',
      },
      couponCode: request.couponCode,
      coinReward: quote.coinReward,
      giftDescription: quote.giftDescription,
      isUserPlaced: true,
    );
  }
}
