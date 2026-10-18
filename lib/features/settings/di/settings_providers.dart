import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/mock_settings_repository.dart';
import '../domain/repositories/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return MockSettingsRepository();
});
