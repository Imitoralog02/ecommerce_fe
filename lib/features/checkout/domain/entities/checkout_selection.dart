enum ShippingType { standard, express, storePickup }

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
