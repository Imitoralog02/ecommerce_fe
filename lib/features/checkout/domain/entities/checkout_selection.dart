enum ShippingType { standard, express, storePickup }

extension ShippingTypeDisplay on ShippingType {
  String get displayLabel => switch (this) {
    ShippingType.standard => 'Giao hàng tiêu chuẩn',
    ShippingType.express => 'Giao hàng hỏa tốc',
    ShippingType.storePickup => 'Nhận tại cửa hàng',
  };

  String get demoEstimatedDelivery => switch (this) {
    ShippingType.standard => 'Trong 2–3 ngày làm việc',
    ShippingType.express => 'Trong 24 giờ (dự kiến)',
    ShippingType.storePickup => 'Chờ xác nhận thời gian nhận',
  };
}

enum PaymentType { creditCard, applePay, momo, zalopay, cashOnDelivery }

class CheckoutSelection {
  final ShippingType shippingType;
  final PaymentType paymentType;
  final String? paymentCardLastFour;

  const CheckoutSelection({
    required this.shippingType,
    required this.paymentType,
    this.paymentCardLastFour,
  });

  double get shippingFee => switch (shippingType) {
    ShippingType.express => 30000,
    ShippingType.standard || ShippingType.storePickup => 0,
  };
}
