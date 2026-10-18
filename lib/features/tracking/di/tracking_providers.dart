import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/mock_tracking_repository.dart';
import '../domain/repositories/tracking_repository.dart';

final trackingRepositoryProvider = Provider<TrackingRepository>((ref) {
  return MockTrackingRepository();
});
