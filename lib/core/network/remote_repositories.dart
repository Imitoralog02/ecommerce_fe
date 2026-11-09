import 'dart:async';
import 'dart:math';

import '../../features/address/domain/entities/address_entity.dart';
import '../../features/address/domain/repositories/address_repository.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/cart/domain/entities/cart_item_entity.dart';
import '../../features/cart/domain/entities/cart_snapshot.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/checkout/domain/entities/checkout_request.dart';
import '../../features/checkout/domain/entities/checkout_selection.dart';
import '../../features/checkout/domain/entities/promotion_offer.dart';
import '../../features/checkout/domain/repositories/checkout_repository.dart';
import '../../features/home/domain/entities/product_entity.dart';
import '../../features/home/domain/repositories/product_repository.dart';
import '../../features/notifications/domain/entities/notification_entity.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/orders/domain/entities/order_entity.dart';
import '../../features/shop/domain/entities/remote_flash_sale_campaign.dart';
import '../../features/orders/domain/repositories/order_repository.dart';
import '../../features/wishlist/domain/repositories/wishlist_repository.dart';
import 'api_client.dart';
import 'api_models.dart';
import 'pending_checkout_store.dart';

class RemoteAuthRepository implements AuthRepository {
  RemoteAuthRepository(this.api);
  final ApiClient api;
  @override
  Future<void> login({required String email, required String password}) =>
      api.authenticate('/auth/login', {'email': email, 'password': password});
  @override
  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    await api.authenticate('/auth/register', {
      'fullName': fullName,
      'email': email,
      'password': password,
    });
    await api.logout();
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    await api.post('/auth/password-reset/request', {
      'email': email,
    }, auth: false);
  }

  @override
  Future<void> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await api.post('/auth/password-reset/confirm', {
      'email': email,
      'code': code,
      'newPassword': newPassword,
    }, auth: false);
    await api.clearSession();
  }

  Future<void> logout() => api.logout();
  Future<Map<String, dynamic>> profile() async => asMap(await api.get('/me'));
  Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    required String phone,
  }) async =>
      asMap(await api.put('/me', {'fullName': fullName, 'phone': phone}));
}

class RemoteProductRepository implements ProductRepository {
  RemoteProductRepository(this.api);
  final ApiClient api;
  @override
  Future<List<ProductEntity>> getFeaturedProducts() async {
    return asList(
      await api.get('/products/featured', query: {'size': '8'}),
    ).map(productFromApi).toList();
  }

  Future<List<RemoteFlashSaleCampaign>> getActiveFlashSales() async {
    return asList(await api.get('/flash-sales/active')).map((entry) {
      final data = asMap(entry);
      return RemoteFlashSaleCampaign(
        id: data['id'] as String,
        title: data['title'] as String? ?? 'Flash Sale',
        startsAt: DateTime.parse(data['startsAt'] as String).toLocal(),
        endsAt: DateTime.parse(data['endsAt'] as String).toLocal(),
        products: asList(data['products']).map(productFromApi).toList(),
      );
    }).toList();
  }

  Future<List<ProductEntity>> getAllProducts() => _loadPages(null);

  Future<List<ProductEntity>> _loadPages(String? category) async {
    final products = <ProductEntity>[];
    var page = 0;
    while (true) {
      final query = {'page': '$page', 'size': '100'};
      if (category != null) query['category'] = category;
      final data = asMap(await api.get('/products', query: query));
      products.addAll(asList(data['content']).map(productFromApi));
      final totalPages = data['totalPages'] as int? ?? 0;
      page++;
      if (page >= totalPages) return products;
    }
  }

  @override
  Future<List<ProductEntity>> getSneakers() => getProductsByCategory('Giày');
  @override
  Future<ProductEntity?> getProductById(String id) async {
    try {
      return productFromApi(
        await api.get('/products/${Uri.encodeComponent(id)}'),
      );
    } on ApiException catch (error) {
      if (error.status == 404) return null;
      rethrow;
    }
  }

  @override
  Future<List<ProductEntity>> getProductsByCategory(String category) async {
    return _loadPages(category);
  }
}

class RemoteCartRepository implements CartRepository {
  RemoteCartRepository(this.api);
  final ApiClient api;
  CartSnapshot _cache = const CartSnapshot();
  bool _loaded = false;
  String? _owner;
  Future<void> _pending = Future.value();
  Object? _lastError;
  @override
  CartSnapshot load() {
    _ensureOwner();
    return _cache;
  }

  void _ensureOwner() {
    if (_owner == api.userId) return;
    _owner = api.userId;
    _cache = const CartSnapshot();
    _loaded = false;
  }

