import '../entities/user_settings.dart';

abstract class SettingsRepository {
  UserSettings load();
  void save(UserSettings settings);
}
