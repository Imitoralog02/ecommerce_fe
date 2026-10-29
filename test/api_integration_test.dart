import 'dart:async';
import 'dart:convert';

import 'package:ecommerce_fe/core/network/api_client.dart';
import 'package:ecommerce_fe/core/network/pending_checkout_store.dart';
import 'package:ecommerce_fe/core/network/remote_repositories.dart';
import 'package:ecommerce_fe/features/address/domain/entities/address_entity.dart';
import 'package:ecommerce_fe/features/cart/domain/entities/cart_item_entity.dart';
import 'package:ecommerce_fe/features/cart/domain/entities/cart_snapshot.dart';
import 'package:ecommerce_fe/features/checkout/domain/entities/checkout_quote.dart';
import 'package:ecommerce_fe/features/checkout/domain/entities/checkout_request.dart';
import 'package:ecommerce_fe/features/checkout/domain/entities/checkout_selection.dart';
import 'package:ecommerce_fe/features/orders/domain/entities/order_entity.dart';
import 'package:ecommerce_fe/features/home/domain/entities/product_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class MemorySessionStorage implements SessionStorage {
  String? token;
  @override
  Future<String?> readRefresh() async => token;
  @override
  Future<void> writeRefresh(String? value) async => token = value;
}

http.Response jsonResponse(Object body, [int status = 200]) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

