import 'dart:convert';

import 'package:ecommerce_fe/core/network/api_client.dart';
import 'package:ecommerce_fe/core/network/remote_repositories.dart';
import 'package:ecommerce_fe/features/home/di/home_providers.dart';
import 'package:ecommerce_fe/features/shop/presentation/views/remote_flash_sale_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  Future<void> showCampaign(
    WidgetTester tester,
    List<Map<String, Object?>> products,
  ) async {
    final now = DateTime.now().toUtc();
    final client = MockClient((request) async {
      expect(request.url.path, '/api/v1/flash-sales/active');
      return http.Response(
        jsonEncode([
          {
            'id': 'demo_week',
            'title': 'Ưu đãi tuần này',
            'startsAt': now
                .subtract(const Duration(minutes: 1))
                .toIso8601String(),
            'endsAt': now.add(const Duration(hours: 1)).toIso8601String(),
            'products': products,
          },
        ]),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productRepositoryProvider.overrideWithValue(
            RemoteProductRepository(
              ApiClient(
                client: client,
                baseUrl: 'http://localhost:8080/api/v1',
              ),
            ),
          ),
        ],
        child: const MaterialApp(home: RemoteFlashSaleScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Flash Sale shows real remaining quota and server price', (
    tester,
  ) async {
    await showCampaign(tester, [
      {
        'id': 'prod_dress_wrap',
        'title': 'Đầm',
        'price': 399000,
        'originalPrice': 459000,
        'flashSaleId': 'demo_week',
        'flashSaleRemaining': 3,
      },
    ]);

    expect(find.text('Còn 3 suất'), findsOneWidget);
    expect(find.textContaining('399.000₫'), findsOneWidget);
  });

  testWidgets('Flash Sale explains when all offers are exhausted', (
    tester,
  ) async {
    await showCampaign(tester, []);

    expect(
      find.text('Các sản phẩm trong đợt sale này đã hết lượt.'),
      findsOneWidget,
    );
  });
}
