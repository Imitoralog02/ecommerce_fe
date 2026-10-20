import 'package:ecommerce_fe/features/home/data/repositories/mock_product_repository.dart';
import 'package:ecommerce_fe/features/orders/data/repositories/mock_order_repository.dart';
import 'package:ecommerce_fe/features/orders/di/order_providers.dart';
import 'package:ecommerce_fe/features/orders/domain/entities/order_entity.dart';
import 'package:ecommerce_fe/features/orders/presentation/views/order_detail_screen.dart';
import 'package:ecommerce_fe/features/tracking/presentation/views/order_tracking_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'order detail uses its shipping choice and never invents a tracking code',
    (tester) async {
      final repository = MockOrderRepository(MockProductRepository.mockCatalog);
      final order = repository.getOrders().firstWhere(
        (item) => item.id == 'NEO-5102',
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [orderRepositoryProvider.overrideWithValue(repository)],
          child: MaterialApp(home: OrderDetailScreen(order: order)),
        ),
      );

      expect(find.text('Giao hàng tiêu chuẩn'), findsOneWidget);
      expect(find.textContaining('GHN Express 2h'), findsNothing);
      expect(find.textContaining('GHN-VN-882194'), findsNothing);
    },
  );

  testWidgets(
    'cancelled order tracking has no delivery estimate or active step',
    (tester) async {
      final repository = MockOrderRepository(MockProductRepository.mockCatalog);
      final cancelled = repository.getOrders().firstWhere(
        (item) => item.status == OrderStatus.cancelled,
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [orderRepositoryProvider.overrideWithValue(repository)],
          child: MaterialApp(home: OrderTrackingScreen(orderId: cancelled.id)),
        ),
      );

      expect(find.text('Đơn hàng đã huỷ'), findsOneWidget);
      expect(find.textContaining('Dự kiến giao'), findsNothing);
      expect(find.textContaining('Giao hàng hỏa tốc'), findsNothing);
    },
  );
}
