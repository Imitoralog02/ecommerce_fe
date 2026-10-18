import 'package:flutter_riverpod/flutter_riverpod.dart';

export '../../di/onboarding_providers.dart';

class OnboardingViewModel extends Notifier<int> {
  @override
  int build() => 0;

  void selectPage(int index) {
    if (index == state) return;
    state = index;
  }
}

final onboardingViewModelProvider = NotifierProvider<OnboardingViewModel, int>(
  OnboardingViewModel.new,
);
