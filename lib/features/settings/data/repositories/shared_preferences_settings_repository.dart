import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/user_settings.dart';
import '../../domain/repositories/settings_repository.dart';

class SharedPreferencesSettingsRepository implements SettingsRepository {
  SharedPreferencesSettingsRepository(this._preferences);

  final SharedPreferences _preferences;

  static const _languageCodeKey = 'settings_language_code';
  static const _profileNameKey = 'settings_profile_name';
  static const _profileEmailKey = 'settings_profile_email';
  static const _profilePhoneKey = 'settings_profile_phone';
  static const _profileBirthdayKey = 'settings_profile_birthday';
  static const _profileGenderKey = 'settings_profile_gender';
  static const _biometricsKey = 'settings_biometrics';
  static const _twoFactorKey = 'settings_two_factor';
  static const _notifyOrdersKey = 'settings_notify_orders';
  static const _notifyPromotionsKey = 'settings_notify_promotions';
  static const _notifyStylistKey = 'settings_notify_stylist';
  static const _cacheSizeKey = 'settings_cache_size';

  @override
  UserSettings load() => UserSettings(
    profile: UserProfile(
      name: _preferences.getString(_profileNameKey) ?? 'Nguyễn Linh',
      email: _preferences.getString(_profileEmailKey) ?? 'nguyenlinh@neora.vn',
      phone: _preferences.getString(_profilePhoneKey) ?? '0908 123 456',
      birthday: _preferences.getString(_profileBirthdayKey) ?? '15/08/1998',
      gender: _preferences.getString(_profileGenderKey) ?? 'Nữ',
    ),
    languageCode: _preferences.getString(_languageCodeKey) ?? 'vi',
    enableBiometrics: _preferences.getBool(_biometricsKey) ?? true,
    enableTwoFactor: _preferences.getBool(_twoFactorKey) ?? false,
    notifyOrders: _preferences.getBool(_notifyOrdersKey) ?? true,
    notifyPromotions: _preferences.getBool(_notifyPromotionsKey) ?? true,
    notifyStylist: _preferences.getBool(_notifyStylistKey) ?? true,
    cacheSizeMb: _preferences.getDouble(_cacheSizeKey) ?? 48.5,
  );

  @override
  void save(UserSettings settings) {
    _preferences.setString(_languageCodeKey, settings.languageCode);
    _preferences.setString(_profileNameKey, settings.profile.name);
    _preferences.setString(_profileEmailKey, settings.profile.email);
    _preferences.setString(_profilePhoneKey, settings.profile.phone);
    _preferences.setString(_profileBirthdayKey, settings.profile.birthday);
    _preferences.setString(_profileGenderKey, settings.profile.gender);
    _preferences.setBool(_biometricsKey, settings.enableBiometrics);
    _preferences.setBool(_twoFactorKey, settings.enableTwoFactor);
    _preferences.setBool(_notifyOrdersKey, settings.notifyOrders);
    _preferences.setBool(_notifyPromotionsKey, settings.notifyPromotions);
    _preferences.setBool(_notifyStylistKey, settings.notifyStylist);
    _preferences.setDouble(_cacheSizeKey, settings.cacheSizeMb);
  }
}
