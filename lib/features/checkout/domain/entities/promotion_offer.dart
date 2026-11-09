class PromotionOffer {
  const PromotionOffer({
    required this.code,
    required this.title,
    required this.type,
    required this.value,
    required this.minSubtotal,
    required this.available,
    required this.remainingUses,
    this.endsAt,
  });

  final String code;
  final String title;
  final String type;
  final double value;
  final double minSubtotal;
  final bool available;
  final int? remainingUses;
  final DateTime? endsAt;
}
