import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_connectivity_repository.dart';
import '../domain/repositories/connectivity_repository.dart';

final connectivityRepositoryProvider = Provider<ConnectivityRepository>((ref) {
  return MockConnectivityRepository();
});
