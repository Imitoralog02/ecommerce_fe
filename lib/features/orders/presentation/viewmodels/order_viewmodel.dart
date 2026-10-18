import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../cart/presentation/viewmodels/cart_viewmodel.dart';
import '../../di/order_providers.dart';
import '../../domain/entities/order_entity.dart';

class OrderState {
  const OrderState({required this.orders});

  final List<OrderEntity> orders;

  List<OrderEntity> getOrdersByStatus(OrderStatus? status) => status == null
      ? orders
      : orders.where((order) => order.status == status).toList();

  OrderEntity? findById(String id) {
    for (final order in orders) {
      if (order.id == id) return order;
    }
    return null;
  }

  OrderState copyWith({List<OrderEntity>? orders}) =>
      OrderState(orders: orders ?? this.orders);
}

class OrderViewModel extends Notifier<OrderState> {
  @override
  OrderState build() =>
      OrderState(orders: ref.read(orderRepositoryProvider).getOrders());

  void addOrder(OrderEntity order) {
    final repository = ref.read(orderRepositoryProvider)..saveOrder(order);
    state = state.copyWith(orders: repository.getOrders());
  }

  void cancelOrder(String orderId) {
    final repository = ref.read(orderRepositoryProvider)
      ..updateStatus(orderId, OrderStatus.cancelled);
    state = state.copyWith(orders: repository.getOrders());
  }

  void buyAgain(OrderEntity order) {
    ref.read(cartViewModelProvider.notifier).addItems(order.items);
  }
}

final orderViewModelProvider = NotifierProvider<OrderViewModel, OrderState>(
  OrderViewModel.new,
);
