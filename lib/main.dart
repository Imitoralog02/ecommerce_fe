import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/app_router.dart';
import 'core/l10n/generated/app_localizations.dart';
import 'features/navigation/presentation/views/main_nav_screen.dart';
import 'features/onboarding/presentation/views/onboarding_screen.dart';
import 'features/onboarding/presentation/viewmodels/onboarding_viewmodel.dart';
import 'features/settings/presentation/viewmodels/settings_viewmodel.dart';
import 'features/settings/data/repositories/shared_preferences_settings_repository.dart';
import 'features/settings/di/settings_providers.dart';
import 'features/address/data/repositories/shared_preferences_address_repository.dart';
import 'features/address/di/address_providers.dart';
import 'features/cart/data/repositories/shared_preferences_cart_repository.dart';
import 'features/cart/di/cart_providers.dart';
import 'features/home/data/repositories/mock_product_repository.dart';
import 'features/orders/data/repositories/shared_preferences_order_repository.dart';
import 'features/orders/di/order_providers.dart';
import 'features/wishlist/data/repositories/shared_preferences_wishlist_repository.dart';
import 'features/wishlist/di/wishlist_providers.dart';
import 'features/wallet/data/repositories/shared_preferences_wallet_repository.dart';
import 'features/wallet/di/wallet_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
  runApp(
    ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(
          SharedPreferencesSettingsRepository(preferences),
        ),
        cartRepositoryProvider.overrideWithValue(
          SharedPreferencesCartRepository(preferences),
        ),
        addressRepositoryProvider.overrideWithValue(
          SharedPreferencesAddressRepository(preferences),
        ),
        wishlistRepositoryProvider.overrideWithValue(
          SharedPreferencesWishlistRepository(
            preferences,
            MockProductRepository.mockCatalog,
          ),
        ),
        orderRepositoryProvider.overrideWithValue(
          SharedPreferencesOrderRepository(
            preferences,
            MockProductRepository.mockCatalog,
          ),
        ),
        walletRepositoryProvider.overrideWithValue(
          SharedPreferencesWalletRepository(preferences),
        ),
      ],
      child: const NeoraApp(),
    ),
  );
}

class NeoraApp extends ConsumerWidget {
  const NeoraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = ref.watch(
      settingsViewModelProvider.select((settings) => settings.languageCode),
    );
    return MaterialApp(
      navigatorKey: AppRouter.navigatorKey,
      title: 'NÉORA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: Locale(languageCode),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      onGenerateRoute: AppRouter.onGenerateRoute,
      home: const _AppStartupGate(),
    );
  }
}

class _AppStartupGate extends ConsumerWidget {
  const _AppStartupGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingStatus = ref.watch(hasSeenOnboardingProvider);

    return onboardingStatus.when(
      data: (hasSeenOnboarding) =>
          hasSeenOnboarding ? const MainNavScreen() : const OnboardingScreen(),
      loading: () => Scaffold(
        body: Center(
          child: Semantics(
            label: 'Đang khởi động NÉORA',
            child: const CircularProgressIndicator(),
          ),
        ),
      ),
      error: (_, _) => const OnboardingScreen(),
    );
  }
}
