import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../data/local/demo_entity_codec.dart';
import '../../../home/domain/entities/product_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import 'mock_order_repository.dart';

class SharedPreferencesOrderRepository implements OrderRepository {
  SharedPreferencesOrderRepository(this._preferences, this._catalog);

  static const _key = 'demo_orders_v1';
  final SharedPreferences _preferences;
  final List<ProductEntity> _catalog;
  List<OrderEntity>? _orders;

  @override
  List<OrderEntity> getOrders() {
    _orders ??= _load();
    return List.unmodifiable(_orders!);
  }

  List<OrderEntity> _load() {
    final raw = _preferences.getString(_key);
    if (raw == null) return MockOrderRepository(_catalog).getOrders();
    try {
      final data = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      if (data['version'] != 1) {
        return MockOrderRepository(_catalog).getOrders();
      }
      return (data['orders'] as List)
          .map(DemoEntityCodec.orderFromJson)
          .toList();
    } catch (_) {
      return MockOrderRepository(_catalog).getOrders();
    }
  }

  void _save(List<OrderEntity> orders) {
    _orders = orders;
    final data = {
      'version': 1,
      'orders': orders.map(DemoEntityCodec.orderToJson).toList(),
    };
    unawaited(_preferences.setString(_key, jsonEncode(data)));
  }

  @override
  OrderEntity? getOrderById(String id) {
    for (final order in getOrders()) {
      if (order.id == id) return order;
    }
    return null;
  }

  @override
  void saveOrder(OrderEntity order) {
    final orders = List<OrderEntity>.from(getOrders());
    orders.removeWhere((item) => item.id == order.id);
    orders.insert(0, order);
    _save(orders);
  }

  @override
  void updateStatus(String orderId, OrderStatus status) {
    _save(
      getOrders()
          .map(
            (order) =>
                order.id == orderId ? order.copyWith(status: status) : order,
          )
          .toList(),
    );
  }
}
