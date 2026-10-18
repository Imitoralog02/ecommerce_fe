import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/mock_support_repository.dart';
import '../domain/repositories/support_repository.dart';

final supportRepositoryProvider = Provider<SupportRepository>((ref) {
  return const MockSupportRepository();
});
