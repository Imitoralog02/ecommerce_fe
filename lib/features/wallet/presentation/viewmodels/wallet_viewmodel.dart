import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../di/wallet_providers.dart';
import '../../domain/entities/voucher_entity.dart';
import '../../domain/entities/wallet_snapshot.dart';
import '../../domain/services/wallet_day.dart';

class WalletState {
  const WalletState({
    this.coinBalance = 0,
    this.cashBalance = 0,
    this.memberTier = '',
    this.coinsToNextTier = 0,
    this.tierProgress = 0,
    this.checkedInToday = false,
    this.lastCheckInDay,
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
    lastCheckInDay: snapshot.lastCheckInDay,
    vouchers: snapshot.vouchers,
    transactions: snapshot.transactions,
  );

  final int coinBalance;
  final double cashBalance;
  final String memberTier;
  final int coinsToNextTier;
  final double tierProgress;
  final bool checkedInToday;
  final String? lastCheckInDay;
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
  int get coinRewardCount => vouchers
      .where((voucher) => voucher.type == VoucherType.coinReward)
      .length;

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
    lastCheckInDay: lastCheckInDay,
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
    String? lastCheckInDay,
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
    lastCheckInDay: lastCheckInDay ?? this.lastCheckInDay,
    vouchers: vouchers ?? this.vouchers,
    transactions: transactions ?? this.transactions,
    selectedTab: selectedTab ?? this.selectedTab,
  );
}

class WalletViewModel extends Notifier<WalletState> {
  Timer? _dayTimer;

  @override
  WalletState build() {
    ref.onDispose(() => _dayTimer?.cancel());
    _scheduleNextDay();
    final loaded = WalletState.fromSnapshot(
      ref.read(walletRepositoryProvider).load(),
    );
    return loaded.copyWith(
      checkedInToday:
          loaded.lastCheckInDay ==
          WalletDay.key(ref.read(walletClockProvider)()),
    );
  }

  void _scheduleNextDay() {
    _dayTimer?.cancel();
    final now = ref.read(walletClockProvider)();
    final delay = WalletDay.nextMidnight(now).difference(now);
    _dayTimer = Timer(
      delay > Duration.zero ? delay : const Duration(seconds: 1),
      () {
        if (!ref.mounted) return;
        refreshDailyStatus();
        _scheduleNextDay();
      },
    );
  }

  void refreshDailyStatus() {
    final checkedInToday =
        state.lastCheckInDay == WalletDay.key(ref.read(walletClockProvider)());
    if (state.checkedInToday != checkedInToday) {
      state = state.copyWith(checkedInToday: checkedInToday);
    }
  }

  void _save(WalletState next) {
    ref.read(walletRepositoryProvider).save(next.toSnapshot());
    state = next;
  }

  WalletState _creditCoins(
    WalletState current,
    int amount,
    WalletTransactionEntity transaction,
  ) {
    final remaining = (current.coinsToNextTier - amount).clamp(0, 9999);
    final reachedDiamond =
        current.memberTier.contains('Kim Cương') || remaining == 0;
    final tierSize = current.tierProgress < 1
        ? current.coinsToNextTier / (1 - current.tierProgress)
        : 0.0;
    return current.copyWith(
      coinBalance: current.coinBalance + amount,
      coinsToNextTier: remaining,
      memberTier: reachedDiamond ? 'Thành viên Kim Cương' : current.memberTier,
      tierProgress: reachedDiamond
          ? 1
          : (current.tierProgress + (tierSize > 0 ? amount / tierSize : 0))
                .clamp(0.0, 1.0),
      transactions: [transaction, ...current.transactions],
    );
  }

  bool checkInDaily() {
    refreshDailyStatus();
    final now = ref.read(walletClockProvider)();
    final day = WalletDay.key(now);
    final transactionId = 'daily_checkin_$day';
    if (state.checkedInToday ||
        state.transactions.any((item) => item.id == transactionId)) {
      return false;
    }

    final transaction = WalletTransactionEntity(
      id: transactionId,
      title: 'Điểm danh nhận xu hàng ngày',
      coinDelta: 50,
      date: DateFormat('dd/MM/yyyy').format(now.toLocal()),
      icon: '📅',
    );

    _save(
      _creditCoins(
        state.copyWith(checkedInToday: true, lastCheckInDay: day),
        50,
        transaction,
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
    _save(_creditCoins(state, 50, transaction));
    return true;
  }

  void completeOrderVoucher(String orderId, String? code, int coinReward) {
    if (code == null) return;
    final transactionId = 'voucher_reward_$orderId';
    if (state.transactions.any((item) => item.id == transactionId)) return;
    if (state.vouchers.any((item) => item.code == code && item.isUsed)) return;
    final vouchers = state.vouchers
        .map(
          (voucher) =>
              voucher.code == code ? voucher.copyWith(isUsed: true) : voucher,
        )
        .toList();
    final transaction = coinReward > 0
        ? WalletTransactionEntity(
            id: transactionId,
            title: 'Hoàn xu voucher đơn hàng #$orderId',
            coinDelta: coinReward,
            date: 'Vừa xong',
            icon: '🛍️',
          )
        : null;
    final next = state.copyWith(vouchers: vouchers);
    _save(
      transaction == null ? next : _creditCoins(next, coinReward, transaction),
    );
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
