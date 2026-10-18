import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_media_picker_repository.dart';
import '../domain/media_picker_repository.dart';

final mediaPickerRepositoryProvider = Provider<MediaPickerRepository>((ref) {
  return MockMediaPickerRepository();
});
