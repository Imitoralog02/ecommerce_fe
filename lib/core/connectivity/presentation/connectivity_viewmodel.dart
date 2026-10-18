import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../di/connectivity_providers.dart';

class ConnectivityState {
  const ConnectivityState({this.isRetrying = false});

  final bool isRetrying;
}

class ConnectivityViewModel extends Notifier<ConnectivityState> {
  @override
  ConnectivityState build() => const ConnectivityState();

  Future<bool> retry() async {
    if (state.isRetrying) return false;
    state = const ConnectivityState(isRetrying: true);
    try {
      return await ref.read(connectivityRepositoryProvider).checkConnection();
    } finally {
      state = const ConnectivityState();
    }
  }
}

final connectivityViewModelProvider =
    NotifierProvider.autoDispose<ConnectivityViewModel, ConnectivityState>(
      ConnectivityViewModel.new,
    );
