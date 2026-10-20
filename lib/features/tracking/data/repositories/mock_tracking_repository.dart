import '../../../orders/domain/entities/order_entity.dart';
import '../../../checkout/domain/entities/checkout_selection.dart';
import '../../domain/entities/tracking_snapshot.dart';
import '../../domain/repositories/tracking_repository.dart';

class MockTrackingRepository implements TrackingRepository {
  @override
  TrackingSnapshot load({
    required String orderId,
    required OrderStatus status,
    ShippingType shippingType = ShippingType.express,
  }) => TrackingSnapshot(
    orderId: orderId,
    stage: switch (status) {
      OrderStatus.shipping => TrackingStage.shipping,
      OrderStatus.delivered => TrackingStage.delivered,
      OrderStatus.cancelled => TrackingStage.cancelled,
      _ => TrackingStage.processing,
    },
    statusLabel: status.label,
    deliveryMethod: shippingType.displayLabel,
  );
}
