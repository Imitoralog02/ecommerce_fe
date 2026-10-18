import 'voucher_entity.dart';

class WalletSnapshot {
  const WalletSnapshot({
    required this.coinBalance,
    required this.cashBalance,
    required this.memberTier,
    required this.coinsToNextTier,
    required this.tierProgress,
    required this.checkedInToday,
    this.lastCheckInDay,
    required this.vouchers,
    required this.transactions,
  });

  final int coinBalance;
  final double cashBalance;
  final String memberTier;
  final int coinsToNextTier;
  final double tierProgress;
  final bool checkedInToday;
  final String? lastCheckInDay;
  final List<VoucherEntity> vouchers;
  final List<WalletTransactionEntity> transactions;
}