  @override
  void save(CartSnapshot snapshot) {
    unawaited(synchronize(snapshot));
  }

  @override
  CartSnapshot demoCart() => const CartSnapshot();
  Future<CartSnapshot> refresh() async {
    _ensureOwner();
    final owner = _owner;
    await _pending;
    final response = await api.get('/cart');
    if (owner != api.userId) {
      throw const ApiException(401, 'Phiên đăng nhập đã thay đổi');
    }
    _cache = cartFromApi(response);
    _loaded = true;
    return _cache;
  }

  Future<void> settle() async {
    await _pending;
    if (_lastError != null) throw _lastError!;
  }

  Future<CartSnapshot> synchronize(CartSnapshot desired) {
    _ensureOwner();
    if (!_loaded) {
      return Future.error(
        const ApiException(409, 'Giỏ hàng đang tải, vui lòng thử lại'),
      );
    }
    final owner = _owner;
    final result = Completer<CartSnapshot>();
    _pending = _pending.catchError((Object _) {}).then((_) async {
      try {
        _lastError = null;
        if (owner != api.userId) {
          throw const ApiException(401, 'Phiên đăng nhập đã thay đổi');
        }
        result.complete(await _apply(desired, owner));
      } catch (error, stack) {
        _lastError = error;
        result.completeError(error, stack);
      }
    });
    return result.future;
  }

  String _key(CartItemEntity item) =>
      '${item.product.id}\u0000${item.selectedSize}\u0000${item.selectedColor}';
  Future<CartSnapshot> _apply(CartSnapshot desired, String? owner) async {
    final wanted = {for (final item in desired.items) _key(item): item};
    for (final item in List<CartItemEntity>.from(_cache.items)) {
      if (owner != api.userId) {
        throw const ApiException(401, 'Phiên đăng nhập đã thay đổi');
      }
      if (!wanted.containsKey(_key(item))) {
        _cache = cartFromApi(
          await api.delete(
            '/cart/items/${Uri.encodeComponent(item.serverId!)}',
          ),
        );
      }
    }
    for (final item in desired.items) {
      if (owner != api.userId) {
        throw const ApiException(401, 'Phiên đăng nhập đã thay đổi');
      }
      final existing = _cache.items
          .where((row) => _key(row) == _key(item))
          .firstOrNull;
      if (existing == null) {
        _cache = cartFromApi(
          await api.post('/cart/items', {
            'productId': item.product.id,
            'selectedSize': item.selectedSize,
            'selectedColor': item.selectedColor,
            'quantity': item.quantity,
          }),
        );
      } else if (existing.quantity != item.quantity) {
        _cache = cartFromApi(
          await api.put(
            '/cart/items/${Uri.encodeComponent(existing.serverId!)}',
            {'quantity': item.quantity},
          ),
        );
      }
    }
    return _cache;
  }
}

class RemoteAddressRepository implements AddressRepository {
  RemoteAddressRepository(this.api);
  final ApiClient api;
  AddressBookSnapshot _cache = const AddressBookSnapshot(
    addresses: [],
    selectedAddressId: '',
  );
  String? _owner;
  bool _loaded = false;
  Future<void> _pending = Future.value();
  @override
  AddressBookSnapshot load() {
    _ensureOwner();
    return _cache;
  }

  void selectAddress(String id) {
    _ensureOwner();
    if (_cache.addresses.any((address) => address.id == id)) {
      _cache = AddressBookSnapshot(
        addresses: _cache.addresses,
        selectedAddressId: id,
      );
    }
  }

  void _ensureOwner() {
    if (_owner == api.userId) return;
    _owner = api.userId;
    _loaded = false;
    _cache = const AddressBookSnapshot(addresses: [], selectedAddressId: '');
  }

  @override
  void save(AddressBookSnapshot snapshot) {
    throw UnsupportedError('Dùng API thêm, sửa hoặc xóa từng địa chỉ.');
  }

  Future<AddressBookSnapshot> refresh() async {
    _ensureOwner();
    final owner = _owner;
    await _pending;
    return _fetch(owner);
  }

  Future<AddressBookSnapshot> _fetch(String? owner) async {
    final response = await api.get('/addresses');
    if (owner != api.userId) {
      throw const ApiException(401, 'Phiên đăng nhập đã thay đổi');
    }
    final items = asList(response).map(addressFromApi).toList();
    final selected = items.any((item) => item.id == _cache.selectedAddressId)
        ? _cache.selectedAddressId
        : (items.where((item) => item.isDefault).firstOrNull?.id ??
              items.firstOrNull?.id ??
              '');
    _cache = AddressBookSnapshot(addresses: items, selectedAddressId: selected);
    _loaded = true;
    return _cache;
  }

