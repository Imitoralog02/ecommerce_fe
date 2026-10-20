import 'package:ecommerce_fe/features/address/domain/repositories/address_repository.dart';
import 'package:ecommerce_fe/features/address/di/address_providers.dart';
import 'package:ecommerce_fe/features/cart/presentation/viewmodels/cart_viewmodel.dart';
import 'package:ecommerce_fe/features/checkout/domain/entities/checkout_request.dart';
import 'package:ecommerce_fe/features/checkout/domain/entities/checkout_selection.dart';
import 'package:ecommerce_fe/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:ecommerce_fe/features/checkout/presentation/viewmodels/checkout_viewmodel.dart';
import 'package:ecommerce_fe/features/home/data/repositories/mock_product_repository.dart';
import 'package:ecommerce_fe/features/orders/domain/entities/order_entity.dart';
import 'package:ecommerce_fe/features/orders/presentation/viewmodels/order_viewmodel.dart';
import 'package:ecommerce_fe/features/payment_methods/domain/entities/payment_method_entities.dart';
import 'package:ecommerce_fe/features/payment_methods/presentation/viewmodels/payment_methods_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingCheckoutRepository implements CheckoutRepository {
  CheckoutRequest? request;
  bool fail = false;

  @override
  Future<OrderEntity> placeOrder(CheckoutRequest input) async {
    request = input;
    if (fail) throw StateError('checkout unavailable');
    return OrderEntity(
      id: 'NEO-TEST-1',
      orderDate: DateTime(2026, 10, 18),
      status: OrderStatus.pendingConfirmation,
      items: input.items,
      subtotal: input.quote.subtotal,
      shippingFee: input.quote.shippingFee,
      discountAmount: input.quote.discount,
      totalAmount: input.quote.total,
      shippingAddress: input.address,
    );
  }
}

class _EmptyAddressRepository implements AddressRepository {
  @override
  AddressBookSnapshot load() =>
      const AddressBookSnapshot(addresses: [], selectedAddressId: '');

  @override
  void save(AddressBookSnapshot snapshot) {}
}

