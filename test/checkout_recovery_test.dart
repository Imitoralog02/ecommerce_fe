import 'package:ecommerce_fe/core/network/api_client.dart';
import 'package:ecommerce_fe/core/network/remote_repositories.dart';
import 'package:ecommerce_fe/features/address/domain/entities/address_entity.dart';
import 'package:ecommerce_fe/features/cart/presentation/viewmodels/cart_viewmodel.dart';
import 'package:ecommerce_fe/features/checkout/presentation/viewmodels/checkout_viewmodel.dart';
import 'package:ecommerce_fe/features/orders/domain/entities/order_entity.dart';
import 'package:ecommerce_fe/features/orders/presentation/viewmodels/order_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemorySessionStorage implements SessionStorage {
  @override
  Future<String?> readRefresh() async => null;

  @override
  Future<void> writeRefresh(String? value) async {}
}

class _CancelledRecoveryRepository extends RemoteCheckoutRepository {
  _CancelledRecoveryRepository(ApiClient api)
    : super(api, RemoteCartRepository(api));

  @override
  Future<OrderEntity?> recoverPendingOrder() async => OrderEntity(
    id: 'cancelled-order',
    orderDate: DateTime(2026, 10, 30),
    status: OrderStatus.cancelled,
    items: const [],
    subtotal: 0,
    totalAmount: 0,
    shippingAddress: const AddressEntity(
      id: 'address-1',
      recipientName: 'Lan',
      phoneNumber: '0901234567',
      streetAddress: '1 Đường A',
      ward: 'Phường 1',
      district: 'Quận 1',
      city: 'Hồ Chí Minh',
    ),
  );
}

void main() {
  test('recovered cancelled COD order keeps cart and shows an error', () async {
    final api = ApiClient(
      baseUrl: 'http://example.test/api/v1',
      storage: _MemorySessionStorage(),
    );
    final container = ProviderContainer(
      overrides: [
        checkoutRepositoryProvider.overrideWithValue(
          _CancelledRecoveryRepository(api),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.read(cartViewModelProvider.notifier).restoreVideoOrder();
    final previousCount = container.read(cartViewModelProvider).totalItemCount;

    final result = await container
        .read(checkoutViewModelProvider.notifier)
        .placeOrder();

    expect(result, isNull);
    expect(container.read(cartViewModelProvider).totalItemCount, previousCount);
    expect(
      container.read(checkoutViewModelProvider).errorMessage,
      contains('đã bị hủy'),
    );
    expect(container.read(checkoutViewModelProvider).isProcessing, isFalse);
    expect(
      container
          .read(orderViewModelProvider)
          .findById('cancelled-order')
          ?.status,
      OrderStatus.cancelled,
    );
  });
}
