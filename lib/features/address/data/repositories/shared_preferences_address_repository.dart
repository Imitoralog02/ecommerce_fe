import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../data/local/demo_entity_codec.dart';
import '../../domain/repositories/address_repository.dart';
import 'mock_address_repository.dart';

class SharedPreferencesAddressRepository implements AddressRepository {
  SharedPreferencesAddressRepository(this._preferences);

  static const _key = 'demo_addresses_v1';
  final SharedPreferences _preferences;

  @override
  AddressBookSnapshot load() {
    final raw = _preferences.getString(_key);
    if (raw == null) return MockAddressRepository().load();
    try {
      final data = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      if (data['version'] != 1) return MockAddressRepository().load();
      return AddressBookSnapshot(
        addresses: List.unmodifiable(
          (data['addresses'] as List).map(DemoEntityCodec.addressFromJson),
        ),
        selectedAddressId: data['selectedAddressId'] as String,
      );
    } catch (_) {
      return MockAddressRepository().load();
    }
  }

  @override
  void save(AddressBookSnapshot snapshot) {
    final data = {
      'version': 1,
      'addresses': snapshot.addresses
          .map(DemoEntityCodec.addressToJson)
          .toList(),
      'selectedAddressId': snapshot.selectedAddressId,
    };
    unawaited(_preferences.setString(_key, jsonEncode(data)));
  }
}
