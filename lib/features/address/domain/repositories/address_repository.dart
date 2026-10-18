import '../entities/address_entity.dart';

class AddressBookSnapshot {
  const AddressBookSnapshot({
    required this.addresses,
    required this.selectedAddressId,
  });

  final List<AddressEntity> addresses;
  final String selectedAddressId;
}

abstract class AddressRepository {
  AddressBookSnapshot load();
  void save(AddressBookSnapshot snapshot);
}
