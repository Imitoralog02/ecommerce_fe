import '../../../cart/domain/entities/cart_snapshot.dart';
import '../../../cart/domain/services/cart_pricing.dart';
import '../../../wallet/domain/entities/wallet_snapshot.dart';
import 'checkout_selection.dart';

class CheckoutQuote {
  const CheckoutQuote({
    required this.subtotal,
    required this.shippingFee,
    required this.discount,
    required this.total,
    this.coinReward = 0,
    this.giftDescription,
    this.promotionReason,
  });

  final double subtotal;
  final double shippingFee;
  final double discount;
  final double total;
  final int coinReward;
  final String? giftDescription;
  final String? promotionReason;

  factory CheckoutQuote.calculate(
    CartSnapshot cart,
    CheckoutSelection selection, {
    WalletSnapshot? wallet,
    bool firstOrder = false,
  }) {
    final subtotal = cart.items.fold<double>(
      0,
      (sum, item) => sum + item.totalPrice,
    );
    final baseShippingFee = selection.shippingFee;
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
      shippingFee: baseShippingFee,
      requireShippingBenefit: true,
    );
    final shippingFee = baseShippingFee - promotion.shippingDiscount;
    final discount = promotion.itemDiscount;
    return CheckoutQuote(
      subtotal: subtotal,
      shippingFee: shippingFee,
      discount: discount,
      total: (subtotal + shippingFee - discount).clamp(0.0, double.infinity),
      coinReward: promotion.coinReward,
      giftDescription: promotion.giftDescription,
      promotionReason: cart.appliedCoupon == null ? null : promotion.reason,
    );
  }
}
