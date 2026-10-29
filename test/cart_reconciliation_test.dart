import 'dart:convert';

import 'package:ecommerce_fe/core/network/api_client.dart';
import 'package:ecommerce_fe/core/network/remote_repositories.dart';
import 'package:ecommerce_fe/features/cart/di/cart_providers.dart';
import 'package:ecommerce_fe/features/cart/domain/entities/cart_item_entity.dart';
import 'package:ecommerce_fe/features/cart/domain/entities/cart_snapshot.dart';
import 'package:ecommerce_fe/features/cart/presentation/viewmodels/cart_viewmodel.dart';
import 'package:ecommerce_fe/features/home/domain/entities/product_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class _MemorySessionStorage implements SessionStorage {
  @override
  Future<String?> readRefresh() async => null;

  @override
  Future<void> writeRefresh(String? value) async {}
}

class _DelayedCartRepository extends RemoteCartRepository {
  _DelayedCartRepository(super.api);

  static const _product = ProductEntity(
    id: 'p1',
    pieceNumber: '01',
    title: 'Giày thử',
    subCategory: 'Giày',
    category: 'Giày',
    price: 690000,
    composition: '',
    description: '',
    availableSizes: ['36'],
    imageType: 'sneaker',
  );
  static const purchased = CartItemEntity(
    serverId: 'ordered-item',
    product: _product,
    selectedSize: '36',
  );
  static const other = CartItemEntity(
    serverId: 'other-item',
    product: _product,
    selectedSize: '37',
  );

  int refreshCalls = 0;
  int consumeOnRefresh = 99;
  bool failFirst = false;

  @override
  CartSnapshot load() => const CartSnapshot(items: [purchased, other]);

  @override
  Future<CartSnapshot> refresh() async {
    final call = ++refreshCalls;
    if (failFirst && call == 1) {
      throw const ApiException(503, 'Mất kết nối tạm thời');
    }
    return CartSnapshot(
      items: call >= consumeOnRefresh
          ? const [other]
          : const [purchased, other],
    );
  }
}

Future<(_DelayedCartRepository, ProviderContainer)> _setup() async {
  final api = ApiClient(
    baseUrl: 'http://example.test/api/v1',
    storage: _MemorySessionStorage(),
    client: MockClient(
      (request) async => http.Response(
        jsonEncode({
          'accessToken': 'token',
          'refreshToken': 'refresh',
          'user': {'id': 'user-1'},
        }),
        200,
        headers: {'content-type': 'application/json'},
      ),
    ),
  );
  await api.authenticate('/auth/login', {
    'email': 'test@example.test',
    'password': 'test',
  });
  final repository = _DelayedCartRepository(api);
  final container = ProviderContainer(
    overrides: [cartRepositoryProvider.overrideWithValue(repository)],
  );
  container.read(cartViewModelProvider);
  await Future<void>.delayed(Duration.zero);
  repository.refreshCalls = 0;
  return (repository, container);
}

void main() {
  test('purchased line disappears after backend consumes it later', () async {
    final (repository, container) = await _setup();
    addTearDown(container.dispose);
    repository.consumeOnRefresh = 2;

    await container
        .read(cartViewModelProvider.notifier)
        .reconcilePurchasedItems(
          ['ordered-item'],
          retryDelays: [Duration.zero, Duration.zero],
        );

    expect(repository.refreshCalls, 2);
    expect(container.read(cartViewModelProvider).items, [
      _DelayedCartRepository.other,
    ]);
  });

  test('temporary cart outage still gets a later refresh', () async {
    final (repository, container) = await _setup();
    addTearDown(container.dispose);
    repository.failFirst = true;
    repository.consumeOnRefresh = 2;

    await container
        .read(cartViewModelProvider.notifier)
        .reconcilePurchasedItems(
          ['ordered-item'],
          retryDelays: [Duration.zero, Duration.zero],
        );

    expect(repository.refreshCalls, 2);
    expect(container.read(cartViewModelProvider).items, [
      _DelayedCartRepository.other,
    ]);
    expect(container.read(cartViewModelProvider).errorMessage, isEmpty);
  });
}
