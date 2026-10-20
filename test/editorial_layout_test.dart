import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecommerce_fe/core/theme/app_theme.dart';
import 'package:ecommerce_fe/core/l10n/generated/app_localizations.dart';
import 'package:ecommerce_fe/features/onboarding/presentation/views/onboarding_screen.dart';
import 'package:ecommerce_fe/features/onboarding/presentation/viewmodels/onboarding_viewmodel.dart';
import 'package:ecommerce_fe/features/auth/presentation/views/auth_screen.dart';
import 'package:ecommerce_fe/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:ecommerce_fe/features/home/presentation/views/home_screen.dart';
import 'package:ecommerce_fe/features/shop/presentation/views/shop_screen.dart';
import 'package:ecommerce_fe/features/shop/presentation/views/lookbook_screen.dart';
import 'package:ecommerce_fe/features/product_detail/presentation/views/product_detail_screen.dart';
import 'package:ecommerce_fe/features/home/domain/entities/product_entity.dart';
import 'package:ecommerce_fe/features/cart/presentation/viewmodels/cart_viewmodel.dart';
import 'package:ecommerce_fe/features/profile/presentation/views/profile_screen.dart';
import 'package:ecommerce_fe/features/cart/presentation/views/cart_screen.dart';
import 'package:ecommerce_fe/features/checkout/presentation/views/checkout_screen.dart';
import 'package:ecommerce_fe/features/wallet/presentation/views/voucher_wallet_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const product = ProductEntity(
    id: 'preview-shirt',
    pieceNumber: '01',
    title: 'Sơ mi cotton dáng rộng',
    subCategory: 'Áo sơ mi',
    category: 'Sơ mi',
    price: 590000,
    composition: 'Cotton',
    description: 'Thiết kế thoải mái cho nhịp sống mỗi ngày.',
    availableSizes: ['S', 'M', 'L'],
    imageType: 'shirt',
    imagePath: 'assets/images/real/p_shirt.jpg',
  );
  setUpAll(() async {
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    for (final font in [
      'PlayfairDisplay',
      'PlusJakartaSans',
      'NotoSerif',
      'Inter',
    ]) {
      await (FontLoader(
        font,
      )..addFont(rootBundle.load('assets/fonts/$font.ttf'))).load();
    }
  });
  for (final size in [const Size(360, 640), const Size(390, 844)]) {
    for (final screen in [
      'onboarding',
      'onboarding_2',
      'onboarding_3',
      'login',
      'register',
      'home',
      'shop',
      'profile',
      'cart',
      'checkout',
      'product',
      'lookbook',
    ]) {
      testWidgets('$screen editorial layout at $size', (tester) async {
        SharedPreferences.setMockInitialValues({});
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final container = ProviderContainer();

        if (screen == 'onboarding_2') {
          container.read(onboardingViewModelProvider.notifier).selectPage(1);
        }
        if (screen == 'onboarding_3') {
          container.read(onboardingViewModelProvider.notifier).selectPage(2);
        }
        if (screen == 'register') {
          container
              .read(authViewModelProvider.notifier)
              .switchTab(AuthTab.register);
        }
        if (screen == 'cart' || screen == 'checkout') {
          container
              .read(cartViewModelProvider.notifier)
              .addToCart(product, 'M');
        }
        final home = switch (screen) {
          'onboarding' ||
          'onboarding_2' ||
          'onboarding_3' => const OnboardingScreen(),
          'login' || 'register' => const AuthScreen(),
          'home' => HomeScreen(onOpenCart: () {}),
          'shop' => const ShopScreen(),
          'profile' => const ProfileScreen(),
          'cart' => const CartScreen(),
          'product' => const ProductDetailScreen(product: product),
          'lookbook' => const LookbookScreen(),
          _ => const CheckoutScreen(),
        };
        final key = GlobalKey();
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              locale: const Locale('vi'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: RepaintBoundary(key: key, child: home),
            ),
          ),
        );
        await tester.pump(const Duration(seconds: 1));
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 300));
        });
        await tester.pump(const Duration(milliseconds: 300));

        if (const bool.fromEnvironment('EXPORT_PREVIEWS') &&
            size.width == 390) {
          await tester.runAsync(() async {
            final boundary =
                key.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary;
            final image = await boundary.toImage(pixelRatio: 1);
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final file = File('build/editorial-previews/$screen.png');
            await file.parent.create(recursive: true);
            await file.writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
        if (screen == 'home') {
          await tester.drag(
            find.byType(CustomScrollView),
            const Offset(0, -4000),
          );
          await tester.pumpAndSettle();
          expect(find.text('Lên đầu trang'), findsOneWidget);
          expect(tester.takeException(), isNull);

          if (const bool.fromEnvironment('EXPORT_PREVIEWS') &&
              size.width == 390) {
            await tester.runAsync(() async {
              final boundary =
                  key.currentContext!.findRenderObject()!
                      as RenderRepaintBoundary;
              final image = await boundary.toImage(pixelRatio: 1);
              final bytes = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );
              final file = File('build/editorial-previews/home_bottom.png');
              await file.parent.create(recursive: true);
              await file.writeAsBytes(bytes!.buffer.asUint8List());
              image.dispose();
            });
          }

          await tester.tap(find.text('Xem gợi ý phối đồ'));
          await tester.pumpAndSettle();
          final openedLookbook = tester.widget<LookbookScreen>(
            find.byType(LookbookScreen),
          );
          expect(openedLookbook.initialOccasion, 'Đi chơi');
          tester.state<NavigatorState>(find.byType(Navigator)).pop();
          await tester.pumpAndSettle();

          await tester.tap(find.text('Ưu đãi cho tủ đồ của bạn'));
          await tester.pumpAndSettle();
          expect(find.byType(VoucherWalletScreen), findsOneWidget);
          tester.state<NavigatorState>(find.byType(Navigator)).pop();
          await tester.pumpAndSettle();

          await tester.tap(find.text('Lên đầu trang'));
          await tester.pumpAndSettle();
          final scrollable = tester.state<ScrollableState>(
            find.byType(Scrollable).first,
          );
          expect(scrollable.position.pixels, 0);
        }
        await tester.pumpWidget(const SizedBox.shrink());
        container.dispose();
      });
    }
  }
}
