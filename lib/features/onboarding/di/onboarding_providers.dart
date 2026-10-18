import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/shared_preferences_onboarding_repository.dart';
import '../domain/repositories/onboarding_repository.dart';

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return SharedPreferencesOnboardingRepository();
});

final hasSeenOnboardingProvider = FutureProvider<bool>((ref) {
  return ref.watch(onboardingRepositoryProvider).hasSeenOnboarding();
});
