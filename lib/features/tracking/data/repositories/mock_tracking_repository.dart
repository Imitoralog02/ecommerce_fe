import '../../../orders/domain/entities/order_entity.dart';
import '../../domain/entities/tracking_snapshot.dart';
import '../../domain/repositories/tracking_repository.dart';

class MockTrackingRepository implements TrackingRepository {
  @override
  TrackingSnapshot load({
    required String orderId,
    required OrderStatus status,
  }) => TrackingSnapshot(
    orderId: orderId,
    stage: switch (status) {
      OrderStatus.shipping => TrackingStage.shipping,
      OrderStatus.delivered => TrackingStage.delivered,
      _ => TrackingStage.processing,
    },
    statusLabel: status.label,
    deliveryMethod: 'Giao hàng hỏa tốc',
  );
}
