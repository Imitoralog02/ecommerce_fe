import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/voucher_entity.dart';
import '../../domain/entities/wallet_snapshot.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../../domain/services/wallet_day.dart';
import 'mock_wallet_repository.dart';

class SharedPreferencesWalletRepository implements WalletRepository {
  SharedPreferencesWalletRepository(
    this._preferences, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  static const _key = 'demo_wallet_v1';
  final SharedPreferences _preferences;
  final DateTime Function() _clock;
  WalletSnapshot? _snapshot;

  @override
  WalletSnapshot load() => _snapshot ??= _load();

  WalletSnapshot _load() {
    final raw = _preferences.getString(_key);
    if (raw == null) {
      final seed = MockWalletRepository().load();
      save(seed);
      return seed;
    }
    try {
      final data = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      if (data['version'] != 1) return MockWalletRepository().load();
      final seed = MockWalletRepository().load();
      final storedVouchers = (data['vouchers'] as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
      final vouchers = seed.vouchers.map((voucher) {
        final matches = storedVouchers.where(
          (item) => item['id'] == voucher.id,
        );
        if (matches.isEmpty) return voucher;
        final saved = matches.first;
        return voucher.copyWith(
          isSaved: saved['isSaved'] as bool? ?? voucher.isSaved,
          isUsed: saved['isUsed'] as bool? ?? voucher.isUsed,
          expiryDate: saved['expiryDate'] as String? ?? voucher.expiryDate,
        );
      }).toList();
      final lastCheckInDay =
          data['lastCheckInDay'] as String? ??
          ((data['checkedInToday'] as bool? ?? false)
              ? WalletDay.key(_clock())
              : null);
      final snapshot = WalletSnapshot(
        coinBalance: (data['coinBalance'] as num).toInt(),
        cashBalance: (data['cashBalance'] as num).toDouble(),
        memberTier: data['memberTier'] as String,
        coinsToNextTier: (data['coinsToNextTier'] as num).toInt(),
        tierProgress: (data['tierProgress'] as num).toDouble(),
        checkedInToday: lastCheckInDay == WalletDay.key(_clock()),
        lastCheckInDay: lastCheckInDay,
        vouchers: vouchers,
        transactions: (data['transactions'] as List).map((item) {
          final map = Map<String, dynamic>.from(item as Map);
          return WalletTransactionEntity(
            id: map['id'] as String,
            title: map['title'] as String,
            coinDelta: (map['coinDelta'] as num).toInt(),
            date: map['date'] as String,
            icon: map['icon'] as String,
          );
        }).toList(),
      );
      if (!data.containsKey('lastCheckInDay')) save(snapshot);
      return snapshot;
    } catch (_) {
      return MockWalletRepository().load();
    }
  }

  @override
  void save(WalletSnapshot snapshot) {
    _snapshot = snapshot;
    final data = {
      'version': 1,
      'coinBalance': snapshot.coinBalance,
      'cashBalance': snapshot.cashBalance,
      'memberTier': snapshot.memberTier,
      'coinsToNextTier': snapshot.coinsToNextTier,
      'tierProgress': snapshot.tierProgress,
      'checkedInToday': snapshot.checkedInToday,
      'lastCheckInDay': snapshot.lastCheckInDay,
      'vouchers': snapshot.vouchers
          .map(
            (item) => {
              'id': item.id,
              'isSaved': item.isSaved,
              'isUsed': item.isUsed,
              'expiryDate': item.expiryDate,
            },
          )
          .toList(),
      'transactions': snapshot.transactions
          .map(
            (item) => {
              'id': item.id,
              'title': item.title,
              'coinDelta': item.coinDelta,
              'date': item.date,
              'icon': item.icon,
            },
          )
          .toList(),
    };
    unawaited(_preferences.setString(_key, jsonEncode(data)));
  }
}
