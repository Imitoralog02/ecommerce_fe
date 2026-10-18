import 'dart:async';

import 'package:ecommerce_fe/core/connectivity/di/connectivity_providers.dart';
import 'package:ecommerce_fe/core/connectivity/domain/repositories/connectivity_repository.dart';
import 'package:ecommerce_fe/core/connectivity/presentation/connectivity_viewmodel.dart';
import 'package:ecommerce_fe/features/notifications/presentation/viewmodels/notification_viewmodel.dart';
import 'package:ecommerce_fe/features/address/di/address_providers.dart';
import 'package:ecommerce_fe/features/address/domain/entities/address_entity.dart';
import 'package:ecommerce_fe/features/address/presentation/viewmodels/address_viewmodel.dart';
import 'package:ecommerce_fe/features/cart/di/cart_providers.dart';
import 'package:ecommerce_fe/features/cart/presentation/viewmodels/cart_viewmodel.dart';
import 'package:ecommerce_fe/features/orders/domain/entities/order_entity.dart';
import 'package:ecommerce_fe/features/orders/presentation/viewmodels/order_viewmodel.dart';
import 'package:ecommerce_fe/features/payment_methods/domain/entities/payment_method_entities.dart';
import 'package:ecommerce_fe/features/payment_methods/presentation/viewmodels/payment_methods_viewmodel.dart';
import 'package:ecommerce_fe/features/wishlist/presentation/viewmodels/wishlist_viewmodel.dart';
import 'package:ecommerce_fe/features/settings/di/settings_providers.dart';
import 'package:ecommerce_fe/features/settings/domain/entities/user_settings.dart';
import 'package:ecommerce_fe/features/settings/presentation/viewmodels/settings_viewmodel.dart';
import 'package:ecommerce_fe/features/reviews/di/review_providers.dart';
import 'package:ecommerce_fe/features/reviews/presentation/viewmodels/review_viewmodel.dart';
import 'package:ecommerce_fe/features/returns/di/return_providers.dart';
import 'package:ecommerce_fe/features/returns/domain/entities/return_request.dart';
import 'package:ecommerce_fe/features/returns/presentation/viewmodels/return_request_viewmodel.dart';
import 'package:ecommerce_fe/features/search/di/search_providers.dart';
import 'package:ecommerce_fe/features/search/domain/entities/search_suggestions.dart';
import 'package:ecommerce_fe/features/search/domain/entities/visual_search_result.dart';
import 'package:ecommerce_fe/features/search/domain/repositories/search_repository.dart';
import 'package:ecommerce_fe/features/search/presentation/viewmodels/visual_search_viewmodel.dart';
import 'package:ecommerce_fe/features/tracking/domain/entities/tracking_snapshot.dart';
import 'package:ecommerce_fe/features/tracking/presentation/viewmodels/tracking_viewmodel.dart';
import 'package:ecommerce_fe/features/wallet/di/wallet_providers.dart';
import 'package:ecommerce_fe/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeConnectivityRepository implements ConnectivityRepository {
  final result = Completer<bool>();

  @override
  Future<bool> checkConnection() => result.future;
}

class _FakeSearchRepository implements SearchRepository {
  final visualResult = Completer<VisualSearchResult>();

  @override
  SearchSuggestions loadSuggestions() =>
      const SearchSuggestions(recentSearches: [], trendingSearches: []);

  @override
  void saveRecentSearches(List<String> searches) {}

  @override
  Future<VisualSearchResult> searchByImage(String imagePath) =>
      visualResult.future;
}

