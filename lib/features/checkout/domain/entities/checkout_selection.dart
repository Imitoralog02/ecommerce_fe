enum ShippingType { standard, express, storePickup }

enum PaymentType { creditCard, applePay, cashOnDelivery }

class CheckoutSelection {
  final ShippingType shippingType;
  final PaymentType paymentType;

  const CheckoutSelection({
    required this.shippingType,
    required this.paymentType,
  });

  double get shippingFee => switch (shippingType) {
    ShippingType.express => 30000,
    ShippingType.standard || ShippingType.storePickup => 0,
  };
}
