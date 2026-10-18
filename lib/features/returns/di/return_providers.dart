import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/mock_return_repository.dart';
import '../domain/repositories/return_repository.dart';

final returnRepositoryProvider = Provider<ReturnRepository>((ref) {
  return MockReturnRepository();
});
