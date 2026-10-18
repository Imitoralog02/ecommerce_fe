import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../di/address_providers.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/repositories/address_repository.dart';

class AddressState {
  final List<AddressEntity> addresses;
  final String selectedAddressId;

  const AddressState({
    required this.addresses,
    required this.selectedAddressId,
  });

  AddressEntity? get selectedAddress {
    final found = addresses.where((a) => a.id == selectedAddressId).firstOrNull;
    if (found != null) return found;
    return addresses.where((a) => a.isDefault).firstOrNull ??
        addresses.firstOrNull;
  }

  AddressState copyWith({
    List<AddressEntity>? addresses,
    String? selectedAddressId,
  }) {
    return AddressState(
      addresses: addresses ?? this.addresses,
      selectedAddressId: selectedAddressId ?? this.selectedAddressId,
    );
  }
}

class AddressViewModel extends Notifier<AddressState> {
  @override
  AddressState build() {
    final snapshot = ref.read(addressRepositoryProvider).load();
    return AddressState(
      addresses: snapshot.addresses,
      selectedAddressId: snapshot.selectedAddressId,
    );
  }

  void _save(AddressState next) {
    ref
        .read(addressRepositoryProvider)
        .save(
          AddressBookSnapshot(
            addresses: next.addresses,
            selectedAddressId: next.selectedAddressId,
          ),
        );
    state = next;
  }

  void selectAddress(String id) {
    _save(state.copyWith(selectedAddressId: id));
  }

  void addAddress(AddressEntity address) {
    var updated = List<AddressEntity>.from(state.addresses);
    if (address.isDefault) {
      updated = updated.map((a) => a.copyWith(isDefault: false)).toList();
    }
    updated.insert(0, address);
    _save(
      state.copyWith(
        addresses: updated,
        selectedAddressId: address.isDefault
            ? address.id
            : state.selectedAddressId,
      ),
    );
  }

  void updateAddress(AddressEntity address) {
    var updated = state.addresses.map((a) {
      if (address.isDefault && a.id != address.id) {
        return a.copyWith(isDefault: false);
      }
      return a.id == address.id ? address : a;
    }).toList();

    _save(state.copyWith(addresses: updated));
  }

  void deleteAddress(String id) {
    final updated = state.addresses.where((a) => a.id != id).toList();
    String newSelected = state.selectedAddressId;
    if (newSelected == id) {
      newSelected = updated.firstOrNull?.id ?? '';
    }
    _save(state.copyWith(addresses: updated, selectedAddressId: newSelected));
  }

  void setDefaultAddress(String id) {
    final updated = state.addresses.map((a) {
      return a.copyWith(isDefault: a.id == id);
    }).toList();
    _save(state.copyWith(addresses: updated, selectedAddressId: id));
  }
}

final addressViewModelProvider =
    NotifierProvider<AddressViewModel, AddressState>(() {
      return AddressViewModel();
    });
