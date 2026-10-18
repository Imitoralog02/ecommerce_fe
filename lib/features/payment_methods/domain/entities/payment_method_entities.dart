class PaymentCardEntity {
  const PaymentCardEntity({
    required this.id,
    required this.bankName,
    required this.cardType,
    required this.lastFour,
    required this.holderName,
    required this.expiry,
    required this.gradientValues,
    this.isDefault = false,
  });

  final String id;
  final String bankName;
  final String cardType;
  final String lastFour;
  final String holderName;
  final String expiry;
  final List<int> gradientValues;
  final bool isDefault;

  PaymentCardEntity copyWith({bool? isDefault}) => PaymentCardEntity(
    id: id,
    bankName: bankName,
    cardType: cardType,
    lastFour: lastFour,
    holderName: holderName,
    expiry: expiry,
    gradientValues: gradientValues,
    isDefault: isDefault ?? this.isDefault,
  );
}

class PaymentMethodsState {
  const PaymentMethodsState({
    this.cards = const [],
    this.momoLinked = true,
    this.zalopayLinked = true,
    this.deviceWalletEnabled = true,
  });

  final List<PaymentCardEntity> cards;
  final bool momoLinked;
  final bool zalopayLinked;
  final bool deviceWalletEnabled;

  PaymentMethodsState copyWith({
    List<PaymentCardEntity>? cards,
    bool? momoLinked,
    bool? zalopayLinked,
    bool? deviceWalletEnabled,
  }) => PaymentMethodsState(
    cards: cards ?? this.cards,
    momoLinked: momoLinked ?? this.momoLinked,
    zalopayLinked: zalopayLinked ?? this.zalopayLinked,
    deviceWalletEnabled: deviceWalletEnabled ?? this.deviceWalletEnabled,
  );
}
