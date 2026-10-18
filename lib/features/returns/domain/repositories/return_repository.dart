import '../entities/return_request.dart';

abstract class ReturnRepository {
  ReturnRequestDraft? loadDraft(String orderId);
  void saveDraft(ReturnRequestDraft draft);
  ReturnRequestReceipt submit(ReturnRequestDraft draft, {required String note});
}
