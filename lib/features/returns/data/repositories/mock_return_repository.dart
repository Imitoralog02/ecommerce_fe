import '../../domain/entities/return_request.dart';
import '../../domain/repositories/return_repository.dart';

class MockReturnRepository implements ReturnRepository {
  final Map<String, ReturnRequestDraft> _drafts = {};
  final Map<String, ReturnRequestReceipt> _receiptsByOrder = {};
  final List<ReturnRequestReceipt> submittedRequests = [];

  @override
  ReturnRequestDraft? loadDraft(String orderId) => _drafts[orderId];

  @override
  void saveDraft(ReturnRequestDraft draft) {
    _drafts[draft.orderId] = draft;
  }

  @override
  ReturnRequestReceipt submit(
    ReturnRequestDraft draft, {
    required String note,
  }) {
    final existing = _receiptsByOrder[draft.orderId];
    if (existing != null) return existing;

    final receipt = ReturnRequestReceipt(
      code: 'RET-${1000 + submittedRequests.length + 1}',
      draft: draft,
      note: note,
    );
    submittedRequests.add(receipt);
    _receiptsByOrder[draft.orderId] = receipt;
    _drafts.remove(draft.orderId);
    return receipt;
  }
}
