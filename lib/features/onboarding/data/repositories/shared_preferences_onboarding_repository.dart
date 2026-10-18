import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/onboarding_repository.dart';

class SharedPreferencesOnboardingRepository implements OnboardingRepository {
  static const _hasSeenOnboardingKey = 'has_seen_onboarding';

  @override
  Future<bool> hasSeenOnboarding() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_hasSeenOnboardingKey) ?? false;
  }

  @override
  Future<void> markOnboardingSeen() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_hasSeenOnboardingKey, true);
  }
}
