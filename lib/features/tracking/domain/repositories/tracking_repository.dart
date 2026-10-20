import '../../../orders/domain/entities/order_entity.dart';
import '../../../checkout/domain/entities/checkout_selection.dart';
import '../entities/tracking_snapshot.dart';

abstract class TrackingRepository {
  TrackingSnapshot load({
    required String orderId,
    required OrderStatus status,
    ShippingType shippingType = ShippingType.express,
  });
}
