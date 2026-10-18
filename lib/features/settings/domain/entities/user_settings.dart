class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.birthday,
    required this.gender,
  });

  final String name;
  final String email;
  final String phone;
  final String birthday;
  final String gender;

  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? birthday,
    String? gender,
  }) => UserProfile(
    name: name ?? this.name,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    birthday: birthday ?? this.birthday,
    gender: gender ?? this.gender,
  );
}

class UserSettings {
  const UserSettings({
    required this.profile,
    this.languageCode = 'vi',
    this.enableBiometrics = true,
    this.enableTwoFactor = false,
    this.notifyOrders = true,
    this.notifyPromotions = true,
    this.notifyStylist = true,
    this.cacheSizeMb = 48.5,
  });

  final UserProfile profile;
  final String languageCode;
  final bool enableBiometrics;
  final bool enableTwoFactor;
  final bool notifyOrders;
  final bool notifyPromotions;
  final bool notifyStylist;
  final double cacheSizeMb;

  UserSettings copyWith({
    UserProfile? profile,
    String? languageCode,
    bool? enableBiometrics,
    bool? enableTwoFactor,
    bool? notifyOrders,
    bool? notifyPromotions,
    bool? notifyStylist,
    double? cacheSizeMb,
  }) => UserSettings(
    profile: profile ?? this.profile,
    languageCode: languageCode ?? this.languageCode,
    enableBiometrics: enableBiometrics ?? this.enableBiometrics,
    enableTwoFactor: enableTwoFactor ?? this.enableTwoFactor,
    notifyOrders: notifyOrders ?? this.notifyOrders,
    notifyPromotions: notifyPromotions ?? this.notifyPromotions,
    notifyStylist: notifyStylist ?? this.notifyStylist,
    cacheSizeMb: cacheSizeMb ?? this.cacheSizeMb,
  );
}
