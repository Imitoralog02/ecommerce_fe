import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ecommerce_fe/core/l10n/generated/app_localizations.dart';
import 'package:ecommerce_fe/features/home/presentation/views/home_screen.dart';
import 'package:ecommerce_fe/features/cart/presentation/views/cart_screen.dart';
import 'package:ecommerce_fe/features/profile/presentation/views/profile_screen.dart';
import 'package:ecommerce_fe/features/shop/presentation/views/shop_screen.dart';
import 'package:ecommerce_fe/features/checkout/presentation/views/checkout_screen.dart';
import 'package:ecommerce_fe/features/tracking/presentation/views/order_tracking_screen.dart';
import 'package:ecommerce_fe/features/home/domain/entities/product_entity.dart';
import 'package:ecommerce_fe/features/notifications/presentation/views/notifications_screen.dart';
import 'package:ecommerce_fe/features/navigation/presentation/views/main_nav_screen.dart';
import 'package:ecommerce_fe/features/product_detail/presentation/views/product_detail_screen.dart';

Widget buildTestApp(Widget home) {
  return ProviderScope(
    child: MaterialApp(
      locale: const Locale('vi'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    ),
  );
}

void main() {
  const dummyProduct = ProductEntity(
    id: 'prod_sculptural_coat_01',
    pieceNumber: '01',
    title: 'Sculptural Virgin Coat',
    subCategory: 'OUTERWEAR',
    category: 'Coats',
    price: 890.0,
    composition: '100% Virgin Wool Triple-Twist',
    description: 'Soft heavyweight knit with a relaxed oversized fit.',
    availableSizes: ['S', 'M', 'L', 'XL'],
    tag: 'New Arrival',
    imageType: 'sculptural_coat',
  );

  final screenSizes = [
    const Size(360, 640), // Small Android
    const Size(375, 667), // iPhone SE
    const Size(390, 844), // iPhone 14
    const Size(412, 915), // Pixel 7
  ];

  for (final size in screenSizes) {
    testWidgets('Test All Screens on size ${size.width}x${size.height}', (
      tester,
    ) async {
      tester.view.physicalSize = Size(size.width * 2, size.height * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      // Home
      await tester.pumpWidget(buildTestApp(HomeScreen(onOpenCart: () {})));
      await tester.pump(const Duration(milliseconds: 300));

      // Detail
      await tester.pumpWidget(
        buildTestApp(const ProductDetailScreen(product: dummyProduct)),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Cart
      await tester.pumpWidget(buildTestApp(const CartScreen()));
      await tester.pump(const Duration(milliseconds: 300));

      // Shop
      await tester.pumpWidget(buildTestApp(const ShopScreen()));
      await tester.pump(const Duration(milliseconds: 300));

      // Checkout
      await tester.pumpWidget(buildTestApp(const CheckoutScreen()));
      await tester.pump(const Duration(milliseconds: 300));

      // Profile
      await tester.pumpWidget(buildTestApp(const ProfileScreen()));
      await tester.pump(const Duration(milliseconds: 300));

      // Tracking
      await tester.pumpWidget(buildTestApp(const OrderTrackingScreen()));
      await tester.pump(const Duration(milliseconds: 300));

      // Notifications
      await tester.pumpWidget(buildTestApp(const NotificationsScreen()));
      await tester.pump(const Duration(milliseconds: 300));

      // MainNav (5-item dock)
      await tester.pumpWidget(buildTestApp(const MainNavScreen()));
      await tester.pump(const Duration(milliseconds: 300));
    });
  }
}
