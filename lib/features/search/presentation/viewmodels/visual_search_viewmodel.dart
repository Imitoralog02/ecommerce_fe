import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/media/di/media_picker_providers.dart';
import '../../../../core/media/domain/media_picker_repository.dart';
import '../../di/search_providers.dart';
import '../../domain/entities/visual_search_result.dart';

class VisualSearchState {
  const VisualSearchState({
    this.isScanning = false,
    this.sourceImagePath,
    this.result,
    this.errorMessage,
  });

  final bool isScanning;
  final String? sourceImagePath;
  final VisualSearchResult? result;
  final String? errorMessage;
}

class VisualSearchViewModel extends Notifier<VisualSearchState> {
  @override
  VisualSearchState build() => const VisualSearchState();

  Future<void> pickAndSearch() async {
    final imagePath = await ref
        .read(mediaPickerRepositoryProvider)
        .pickImage(MediaPickerPurpose.visualSearch);
    if (!ref.mounted) return;
    if (imagePath == null) {
      state = const VisualSearchState(
        errorMessage: 'Bạn chưa chọn hình ảnh để tìm kiếm.',
      );
      return;
    }
    await search(imagePath);
  }

  Future<void> search(String imagePath) async {
    if (state.isScanning) return;
    state = VisualSearchState(isScanning: true, sourceImagePath: imagePath);
    try {
      final result = await ref
          .read(searchRepositoryProvider)
          .searchByImage(imagePath);
      if (!ref.mounted) return;
      state = VisualSearchState(sourceImagePath: imagePath, result: result);
    } catch (_) {
      if (!ref.mounted) return;
      state = VisualSearchState(
        sourceImagePath: imagePath,
        errorMessage: 'Không thể phân tích hình ảnh. Vui lòng thử lại.',
      );
    }
  }
}

final visualSearchViewModelProvider =
    NotifierProvider.autoDispose<VisualSearchViewModel, VisualSearchState>(
      VisualSearchViewModel.new,
    );
