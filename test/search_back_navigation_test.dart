import 'package:ecommerce_fe/features/navigation/presentation/views/main_nav_screen.dart';
import 'package:ecommerce_fe/core/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('back from focused search returns to home without an exception', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(824, 1830);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const MainNavScreen(initialIndex: 1),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final searchField = find.byType(TextField);
    expect(searchField, findsOneWidget);

    await tester.tap(searchField);
    await tester.pump();
    expect(tester.widget<TextField>(searchField).focusNode?.hasFocus, isTrue);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(MainNavScreen), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });
}
