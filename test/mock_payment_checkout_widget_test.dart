import 'package:ecommerce_fe/core/l10n/generated/app_localizations.dart';
import 'package:ecommerce_fe/features/checkout/domain/entities/checkout_selection.dart';
import 'package:ecommerce_fe/features/checkout/presentation/viewmodels/checkout_viewmodel.dart';
import 'package:ecommerce_fe/features/checkout/presentation/views/checkout_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('linked mock wallet is selectable in checkout', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: CheckoutScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final momo = find.text('MoMo');
    await tester.ensureVisible(momo);
    await tester.tap(momo);
    await tester.pump();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(CheckoutScreen)),
    );
    expect(
      container.read(checkoutViewModelProvider).paymentType,
      PaymentType.momo,
    );
  });
}