void main() {
  test('stored login can recover after an offline app start', () async {
    final storage = MemorySessionStorage()..token = 'saved-refresh';
    var online = false;
    final client = ApiClient(
      baseUrl: 'http://example.test/api/v1',
      storage: storage,
      client: MockClient((request) async {
        expect(request.url.path, '/api/v1/auth/refresh');
        if (!online) throw http.ClientException('offline');
        return jsonResponse({
          'accessToken': 'new-access',
          'refreshToken': 'new-refresh',
          'user': {'id': 'u1'},
        });
      }),
    );

    await client.restoreSession();
    expect(client.isAuthenticated, isFalse);
    expect(storage.token, 'saved-refresh');

    online = true;
    await client.restoreSession();
    expect(client.isAuthenticated, isTrue);
    expect(client.userId, 'u1');
    expect(storage.token, 'new-refresh');
  });

  test('network request times out with a readable error', () async {
    final client = ApiClient(
      baseUrl: 'http://example.test/api/v1',
      storage: MemorySessionStorage(),
      client: MockClient((request) => Completer<http.Response>().future),
      requestTimeout: const Duration(milliseconds: 20),
    );

    await expectLater(
      client.get('/products'),
      throwsA(
        isA<ApiException>()
            .having((error) => error.status, 'status', 503)
            .having((error) => error.message, 'message', contains('quá lâu')),
      ),
    );
  });

  test('profile update sends only fields supported by backend', () async {
    final client = ApiClient(
      baseUrl: 'http://example.test/api/v1',
      storage: MemorySessionStorage(),
      client: MockClient((request) async {
        expect(request.method, 'PUT');
        expect(request.url.path, '/api/v1/me');
        expect(jsonDecode(request.body), {
          'fullName': 'Lan Nguyễn',
          'phone': '0901234567',
        });
        return jsonResponse({
          'id': 'u1',
          'email': 'lan@example.com',
          'fullName': 'Lan Nguyễn',
          'phone': '0901234567',
        });
      }),
    );
    final updated = await RemoteAuthRepository(
      client,
    ).updateProfile(fullName: 'Lan Nguyễn', phone: '0901234567');
    expect(updated['fullName'], 'Lan Nguyễn');
  });

  test(
    'catalog loads later pages instead of truncating at 100 products',
    () async {
      final requestedPages = <String>[];
      final client = ApiClient(
        baseUrl: 'http://example.test/api/v1',
        storage: MemorySessionStorage(),
        client: MockClient((request) async {
          final page = request.url.queryParameters['page']!;
          requestedPages.add(page);
          return jsonResponse({
            'content': [
              {'id': 'p$page', 'title': 'Sản phẩm $page', 'price': 100000},
            ],
            'totalPages': 2,
          });
        }),
      );
      final products = await RemoteProductRepository(client).getAllProducts();
      expect(products.map((item) => item.id), ['p0', 'p1']);
      expect(requestedPages, ['0', '1']);
    },
  );

  test('login uses access token and rotates refresh token after 401', () async {
    final storage = MemorySessionStorage();
    var cartCalls = 0;
    final client = ApiClient(
      baseUrl: 'http://example.test/api/v1',
      storage: storage,
      client: MockClient((request) async {
        if (request.url.path.endsWith('/auth/login')) {
          return jsonResponse({
            'accessToken': 'old',
            'refreshToken': 'refresh-1',
            'user': {'id': 'u1'},
          });
        }
        if (request.url.path.endsWith('/auth/refresh')) {
          expect(jsonDecode(request.body)['refreshToken'], 'refresh-1');
          return jsonResponse({
            'accessToken': 'new',
            'refreshToken': 'refresh-2',
            'user': {'id': 'u1'},
          });
        }
        if (request.url.path.endsWith('/cart')) {
          cartCalls++;
          if (cartCalls == 1) {
            expect(request.headers['authorization'], 'Bearer old');
            return jsonResponse({'message': 'expired'}, 401);
          }
          expect(request.headers['authorization'], 'Bearer new');
          return jsonResponse({'items': [], 'discount': 0, 'shippingFee': 0});
        }
        throw StateError('Unexpected ${request.url}');
      }),
    );
    await client.authenticate('/auth/login', {
      'email': 'user@example.com',
      'password': 'password',
    });
    await RemoteCartRepository(client).refresh();
    expect(storage.token, 'refresh-2');
    expect(cartCalls, 2);
  });

  test('cart update uses server item ID and returned quantity', () async {
    var quantity = 1;
    final client = ApiClient(
      baseUrl: 'http://example.test/api/v1',
      storage: MemorySessionStorage(),
      client: MockClient((request) async {
        if (request.method == 'PUT') {
          expect(request.url.path, '/api/v1/cart/items/server-item-1');
          quantity = jsonDecode(request.body)['quantity'] as int;
        }
        return jsonResponse({
          'items': [
            {
              'id': 'server-item-1',
              'product': {
                'id': 'p1',
                'title': 'Áo',
                'price': 100000,
                'availableSizes': ['M'],
                'colorNames': ['Đen'],
              },
              'selectedSize': 'M',
              'selectedColor': 'Đen',
              'quantity': quantity,
            },
          ],
          'discount': 0,
          'shippingFee': 0,
        });
      }),
    );
    final repository = RemoteCartRepository(client);
    final initial = await repository.refresh();
    final updated = await repository.synchronize(
      CartSnapshot(items: [initial.items.single.copyWith(quantity: 2)]),
    );
    expect(updated.items.single.serverId, 'server-item-1');
    expect(updated.items.single.quantity, 2);
  });

  test('COD order sends backend fields and idempotency key', () async {
    String? key;
    final client = ApiClient(
      baseUrl: 'http://example.test/api/v1',
      storage: MemorySessionStorage(),
      client: MockClient((request) async {
        if (request.url.path.endsWith('/orders/quote')) {
          expect(jsonDecode(request.body)['shippingType'], 'STANDARD');
          return jsonResponse({
            'subtotal': 100000,
            'shippingFee': 0,
            'discount': 0,
            'total': 100000,
            'currency': 'VND',
          });
        }
        if (request.url.path.endsWith('/orders')) {
          key = request.headers['idempotency-key'];
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['paymentType'], 'CASH_ON_DELIVERY');
          expect(body['addressLine'], '1 Đường A, Hà Nội');
          expect(body['expectedCartItems'], [
            {'id': 'server-item-1', 'quantity': 2},
          ]);
          return jsonResponse({
            'id': 'order-1',
            'status': 'CONFIRMED',
            'inventoryState': 'RESERVED',
            'items': [],
            'subtotal': 100000,
            'shippingFee': 0,
            'discount': 0,
            'total': 100000,
            'shippingType': 'STANDARD',
            'paymentType': 'CASH_ON_DELIVERY',
            'recipientName': 'Lan',
            'phone': '0901234567',
            'addressLine': '1 Đường A, Hà Nội',
            'createdAt': '2026-10-23T00:00:00Z',
            'updatedAt': '2026-10-23T00:00:00Z',
          }, 201);
        }
        throw StateError('Unexpected ${request.url}');
      }),
    );
    client.userId = 'u1';
    final repository = RemoteCheckoutRepository(
      client,
      RemoteCartRepository(client),
    );
    const address = AddressEntity(
      id: 'a1',
      recipientName: 'Lan',
      phoneNumber: '0901234567',
      streetAddress: '1 Đường A',
      ward: '',
      district: '',
      city: 'Hà Nội',
    );
    final order = await repository.placeOrder(
      const CheckoutRequest(
        items: [
          CartItemEntity(
            serverId: 'server-item-1',
            product: ProductEntity(
              id: 'p1',
              pieceNumber: 'p1',
              title: 'Áo',
              subCategory: 'Áo',
              category: 'Áo',
              price: 50000,
              composition: '',
              description: '',
              availableSizes: ['M'],
              imageType: 'asset',
            ),
            selectedSize: 'M',
            quantity: 2,
          ),
        ],
        address: address,
        selection: CheckoutSelection(
          shippingType: ShippingType.standard,
          paymentType: PaymentType.cashOnDelivery,
        ),
        quote: CheckoutQuote(
          subtotal: 100000,
          shippingFee: 0,
          discount: 0,
          total: 100000,
        ),
      ),
    );
    expect(key, isNotEmpty);
    expect(order.status, OrderStatus.processing);
    expect(order.id, 'order-1');
  });

  test('COD recovers a committed order after the response is lost', () async {
    final pendingStore = MemoryPendingCheckoutStore();
    String? submittedKey;
    var lookups = 0;
    var posts = 0;
    final client = ApiClient(
      baseUrl: 'http://example.test/api/v1',
      storage: MemorySessionStorage(),
      client: MockClient((request) async {
        if (request.url.path.endsWith('/orders/quote')) {
          return jsonResponse({
            'subtotal': 100000,
            'shippingFee': 0,
            'discount': 0,
            'total': 100000,
          });
        }
        if (request.method == 'POST' && request.url.path.endsWith('/orders')) {
          posts++;
          submittedKey = request.headers['idempotency-key'];
          throw http.ClientException('connection reset');
        }
        if (request.method == 'GET' &&
            request.url.path.endsWith('/orders/by-request/$submittedKey')) {
          lookups++;
          return jsonResponse({'message': 'Not found'}, 404);
        }
        if (request.method == 'POST' &&
            request.url.path.endsWith(
              '/orders/by-request/$submittedKey/abandon',
            )) {
          return jsonResponse({
            'outcome': 'ORDER_FOUND',
            'order': {
              'id': 'order-recovered',
              'status': 'CONFIRMED',
              'items': [],
              'subtotal': 100000,
              'shippingFee': 0,
              'discount': 0,
              'total': 100000,
              'shippingType': 'STANDARD',
              'recipientName': 'Lan',
              'phone': '0901234567',
              'addressLine': '1 Đường A, Hà Nội',
              'createdAt': '2026-10-23T00:00:00Z',
            },
          });
        }
        throw StateError('Unexpected ${request.url}');
      }),
    );
    client.userId = 'u1';
    const address = AddressEntity(
      id: 'a1',
      recipientName: 'Lan',
      phoneNumber: '0901234567',
      streetAddress: '1 Đường A',
      ward: '',
      district: '',
      city: 'Hà Nội',
    );
    const checkout = CheckoutRequest(
      items: [],
      address: address,
      selection: CheckoutSelection(
        shippingType: ShippingType.standard,
        paymentType: PaymentType.cashOnDelivery,
      ),
      quote: CheckoutQuote(
        subtotal: 100000,
        shippingFee: 0,
        discount: 0,
        total: 100000,
      ),
    );
    final first = RemoteCheckoutRepository(
      client,
      RemoteCartRepository(client),
      pendingStore: pendingStore,
    );
    await expectLater(
      first.placeOrder(checkout),
      throwsA(
        isA<ApiException>()
            .having((error) => error.status, 'status', 503)
            .having(
              (error) => error.message,
              'message',
              isNot(contains('connection reset')),
            ),
      ),
    );
    expect(submittedKey, isNotEmpty);
    expect(pendingStore.read('u1')?.key, submittedKey);

    final afterRestart = RemoteCheckoutRepository(
      client,
      RemoteCartRepository(client),
      pendingStore: pendingStore,
    );
    expect(await afterRestart.recoverPendingOrder(), isNull);
    expect(pendingStore.read('u1')?.key, submittedKey);
    final changed = CheckoutRequest(
      items: checkout.items,
      address: const AddressEntity(
        id: 'a2',
        recipientName: 'Lan',
        phoneNumber: '0901234567',
        streetAddress: '2 Đường B',
        ward: '',
        district: '',
        city: 'Hà Nội',
      ),
      selection: checkout.selection,
      quote: checkout.quote,
    );
    final recovered = await afterRestart.placeOrder(changed);
    expect(posts, 1);
    expect(lookups, 2);
    expect(recovered.id, 'order-recovered');
    expect(pendingStore.read('u1'), isNull);
  });

  test('COD safely abandons a missing request before placing again', () async {
    final pendingStore = MemoryPendingCheckoutStore();
    await pendingStore.write(
      'u1',
      const PendingCheckout(key: 'old-checkout-key', fingerprint: 'old-cart'),
    );
    String? newKey;
    var abandoned = false;
    final client = ApiClient(
      baseUrl: 'http://example.test/api/v1',
      storage: MemorySessionStorage(),
      client: MockClient((request) async {
        if (request.method == 'GET' &&
            request.url.path.endsWith('/orders/by-request/old-checkout-key')) {
          return jsonResponse({'message': 'Not found'}, 404);
        }
        if (request.method == 'POST' &&
            request.url.path.endsWith(
              '/orders/by-request/old-checkout-key/abandon',
            )) {
          abandoned = true;
          return jsonResponse({'outcome': 'ABANDONED', 'order': null});
        }
        if (request.url.path.endsWith('/orders/quote')) {
          expect(abandoned, isTrue);
          return jsonResponse({
            'subtotal': 100000,
            'shippingFee': 0,
            'discount': 0,
            'total': 100000,
          });
        }
        if (request.method == 'POST' && request.url.path.endsWith('/orders')) {
          expect(abandoned, isTrue);
          newKey = request.headers['idempotency-key'];
          return jsonResponse({
            'id': 'new-order',
            'status': 'CONFIRMED',
            'items': [],
            'subtotal': 100000,
            'shippingFee': 0,
            'discount': 0,
            'total': 100000,
            'shippingType': 'STANDARD',
            'recipientName': 'Lan',
            'phone': '0901234567',
            'addressLine': '2 Đường B, Hà Nội',
            'createdAt': '2026-10-23T00:00:00Z',
          }, 201);
        }
        throw StateError('Unexpected ${request.url}');
      }),
    );
    client.userId = 'u1';
    final repository = RemoteCheckoutRepository(
      client,
      RemoteCartRepository(client),
      pendingStore: pendingStore,
    );
    const checkout = CheckoutRequest(
      items: [],
      address: AddressEntity(
        id: 'a2',
        recipientName: 'Lan',
        phoneNumber: '0901234567',
        streetAddress: '2 Đường B',
        ward: '',
        district: '',
        city: 'Hà Nội',
      ),
      selection: CheckoutSelection(
        shippingType: ShippingType.standard,
        paymentType: PaymentType.cashOnDelivery,
      ),
      quote: CheckoutQuote(
        subtotal: 100000,
        shippingFee: 0,
        discount: 0,
        total: 100000,
      ),
    );

    final order = await repository.placeOrder(checkout);
    expect(order.id, 'new-order');
    expect(newKey, isNot('old-checkout-key'));
    expect(pendingStore.read('u1'), isNull);
  });

  test('order history and notifications use server data', () async {
    var read = false;
    final client = ApiClient(
      baseUrl: 'http://example.test/api/v1',
      storage: MemorySessionStorage(),
      client: MockClient((request) async {
        if (request.url.path == '/api/v1/orders') {
          return jsonResponse([
            {
              'id': 'order-2',
              'status': 'SHIPPED',
              'items': [],
              'subtotal': 250000,
              'shippingFee': 0,
              'discount': 0,
              'total': 250000,
              'shippingType': 'STANDARD',
              'paymentType': 'CASH_ON_DELIVERY',
              'recipientName': 'Lan',
              'phone': '0901234567',
              'addressLine': '1 Đường A, Hà Nội',
              'createdAt': '2026-10-23T00:00:00Z',
            },
          ]);
        }
        if (request.url.path == '/api/v1/notifications/n1/read') {
          expect(request.method, 'PATCH');
          read = true;
          return jsonResponse({'id': 'n1'});
        }
        if (request.url.path == '/api/v1/notifications') {
          return jsonResponse([
            {
              'id': 'n1',
              'title': 'Đơn hàng đang giao',
              'message': 'Đơn order-2 đang giao',
              'referenceId': 'order-2',
              'read': read,
              'createdAt': '2026-10-23T00:00:00Z',
            },
          ]);
        }
        throw StateError('Unexpected ${request.url}');
      }),
    );
    final orders = await RemoteOrderRepository(client).refresh();
    expect(orders.single.status, OrderStatus.shipping);
    final notifications = RemoteNotificationRepository(client);
    expect((await notifications.refresh()).single.relatedOrderId, 'order-2');
    expect((await notifications.read('n1')).single.isRead, isTrue);
  });
}
