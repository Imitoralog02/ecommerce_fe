import '../../../orders/domain/entities/order_entity.dart';
import '../entities/tracking_snapshot.dart';

abstract class TrackingRepository {
  TrackingSnapshot load({required String orderId, required OrderStatus status});
}
