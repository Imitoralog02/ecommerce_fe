import 'package:ecommerce_fe/core/network/api_client.dart';
import 'package:ecommerce_fe/core/network/remote_repositories.dart';
import 'package:ecommerce_fe/features/auth/di/auth_providers.dart';
import 'package:ecommerce_fe/features/profile/presentation/views/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _EmptySessionStorage implements SessionStorage {
  @override
  Future<String?> readRefresh() async => null;

  @override
  Future<void> writeRefresh(String? token) async {}
}

void main() {
  testWidgets('guest account does not show demo identity or logout', (
    tester,
  ) async {
    final api = ApiClient(storage: _EmptySessionStorage());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(RemoteAuthRepository(api)),
        ],
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );

    expect(find.text('Bạn chưa đăng nhập'), findsOneWidget);
    expect(find.text('Đăng nhập'), findsOneWidget);
    expect(find.text('Nguyễn Linh'), findsNothing);
    expect(find.text('Đăng xuất tài khoản'), findsNothing);
  });
}
