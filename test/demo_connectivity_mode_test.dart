import 'package:ecommerce_fe/core/connectivity/di/connectivity_providers.dart';
import 'package:ecommerce_fe/core/connectivity/presentation/demo_connectivity_mode.dart';
import 'package:ecommerce_fe/core/l10n/generated/app_localizations.dart';
import 'package:ecommerce_fe/core/widgets/no_internet_screen.dart';
import 'package:ecommerce_fe/features/navigation/presentation/views/main_nav_screen.dart';
import 'package:ecommerce_fe/features/settings/presentation/views/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('demo connectivity mode controls the mock retry result', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final repository = container.read(connectivityRepositoryProvider);

    expect(container.read(demoConnectivityModeProvider), isFalse);
    expect(await repository.checkConnection(), isTrue);

    container.read(demoConnectivityModeProvider.notifier).setOffline(true);
    expect(await repository.checkConnection(), isFalse);

    container.read(demoConnectivityModeProvider.notifier).setOffline(false);
    expect(await repository.checkConnection(), isTrue);
  });

  testWidgets('offline preview can retry and return to the app', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(demoConnectivityModeProvider.notifier).setOffline(true);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.5),
              disableAnimations: true,
            ),
            child: child!,
          ),
          home: const MainNavScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(NoInternetScreen), findsOneWidget);
    expect(find.text('Mô Phỏng Mất Kết Nối'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.text('THỬ LẠI'));
    await tester.tap(find.text('THỬ LẠI'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(NoInternetScreen), findsOneWidget);
    expect(container.read(demoConnectivityModeProvider), isTrue);
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.text('TIẾP TỤC DÙNG APP'));
    await tester.tap(find.text('TIẾP TỤC DÙNG APP'));
    await tester.pump();
    expect(container.read(demoConnectivityModeProvider), isFalse);
    expect(find.byType(NoInternetScreen), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('settings switch opens the offline preview flow', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const SettingsScreen(),
                    ),
                  ),
                  child: const Text('Mở cài đặt'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Mở cài đặt'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Mô phỏng mất kết nối'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    final switchFinder = find.descendant(
      of: find.ancestor(
        of: find.text('Mô phỏng mất kết nối'),
        matching: find.byType(ListTile),
      ),
      matching: find.byType(Switch),
    );
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    expect(container.read(demoConnectivityModeProvider), isTrue);
    expect(find.text('Mở cài đặt'), findsOneWidget);
    expect(find.byType(SettingsScreen), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
  });
}
