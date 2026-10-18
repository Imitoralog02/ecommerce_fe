import 'cart_item_entity.dart';

class CartSnapshot {
  const CartSnapshot({
    this.items = const [],
    this.appliedCoupon,
    this.discount = 0,
    this.shippingFee = 0,
  });

  final List<CartItemEntity> items;
  final String? appliedCoupon;
  final double discount;
  final double shippingFee;
}
