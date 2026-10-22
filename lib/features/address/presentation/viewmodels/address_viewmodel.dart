import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../di/address_providers.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/repositories/address_repository.dart';
import '../../../../core/network/remote_repositories.dart';

class AddressState {
  final String? errorMessage;
  final List<AddressEntity> addresses;
  final String selectedAddressId;

  const AddressState({
    this.errorMessage,
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
    String? errorMessage,
    List<AddressEntity>? addresses,
    String? selectedAddressId,
  }) {
    return AddressState(
      errorMessage: errorMessage,
      addresses: addresses ?? this.addresses,
      selectedAddressId: selectedAddressId ?? this.selectedAddressId,
    );
  }
}

class AddressViewModel extends Notifier<AddressState> {
  @override
  AddressState build() {
    final snapshot = ref.read(addressRepositoryProvider).load();
    final repository = ref.read(addressRepositoryProvider);
    if (repository is RemoteAddressRepository) {
      Future.microtask(() async {
        try {
          final remote = await repository.refresh();
          if (ref.mounted) {
            state = AddressState(
              addresses: remote.addresses,
              selectedAddressId: remote.selectedAddressId,
            );
          }
        } catch (error) {
          if (ref.mounted) state = state.copyWith(errorMessage: '$error');
        }
      });
    }
    return AddressState(
      addresses: snapshot.addresses,
      selectedAddressId: snapshot.selectedAddressId,
    );
  }

  Future<bool> _save(AddressState next) async {
    final repository = ref.read(addressRepositoryProvider);
    if (repository is RemoteAddressRepository) {
      try {
        final remote = await repository.synchronize(
          AddressBookSnapshot(
            addresses: next.addresses,
            selectedAddressId: next.selectedAddressId,
          ),
        );
        if (ref.mounted) {
          state = AddressState(
            addresses: remote.addresses,
            selectedAddressId: remote.selectedAddressId,
          );
        }
        return true;
      } catch (error) {
        if (ref.mounted) state = state.copyWith(errorMessage: '$error');
        return false;
      }
    }
    ref
        .read(addressRepositoryProvider)
        .save(
          AddressBookSnapshot(
            addresses: next.addresses,
            selectedAddressId: next.selectedAddressId,
          ),
        );
    state = next;
    return true;
  }

  void selectAddress(String id) {
    state = state.copyWith(selectedAddressId: id);
  }

  Future<bool> addAddress(AddressEntity address) {
    var updated = List<AddressEntity>.from(state.addresses);
    if (address.isDefault) {
      updated = updated.map((a) => a.copyWith(isDefault: false)).toList();
    }
    updated.insert(0, address);
    return _save(
      state.copyWith(
        addresses: updated,
        selectedAddressId: address.isDefault
            ? address.id
            : state.selectedAddressId,
      ),
    );
  }

  Future<bool> updateAddress(AddressEntity address) {
    var updated = state.addresses.map((a) {
      if (address.isDefault && a.id != address.id) {
        return a.copyWith(isDefault: false);
      }
      return a.id == address.id ? address : a;
    }).toList();

    return _save(state.copyWith(addresses: updated));
  }

  Future<bool> deleteAddress(String id) {
    final updated = state.addresses.where((a) => a.id != id).toList();
    String newSelected = state.selectedAddressId;
    if (newSelected == id) {
      newSelected = updated.firstOrNull?.id ?? '';
    }
    return _save(
      state.copyWith(addresses: updated, selectedAddressId: newSelected),
    );
  }

  Future<bool> setDefaultAddress(String id) {
    final updated = state.addresses.map((a) {
      return a.copyWith(isDefault: a.id == id);
    }).toList();
    return _save(state.copyWith(addresses: updated, selectedAddressId: id));
  }
}

final addressViewModelProvider =
    NotifierProvider<AddressViewModel, AddressState>(() {
      return AddressViewModel();
    });
