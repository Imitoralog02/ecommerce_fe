import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/network/api_client.dart';
import 'core/network/pending_checkout_store.dart';
import 'core/network/remote_repositories.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/app_router.dart';
import 'core/l10n/generated/app_localizations.dart';
import 'features/navigation/presentation/views/main_nav_screen.dart';
import 'features/onboarding/presentation/views/onboarding_screen.dart';
import 'features/onboarding/presentation/viewmodels/onboarding_viewmodel.dart';
import 'features/settings/presentation/viewmodels/settings_viewmodel.dart';
import 'features/settings/data/repositories/shared_preferences_settings_repository.dart';
import 'features/settings/di/settings_providers.dart';
import 'features/address/di/address_providers.dart';
import 'features/cart/di/cart_providers.dart';
import 'features/home/data/repositories/mock_product_repository.dart';
import 'features/home/di/home_providers.dart';
import 'features/auth/di/auth_providers.dart';
import 'features/checkout/di/checkout_providers.dart';
import 'features/orders/di/order_providers.dart';
import 'features/wishlist/di/wishlist_providers.dart';
import 'features/wallet/data/repositories/shared_preferences_wallet_repository.dart';
import 'features/wallet/di/wallet_providers.dart';
import 'data/local/demo_preferences_store.dart';
import 'features/history/data/repositories/mock_recently_viewed_repository.dart';
import 'features/history/di/history_providers.dart';
import 'features/notifications/di/notification_providers.dart';
import 'features/payment_methods/data/repositories/mock_payment_methods_repository.dart';
import 'features/payment_methods/di/payment_methods_providers.dart';
import 'features/returns/data/repositories/mock_return_repository.dart';
import 'features/returns/di/return_providers.dart';
import 'features/reviews/data/repositories/mock_review_repository.dart';
import 'features/reviews/di/review_providers.dart';
import 'features/search/data/repositories/mock_search_repository.dart';
import 'features/search/di/search_providers.dart';
import 'features/support/data/repositories/mock_support_repository.dart';
import 'features/support/di/support_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final demoStore = DemoPreferencesStore(preferences);
  final api = ApiClient();
  await api.restoreSession();
  final remoteProducts = RemoteProductRepository(api);
  final remoteCart = RemoteCartRepository(api);
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
        authRepositoryProvider.overrideWithValue(RemoteAuthRepository(api)),
        productRepositoryProvider.overrideWithValue(remoteProducts),
        checkoutRepositoryProvider.overrideWithValue(
          RemoteCheckoutRepository(
            api,
            remoteCart,
            pendingStore: SharedPreferencesPendingCheckoutStore(preferences),
          ),
        ),
        settingsRepositoryProvider.overrideWithValue(
          SharedPreferencesSettingsRepository(preferences),
        ),
        cartRepositoryProvider.overrideWithValue(remoteCart),
        addressRepositoryProvider.overrideWithValue(
          RemoteAddressRepository(api),
        ),
        wishlistRepositoryProvider.overrideWithValue(
          RemoteWishlistRepository(api),
        ),
        orderRepositoryProvider.overrideWithValue(RemoteOrderRepository(api)),
        walletRepositoryProvider.overrideWithValue(
          SharedPreferencesWalletRepository(preferences),
        ),
        recentlyViewedRepositoryProvider.overrideWithValue(
          MockRecentlyViewedRepository(
            MockProductRepository.mockCatalog,
            demoStore,
          ),
        ),
        notificationRepositoryProvider.overrideWithValue(
          RemoteNotificationRepository(api),
        ),
        paymentMethodsRepositoryProvider.overrideWithValue(
          MockPaymentMethodsRepository(demoStore),
        ),
        returnRepositoryProvider.overrideWithValue(
          MockReturnRepository(demoStore),
        ),
        reviewRepositoryProvider.overrideWithValue(
          MockReviewRepository(demoStore),
        ),
        searchRepositoryProvider.overrideWithValue(
          MockSearchRepository(remoteProducts, demoStore),
        ),
        supportRepositoryProvider.overrideWithValue(
          MockSupportRepository(demoStore),
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