  Future<AddressBookSnapshot> _change(
    Future<AddressBookSnapshot> Function(AddressBookSnapshot current) action,
  ) {
    _ensureOwner();
    final owner = _owner;
    final result = Completer<AddressBookSnapshot>();
    _pending = _pending.catchError((Object _) {}).then((_) async {
      try {
        if (owner != api.userId) {
          throw const ApiException(401, 'Phiên đăng nhập đã thay đổi');
        }
        if (!_loaded) await _fetch(owner);
        final next = await action(_cache);
        if (owner != api.userId) {
          throw const ApiException(401, 'Phiên đăng nhập đã thay đổi');
        }
        _cache = next;
        result.complete(next);
      } catch (error, stack) {
        result.completeError(error, stack);
      }
    });
    return result.future;
  }

  Future<AddressBookSnapshot> createAddress(AddressEntity address) => _change((
    current,
  ) async {
    final created = addressFromApi(
      await api.post('/addresses', addressToApi(address)),
    );
    final items = current.addresses
        .map(
          (item) => created.isDefault ? item.copyWith(isDefault: false) : item,
        )
        .toList();
    items.insert(0, created);
    return AddressBookSnapshot(
      addresses: items,
      selectedAddressId: created.isDefault || current.selectedAddressId.isEmpty
          ? created.id
          : current.selectedAddressId,
    );
  });

  Future<AddressBookSnapshot> updateAddress(AddressEntity address) => _change((
    current,
  ) async {
    final updated = addressFromApi(
      await api.put(
        '/addresses/${Uri.encodeComponent(address.id)}',
        addressToApi(address),
      ),
    );
    final items = current.addresses.map((item) {
      if (item.id == updated.id) return updated;
      return updated.isDefault ? item.copyWith(isDefault: false) : item;
    }).toList();
    if (!items.any((item) => item.id == updated.id)) items.insert(0, updated);
    return AddressBookSnapshot(
      addresses: items,
      selectedAddressId: updated.isDefault
          ? updated.id
          : current.selectedAddressId,
    );
  });

  Future<AddressBookSnapshot> deleteAddress(String id) => _change((
    current,
  ) async {
    await api.delete('/addresses/${Uri.encodeComponent(id)}');
    final items = current.addresses.where((item) => item.id != id).toList();
    if (items.isNotEmpty && !items.any((item) => item.isDefault)) {
      items[0] = items[0].copyWith(isDefault: true);
    }
    final selected = items.any((item) => item.id == current.selectedAddressId)
        ? current.selectedAddressId
        : (items.where((item) => item.isDefault).firstOrNull?.id ??
              items.firstOrNull?.id ??
              '');
    return AddressBookSnapshot(addresses: items, selectedAddressId: selected);
  });

  Future<AddressBookSnapshot> setDefaultAddress(String id) => _change((
    current,
  ) async {
    final updated = addressFromApi(
      await api.patch('/addresses/${Uri.encodeComponent(id)}/default'),
    );
    final items = current.addresses
        .map(
          (item) =>
              item.id == updated.id ? updated : item.copyWith(isDefault: false),
        )
        .toList();
    if (!items.any((item) => item.id == updated.id)) items.insert(0, updated);
    return AddressBookSnapshot(addresses: items, selectedAddressId: updated.id);
  });
}

class RemoteWishlistRepository implements WishlistRepository {
  RemoteWishlistRepository(this.api);
  final ApiClient api;
  List<ProductEntity> _items = [];
  String? _owner;
  void _ensureOwner() {
    if (_owner == api.userId) return;
    _owner = api.userId;
    _items = [];
  }

  Future<void> _pending = Future<void>.value();
  @override
  List<ProductEntity> getItems() {
    _ensureOwner();
    return List.unmodifiable(_items);
  }

  @override
  Future<List<ProductEntity>> refresh() async {
    _ensureOwner();
    final owner = _owner;
    await _pending;
    final response = await api.get('/wishlist');
    if (owner != api.userId) {
      throw const ApiException(401, 'Phiên đăng nhập đã thay đổi');
    }
    _items = _fromResponse(response);
    return getItems();
  }

  @override
  void saveItems(List<ProductEntity> items) {
    unawaited(synchronize(items));
  }

