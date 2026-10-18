import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/di/home_providers.dart';
import '../data/repositories/mock_search_repository.dart';
import '../domain/repositories/search_repository.dart';

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return MockSearchRepository(ref.read(productRepositoryProvider));
});
