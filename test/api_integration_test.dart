import 'dart:convert';

import 'package:ecommerce_fe/core/network/api_client.dart';
import 'package:ecommerce_fe/core/network/remote_repositories.dart';
import 'package:ecommerce_fe/features/address/domain/entities/address_entity.dart';
import 'package:ecommerce_fe/features/cart/domain/entities/cart_snapshot.dart';
import 'package:ecommerce_fe/features/checkout/domain/entities/checkout_quote.dart';
import 'package:ecommerce_fe/features/checkout/domain/entities/checkout_request.dart';
import 'package:ecommerce_fe/features/checkout/domain/entities/checkout_selection.dart';
import 'package:ecommerce_fe/features/orders/domain/entities/order_entity.dart';
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
      ),
    );
    expect(key, isNotEmpty);
    expect(order.status, OrderStatus.processing);
    expect(order.id, 'order-1');
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