  Future<List<ProductEntity>> synchronize(List<ProductEntity> desired) {
    _ensureOwner();
    final owner = _owner;
    final result = Completer<List<ProductEntity>>();
    _pending = _pending.catchError((Object _) {}).then((_) async {
      try {
        if (owner != api.userId) {
          throw const ApiException(401, 'Phiên đăng nhập đã thay đổi');
        }
        final wanted = desired.map((item) => item.id).toSet();
        final current = _items.map((item) => item.id).toSet();
        for (final id in current.difference(wanted)) {
          if (owner != api.userId) {
            throw const ApiException(401, 'Phiên đăng nhập đã thay đổi');
          }
          _items = _fromResponse(
            await api.delete('/wishlist/items/${Uri.encodeComponent(id)}'),
          );
        }
        for (final id in wanted.difference(current)) {
          if (owner != api.userId) {
            throw const ApiException(401, 'Phiên đăng nhập đã thay đổi');
          }
          _items = _fromResponse(
            await api.post('/wishlist/items', {'productId': id}),
          );
        }
        result.complete(getItems());
      } catch (error, stack) {
        result.completeError(error, stack);
      }
    });
    return result.future;
  }

  List<ProductEntity> _fromResponse(dynamic response) =>
      asList(asMap(response)['items'])
          .map(
            (item) => productFromApi(
              asMap(item)['product'],
            ).copyWith(isFavorite: true),
          )
          .toList();
}

class RemoteOrderRepository implements OrderRepository {
  RemoteOrderRepository(this.api);
  final ApiClient api;
  List<OrderEntity> _orders = [];
  String? _owner;
  void _ensureOwner() {
    if (_owner == api.userId) return;
    _owner = api.userId;
    _orders = [];
  }

  @override
  List<OrderEntity> getOrders() {
    _ensureOwner();
    return List.unmodifiable(_orders);
  }

  @override
  OrderEntity? getOrderById(String id) =>
      getOrders().where((item) => item.id == id).firstOrNull;
  @override
  void saveOrder(OrderEntity order) {
    _ensureOwner();
    _orders = [order, ..._orders.where((item) => item.id != order.id)];
  }

  @override
  void updateStatus(String orderId, OrderStatus status) {
    // Status is owned by the server. Use cancel() for a user cancellation.
  }
  Future<List<OrderEntity>> refresh() async {
    _ensureOwner();
    final owner = _owner;
    final response = await api.get('/orders');
    if (owner != api.userId) {
      throw const ApiException(401, 'Phiên đăng nhập đã thay đổi');
    }
    _orders = asList(response).map(orderFromApi).toList();
    return getOrders();
  }

  Future<OrderEntity> getRemote(String id) async {
    _ensureOwner();
    final owner = _owner;
    final order = orderFromApi(
      await api.get('/orders/${Uri.encodeComponent(id)}'),
    );
    if (owner != api.userId) {
      throw const ApiException(401, 'Phiên đăng nhập đã thay đổi');
    }
    saveOrder(order);
    return order;
  }

  Future<OrderEntity> cancel(String id) async {
    _ensureOwner();
    final owner = _owner;
    final order = orderFromApi(
      await api.patch('/orders/${Uri.encodeComponent(id)}/cancel'),
    );
    if (owner != api.userId) {
      throw const ApiException(401, 'Phiên đăng nhập đã thay đổi');
    }
    saveOrder(order);
    return order;
  }
}

class RemoteNotificationRepository implements NotificationRepository {
  RemoteNotificationRepository(this.api);
  final ApiClient api;
  List<NotificationEntity> _items = [];
  String? _owner;
  void _ensureOwner() {
    if (_owner == api.userId) return;
    _owner = api.userId;
    _items = [];
  }

  @override
  List<NotificationEntity> getNotifications() {
    _ensureOwner();
    return List.unmodifiable(_items);
  }

  Future<List<NotificationEntity>> refresh() async {
    _ensureOwner();
    final owner = _owner;
    final response = await api.get('/notifications');
    if (owner != api.userId) {
      throw const ApiException(401, 'Phiên đăng nhập đã thay đổi');
    }
    _items = asList(response).map(notificationFromApi).toList();
    return getNotifications();
  }

  @override
  void markAsRead(String id) {
    unawaited(read(id));
  }

  Future<List<NotificationEntity>> read(String id) async {
    await api.patch('/notifications/${Uri.encodeComponent(id)}/read');
    return refresh();
  }

  @override
  void markAllAsRead() {
    unawaited(readAll());
  }

  Future<List<NotificationEntity>> readAll() async {
    for (final item in _items.where((item) => !item.isRead)) {
      await api.patch('/notifications/${Uri.encodeComponent(item.id)}/read');
    }
    return refresh();
  }
}

