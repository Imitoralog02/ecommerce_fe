import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/settings_providers.dart';
import '../../domain/entities/user_settings.dart';

class SettingsViewModel extends Notifier<UserSettings> {
  @override
  UserSettings build() => ref.read(settingsRepositoryProvider).load();

  void _save(UserSettings next) {
    ref.read(settingsRepositoryProvider).save(next);
    state = next;
  }

  void updateProfile(UserProfile profile) =>
      _save(state.copyWith(profile: profile));
  void setLanguage(String languageCode) {
    if (languageCode != 'vi' && languageCode != 'en') return;
    _save(state.copyWith(languageCode: languageCode));
  }

  void setBiometrics(bool value) =>
      _save(state.copyWith(enableBiometrics: value));
  void setTwoFactor(bool value) =>
      _save(state.copyWith(enableTwoFactor: value));
  void setOrderNotifications(bool value) =>
      _save(state.copyWith(notifyOrders: value));
  void setPromotionNotifications(bool value) =>
      _save(state.copyWith(notifyPromotions: value));
  void setStylistNotifications(bool value) =>
      _save(state.copyWith(notifyStylist: value));
  void clearCache() => _save(state.copyWith(cacheSizeMb: 0));
}

final settingsViewModelProvider =
    NotifierProvider<SettingsViewModel, UserSettings>(SettingsViewModel.new);
