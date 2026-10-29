import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PendingCheckout {
  const PendingCheckout({required this.key, required this.fingerprint});

  final String key;
  final String fingerprint;

  Map<String, String> toJson() => {'key': key, 'fingerprint': fingerprint};

  static PendingCheckout? fromJson(String? raw) {
    if (raw == null) return null;
    try {
      final value = jsonDecode(raw);
      if (value is! Map<String, dynamic>) return null;
      final key = value['key'];
      final fingerprint = value['fingerprint'];
      if (key is! String || fingerprint is! String) return null;
      return PendingCheckout(key: key, fingerprint: fingerprint);
    } catch (_) {
      return null;
    }
  }
}

abstract interface class PendingCheckoutStore {
  PendingCheckout? read(String userId);
  Future<void> write(String userId, PendingCheckout? pending);
}

class SharedPreferencesPendingCheckoutStore implements PendingCheckoutStore {
  const SharedPreferencesPendingCheckoutStore(this.preferences);

  final SharedPreferences preferences;

  String _storageKey(String userId) => 'pending_cod_checkout_$userId';

  @override
  PendingCheckout? read(String userId) =>
      PendingCheckout.fromJson(preferences.getString(_storageKey(userId)));

  @override
  Future<void> write(String userId, PendingCheckout? pending) async {
    if (pending == null) {
      await preferences.remove(_storageKey(userId));
    } else {
      await preferences.setString(
        _storageKey(userId),
        jsonEncode(pending.toJson()),
      );
    }
  }
}

class MemoryPendingCheckoutStore implements PendingCheckoutStore {
  final Map<String, PendingCheckout> _values = {};

  @override
  PendingCheckout? read(String userId) => _values[userId];

  @override
  Future<void> write(String userId, PendingCheckout? pending) async {
    if (pending == null) {
      _values.remove(userId);
    } else {
      _values[userId] = pending;
    }
  }
}
