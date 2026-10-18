import '../../../orders/domain/entities/order_entity.dart';
import '../entities/checkout_request.dart';

abstract interface class CheckoutRepository {
  Future<OrderEntity> placeOrder(CheckoutRequest request);
}
