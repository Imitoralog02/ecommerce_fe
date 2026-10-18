import 'package:ecommerce_fe/features/home/domain/entities/product_entity.dart';
import 'package:ecommerce_fe/core/l10n/generated/app_localizations.dart';
import 'package:ecommerce_fe/features/navigation/presentation/views/main_nav_screen.dart';
import 'package:ecommerce_fe/features/notifications/presentation/views/notifications_screen.dart';
import 'package:ecommerce_fe/features/product_detail/presentation/views/product_detail_screen.dart';
import 'package:ecommerce_fe/features/profile/presentation/views/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const product = ProductEntity(
    id: 'accessibility-product',
    pieceNumber: '01',
    title: 'Đầm hoa midi dáng dài thanh lịch',
    subCategory: 'ĐẦM',
    category: 'Đầm',
    price: 459000,
    composition: 'Voan tơ mềm mại',
    description:
        'Thiết kế thanh lịch với chất liệu mềm mại và phom dáng thoải mái.',
    availableSizes: ['S', 'M', 'L', 'XL'],
    tag: 'BÁN CHẠY',
    imageType: 'dress',
  );

  Widget buildScaledApp(Widget home) {
    return ProviderScope(
      child: MaterialApp(
        locale: const Locale('vi'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) {
          final mediaQuery = MediaQuery.of(context);
          return MediaQuery(
            data: mediaQuery.copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          );
        },
        home: home,
      ),
    );
  }

  Widget buildAtScale(Widget home, double scale) {
    return ProviderScope(
      child: MaterialApp(
        locale: const Locale('vi'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) {
          final mediaQuery = MediaQuery.of(context);
          return MediaQuery(
            data: mediaQuery.copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          );
        },
        home: home,
      ),
    );
  }

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  final keyScreens = <String, Widget>{
    'product detail': const ProductDetailScreen(product: product),
    'notifications': const NotificationsScreen(),
    'profile': const ProfileScreen(),
    'main navigation': const MainNavScreen(),
  };

  for (final entry in keyScreens.entries) {
    testWidgets('${entry.key} reflows at 150 percent text size', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(780, 1688);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildScaledApp(entry.value));
      await tester.pump(const Duration(milliseconds: 300));
    });
  }

  for (final entry in {
    'notifications': const NotificationsScreen(),
    'main navigation': const MainNavScreen(),
  }.entries) {
    testWidgets('${entry.key} reflows at 200 percent text size', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(780, 1688);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildAtScale(entry.value, 2));
      await tester.pump(const Duration(milliseconds: 300));
    });
  }

  testWidgets('bottom navigation exposes meaningful semantic labels', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(buildScaledApp(const MainNavScreen()));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.bySemanticsLabel('Trang chủ'), findsOneWidget);
    expect(find.bySemanticsLabel('Khám phá'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Thông báo, có thông báo mới'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Giỏ hàng'), findsOneWidget);
    expect(find.bySemanticsLabel('Tài khoản'), findsOneWidget);
    semantics.dispose();
  });
}
