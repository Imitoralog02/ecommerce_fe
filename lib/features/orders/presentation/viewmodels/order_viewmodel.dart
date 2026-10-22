import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../cart/presentation/viewmodels/cart_viewmodel.dart';
import '../../../wallet/presentation/viewmodels/wallet_viewmodel.dart';
import '../../di/order_providers.dart';
import '../../domain/entities/order_entity.dart';
import '../../../../core/network/remote_repositories.dart';

class OrderState {
  const OrderState({required this.orders, this.errorMessage});

  final List<OrderEntity> orders;
  final String? errorMessage;

  List<OrderEntity> getOrdersByStatus(OrderStatus? status) => status == null
      ? orders
      : orders.where((order) => order.status == status).toList();

  OrderEntity? findById(String id) {
    for (final order in orders) {
      if (order.id == id) return order;
    }
    return null;
  }

  OrderState copyWith({List<OrderEntity>? orders, String? errorMessage}) =>
      OrderState(orders: orders ?? this.orders, errorMessage: errorMessage);
}

class OrderViewModel extends Notifier<OrderState> {
  @override
  OrderState build() {
    if (ref.read(orderRepositoryProvider) is RemoteOrderRepository) {
      Future.microtask(() => refresh());
    }
    return OrderState(orders: ref.read(orderRepositoryProvider).getOrders());
  }

  Future<void> refresh() async {
    final repository = ref.read(orderRepositoryProvider);
    if (repository is! RemoteOrderRepository) return;
    try {
      final orders = await repository.refresh();
      if (ref.mounted) state = state.copyWith(orders: orders);
    } catch (error) {
      if (ref.mounted) state = state.copyWith(errorMessage: '$error');
    }
  }

  Future<bool> cancelOrderAsync(String orderId) async {
    final repository = ref.read(orderRepositoryProvider);
    if (repository is! RemoteOrderRepository) return cancelOrder(orderId);
    try {
      await repository.cancel(orderId);
      if (ref.mounted) state = state.copyWith(orders: repository.getOrders());
      return true;
    } catch (error) {
      if (ref.mounted) state = state.copyWith(errorMessage: '$error');
      return false;
    }
  }

  void addOrder(OrderEntity order) {
    final repository = ref.read(orderRepositoryProvider)..saveOrder(order);
    state = state.copyWith(orders: repository.getOrders());
  }

  bool cancelOrder(String orderId) {
    final order = state.findById(orderId);
    if (order == null ||
        (order.status != OrderStatus.pendingConfirmation &&
            order.status != OrderStatus.processing)) {
      return false;
    }
    final repository = ref.read(orderRepositoryProvider)
      ..updateStatus(orderId, OrderStatus.cancelled);
    state = state.copyWith(orders: repository.getOrders());
    if (order.isUserPlaced) {
      ref
          .read(walletViewModelProvider.notifier)
          .reverseOrderVoucher(order.id, order.couponCode, order.coinReward);
    }
    return true;
  }

  void buyAgain(OrderEntity order) {
    ref.read(cartViewModelProvider.notifier).addItems(order.items);
  }
}

final orderViewModelProvider = NotifierProvider<OrderViewModel, OrderState>(
  OrderViewModel.new,
);
