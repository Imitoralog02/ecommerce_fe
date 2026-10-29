import 'package:ecommerce_fe/core/l10n/generated/app_localizations.dart';
import 'package:ecommerce_fe/features/checkout/presentation/views/order_confirmed_screen.dart';
import 'package:ecommerce_fe/features/orders/domain/entities/order_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('long remote order fields stay inside the receipt', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(780, 1688);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: OrderConfirmedScreen(
            orderId:
                'ord_50fe147193dedc77ea47be579e0af52843c7d7445a8f3eaf5994857319c0a7e3',
            paymentMethod: 'Thanh toán khi nhận hàng (COD)',
            estimatedDelivery: 'Chưa có dự kiến giao hàng',
            totalAmount: '720.000đ',
            status: OrderStatus.processing,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 800));
    expect(tester.takeException(), isNull);
  });
}
