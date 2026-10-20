import 'package:ecommerce_fe/core/l10n/generated/app_localizations.dart';
import 'package:ecommerce_fe/features/auth/domain/repositories/auth_repository.dart';
import 'package:ecommerce_fe/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:ecommerce_fe/features/auth/presentation/views/auth_screen.dart';
import 'package:ecommerce_fe/features/cart/presentation/viewmodels/cart_viewmodel.dart';
import 'package:ecommerce_fe/features/home/data/repositories/mock_product_repository.dart';
import 'package:ecommerce_fe/features/shop/domain/services/lookbook_outfits.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _AuthSpy implements AuthRepository {
  int logins = 0;
  int registrations = 0;

  @override
  Future<void> login({required String email, required String password}) async {
    logins++;
  }

  @override
  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    registrations++;
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {}
}

void main() {
  testWidgets('empty login form does not inject demo credentials', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AuthScreen(),
        ),
      ),
    );
    final login = find.text('Đăng nhập  →');
    await tester.ensureVisible(login);
    await tester.tap(login);
    await tester.pumpAndSettle();
    expect(find.text('Vui lòng nhập email hoặc tài khoản'), findsOneWidget);
  });

  test(
    'auth rejects empty input and registration remains on login form',
    () async {
      final repository = _AuthSpy();
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      final auth = container.read(authViewModelProvider.notifier);

      auth.updateEmail('');
      expect(await auth.submit(), isFalse);
      expect(repository.logins, 0);

      auth.switchTab(AuthTab.register);
      auth.updateFullName('Nguyễn An');
      auth.updateEmail('an@example.com');
      auth.updatePassword('Password1');
      auth.updateConfirmPassword('');
      expect(await auth.submit(), isFalse);
      expect(
        container.read(authViewModelProvider).errorCode,
        AuthErrorCode.passwordMismatch,
      );
      expect(repository.registrations, 0);

      auth.updateConfirmPassword('Password1');
      expect(await auth.submit(), isTrue);
      expect(repository.registrations, 1);
      expect(container.read(authViewModelProvider).currentTab, AuthTab.login);
      expect(container.read(authViewModelProvider).isAuthenticated, isFalse);

      auth.updatePassword('Password1');
      expect(await auth.submit(), isTrue);
      expect(container.read(authViewModelProvider).isAuthenticated, isTrue);
      auth.logout();
      expect(container.read(authViewModelProvider).isAuthenticated, isFalse);
    },
  );

  test(
    'quick add chooses a catalog variant and rejects invalid selections',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final cart = container.read(cartViewModelProvider.notifier);
      final catalog = MockProductRepository.mockCatalog;

      for (final product in catalog) {
        expect(cart.addToCart(product), isTrue);
      }
      final items = container.read(cartViewModelProvider).items;
      expect(items, hasLength(catalog.length));
      for (final item in items) {
        expect(item.product.availableSizes, contains(item.selectedSize));
        expect(item.product.colorNames, contains(item.selectedColor));
      }

      final before = items.length;
      expect(cart.addToCart(catalog.first, '41', 'Kem Be'), isFalse);
      expect(cart.addToCart(catalog.first, 'M', 'Không tồn tại'), isFalse);
      expect(container.read(cartViewModelProvider).items.length, before);
    },
  );

  test('stylist filters occasion, gender and budget using catalog prices', () {
    final catalog = MockProductRepository.mockCatalog;
    final byId = {for (final product in catalog) product.id: product};
    for (final occasion in ['Đi làm', 'Đi chơi', 'Dự tiệc', 'Du lịch']) {
      final outfits = LookbookOutfits.select(
        catalog,
        occasion: occasion,
        gender: 'Tất cả',
        budget: 1800000,
      );
      expect(outfits, hasLength(2));
      expect(outfits.every((outfit) => outfit.occasion == occasion), isTrue);
      for (final outfit in outfits) {
        expect(outfit.totalPrice, lessThanOrEqualTo(1800000));
        expect(
          outfit.totalPrice,
          outfit.items.fold<double>(0, (sum, item) => sum + item.price),
        );
        for (final item in outfit.items) {
          final product = byId[item.product.id]!;
          expect(item.price, product.price);
          expect(item.title, product.title);
          expect(item.selectedSize, isIn(product.availableSizes));
          expect(item.selectedColor, isIn(product.colorNames));
        }
      }
    }

    final women = LookbookOutfits.select(
      catalog,
      occasion: 'Đi làm',
      gender: 'Nữ',
      budget: 500000,
    );
    expect(women, hasLength(1));
    expect(women.single.gender, 'Nữ');
    expect(women.single.totalPrice, lessThanOrEqualTo(500000));
    expect(women.single.items, hasLength(1));

    final withBlackBag = LookbookOutfits.select(
      catalog,
      occasion: 'Dự tiệc',
      gender: 'Nữ',
      budget: 1800000,
      bagColor: 'Đen',
    ).single;
    final bag = withBlackBag.items.singleWhere(
      (item) => item.product.id == 'prod_leather_bag',
    );
    expect(bag.selectedColor, 'Đen');
    expect(bag.price, byId['prod_leather_bag']!.price);
  });
}
