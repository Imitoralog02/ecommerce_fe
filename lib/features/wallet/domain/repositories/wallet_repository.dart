import '../entities/wallet_snapshot.dart';

abstract class WalletRepository {
  WalletSnapshot load();
  void save(WalletSnapshot snapshot);
}
