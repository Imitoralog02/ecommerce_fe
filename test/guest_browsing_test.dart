import 'package:ecommerce_fe/core/navigation/app_router.dart';
import 'package:ecommerce_fe/core/network/api_client.dart';
import 'package:ecommerce_fe/core/network/remote_repositories.dart';
import 'package:ecommerce_fe/features/auth/di/auth_providers.dart';
import 'package:ecommerce_fe/features/cart/di/cart_providers.dart';
import 'package:ecommerce_fe/features/cart/presentation/viewmodels/cart_viewmodel.dart';
import 'package:ecommerce_fe/features/home/data/repositories/mock_product_repository.dart';
import 'package:ecommerce_fe/features/home/presentation/viewmodels/home_viewmodel.dart';
import 'package:ecommerce_fe/features/home/presentation/widgets/product_card_widget.dart';
import 'package:ecommerce_fe/features/wishlist/di/wishlist_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class _NoSession implements SessionStorage {
  @override
  Future<String?> readRefresh() async => null;

  @override
  Future<void> writeRefresh(String? token) async {}
}

ApiClient _offlineApi() => ApiClient(
  baseUrl: 'http://example.test/api/v1',
  storage: _NoSession(),
  client: MockClient((_) async => throw http.ClientException('offline')),
);

void main() {
  test('gateway HTML outage becomes a retryable API error', () async {
    final api = ApiClient(
      baseUrl: 'http://example.test/api/v1',
      storage: _NoSession(),
      client: MockClient((_) async => http.Response('<html>down</html>', 503)),
    );
    await expectLater(
      api.get('/products'),
      throwsA(
        isA<ApiException>().having((error) => error.status, 'status', 503),
      ),
    );
  });

  test('guest sees bundled products when the catalog API is offline', () async {
    final api = _offlineApi();
    final container = ProviderContainer(
      overrides: [
        productRepositoryProvider.overrideWithValue(
          RemoteProductRepository(api),
        ),
      ],
    );
    addTearDown(container.dispose);

    final initial = container.read(homeViewModelProvider);
    expect(initial.isLoading, isFalse);
    expect(initial.usingSampleCatalog, isTrue);
    expect(initial.allProducts, isNotEmpty);

    await container.read(homeViewModelProvider.notifier).loadHomeData();
    final state = container.read(homeViewModelProvider);
    expect(state.usingSampleCatalog, isTrue);
    expect(state.errorMessage, isNull);
    expect(state.allProducts, MockProductRepository.mockCatalog);
  });

  test('guest cannot add a product before signing in', () async {
    final api = _offlineApi();
    final container = ProviderContainer(
      overrides: [
        cartRepositoryProvider.overrideWithValue(RemoteCartRepository(api)),
      ],
    );
    addTearDown(container.dispose);

    final added = await container
        .read(cartViewModelProvider.notifier)
        .addToCartConfirmed(MockProductRepository.mockCatalog.first);
    expect(added, isFalse);
    expect(container.read(cartViewModelProvider).items, isEmpty);
  });

  testWidgets('guest favorite action opens the login screen', (tester) async {
    final api = _offlineApi();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(RemoteAuthRepository(api)),
          wishlistRepositoryProvider.overrideWithValue(
            RemoteWishlistRepository(api),
          ),
        ],
        child: MaterialApp(
          routes: {
            AppRoutes.auth: (_) => const Scaffold(body: Text('Login needed')),
          },
          home: Scaffold(
            body: SizedBox(
              width: 180,
              height: 300,
              child: ProductCardWidget(
                product: MockProductRepository.mockCatalog.first,
                onTap: () {},
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Yêu thích'));
    await tester.pumpAndSettle();
    expect(find.text('Login needed'), findsOneWidget);
  });
}
