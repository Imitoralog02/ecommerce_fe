enum ReturnSolution { exchange, refund }

enum RefundMethod { wallet, bank }

class ReturnRequestOptions {
  static const reasons = [
    '📏 Không vừa size (Cần đổi size khác)',
    '🧵 Lỗi chất liệu hoặc đường may',
    '📦 Sản phẩm không giống mô tả / hình ảnh',
    '💡 Đổi ý / Muốn chọn mẫu thiết kế khác',
    'Khác (vui lòng ghi rõ bên dưới)',
  ];

  static const sizes = ['XS', 'S', 'M', 'L', 'XL'];
}

class ReturnRequestDraft {
  const ReturnRequestDraft({
    required this.orderId,
    required this.selectedItemIds,
    this.selectedReason = '📏 Không vừa size (Cần đổi size khác)',
    this.solution = ReturnSolution.exchange,
    this.targetSize = 'M',
    this.refundMethod = RefundMethod.wallet,
    this.evidencePhotos = const [],
  });

  final String orderId;
  final Set<String> selectedItemIds;
  final String selectedReason;
  final ReturnSolution solution;
  final String targetSize;
  final RefundMethod refundMethod;
  final List<String> evidencePhotos;

  ReturnRequestDraft copyWith({
    Set<String>? selectedItemIds,
    String? selectedReason,
    ReturnSolution? solution,
    String? targetSize,
    RefundMethod? refundMethod,
    List<String>? evidencePhotos,
  }) => ReturnRequestDraft(
    orderId: orderId,
    selectedItemIds: selectedItemIds ?? this.selectedItemIds,
    selectedReason: selectedReason ?? this.selectedReason,
    solution: solution ?? this.solution,
    targetSize: targetSize ?? this.targetSize,
    refundMethod: refundMethod ?? this.refundMethod,
    evidencePhotos: evidencePhotos ?? this.evidencePhotos,
  );
}

class ReturnRequestReceipt {
  const ReturnRequestReceipt({
    required this.code,
    required this.draft,
    required this.note,
  });

  final String code;
  final ReturnRequestDraft draft;
  final String note;
}
