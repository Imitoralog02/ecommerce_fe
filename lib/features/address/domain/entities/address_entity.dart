class AddressEntity {
  final String id;
  final String recipientName;
  final String phoneNumber;
  final String streetAddress;
  final String ward;
  final String district;
  final String city;
  final bool isDefault;
  final String label; // 'Nhà riêng', 'Văn phòng', 'Khác'

  const AddressEntity({
    required this.id,
    required this.recipientName,
    required this.phoneNumber,
    required this.streetAddress,
    required this.ward,
    required this.district,
    required this.city,
    this.isDefault = false,
    this.label = 'Nhà riêng',
  });

  String get fullAddress {
    final parts = [
      streetAddress,
      ward,
      district,
      city,
    ].where((p) => p.trim().isNotEmpty).toList();
    return parts.join(', ');
  }

  String get shortAddress {
    if (district.isNotEmpty && city.isNotEmpty) {
      return '$district, $city';
    }
    return city.isNotEmpty ? city : streetAddress;
  }

  AddressEntity copyWith({
    String? id,
    String? recipientName,
    String? phoneNumber,
    String? streetAddress,
    String? ward,
    String? district,
    String? city,
    bool? isDefault,
    String? label,
  }) {
    return AddressEntity(
      id: id ?? this.id,
      recipientName: recipientName ?? this.recipientName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      streetAddress: streetAddress ?? this.streetAddress,
      ward: ward ?? this.ward,
      district: district ?? this.district,
      city: city ?? this.city,
      isDefault: isDefault ?? this.isDefault,
      label: label ?? this.label,
    );
  }
}
