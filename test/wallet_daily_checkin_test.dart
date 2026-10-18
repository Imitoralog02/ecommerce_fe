import 'dart:convert';

import 'package:ecommerce_fe/features/wallet/data/repositories/shared_preferences_wallet_repository.dart';
import 'package:ecommerce_fe/features/wallet/di/wallet_providers.dart';
import 'package:ecommerce_fe/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'check-in rewards once per local day across midnight and restart',
    () async {
      var now = DateTime(2026, 10, 19, 23, 59);
      final preferences = await SharedPreferences.getInstance();
      ProviderContainer container() => ProviderContainer(
        overrides: [
          walletClockProvider.overrideWithValue(() => now),
          walletRepositoryProvider.overrideWithValue(
            SharedPreferencesWalletRepository(preferences, clock: () => now),
          ),
        ],
      );

      final first = container();
      final initialCoins = first.read(walletViewModelProvider).coinBalance;
      final wallet = first.read(walletViewModelProvider.notifier);
      expect(wallet.checkInDaily(), isTrue);
      expect(wallet.checkInDaily(), isFalse);
      expect(
        first.read(walletViewModelProvider).coinBalance,
        initialCoins + 50,
      );

      now = DateTime(2026, 10, 20, 0, 1);
      wallet.refreshDailyStatus();
      expect(first.read(walletViewModelProvider).checkedInToday, isFalse);
      expect(wallet.checkInDaily(), isTrue);
      expect(
        first.read(walletViewModelProvider).coinBalance,
        initialCoins + 100,
      );
      expect(
        first
            .read(walletViewModelProvider)
            .transactions
            .where((item) => item.id.startsWith('daily_checkin_'))
            .map((item) => item.id)
            .toSet(),
        {'daily_checkin_2026-10-19', 'daily_checkin_2026-10-20'},
      );
      await Future<void>.delayed(Duration.zero);
      first.dispose();

      final second = container();
      addTearDown(second.dispose);
      expect(second.read(walletViewModelProvider).checkedInToday, isTrue);
      expect(
        second.read(walletViewModelProvider.notifier).checkInDaily(),
        isFalse,
      );
      expect(
        second.read(walletViewModelProvider).coinBalance,
        initialCoins + 100,
      );
    },
  );

  test('legacy checked-in flag migrates to a dated check-in', () async {
    final preferences = await SharedPreferences.getInstance();
    final seed = SharedPreferencesWalletRepository(preferences);
    seed.load();
    await Future<void>.delayed(Duration.zero);
    final data = Map<String, dynamic>.from(
      jsonDecode(preferences.getString('demo_wallet_v1')!) as Map,
    );
    data.remove('lastCheckInDay');
    data['checkedInToday'] = true;
    await preferences.setString('demo_wallet_v1', jsonEncode(data));

    final today = SharedPreferencesWalletRepository(
      preferences,
      clock: () => DateTime(2026, 10, 19),
    );
    expect(today.load().checkedInToday, isTrue);
    await Future<void>.delayed(Duration.zero);
    final migrated = Map<String, dynamic>.from(
      jsonDecode(preferences.getString('demo_wallet_v1')!) as Map,
    );
    expect(migrated['lastCheckInDay'], '2026-10-19');

    final tomorrow = SharedPreferencesWalletRepository(
      preferences,
      clock: () => DateTime(2026, 10, 20),
    );
    expect(tomorrow.load().checkedInToday, isFalse);
  });

  testWidgets('wallet state refreshes automatically at midnight', (
    tester,
  ) async {
    var now = DateTime(2026, 10, 19, 23, 59);
    final container = ProviderContainer(
      overrides: [walletClockProvider.overrideWithValue(() => now)],
    );
    final wallet = container.read(walletViewModelProvider.notifier);
    expect(wallet.checkInDaily(), isTrue);
    expect(container.read(walletViewModelProvider).checkedInToday, isTrue);

    now = DateTime(2026, 10, 20, 0, 1);
    await tester.pump(const Duration(minutes: 1));
    expect(container.read(walletViewModelProvider).checkedInToday, isFalse);
    container.dispose();
  });
}