void main() {
  test('notification badge follows read state from repository', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(unreadNotificationCountProvider), 3);
    container.read(notificationViewModelProvider.notifier).markAllAsRead();
    expect(container.read(unreadNotificationCountProvider), 0);
  });

  test('orders are seeded once and status updates through repository', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final firstOrder = container.read(orderViewModelProvider).orders.first;
    container.read(orderViewModelProvider.notifier).cancelOrder(firstOrder.id);

    expect(
      container.read(orderViewModelProvider).findById(firstOrder.id)?.status,
      OrderStatus.cancelled,
    );
  });

  test(
    'wishlist state and refresh are backed by the mock repository',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initial = container.read(wishlistViewModelProvider);
      expect(initial.items, isNotEmpty);

      container
          .read(wishlistViewModelProvider.notifier)
          .removeFromWishlist(initial.items.first.id);
      expect(
        container.read(wishlistViewModelProvider).items.length,
        initial.items.length - 1,
      );

      await container.read(wishlistViewModelProvider.notifier).refresh();
      expect(
        container.read(wishlistViewModelProvider).items.length,
        initial.items.length - 1,
      );
    },
  );

  test('payment methods preserve one default card', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(paymentMethodsViewModelProvider.notifier)
        .addCard(
          const PaymentCardEntity(
            id: 'test-card',
            bankName: 'NÉORA Test Bank',
            cardType: 'Visa',
            lastFour: '0001',
            holderName: 'NEORA TEST',
            expiry: '12/30',
            gradientValues: [0xFF111111, 0xFF222222],
            isDefault: true,
          ),
        );

    final state = container.read(paymentMethodsViewModelProvider);
    expect(state.cards.where((card) => card.isDefault), hasLength(1));
    expect(state.cards.last.id, 'test-card');
  });

  test('cart mutations are persisted by CartRepository', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(cartViewModelProvider.notifier).restoreVideoOrder();
    final cart = container.read(cartViewModelProvider);
    final snapshot = container.read(cartRepositoryProvider).load();

    expect(cart.items, isNotEmpty);
    expect(snapshot.items.length, cart.items.length);
    expect(cart.formattedDiscount, endsWith('₫'));
  });

  test('address changes are persisted by AddressRepository', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    const address = AddressEntity(
      id: 'test-address',
      recipientName: 'NÉORA Test',
      phoneNumber: '0900000000',
      streetAddress: '1 Nguyễn Huệ',
      ward: 'Bến Nghé',
      district: 'Quận 1',
      city: 'TP. Hồ Chí Minh',
      isDefault: true,
    );
    container.read(addressViewModelProvider.notifier).addAddress(address);

    final snapshot = container.read(addressRepositoryProvider).load();
    expect(snapshot.selectedAddressId, address.id);
    expect(snapshot.addresses.first.id, address.id);
  });

  test('profile and preferences share one settings repository', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    const updatedProfile = UserProfile(
      name: 'NÉORA Member',
      email: 'member@neora.vn',
      phone: '0900000001',
      birthday: '01/01/2000',
      gender: 'Khác',
    );
    final notifier = container.read(settingsViewModelProvider.notifier);
    notifier.updateProfile(updatedProfile);
    notifier.setBiometrics(false);
    notifier.clearCache();

    final persisted = container.read(settingsRepositoryProvider).load();
    expect(persisted.profile.name, updatedProfile.name);
    expect(persisted.enableBiometrics, isFalse);
    expect(persisted.cacheSizeMb, 0);
  });

  test('wallet mutations are persisted and daily check-in is idempotent', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final initial = container.read(walletViewModelProvider);
    final voucher = initial.vouchers.first;
    final notifier = container.read(walletViewModelProvider.notifier);

    expect(notifier.checkInDaily(), isTrue);
    expect(notifier.checkInDaily(), isFalse);
    notifier.toggleSaveVoucher(voucher.id);

    final persisted = container.read(walletRepositoryProvider).load();
    expect(persisted.coinBalance, initial.coinBalance + 50);
    expect(persisted.checkedInToday, isTrue);
    expect(persisted.transactions.first.coinDelta, 50);
    expect(
      persisted.vouchers.firstWhere((item) => item.id == voucher.id).isSaved,
      !voucher.isSaved,
    );
  });

  test('review filters and helpful state use repository-backed review ids', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    const productId = 'review-product';
    final provider = reviewViewModelProvider(productId);
    final notifier = container.read(provider.notifier);
    notifier.selectFilter(ReviewFilter.images);
    final filtered = container.read(provider).filteredReviews;
    final review = filtered.last;
    notifier.toggleHelpful(review.id);

    final persisted = container.read(reviewRepositoryProvider).load(productId);
    final updated = persisted.firstWhere((item) => item.id == review.id);
    expect(updated.isHelpful, isTrue);
    expect(updated.helpfulCount, review.helpfulCount + 1);
    expect(container.read(provider).selectedFilter, ReviewFilter.images);

    final submittedReview = review.copyWith(id: 'submitted-review');
    expect(
      notifier.submitReview(
        review: submittedReview,
        submissionKey: 'order-1:$productId',
      ),
      isTrue,
    );
    expect(
      notifier.submitReview(
        review: submittedReview,
        submissionKey: 'order-1:$productId',
      ),
      isFalse,
    );
    expect(
      container
          .read(reviewRepositoryProvider)
          .load(productId)
          .where((item) => item.id == submittedReview.id),
      hasLength(1),
    );
  });

  test('review reward adds wallet coins only once per review', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final initialBalance = container.read(walletViewModelProvider).coinBalance;
    final wallet = container.read(walletViewModelProvider.notifier);

    expect(wallet.addReviewReward('review-test'), isTrue);
    expect(wallet.addReviewReward('review-test'), isFalse);
    expect(
      container.read(walletRepositoryProvider).load().coinBalance,
      initialBalance + 50,
    );
  });

  test('return request draft and submission use ReturnRepository', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    const seed = (orderId: 'order-test', firstItemId: 'product-a');
    final notifier = container.read(
      returnRequestViewModelProvider(seed).notifier,
    );
    notifier.setItemSelected('product-b', true);
    notifier.selectSolution(ReturnSolution.refund);
    notifier.selectRefundMethod(RefundMethod.bank);
    notifier.selectReason(ReturnRequestOptions.reasons.last);

    expect(notifier.validate(''), isNotNull);
    expect(notifier.submit(note: ''), isNull);
    notifier.selectReason(ReturnRequestOptions.reasons.first);

    final draft = container
        .read(returnRepositoryProvider)
        .loadDraft(seed.orderId);
    expect(draft?.selectedItemIds, containsAll(['product-a', 'product-b']));
    expect(draft?.solution, ReturnSolution.refund);

    final receipt = notifier.submit(note: 'Liên hệ trước khi đến');
    expect(receipt?.code, startsWith('RET-'));
    expect(receipt?.note, 'Liên hệ trước khi đến');
    final duplicate = notifier.submit(note: 'Gửi lặp');
    expect(duplicate?.code, receipt?.code);
    expect(duplicate?.note, receipt?.note);
    expect(
      container.read(returnRepositoryProvider).loadDraft(seed.orderId),
      isNull,
    );
  });

  test('tracking stage follows each order status', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final shipping = container.read(
      trackingViewModelProvider((
        orderId: 'shipping-order',
        status: OrderStatus.shipping,
      )),
    );
    final delivered = container.read(
      trackingViewModelProvider((
        orderId: 'delivered-order',
        status: OrderStatus.delivered,
      )),
    );

    expect(shipping.stage, TrackingStage.shipping);
    expect(shipping.isStepDone(TrackingStage.delivered), isFalse);
    expect(delivered.stage, TrackingStage.delivered);
    expect(delivered.isStepDone(TrackingStage.delivered), isTrue);
  });

  test(
    'connectivity retry exposes loading state through its ViewModel',
    () async {
      final repository = _FakeConnectivityRepository();
      final container = ProviderContainer(
        overrides: [
          connectivityRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final retry = container
          .read(connectivityViewModelProvider.notifier)
          .retry();
      expect(container.read(connectivityViewModelProvider).isRetrying, isTrue);

      repository.result.complete(true);
      expect(await retry, isTrue);
      expect(container.read(connectivityViewModelProvider).isRetrying, isFalse);
    },
  );

  test('visual search exposes repository progress and results', () async {
    final repository = _FakeSearchRepository();
    final container = ProviderContainer(
      overrides: [searchRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final search = container
        .read(visualSearchViewModelProvider.notifier)
        .search('mock-image.jpg');
    expect(container.read(visualSearchViewModelProvider).isScanning, isTrue);

    repository.visualResult.complete(
      const VisualSearchResult(
        detectedLabel: 'Đầm NÉORA',
        confidence: 0.98,
        products: [],
      ),
    );
    await search;

    final state = container.read(visualSearchViewModelProvider);
    expect(state.isScanning, isFalse);
    expect(state.result?.detectedLabel, 'Đầm NÉORA');
    expect(state.errorMessage, isNull);
  });
}
