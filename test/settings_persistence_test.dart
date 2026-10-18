import 'package:ecommerce_fe/features/settings/data/repositories/shared_preferences_settings_repository.dart';
import 'package:ecommerce_fe/features/settings/domain/entities/user_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'settings repository restores language and profile after recreation',
    () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final repository = SharedPreferencesSettingsRepository(preferences);

      repository.save(
        const UserSettings(
          languageCode: 'en',
          profile: UserProfile(
            name: 'NÉORA Member',
            email: 'member@neora.vn',
            phone: '0900000001',
            birthday: '01/01/2000',
            gender: 'Khác',
          ),
        ),
      );

      final restored = SharedPreferencesSettingsRepository(preferences).load();
      expect(restored.languageCode, 'en');
      expect(restored.profile.name, 'NÉORA Member');
      expect(restored.profile.email, 'member@neora.vn');
    },
  );
}
