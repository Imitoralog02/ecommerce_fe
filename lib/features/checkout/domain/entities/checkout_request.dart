import '../../../address/domain/entities/address_entity.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import 'checkout_quote.dart';
import 'checkout_selection.dart';

class CheckoutRequest {
  const CheckoutRequest({
    required this.items,
    required this.address,
    required this.selection,
    required this.quote,
    this.couponCode,
  });

  final List<CartItemEntity> items;
  final AddressEntity address;
  final CheckoutSelection selection;
  final CheckoutQuote quote;
  final String? couponCode;
}
