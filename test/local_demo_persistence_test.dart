import 'package:ecommerce_fe/features/address/data/repositories/shared_preferences_address_repository.dart';
import 'package:ecommerce_fe/features/address/di/address_providers.dart';
import 'package:ecommerce_fe/features/address/presentation/viewmodels/address_viewmodel.dart';
import 'package:ecommerce_fe/features/cart/data/repositories/shared_preferences_cart_repository.dart';
import 'package:ecommerce_fe/features/cart/di/cart_providers.dart';
import 'package:ecommerce_fe/features/cart/presentation/viewmodels/cart_viewmodel.dart';
import 'package:ecommerce_fe/features/checkout/presentation/viewmodels/checkout_viewmodel.dart';
import 'package:ecommerce_fe/features/checkout/domain/entities/checkout_selection.dart';
import 'package:ecommerce_fe/features/home/data/repositories/mock_product_repository.dart';
import 'package:ecommerce_fe/features/orders/data/repositories/shared_preferences_order_repository.dart';
import 'package:ecommerce_fe/features/orders/di/order_providers.dart';
import 'package:ecommerce_fe/features/orders/domain/entities/order_entity.dart';
import 'package:ecommerce_fe/features/orders/presentation/viewmodels/order_viewmodel.dart';
import 'package:ecommerce_fe/features/wishlist/data/repositories/shared_preferences_wishlist_repository.dart';
import 'package:ecommerce_fe/features/wishlist/di/wishlist_providers.dart';
import 'package:ecommerce_fe/features/wishlist/presentation/viewmodels/wishlist_viewmodel.dart';
import 'package:ecommerce_fe/features/wallet/data/repositories/shared_preferences_wallet_repository.dart';
import 'package:ecommerce_fe/features/wallet/di/wallet_providers.dart';
import 'package:ecommerce_fe/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

