import 'package:ecommerce_fe/data/local/demo_preferences_store.dart';
import 'package:ecommerce_fe/features/history/data/repositories/mock_recently_viewed_repository.dart';
import 'package:ecommerce_fe/features/home/data/repositories/mock_product_repository.dart';
import 'package:ecommerce_fe/features/notifications/data/repositories/mock_notification_repository.dart';
import 'package:ecommerce_fe/features/payment_methods/data/repositories/mock_payment_methods_repository.dart';
import 'package:ecommerce_fe/features/returns/data/repositories/mock_return_repository.dart';
import 'package:ecommerce_fe/features/returns/domain/entities/return_request.dart';
import 'package:ecommerce_fe/features/returns/presentation/viewmodels/return_request_viewmodel.dart';
import 'package:ecommerce_fe/features/reviews/data/repositories/mock_review_repository.dart';
import 'package:ecommerce_fe/features/reviews/presentation/viewmodels/review_viewmodel.dart';
import 'package:ecommerce_fe/features/search/data/repositories/mock_search_repository.dart';
import 'package:ecommerce_fe/features/support/data/repositories/mock_support_repository.dart';
import 'package:ecommerce_fe/features/support/domain/entities/support_message_entity.dart';
import 'package:ecommerce_fe/features/tracking/data/repositories/mock_tracking_repository.dart';
import 'package:ecommerce_fe/features/tracking/domain/entities/tracking_snapshot.dart';
import 'package:ecommerce_fe/features/orders/domain/entities/order_entity.dart';
import 'package:ecommerce_fe/features/checkout/domain/entities/checkout_selection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'reviews are product-specific and submissions survive restart',
    () async {
      final preferences = await SharedPreferences.getInstance();
      final store = DemoPreferencesStore(preferences);
      final first = MockReviewRepository(store);
      final dress = first.load('prod_dress_wrap');
      final sneaker = first.load('prod_sneaker_white');
      expect(dress.first.comment, contains('voan tơ'));
      expect(sneaker.single.comment, contains('Giày sneaker'));
      expect(sneaker.single.reviewImages, ['assets/images/real/p_sneaker.jpg']);
      expect(sneaker.single.comment, isNot(contains('váy')));

      final submitted = sneaker.single.copyWith(
        id: 'user-review-1',
        comment: 'Rất êm chân',
      );
      expect(
        first.addIfAbsent(
          productId: 'prod_sneaker_white',
          submissionKey: 'order-1:sneaker',
          review: submitted,
        ),
        isTrue,
      );
      await Future<void>.delayed(Duration.zero);
      final restored = MockReviewRepository(store);
      expect(restored.load('prod_sneaker_white').first.comment, 'Rất êm chân');
      expect(
        restored.addIfAbsent(
          productId: 'prod_sneaker_white',
          submissionKey: 'order-1:sneaker',
          review: submitted,
        ),
        isFalse,
      );
    },
  );

  test('mock app state survives a new repository instance', () async {
    final preferences = await SharedPreferences.getInstance();
    final store = DemoPreferencesStore(preferences);
    final products = MockProductRepository.mockCatalog;

    MockRecentlyViewedRepository(products, store).save([products.last]);
    MockNotificationRepository(store).markAsRead('notif_1');
    final payment = MockPaymentMethodsRepository(store);
    payment.saveState(payment.getState().copyWith(momoLinked: false));
    MockSearchRepository(
      MockProductRepository(),
      store,
    ).saveRecentSearches(['sneaker']);

    final returns = MockReturnRepository(store);
    final draft = ReturnRequestDraft(
      orderId: 'order-1',
      selectedItemIds: {'line-1'},
    );
    returns.saveDraft(draft);
    final receipt = returns.submit(draft, note: 'Đổi cỡ');

    final support = MockSupportRepository(store);
    support.saveMessages([
      SupportMessageEntity(
        id: 'user-1',
        text: 'Tư vấn cỡ giày',
        timestamp: DateTime(2026, 10, 20),
        isUser: true,
        attachedProduct: products[5],
      ),
    ]);
    await Future<void>.delayed(Duration.zero);

    expect(
      MockRecentlyViewedRepository(products, store).load().single.id,
      products.last.id,
    );
    expect(
      MockNotificationRepository(store).getNotifications().first.isRead,
      isTrue,
    );
    expect(MockPaymentMethodsRepository(store).getState().momoLinked, isFalse);
    expect(
      MockSearchRepository(
        MockProductRepository(),
        store,
      ).loadSuggestions().recentSearches,
      ['sneaker'],
    );
    final restoredReturns = MockReturnRepository(store);
    expect(restoredReturns.loadDraft('order-1'), isNull);
    expect(restoredReturns.submit(draft, note: 'Lặp lại').code, receipt.code);
    expect(
      MockSupportRepository(store).initialMessages().single.attachedProduct?.id,
      products[5].id,
    );
  });

  test(
    'image search returns the product represented by the chosen demo image',
    () async {
      final search = MockSearchRepository(MockProductRepository());
      final shoe = await search.searchByImage(
        'assets/images/real/p_sneaker.jpg',
      );
      expect(shoe.products.single.id, 'prod_sneaker_white');
      expect(shoe.detectedLabel, contains('sneaker'));
      final missing = await search.searchByImage(
        'assets/images/not_in_catalog.jpg',
      );
      expect(missing.products, isEmpty);
      expect(missing.confidence, 0);
    },
  );
  test('tracking method follows the order shipping choice', () {
    final tracking = MockTrackingRepository();
    expect(
      tracking
          .load(
            orderId: 'o',
            status: OrderStatus.shipping,
            shippingType: ShippingType.standard,
          )
          .deliveryMethod,
      'Giao hàng tiêu chuẩn',
    );
    expect(
      tracking
          .load(
            orderId: 'o',
            status: OrderStatus.shipping,
            shippingType: ShippingType.storePickup,
          )
          .deliveryMethod,
      'Nhận tại cửa hàng',
    );
    final cancelled = tracking.load(
      orderId: 'o',
      status: OrderStatus.cancelled,
    );
    expect(cancelled.stage, TrackingStage.cancelled);
    expect(cancelled.isStepDone(TrackingStage.processing), isFalse);
  });

  test('review and return demo photos follow the selected product', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final reviewProvider = reviewViewModelProvider('prod_sneaker_white');
    final reviewSubscription = container.listen(reviewProvider, (_, _) {});
    addTearDown(reviewSubscription.close);
    expect(
      await container.read(reviewProvider.notifier).pickReviewImage(),
      'assets/images/real/p_sneaker.jpg',
    );

    final returnProvider = returnRequestViewModelProvider((
      orderId: 'demo-order',
      firstItemId: 'prod_sneaker_white',
    ));
    final returnSubscription = container.listen(returnProvider, (_, _) {});
    addTearDown(returnSubscription.close);
    await container.read(returnProvider.notifier).pickEvidencePhoto();
    expect(
      container.read(returnProvider).evidencePhotos.single,
      'assets/images/real/p_sneaker.jpg',
    );
  });
}
