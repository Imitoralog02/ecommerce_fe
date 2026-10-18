import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../data/local/demo_entity_codec.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/cart_snapshot.dart';
import '../../domain/repositories/cart_repository.dart';
import 'mock_cart_repository.dart';

class SharedPreferencesCartRepository implements CartRepository {
  SharedPreferencesCartRepository(this._preferences);

  static const _key = 'demo_cart_v1';
  final SharedPreferences _preferences;

  @override
  CartSnapshot load() {
    final raw = _preferences.getString(_key);
    if (raw == null) return const CartSnapshot();
    try {
      final data = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      if (data['version'] != 1) return const CartSnapshot();
      final items = List<CartItemEntity>.unmodifiable(
        (data['items'] as List).map(DemoEntityCodec.cartItemFromJson),
      );
      final coupon = data['appliedCoupon'] as String?;
      return CartSnapshot(
        items: items,
        appliedCoupon: coupon,
        shippingFee: (data['shippingFee'] as num).toDouble(),
      );
    } catch (_) {
      return const CartSnapshot();
    }
  }

  @override
  void save(CartSnapshot snapshot) {
    final data = {
      'version': 1,
      'items': snapshot.items.map(DemoEntityCodec.cartItemToJson).toList(),
      'appliedCoupon': snapshot.appliedCoupon,
      'shippingFee': snapshot.shippingFee,
    };
    unawaited(_preferences.setString(_key, jsonEncode(data)));
  }

  @override
  CartSnapshot demoCart() => MockCartRepository().demoCart();
}
