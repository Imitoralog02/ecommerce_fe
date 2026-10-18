import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/media/di/media_picker_providers.dart';
import '../../../../core/media/domain/media_picker_repository.dart';
import '../../di/return_providers.dart';
import '../../domain/entities/return_request.dart';

typedef ReturnRequestSeed = ({String orderId, String? firstItemId});

class ReturnRequestViewModel extends Notifier<ReturnRequestDraft> {
  ReturnRequestViewModel(this.seed);

  final ReturnRequestSeed seed;

  @override
  ReturnRequestDraft build() {
    final repository = ref.read(returnRepositoryProvider);
    return repository.loadDraft(seed.orderId) ??
        ReturnRequestDraft(
          orderId: seed.orderId,
          selectedItemIds: {?seed.firstItemId},
        );
  }

  void _save(ReturnRequestDraft next) {
    ref.read(returnRepositoryProvider).saveDraft(next);
    state = next;
  }

  void setItemSelected(String itemId, bool selected) {
    final ids = {...state.selectedItemIds};
    selected ? ids.add(itemId) : ids.remove(itemId);
    _save(state.copyWith(selectedItemIds: ids));
  }

  void selectReason(String reason) =>
      _save(state.copyWith(selectedReason: reason));

  void selectSolution(ReturnSolution solution) =>
      _save(state.copyWith(solution: solution));

  void selectTargetSize(String size) => _save(state.copyWith(targetSize: size));

  void selectRefundMethod(RefundMethod method) =>
      _save(state.copyWith(refundMethod: method));

  void addEvidencePhoto(String path) =>
      _save(state.copyWith(evidencePhotos: [...state.evidencePhotos, path]));

  Future<void> pickEvidencePhoto() async {
    final path = await ref
        .read(mediaPickerRepositoryProvider)
        .pickImage(MediaPickerPurpose.returnEvidence);
    if (path == null || !ref.mounted) return;
    addEvidencePhoto(path);
  }

  String? validate(String note) {
    if (state.selectedItemIds.isEmpty) {
      return 'Vui lòng chọn ít nhất 1 sản phẩm cần đổi/trả.';
    }
    if (state.selectedReason == ReturnRequestOptions.reasons.last &&
        note.trim().isEmpty) {
      return 'Vui lòng mô tả rõ lý do đổi/trả trong phần ghi chú.';
    }
    return null;
  }

  ReturnRequestReceipt? submit({required String note}) {
    if (validate(note) != null) return null;
    return ref.read(returnRepositoryProvider).submit(state, note: note);
  }
}

final returnRequestViewModelProvider = NotifierProvider.autoDispose
    .family<ReturnRequestViewModel, ReturnRequestDraft, ReturnRequestSeed>(
      (seed) => ReturnRequestViewModel(seed),
    );
