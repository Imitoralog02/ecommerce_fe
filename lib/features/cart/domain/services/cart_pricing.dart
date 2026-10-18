import '../../../wallet/domain/entities/voucher_entity.dart';
import '../entities/cart_item_entity.dart';

class PromotionResult {
  const PromotionResult({
    this.reason,
    this.itemDiscount = 0,
    this.shippingDiscount = 0,
    this.coinReward = 0,
    this.giftDescription,
  });

  final String? reason;
  final double itemDiscount;
  final double shippingDiscount;
  final int coinReward;
  final String? giftDescription;
  bool get isValid => reason == null;
}

/// Promotion rules shared by cart, checkout and order creation.
abstract final class CartPricing {
  static String normalizeCode(String code) => code.trim().toUpperCase();

  static PromotionResult evaluate(
    String? code, {
    required double subtotal,
    List<CartItemEntity> items = const [],
    VoucherEntity? voucher,
    String memberTier = '',
    bool firstOrder = false,
    bool isExpressShipping = true,
    double shippingFee = 0,
    bool requireShippingBenefit = false,
    DateTime? now,
  }) {
    if (code == null || code.trim().isEmpty) {
      return const PromotionResult(reason: 'Vui lòng nhập mã ưu đãi.');
    }
    if (subtotal <= 0) {
      return const PromotionResult(reason: 'Giỏ hàng đang trống.');
    }
    const walletCodes = {
      'FREESHIP40K',
      'NEORA30K',
      'VIPNEORA',
      'COINBACK5',
      'SHIPFAST25',
      'NEORA50K',
      'VIPDIAMOND',
      'FREESHIPMAX',
      'NEORA100K',
      'SHIPEXP',
      'VIPGIFT',
      'NEORANEW10',
    };
    if (walletCodes.contains(normalizeCode(code)) && voucher == null) {
      return const PromotionResult(
        reason: 'Vui lòng lưu mã vào ví trước khi dùng.',
      );
    }
    if (voucher != null) {
      if (!voucher.isSaved || voucher.isUsed) {
        return const PromotionResult(
          reason: 'Mã chưa được lưu hoặc đã sử dụng.',
        );
      }
      final expiry = _expiry(voucher.expiryDate);
      if (expiry != null && (now ?? DateTime.now()).isAfter(expiry)) {
        return const PromotionResult(reason: 'Mã ưu đãi đã hết hạn.');
      }
      if (subtotal < voucher.minOrderValue) {
        return PromotionResult(
          reason:
              'Đơn hàng cần đạt tối thiểu ${voucher.minOrderValue.toInt()}₫.',
        );
      }
    }

    final collection = items
        .where((item) => item.product.brand == 'NÉORA Collection')
        .fold<double>(0, (sum, item) => sum + item.totalPrice);
    final dresses = items
        .where((item) => item.product.category == 'Đầm')
        .fold<double>(0, (sum, item) => sum + item.totalPrice);
    final newItems = items
        .where((item) => item.product.isNew)
        .fold<double>(0, (sum, item) => sum + item.totalPrice);
    final isVip =
        memberTier.contains('Vàng') || memberTier.contains('Kim Cương');
    final isDiamond = memberTier.contains('Kim Cương');
    PromotionResult item(num amount) =>
        PromotionResult(itemDiscount: amount.toDouble().clamp(0, subtotal));
    PromotionResult shipping(double cap) =>
        requireShippingBenefit && shippingFee <= 0
        ? const PromotionResult(
            reason: 'Hãy chọn cách giao hàng có phí để dùng mã vận chuyển.',
          )
        : PromotionResult(shippingDiscount: shippingFee.clamp(0, cap));
    PromotionResult minimum(int value) =>
        PromotionResult(reason: 'Đơn hàng cần đạt tối thiểu $value₫.');

    switch (normalizeCode(code)) {
      case 'NEO10':
      case 'NEORA10':
        return item((subtotal * .10).round());
      case 'NEO20':
      case 'NEORA20':
        return item((subtotal * .20).round());
      case 'FREESHIP':
        return shipping(double.infinity);
      case 'FREESHIP40K':
        return shipping(40000);
      case 'NEORA30K':
        return subtotal < 299000 ? minimum(299000) : item(30000);
      case 'VIPNEORA':
        if (!isVip) {
          return const PromotionResult(
            reason: 'Mã dành cho hội viên Vàng trở lên.',
          );
        }
        return subtotal < 499000
            ? minimum(499000)
            : item((subtotal * .10).round().clamp(0, 80000));
      case 'COINBACK5':
        return PromotionResult(coinReward: (subtotal * .05).round());
      case 'SHIPFAST25':
        if (subtotal < 250000) return minimum(250000);
        if (!isExpressShipping) {
          return const PromotionResult(
            reason: 'Mã chỉ áp dụng cho giao hoả tốc.',
          );
        }
        return shipping(25000);
      case 'NEORA50K':
        if (subtotal < 599000) return minimum(599000);
        if (collection == 0) {
          return const PromotionResult(
            reason: 'Giỏ cần có sản phẩm NÉORA Collection.',
          );
        }
        return item(50000.clamp(0, collection));
      case 'VIPDIAMOND':
        if (!isDiamond) {
          return const PromotionResult(
            reason: 'Mã dành cho hội viên Kim Cương.',
          );
        }
        return subtotal < 999000
            ? minimum(999000)
            : item((subtotal * .15).round().clamp(0, 150000));
      case 'FREESHIPMAX':
        return subtotal < 500000 ? minimum(500000) : shipping(50000);
      case 'NEORA100K':
        if (subtotal < 1200000) return minimum(1200000);
        if (dresses == 0) {
          return const PromotionResult(reason: 'Giỏ cần có sản phẩm Đầm.');
        }
        return item(100000.clamp(0, dresses));
      case 'SHIPEXP':
        if (!firstOrder) {
          return const PromotionResult(
            reason: 'Mã chỉ áp dụng cho đơn đầu tiên.',
          );
        }
        return shipping(35000);
      case 'VIPGIFT':
        if (!isVip) {
          return const PromotionResult(
            reason: 'Mã dành cho hội viên Vàng trở lên.',
          );
        }
        return subtotal < 1500000
            ? minimum(1500000)
            : const PromotionResult(giftDescription: 'Khăn lụa tơ tằm NÉORA');
      case 'NEORANEW10':
        if (subtotal < 399000) return minimum(399000);
        if (newItems == 0) {
          return const PromotionResult(
            reason: 'Giỏ cần có sản phẩm gắn nhãn MỚI.',
          );
        }
        return item((newItems * .10).round().clamp(0, 70000));
      default:
        return const PromotionResult(reason: 'Mã ưu đãi không tồn tại.');
    }
  }

  static DateTime? _expiry(String label) {
    final match = RegExp(r'(\d{2})/(\d{2})/(\d{4})').firstMatch(label);
    if (match == null) return null;
    return DateTime(
      int.parse(match[3]!),
      int.parse(match[2]!),
      int.parse(match[1]!),
      23,
      59,
      59,
    );
  }
}
