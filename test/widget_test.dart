import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecommerce_fe/main.dart';
import 'package:ecommerce_fe/features/navigation/presentation/views/main_nav_screen.dart';
import 'package:ecommerce_fe/features/settings/presentation/viewmodels/settings_viewmodel.dart';

void main() {
  testWidgets('NeoraApp shows onboarding on first launch', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ProviderScope(child: NeoraApp()));
    await tester.pump();

    // Initial frame displays the current Vietnamese NÉORA onboarding.
    expect(find.text('Bỏ qua'), findsOneWidget);
    expect(find.text('01 / 03'), findsOneWidget);
  });

  testWidgets('NeoraApp skips onboarding after it has been completed', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'has_seen_onboarding': true});
    await tester.pumpWidget(const ProviderScope(child: NeoraApp()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(MainNavScreen), findsOneWidget);
    expect(find.text('Bỏ qua'), findsNothing);
  });

  testWidgets('changing display language updates the navigation labels', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'has_seen_onboarding': true});
    await tester.pumpWidget(const ProviderScope(child: NeoraApp()));
    await tester.pump();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(NeoraApp)),
    );
    container.read(settingsViewModelProvider.notifier).setLanguage('en');
    await tester.pumpAndSettle();

    expect(find.text('Discover'), findsOneWidget);
    expect(find.text('Cart'), findsOneWidget);
  });
}
