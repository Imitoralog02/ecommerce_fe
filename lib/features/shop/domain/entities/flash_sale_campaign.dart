import '../../../home/domain/entities/product_entity.dart';

class FlashSaleSlot {
  const FlashSaleSlot(this.startHour, this.endHour);

  final int startHour;
  final int endHour;

  String get label => '${startHour.toString().padLeft(2, '0')}:00';

  DateTime startsAt(DateTime day) =>
      DateTime(day.year, day.month, day.day, startHour);
  DateTime endsAt(DateTime day) =>
      DateTime(day.year, day.month, day.day, endHour);

  bool isActiveAt(DateTime now) =>
      !now.isBefore(startsAt(now)) && now.isBefore(endsAt(now));
  bool isPastAt(DateTime now) => !now.isBefore(endsAt(now));
  bool isUpcomingAt(DateTime now) => now.isBefore(startsAt(now));

  Duration untilBoundary(DateTime now) {
    final boundary = isUpcomingAt(now) ? startsAt(now) : endsAt(now);
    final remaining = boundary.difference(now);
    return remaining.isNegative ? Duration.zero : remaining;
  }
}

class FlashSaleOffer {
  const FlashSaleOffer({
    required this.productId,
    required this.capacity,
    required this.soldAtStart,
    required this.minutesPerSale,
  });

  final String productId;
  final int capacity;
  final int soldAtStart;
  final int minutesPerSale;

  int soldAt(DateTime now, FlashSaleSlot slot) {
    final start = slot.startsAt(now);
    final end = slot.endsAt(now);
    final elapsed = now.isBefore(start)
        ? 0
        : (now.isAfter(end) ? end : now).difference(start).inMinutes;
    return (soldAtStart + elapsed ~/ minutesPerSale).clamp(0, capacity);
  }

  int remainingAt(DateTime now, FlashSaleSlot slot) =>
      capacity - soldAt(now, slot);

  double soldFractionAt(DateTime now, FlashSaleSlot slot) =>
      capacity == 0 ? 0 : soldAt(now, slot) / capacity;
}

/// A deterministic daily mock campaign. Reopening either screen never restarts it.
abstract final class FlashSaleCampaign {
  static const slots = [
    FlashSaleSlot(9, 12),
    FlashSaleSlot(12, 18),
    FlashSaleSlot(18, 21),
    FlashSaleSlot(21, 24),
  ];

  static const offers = <String, FlashSaleOffer>{
    'prod_dress_wrap': FlashSaleOffer(
      productId: 'prod_dress_wrap',
      capacity: 40,
      soldAtStart: 31,
      minutesPerSale: 35,
    ),
    'prod_knit_sweater': FlashSaleOffer(
      productId: 'prod_knit_sweater',
      capacity: 32,
      soldAtStart: 23,
      minutesPerSale: 48,
    ),
    'prod_hoodie_lavender': FlashSaleOffer(
      productId: 'prod_hoodie_lavender',
      capacity: 45,
      soldAtStart: 32,
      minutesPerSale: 60,
    ),
    'prod_linen_shirt': FlashSaleOffer(
      productId: 'prod_linen_shirt',
      capacity: 30,
      soldAtStart: 22,
      minutesPerSale: 42,
    ),
    'prod_jeans_wide': FlashSaleOffer(
      productId: 'prod_jeans_wide',
      capacity: 36,
      soldAtStart: 25,
      minutesPerSale: 52,
    ),
    'prod_sneaker_white': FlashSaleOffer(
      productId: 'prod_sneaker_white',
      capacity: 28,
      soldAtStart: 21,
      minutesPerSale: 38,
    ),
    'prod_leather_bag': FlashSaleOffer(
      productId: 'prod_leather_bag',
      capacity: 30,
      soldAtStart: 20,
      minutesPerSale: 55,
    ),
    'prod_dress_floral_side': FlashSaleOffer(
      productId: 'prod_dress_floral_side',
      capacity: 38,
      soldAtStart: 29,
      minutesPerSale: 44,
    ),
  };

  static FlashSaleSlot currentOrNext(DateTime now) {
    for (final slot in slots) {
      if (!slot.isPastAt(now)) return slot;
    }
    return slots.first;
  }

  static int currentOrNextIndex(DateTime now) {
    for (var i = 0; i < slots.length; i++) {
      if (!slots[i].isPastAt(now)) return i;
    }
    return 0;
  }

  static int discountPercent(ProductEntity product) {
    final original = product.originalPrice;
    if (original == null || original <= product.price) return 0;
    return ((1 - product.price / original) * 100).round().clamp(0, 100);
  }
}
