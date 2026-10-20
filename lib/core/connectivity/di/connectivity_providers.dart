import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_connectivity_repository.dart';
import '../domain/repositories/connectivity_repository.dart';
import '../presentation/demo_connectivity_mode.dart';

final connectivityRepositoryProvider = Provider<ConnectivityRepository>((ref) {
  return MockConnectivityRepository(
    isSimulatedOffline: () => ref.read(demoConnectivityModeProvider),
  );
});
