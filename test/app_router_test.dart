import 'package:ecommerce_fe/core/navigation/app_router.dart';
import 'package:ecommerce_fe/core/l10n/generated/app_localizations.dart';
import 'package:ecommerce_fe/features/navigation/presentation/views/main_nav_screen.dart';
import 'package:ecommerce_fe/features/tracking/presentation/views/order_tracking_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('central router resolves main tab arguments', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          onGenerateRoute: AppRouter.onGenerateRoute,
          initialRoute: AppRoutes.main,
          onGenerateInitialRoutes: (route) => [
            AppRouter.onGenerateRoute(
              const RouteSettings(name: AppRoutes.main, arguments: 2),
            ),
          ],
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(MainNavScreen), findsOneWidget);
  });

  testWidgets('central router forwards order id to tracking', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          onGenerateRoute: AppRouter.onGenerateRoute,
          initialRoute: AppRoutes.tracking,
          onGenerateInitialRoutes: (route) => [
            AppRouter.onGenerateRoute(
              const RouteSettings(
                name: AppRoutes.tracking,
                arguments: 'NEO-3841',
              ),
            ),
          ],
        ),
      ),
    );

    final screen = tester.widget<OrderTrackingScreen>(
      find.byType(OrderTrackingScreen),
    );
    expect(screen.orderId, 'NEO-3841');
  });
}
