import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce_fe/features/cart/domain/entities/cart_item_entity.dart';
import 'package:ecommerce_fe/features/cart/domain/services/cart_pricing.dart';
import 'package:ecommerce_fe/features/checkout/domain/entities/checkout_selection.dart';
import 'package:ecommerce_fe/features/home/data/repositories/mock_product_repository.dart';
import 'package:ecommerce_fe/features/wallet/data/repositories/mock_wallet_repository.dart';

void main() {
  final vouchers = MockWalletRepository(
    now: DateTime(2026, 10, 19),
  ).load().vouchers;
  final catalog = MockProductRepository.mockCatalog;
  CartItemEntity line(String id, int quantity) => CartItemEntity(
    product: catalog.firstWhere((product) => product.id == id),
    selectedSize: 'M',
    quantity: quantity,
  );
  PromotionResult check(
    String code,
    List<CartItemEntity> items, {
    String tier = 'Thành viên Vàng',
    bool firstOrder = true,
    ShippingType shipping = ShippingType.express,
    DateTime? now,
  }) {
    final voucher = vouchers.firstWhere((v) => v.code == code);
    return CartPricing.evaluate(
      code,
      subtotal: items.fold<double>(0, (sum, item) => sum + item.totalPrice),
      items: items,
      voucher: voucher.copyWith(isSaved: true),
      memberTier: tier,
      firstOrder: firstOrder,
      isExpressShipping: shipping == ShippingType.express,
      shippingFee: shipping == ShippingType.express ? 30000 : 0,
      now: now ?? DateTime(2026, 10, 19),
    );
  }

  test('every wallet voucher has an applicable mock rule', () {
    final cases = <String, List<CartItemEntity>>{
      'FREESHIP40K': [line('prod_dress_wrap', 1)],
      'NEORA30K': [line('prod_dress_wrap', 1)],
      'VIPNEORA': [line('prod_dress_wrap', 2)],
      'COINBACK5': [line('prod_dress_wrap', 1)],
      'SHIPFAST25': [line('prod_dress_wrap', 1)],
      'NEORA50K': [line('prod_dress_wrap', 2)],
      'VIPDIAMOND': [line('prod_dress_wrap', 3)],
      'FREESHIPMAX': [line('prod_dress_wrap', 2)],
      'NEORA100K': [line('prod_dress_wrap', 3)],
      'SHIPEXP': [line('prod_dress_wrap', 1)],
      'VIPGIFT': [line('prod_dress_wrap', 4)],
      'NEORANEW10': [line('prod_dress_floral_side', 1)],
    };
    expect(cases.keys.toSet(), vouchers.map((v) => v.code).toSet());
    for (final entry in cases.entries) {
      final result = check(
        entry.key,
        entry.value,
        tier: entry.key == 'VIPDIAMOND'
            ? 'Thành viên Kim Cương'
            : 'Thành viên Vàng',
      );
      expect(result.isValid, isTrue, reason: '${entry.key}: ${result.reason}');
      expect(
        result.itemDiscount > 0 ||
            result.shippingDiscount > 0 ||
            result.coinReward > 0 ||
            result.giftDescription != null,
        isTrue,
        reason: entry.key,
      );
    }
  });

  test(
    'caps, product scope and shipping conditions match advertised offers',
    () {
      expect(
        check('VIPNEORA', [line('prod_dress_wrap', 3)]).itemDiscount,
        80000,
      );
      expect(
        check('SHIPFAST25', [line('prod_dress_wrap', 1)]).shippingDiscount,
        25000,
      );
      expect(
        check('SHIPFAST25', [
          line('prod_dress_wrap', 1),
        ], shipping: ShippingType.standard).isValid,
        isFalse,
      );
      expect(
        check('NEORA50K', [line('prod_sneaker_white', 1)]).isValid,
        isFalse,
      );
      expect(
        check('NEORANEW10', [line('prod_dress_wrap', 1)]).isValid,
        isFalse,
      );
      expect(
        check('SHIPEXP', [
          line('prod_dress_wrap', 1),
        ], firstOrder: false).isValid,
        isFalse,
      );
      expect(
        check('VIPDIAMOND', [line('prod_dress_wrap', 3)]).isValid,
        isFalse,
      );
    },
  );

  test('saved, unused, unexpired voucher is required', () {
    const code = 'NEORA30K';
    final item = line('prod_dress_wrap', 1);
    final voucher = vouchers.firstWhere((v) => v.code == code);
    expect(check(code, [item], now: DateTime(2026, 10, 25)).isValid, isFalse);
    expect(
      CartPricing.evaluate(
        code,
        subtotal: item.totalPrice,
        items: [item],
        voucher: voucher.copyWith(isSaved: false),
      ).isValid,
      isFalse,
    );
    expect(
      CartPricing.evaluate(
        code,
        subtotal: item.totalPrice,
        items: [item],
        voucher: voucher.copyWith(isUsed: true),
      ).isValid,
      isFalse,
    );
  });

  test('shipping voucher is not consumed on free standard delivery', () {
    final voucher = vouchers.firstWhere((v) => v.code == 'FREESHIP40K');
    final item = line('prod_dress_wrap', 1);
    final result = CartPricing.evaluate(
      voucher.code,
      subtotal: item.totalPrice,
      items: [item],
      voucher: voucher,
      isExpressShipping: false,
      shippingFee: 0,
      requireShippingBenefit: true,
      now: DateTime(2026, 10, 19),
    );
    expect(result.isValid, isFalse);
  });
}
