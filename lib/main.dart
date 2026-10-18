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
