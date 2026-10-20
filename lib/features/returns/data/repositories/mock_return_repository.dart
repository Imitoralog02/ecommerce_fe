import '../../../../data/local/demo_preferences_store.dart';
import '../../domain/entities/return_request.dart';
import '../../domain/repositories/return_repository.dart';

class MockReturnRepository implements ReturnRepository {
  MockReturnRepository([this._store]) {
    final saved = _store?.read(_key);
    if (saved is! Map) return;
    try {
      final data = Map<String, dynamic>.from(saved);
      for (final raw in data['drafts'] as List) {
        final draft = _draftFromJson(Map<String, dynamic>.from(raw as Map));
        _drafts[draft.orderId] = draft;
      }
      for (final raw in data['receipts'] as List) {
        final value = Map<String, dynamic>.from(raw as Map);
        final receipt = ReturnRequestReceipt(
          code: value['code'] as String,
          draft: _draftFromJson(
            Map<String, dynamic>.from(value['draft'] as Map),
          ),
          note: value['note'] as String,
        );
        _receiptsByOrder[receipt.draft.orderId] = receipt;
        submittedRequests.add(receipt);
      }
    } catch (_) {
      _drafts.clear();
      _receiptsByOrder.clear();
      submittedRequests.clear();
    }
  }

  static const _key = 'demo_returns_v1';
  final DemoPreferencesStore? _store;
  final Map<String, ReturnRequestDraft> _drafts = {};
  final Map<String, ReturnRequestReceipt> _receiptsByOrder = {};
  final List<ReturnRequestReceipt> submittedRequests = [];

  @override
  ReturnRequestDraft? loadDraft(String orderId) => _drafts[orderId];

  @override
  void saveDraft(ReturnRequestDraft draft) {
    _drafts[draft.orderId] = draft;
    _persist();
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
    _persist();
    return receipt;
  }

  void _persist() => _store?.write(_key, {
    'drafts': _drafts.values.map(_draftToJson).toList(),
    'receipts': submittedRequests
        .map(
          (receipt) => {
            'code': receipt.code,
            'draft': _draftToJson(receipt.draft),
            'note': receipt.note,
          },
        )
        .toList(),
  });

  static Map<String, Object?> _draftToJson(ReturnRequestDraft draft) => {
    'orderId': draft.orderId,
    'selectedItemIds': draft.selectedItemIds.toList(),
    'selectedReason': draft.selectedReason,
    'solution': draft.solution.name,
    'targetSize': draft.targetSize,
    'refundMethod': draft.refundMethod.name,
    'evidencePhotos': draft.evidencePhotos,
  };

  static ReturnRequestDraft _draftFromJson(Map<String, dynamic> value) =>
      ReturnRequestDraft(
        orderId: value['orderId'] as String,
        selectedItemIds: Set<String>.from(value['selectedItemIds'] as List),
        selectedReason: value['selectedReason'] as String,
        solution: ReturnSolution.values.byName(value['solution'] as String),
        targetSize: value['targetSize'] as String,
        refundMethod: RefundMethod.values.byName(
          value['refundMethod'] as String,
        ),
        evidencePhotos: List<String>.from(value['evidencePhotos'] as List),
      );
}
