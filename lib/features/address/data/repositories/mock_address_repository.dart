import '../../domain/entities/address_entity.dart';
import '../../domain/repositories/address_repository.dart';

class MockAddressRepository implements AddressRepository {
  AddressBookSnapshot _snapshot = const AddressBookSnapshot(
    addresses: [
      AddressEntity(
        id: 'addr_1',
        recipientName: 'Trần Phương Linh',
        phoneNumber: '0908 123 456',
        streetAddress: 'Tầng 12, Toà nhà Bitexco, 2 Hải Triều',
        ward: 'Phường Bến Nghé',
        district: 'Quận 1',
        city: 'TP. Hồ Chí Minh',
        isDefault: true,
        label: 'Văn phòng',
      ),
      AddressEntity(
        id: 'addr_2',
        recipientName: 'Trần Phương Linh',
        phoneNumber: '0908 123 456',
        streetAddress:
            'Căn hộ 15.08, Tháp Aqua 1, Vinhomes Golden River, 2 Tôn Đức Thắng',
        ward: 'Phường Bến Nghé',
        district: 'Quận 1',
        city: 'TP. Hồ Chí Minh',
        label: 'Nhà riêng',
      ),
      AddressEntity(
        id: 'addr_3',
        recipientName: 'Nguyễn Thị Minh',
        phoneNumber: '0912 987 654',
        streetAddress: 'Số 45, Ngõ 12 Đào Tấn',
        ward: 'Phường Cống Vị',
        district: 'Quận Ba Đình',
        city: 'Hà Nội',
        label: 'Nhà riêng',
      ),
    ],
    selectedAddressId: 'addr_1',
  );

  @override
  AddressBookSnapshot load() => AddressBookSnapshot(
    addresses: List.unmodifiable(_snapshot.addresses),
    selectedAddressId: _snapshot.selectedAddressId,
  );

  @override
  void save(AddressBookSnapshot snapshot) => _snapshot = snapshot;
}
