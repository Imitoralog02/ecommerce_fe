import '../../domain/entities/user_settings.dart';
import '../../domain/repositories/settings_repository.dart';

class MockSettingsRepository implements SettingsRepository {
  UserSettings _settings = const UserSettings(
    profile: UserProfile(
      name: 'Nguyễn Linh',
      email: 'nguyenlinh@neora.vn',
      phone: '0908 123 456',
      birthday: '15/08/1998',
      gender: 'Nữ',
    ),
  );

  @override
  UserSettings load() => _settings;

  @override
  void save(UserSettings settings) => _settings = settings;
}
