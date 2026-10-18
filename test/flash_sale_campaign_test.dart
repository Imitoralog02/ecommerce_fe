import 'package:ecommerce_fe/features/home/data/repositories/mock_product_repository.dart';
import 'package:ecommerce_fe/features/shop/domain/entities/flash_sale_campaign.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('daily slots cross boundaries without restarting countdown', () {
    final before = DateTime(2026, 10, 19, 8, 59, 50);
    final morning = FlashSaleCampaign.currentOrNext(before);
    expect(morning.label, '09:00');
    expect(morning.isUpcomingAt(before), isTrue);
    expect(morning.untilBoundary(before), const Duration(seconds: 10));

    final active = DateTime(2026, 10, 19, 9);
    expect(FlashSaleCampaign.currentOrNext(active).isActiveAt(active), isTrue);
    expect(
      FlashSaleCampaign.currentOrNext(
        DateTime(2026, 10, 19, 11, 59, 59),
      ).untilBoundary(DateTime(2026, 10, 19, 11, 59, 59)),
      const Duration(seconds: 1),
    );
    expect(
      FlashSaleCampaign.currentOrNext(DateTime(2026, 10, 19, 12)).label,
      '12:00',
    );
    expect(
      FlashSaleCampaign.currentOrNext(
        DateTime(2026, 10, 19, 21),
      ).endsAt(DateTime(2026, 10, 19, 21)),
      DateTime(2026, 10, 20),
    );
    expect(
      FlashSaleCampaign.currentOrNext(DateTime(2026, 10, 20)).label,
      '09:00',
    );
  });

  test('offer stock is deterministic, bounded and shared by product id', () {
    final products = MockProductRepository.mockCatalog;
    expect(
      FlashSaleCampaign.offers.keys.toSet(),
      products.map((product) => product.id).toSet(),
    );
    final offer = FlashSaleCampaign.offers[products.first.id]!;
    final slot = FlashSaleCampaign.slots.first;
    final early = DateTime(2026, 10, 19, 9);
    final later = DateTime(2026, 10, 19, 10, 30);
    expect(offer.remainingAt(early, slot), offer.remainingAt(early, slot));
    expect(
      offer.remainingAt(later, slot),
      lessThan(offer.remainingAt(early, slot)),
    );
    expect(
      offer.remainingAt(DateTime(2026, 10, 19, 23), FlashSaleCampaign.slots[1]),
      0,
    );
    expect(offer.soldFractionAt(later, slot), inInclusiveRange(0, 1));
    expect(FlashSaleCampaign.discountPercent(products.first), greaterThan(0));
  });
}