class RemoteCheckoutRepository implements CheckoutRepository {
  RemoteCheckoutRepository(
    this.api,
    this.cart, {
    PendingCheckoutStore? pendingStore,
  }) : pendingStore = pendingStore ?? MemoryPendingCheckoutStore();
  final ApiClient api;
  final RemoteCartRepository cart;
  final PendingCheckoutStore pendingStore;

  Future<OrderEntity?> recoverPendingOrder() async {
    final owner = api.userId;
    if (owner == null) return null;
    final pending = pendingStore.read(owner);
    if (pending == null) return null;
    try {
      final result = await api.get(
        '/orders/by-request/${Uri.encodeComponent(pending.key)}',
      );
      final order = orderFromApi(result);
      await pendingStore.write(owner, null);
      return order;
    } on ApiException catch (error) {
      if (error.status == 404) return null;
      rethrow;
    }
  }

  Future<List<PromotionOffer>> loadPromotions() async {
    final response = await api.get('/promotions');
    return asList(response).map((entry) {
      final data = asMap(entry);
      return PromotionOffer(
        code: data['code'] as String,
        title: data['title'] as String? ?? '',
        type: data['type'] as String? ?? '',
        value: asAmount(data['value']),
        minSubtotal: asAmount(data['minSubtotal']),
        available: data['available'] as bool? ?? false,
        remainingUses: data['remainingUses'] as int?,
        endsAt: DateTime.tryParse(data['endsAt'] as String? ?? ''),
      );
    }).toList();
  }

  Future<Map<String, dynamic>> quote(
    ShippingType shipping, {
    String? couponCode,
  }) async {
    await cart.settle();
    return asMap(
      await api.post('/orders/quote', {
        'shippingType': shipping.name.toUpperCase(),
        'couponCode': couponCode,
      }),
    );
  }

  @override
  Future<OrderEntity> placeOrder(CheckoutRequest request) async {
    if (request.selection.paymentType != PaymentType.cashOnDelivery) {
      throw const ApiException(400, 'Hiện chỉ hỗ trợ COD');
    }
    final recovered = await recoverPendingOrder();
    if (recovered != null) return recovered;
    final owner = api.userId;
    if (owner == null) {
      throw const ApiException(401, 'Vui lòng đăng nhập để đặt hàng');
    }
    final previous = pendingStore.read(owner);
    if (previous != null) {
      final resolution = asMap(
        await api.post(
          '/orders/by-request/${Uri.encodeComponent(previous.key)}/abandon',
          {},
        ),
      );
      if (resolution['outcome'] == 'ORDER_FOUND') {
        final order = orderFromApi(resolution['order']);
        await pendingStore.write(owner, null);
        return order;
      }
      if (resolution['outcome'] != 'ABANDONED') {
        throw const ApiException(502, 'Không xác minh được đơn hàng trước');
      }
      await pendingStore.write(owner, null);
    }
    if (request.items.any((item) => item.serverId == null)) {
      throw const ApiException(
        409,
        'Vui lòng tải lại giỏ hàng trước khi đặt hàng',
      );
    }
    final expectedCartItems =
        request.items
            .map(
              (item) => <String, Object>{
                'id': item.serverId!,
                'quantity': item.quantity,
              },
            )
            .toList()
          ..sort((a, b) => (a['id'] as String).compareTo(b['id'] as String));
    final body = <String, Object?>{
      'shippingType': request.selection.shippingType.name.toUpperCase(),
      'paymentType': 'CASH_ON_DELIVERY',
      'recipientName': request.address.recipientName,
      'phone': request.address.phoneNumber,
      'addressLine': request.address.fullAddress,
      'expectedCartItems': expectedCartItems,
      if (request.couponCode != null) 'couponCode': request.couponCode,
    };
    final fingerprint = '$body';
    await quote(request.selection.shippingType, couponCode: request.couponCode);
    final pending = PendingCheckout(
      key:
          '${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(1 << 32)}',
      fingerprint: fingerprint,
    );
    await pendingStore.write(owner, pending);
    final result = await api.post(
      '/orders',
      body,
      headers: {'Idempotency-Key': pending.key},
    );
    var order = orderFromApi(result, address: request.address);
    await pendingStore.write(owner, null);
    for (
      var attempt = 0;
      attempt < 5 && order.status == OrderStatus.pendingConfirmation;
      attempt++
    ) {
      await Future<void>.delayed(const Duration(seconds: 2));
      try {
        order = orderFromApi(
          await api.get('/orders/${Uri.encodeComponent(order.id)}'),
          address: request.address,
        );
      } catch (_) {
        break;
      }
    }
    return order;
  }
}
