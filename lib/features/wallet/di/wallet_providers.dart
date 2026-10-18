import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/mock_wallet_repository.dart';
import '../domain/repositories/wallet_repository.dart';

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return MockWalletRepository();
});

final walletClockProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);
