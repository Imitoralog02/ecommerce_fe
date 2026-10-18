enum VoucherType { all, shipping, discount, coinReward, vipOnly }

class VoucherEntity {
  final String id;
  final String code;
  final String title;
  final String description;
  final String discountValue;
  final String discountLabel;
  final VoucherType type;
  final double minOrderValue;
  final double maxDiscount;
  final String expiryDate;
  final bool isSaved;
  final bool isUsed;
  final bool isMint;
  final String tag;

  const VoucherEntity({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.discountValue,
    required this.discountLabel,
    required this.type,
    this.minOrderValue = 0.0,
    this.maxDiscount = 0.0,
    required this.expiryDate,
    this.isSaved = false,
    this.isUsed = false,
    this.isMint = false,
    this.tag = '',
  });

  String get typeTitle {
    switch (type) {
      case VoucherType.shipping:
        return 'Mã Freeship';
      case VoucherType.discount:
        return 'Giảm giá đơn';
      case VoucherType.coinReward:
        return 'Hoàn xu';
      case VoucherType.vipOnly:
        return 'Độc quyền VIP';
      case VoucherType.all:
        return 'Tất cả';
    }
  }

  VoucherEntity copyWith({
    String? id,
    String? code,
    String? title,
    String? description,
    String? discountValue,
    String? discountLabel,
    VoucherType? type,
    double? minOrderValue,
    double? maxDiscount,
    String? expiryDate,
    bool? isSaved,
    bool? isUsed,
    bool? isMint,
    String? tag,
  }) {
    return VoucherEntity(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      description: description ?? this.description,
      discountValue: discountValue ?? this.discountValue,
      discountLabel: discountLabel ?? this.discountLabel,
      type: type ?? this.type,
      minOrderValue: minOrderValue ?? this.minOrderValue,
      maxDiscount: maxDiscount ?? this.maxDiscount,
      expiryDate: expiryDate ?? this.expiryDate,
      isSaved: isSaved ?? this.isSaved,
      isUsed: isUsed ?? this.isUsed,
      isMint: isMint ?? this.isMint,
      tag: tag ?? this.tag,
    );
  }
}

class WalletTransactionEntity {
  final String id;
  final String title;
  final int coinDelta;
  final String date;
  final String icon;

  const WalletTransactionEntity({
    required this.id,
    required this.title,
    required this.coinDelta,
    required this.date,
    required this.icon,
  });
}