ProviderContainer _container(SharedPreferences preferences) =>
    ProviderContainer(
      overrides: [
        cartRepositoryProvider.overrideWithValue(
          SharedPreferencesCartRepository(preferences),
        ),
        addressRepositoryProvider.overrideWithValue(
          SharedPreferencesAddressRepository(preferences),
        ),
        wishlistRepositoryProvider.overrideWithValue(
          SharedPreferencesWishlistRepository(
            preferences,
            MockProductRepository.mockCatalog,
          ),
        ),
        orderRepositoryProvider.overrideWithValue(
          SharedPreferencesOrderRepository(
            preferences,
            MockProductRepository.mockCatalog,
          ),
        ),
        walletRepositoryProvider.overrideWithValue(
          SharedPreferencesWalletRepository(preferences),
        ),
      ],
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('cart restores product snapshot, variant and coupon', () async {
    final preferences = await SharedPreferences.getInstance();
    final first = _container(preferences);
    final product = MockProductRepository.mockCatalog.first.copyWith(
      price: 123456,
    );
    final cart = first.read(cartViewModelProvider.notifier);
    cart.addToCart(product, 'L', 'Kem Be');
    cart.addToCart(product, 'M', 'Camel Nâu');
    expect(cart.applyCoupon('NEO10'), isTrue);
    await Future<void>.delayed(Duration.zero);
    first.dispose();

    final second = _container(preferences);
    addTearDown(second.dispose);
    final restored = second.read(cartViewModelProvider);
    expect(restored.items, hasLength(2));
    expect(restored.items.first.product.price, 123456);
    expect(restored.items.first.selectedColor, 'Kem Be');
    expect(restored.items.last.selectedSize, 'M');
    expect(restored.appliedCoupon, 'NEO10');
    expect(restored.discount, greaterThan(0));
  });

  test('empty addresses and wishlist stay empty after restart', () async {
    final preferences = await SharedPreferences.getInstance();
    final first = _container(preferences);
    final addresses = first.read(addressViewModelProvider.notifier);
    for (final address in List.of(
      first.read(addressViewModelProvider).addresses,
    )) {
      addresses.deleteAddress(address.id);
    }
    first.read(wishlistViewModelProvider.notifier).clearAll();
    await Future<void>.delayed(Duration.zero);
    first.dispose();

    final second = _container(preferences);
    addTearDown(second.dispose);
    expect(second.read(addressViewModelProvider).addresses, isEmpty);
    expect(second.read(wishlistViewModelProvider).items, isEmpty);
  });

  test('demo checkout and order status survive restart', () async {
    final preferences = await SharedPreferences.getInstance();
    final first = _container(preferences);
    first
        .read(cartViewModelProvider.notifier)
        .addToCart(MockProductRepository.mockCatalog.first, 'M', 'Kem Be');
    first
        .read(checkoutViewModelProvider.notifier)
        .setShipping(ShippingType.standard);
    final order = await first
        .read(checkoutViewModelProvider.notifier)
        .placeOrder();
    expect(order, isNotNull);
    expect(first.read(cartViewModelProvider).items, isEmpty);
    first.read(orderViewModelProvider.notifier).cancelOrder(order!.id);
    await Future<void>.delayed(Duration.zero);
    first.dispose();

    final second = _container(preferences);
    addTearDown(second.dispose);
    expect(second.read(cartViewModelProvider).items, isEmpty);
    final restored = second.read(orderViewModelProvider).findById(order.id);
    expect(restored, isNotNull);
    expect(restored!.status, OrderStatus.cancelled);
    expect(restored.items.single.selectedColor, 'Kem Be');
    expect(restored.totalAmount, order.totalAmount);
    expect(restored.shippingType, ShippingType.standard);
    expect(restored.shippingAddress.id, order.shippingAddress.id);
  });

  test('coinback voucher credits wallet once and survives restart', () async {
    final preferences = await SharedPreferences.getInstance();
    final first = _container(preferences);
    final wallet = first.read(walletViewModelProvider.notifier);
    final before = first.read(walletViewModelProvider).coinBalance;
    final expiry = first
        .read(walletViewModelProvider)
        .vouchers
        .firstWhere((item) => item.code == 'COINBACK5')
        .expiryDate;
    wallet.toggleSaveVoucher('v_coin_5p');
    final cart = first.read(cartViewModelProvider.notifier);
    cart.addToCart(MockProductRepository.mockCatalog.first);
    expect(cart.applyCoupon('COINBACK5'), isTrue);
    final order = await first
        .read(checkoutViewModelProvider.notifier)
        .placeOrder();
    expect(order, isNotNull);
    expect(order!.coinReward, greaterThan(0));
    expect(
      first.read(walletViewModelProvider).memberTier,
      'Thành viên Kim Cương',
    );
    expect(
      first.read(walletViewModelProvider).coinBalance,
      before + order.coinReward,
    );
    expect(
      first
          .read(walletViewModelProvider)
          .vouchers
          .firstWhere((item) => item.code == 'COINBACK5')
          .isUsed,
      isTrue,
    );
    wallet.completeOrderVoucher(order.id, order.couponCode, order.coinReward);
    expect(
      first.read(walletViewModelProvider).coinBalance,
      before + order.coinReward,
    );
    await Future<void>.delayed(Duration.zero);
    first.dispose();

    final second = _container(preferences);
    addTearDown(second.dispose);
    expect(
      second.read(walletViewModelProvider).coinBalance,
      before + order.coinReward,
    );
    expect(
      second.read(walletViewModelProvider).memberTier,
      'Thành viên Kim Cương',
    );
    expect(
      second
          .read(walletViewModelProvider)
          .vouchers
          .firstWhere((item) => item.code == 'COINBACK5')
          .expiryDate,
      expiry,
    );
    expect(
      second.read(orderViewModelProvider).findById(order.id)!.coinReward,
      order.coinReward,
    );
  });

  test(
    'cancelling a new order releases its voucher and coin reward once',
    () async {
      final preferences = await SharedPreferences.getInstance();
      final first = _container(preferences);
      final startingWallet = first.read(walletViewModelProvider);
      first
          .read(walletViewModelProvider.notifier)
          .toggleSaveVoucher('v_coin_5p');
      final cart = first.read(cartViewModelProvider.notifier);
      cart.addToCart(MockProductRepository.mockCatalog.first);
      expect(cart.applyCoupon('COINBACK5'), isTrue);
      final order = await first
          .read(checkoutViewModelProvider.notifier)
          .placeOrder();
      expect(order, isNotNull);
      final orders = first.read(orderViewModelProvider.notifier);
      expect(orders.cancelOrder(order!.id), isTrue);
      expect(orders.cancelOrder(order.id), isFalse);
      expect(
        first.read(walletViewModelProvider).coinBalance,
        startingWallet.coinBalance,
      );
      expect(
        first.read(walletViewModelProvider).memberTier,
        startingWallet.memberTier,
      );
      expect(
        first
            .read(walletViewModelProvider)
            .vouchers
            .firstWhere((v) => v.code == 'COINBACK5')
            .isUsed,
        isFalse,
      );
      await Future<void>.delayed(Duration.zero);
      first.dispose();

      final second = _container(preferences);
      addTearDown(second.dispose);
      expect(
        second.read(orderViewModelProvider).findById(order.id)?.status,
        OrderStatus.cancelled,
      );
      expect(
        second.read(walletViewModelProvider).coinBalance,
        startingWallet.coinBalance,
      );
      expect(
        second
            .read(walletViewModelProvider)
            .vouchers
            .firstWhere((v) => v.code == 'COINBACK5')
            .isUsed,
        isFalse,
      );
    },
  );
}
