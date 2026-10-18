import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/mock_address_repository.dart';
import '../domain/repositories/address_repository.dart';

final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  return MockAddressRepository();
});
