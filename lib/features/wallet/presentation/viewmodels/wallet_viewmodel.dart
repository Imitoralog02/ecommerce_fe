import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../di/wallet_providers.dart';
import '../../domain/entities/voucher_entity.dart';
import '../../domain/entities/wallet_snapshot.dart';

class WalletState {
  const WalletState({
    this.coinBalance = 0,
    this.cashBalance = 0,
    this.memberTier = '',
    this.coinsToNextTier = 0,
    this.tierProgress = 0,
    this.checkedInToday = false,
    this.vouchers = const [],
    this.transactions = const [],
    this.selectedTab = VoucherType.all,
  });

  factory WalletState.fromSnapshot(WalletSnapshot snapshot) => WalletState(
    coinBalance: snapshot.coinBalance,
    cashBalance: snapshot.cashBalance,
    memberTier: snapshot.memberTier,
    coinsToNextTier: snapshot.coinsToNextTier,
    tierProgress: snapshot.tierProgress,
    checkedInToday: snapshot.checkedInToday,
    vouchers: snapshot.vouchers,
    transactions: snapshot.transactions,
  );

  final int coinBalance;
  final double cashBalance;
  final String memberTier;
  final int coinsToNextTier;
  final double tierProgress;
  final bool checkedInToday;
  final List<VoucherEntity> vouchers;
  final List<WalletTransactionEntity> transactions;
  final VoucherType selectedTab;

  String get formattedCashBalance {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(cashBalance.toInt())}₫';
  }

  String get formattedCoinBalance {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return formatter.format(coinBalance);
  }

  int get savedCount => vouchers.where((voucher) => voucher.isSaved).length;

  int get freeshipCount =>
      vouchers.where((voucher) => voucher.type == VoucherType.shipping).length;

  int get discountCount =>
      vouchers.where((voucher) => voucher.type == VoucherType.discount).length;

  int get vipCount =>
      vouchers.where((voucher) => voucher.type == VoucherType.vipOnly).length;

  List<VoucherEntity> get filteredVouchers {
    switch (selectedTab) {
      case VoucherType.all:
        return vouchers;
      case VoucherType.shipping:
        return vouchers
            .where((voucher) => voucher.type == VoucherType.shipping)
            .toList();
      case VoucherType.discount:
        return vouchers
            .where((voucher) => voucher.type == VoucherType.discount)
            .toList();
      case VoucherType.vipOnly:
        return vouchers
            .where((voucher) => voucher.type == VoucherType.vipOnly)
            .toList();
      case VoucherType.coinReward:
        return vouchers
            .where((voucher) => voucher.type == VoucherType.coinReward)
            .toList();
    }
  }

  WalletSnapshot toSnapshot() => WalletSnapshot(
    coinBalance: coinBalance,
    cashBalance: cashBalance,
    memberTier: memberTier,
    coinsToNextTier: coinsToNextTier,
    tierProgress: tierProgress,
    checkedInToday: checkedInToday,
    vouchers: vouchers,
    transactions: transactions,
  );

  WalletState copyWith({
    int? coinBalance,
    double? cashBalance,
    String? memberTier,
    int? coinsToNextTier,
    double? tierProgress,
    bool? checkedInToday,
    List<VoucherEntity>? vouchers,
    List<WalletTransactionEntity>? transactions,
    VoucherType? selectedTab,
  }) => WalletState(
    coinBalance: coinBalance ?? this.coinBalance,
    cashBalance: cashBalance ?? this.cashBalance,
    memberTier: memberTier ?? this.memberTier,
    coinsToNextTier: coinsToNextTier ?? this.coinsToNextTier,
    tierProgress: tierProgress ?? this.tierProgress,
    checkedInToday: checkedInToday ?? this.checkedInToday,
    vouchers: vouchers ?? this.vouchers,
    transactions: transactions ?? this.transactions,
    selectedTab: selectedTab ?? this.selectedTab,
  );
}

class WalletViewModel extends Notifier<WalletState> {
  @override
  WalletState build() =>
      WalletState.fromSnapshot(ref.read(walletRepositoryProvider).load());

  void _save(WalletState next) {
    ref.read(walletRepositoryProvider).save(next.toSnapshot());
    state = next;
  }

  bool checkInDaily() {
    if (state.checkedInToday) return false;

    final transaction = WalletTransactionEntity(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Điểm danh nhận xu hàng ngày',
      coinDelta: 50,
      date: 'Vừa xong',
      icon: '📅',
    );

    _save(
      state.copyWith(
        coinBalance: state.coinBalance + 50,
        coinsToNextTier: (state.coinsToNextTier - 50).clamp(0, 9999),
        checkedInToday: true,
        transactions: [transaction, ...state.transactions],
      ),
    );
    return true;
  }

  bool addReviewReward(String reviewId) {
    final transactionId = 'review_reward_$reviewId';
    if (state.transactions.any((item) => item.id == transactionId)) {
      return false;
    }

    final transaction = WalletTransactionEntity(
      id: transactionId,
      title: 'Thưởng gửi đánh giá sản phẩm',
      coinDelta: 50,
      date: 'Vừa xong',
      icon: '⭐',
    );
    _save(
      state.copyWith(
        coinBalance: state.coinBalance + 50,
        coinsToNextTier: (state.coinsToNextTier - 50).clamp(0, 9999),
        transactions: [transaction, ...state.transactions],
      ),
    );
    return true;
  }

  void toggleSaveVoucher(String voucherId) {
    final vouchers = state.vouchers.map((voucher) {
      if (voucher.id != voucherId) return voucher;
      return voucher.copyWith(isSaved: !voucher.isSaved);
    }).toList();

    _save(state.copyWith(vouchers: vouchers));
  }

  void selectTab(VoucherType type) {
    state = state.copyWith(selectedTab: type);
  }
}

final walletViewModelProvider = NotifierProvider<WalletViewModel, WalletState>(
  WalletViewModel.new,
);
