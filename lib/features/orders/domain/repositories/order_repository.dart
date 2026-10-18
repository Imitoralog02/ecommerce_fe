import '../entities/order_entity.dart';

abstract class OrderRepository {
  List<OrderEntity> getOrders();
  OrderEntity? getOrderById(String id);
  void saveOrder(OrderEntity order);
  void updateStatus(String orderId, OrderStatus status);
}