void main() {
  test('cart locks a product price when the same variant is added again', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final catalogProduct = MockProductRepository.mockCatalog.first;
    final cart = container.read(cartViewModelProvider.notifier);

    cart.addToCart(catalogProduct.copyWith(price: 100000), 'M', 'Kem Be');
    cart.addToCart(catalogProduct.copyWith(price: 200000), 'M', 'Kem Be');

    final state = container.read(cartViewModelProvider);
    expect(state.items, hasLength(1));
    expect(state.items.single.quantity, 2);
    expect(state.items.single.product.price, 100000);
    expect(state.subtotal, 200000);
  });

  test('checkout rejects a wallet until its mock link is enabled', () async {
    final repository = _RecordingCheckoutRepository();
    final container = ProviderContainer(
      overrides: [checkoutRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    container.read(cartViewModelProvider.notifier).restoreVideoOrder();
    container
        .read(paymentMethodsViewModelProvider.notifier)
        .setMomoLinked(false);
    final checkout = container.read(checkoutViewModelProvider.notifier)
      ..setPayment(PaymentType.momo);

    expect(await checkout.placeOrder(), isNull);
    expect(repository.request, isNull);
    expect(container.read(cartViewModelProvider).items, isNotEmpty);

    container
        .read(paymentMethodsViewModelProvider.notifier)
        .setMomoLinked(true);
    expect(await checkout.placeOrder(), isNotNull);
    expect(repository.request?.selection.paymentType, PaymentType.momo);
  });

  test(
    'checkout uses the selected mock card and its last four digits',
    () async {
      final repository = _RecordingCheckoutRepository();
      final container = ProviderContainer(
        overrides: [checkoutRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      container.read(cartViewModelProvider.notifier).restoreVideoOrder();
      container
          .read(paymentMethodsViewModelProvider.notifier)
          .deleteCard('sample-card-4242');
      final checkout = container.read(checkoutViewModelProvider.notifier)
        ..setPayment(PaymentType.creditCard);

      expect(await checkout.placeOrder(), isNull);
      container
          .read(paymentMethodsViewModelProvider.notifier)
          .addCard(
            const PaymentCardEntity(
              id: 'mock-card',
              bankName: 'Mock bank',
              cardType: 'DEMO',
              lastFour: '4242',
              holderName: 'TEST',
              expiry: '12/30',
              gradientValues: [0xFF111111, 0xFF222222],
              isDefault: true,
            ),
          );

      expect(await checkout.placeOrder(), isNotNull);
      expect(repository.request?.selection.paymentType, PaymentType.creditCard);
      expect(repository.request?.selection.paymentCardLastFour, '4242');
    },
  );

  test(
    'cart keeps color variants separate and recalculates coupon discount',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final product = MockProductRepository.mockCatalog.first;
      final cart = container.read(cartViewModelProvider.notifier);

      cart.addToCart(product, 'M', 'Kem Be');
      cart.addToCart(product, 'M', 'Camel Nâu');
      expect(container.read(cartViewModelProvider).items, hasLength(2));

      expect(cart.applyCoupon('neo20'), isTrue);
      final originalDiscount = container.read(cartViewModelProvider).discount;
      expect(originalDiscount, product.price * 2 * 0.20);

      cart.addToCart(product, 'M', 'Kem Be');
      expect(container.read(cartViewModelProvider).items, hasLength(2));
      expect(
        container.read(cartViewModelProvider).discount,
        product.price * 3 * 0.20,
      );
      expect(cart.applyCoupon('NOT-A-COUPON'), isFalse);
      expect(container.read(cartViewModelProvider).appliedCoupon, 'NEO20');

      cart.removeFromCart(product.id, size: 'M', color: 'Camel Nâu');
      expect(container.read(cartViewModelProvider).items, hasLength(1));
      expect(
        container.read(cartViewModelProvider).items.single.selectedColor,
        'Kem Be',
      );
    },
  );

  test(
    'checkout refuses an empty cart before calling the repository',
    () async {
      final repository = _RecordingCheckoutRepository();
      final container = ProviderContainer(
        overrides: [checkoutRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final order = await container
          .read(checkoutViewModelProvider.notifier)
          .placeOrder();
      expect(order, isNull);
      expect(repository.request, isNull);
      expect(
        container.read(checkoutViewModelProvider).errorMessage,
        contains('trống'),
      );
    },
  );

  test('checkout requires a saved delivery address', () async {
    final repository = _RecordingCheckoutRepository();
    final container = ProviderContainer(
      overrides: [
        checkoutRepositoryProvider.overrideWithValue(repository),
        addressRepositoryProvider.overrideWithValue(_EmptyAddressRepository()),
      ],
    );
    addTearDown(container.dispose);
    container.read(cartViewModelProvider.notifier).restoreVideoOrder();

    final order = await container
        .read(checkoutViewModelProvider.notifier)
        .placeOrder();
    expect(order, isNull);
    expect(repository.request, isNull);
    expect(container.read(cartViewModelProvider).items, isNotEmpty);
  });

  test(
    'successful checkout charges the quoted amount and clears the cart',
    () async {
      final repository = _RecordingCheckoutRepository();
      final container = ProviderContainer(
        overrides: [checkoutRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      final cart = container.read(cartViewModelProvider.notifier);
      cart.restoreVideoOrder();
      expect(cart.applyCoupon('NEORA30K'), isTrue);
      final subtotal = container.read(cartViewModelProvider).subtotal;

      final order = await container
          .read(checkoutViewModelProvider.notifier)
          .placeOrder();
      expect(order, isNotNull);
      expect(repository.request?.selection.shippingType, ShippingType.express);
      expect(order!.subtotal, subtotal);
      expect(order.discountAmount, 30000);
      expect(order.shippingFee, 30000);
      expect(order.totalAmount, subtotal);
      expect(
        container.read(orderViewModelProvider).findById(order.id),
        isNotNull,
      );
      expect(container.read(cartViewModelProvider).items, isEmpty);
      expect(container.read(cartViewModelProvider).appliedCoupon, isNull);
    },
  );

  test('free shipping coupon affects checkout quote', () async {
    final repository = _RecordingCheckoutRepository();
    final container = ProviderContainer(
      overrides: [checkoutRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final cart = container.read(cartViewModelProvider.notifier);
    cart.restoreVideoOrder();
    expect(cart.applyCoupon('FREESHIP'), isTrue);

    final order = await container
        .read(checkoutViewModelProvider.notifier)
        .placeOrder();
    expect(order, isNotNull);
    expect(order!.shippingFee, 0);
    expect(order.totalAmount, order.subtotal);
  });

  test('failed checkout retains the cart and does not add an order', () async {
    final repository = _RecordingCheckoutRepository()..fail = true;
    final container = ProviderContainer(
      overrides: [checkoutRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    container.read(cartViewModelProvider.notifier).restoreVideoOrder();
    final orderCount = container.read(orderViewModelProvider).orders.length;

    final order = await container
        .read(checkoutViewModelProvider.notifier)
        .placeOrder();
    expect(order, isNull);
    expect(container.read(cartViewModelProvider).items, isNotEmpty);
    expect(
      container.read(orderViewModelProvider).orders,
      hasLength(orderCount),
    );
    expect(container.read(checkoutViewModelProvider).isProcessing, isFalse);
  });
}
