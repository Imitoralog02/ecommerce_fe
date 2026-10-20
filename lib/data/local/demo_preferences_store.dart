import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Small JSON store for the frontend demo's non-transactional local state.
class DemoPreferencesStore {
  const DemoPreferencesStore(this.preferences);

  final SharedPreferences preferences;

  Object? read(String key) {
    final raw = preferences.getString(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  void write(String key, Object value) {
    unawaited(preferences.setString(key, jsonEncode(value)));
  }
}
