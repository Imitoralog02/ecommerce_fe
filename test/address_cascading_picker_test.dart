import 'package:ecommerce_fe/features/address/presentation/viewmodels/address_viewmodel.dart';
import 'package:ecommerce_fe/features/address/presentation/views/add_edit_address_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('new address accepts locations outside the preset list', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: AddEditAddressScreen())),
    );
    await tester.pumpAndSettle();

    for (final selection in [
      ('Tỉnh / Thành phố', 'Tỉnh tự nhập'),
      ('Quận / Huyện', 'Huyện tự nhập'),
      ('Phường / Xã', 'Xã tự nhập'),
    ]) {
      await tester.tap(find.text(selection.$1));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, selection.$2);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dùng địa phương tôi nhập: ${selection.$2}'));
      await tester.pumpAndSettle();
      expect(find.text(selection.$2), findsOneWidget);
    }
  });

  testWidgets(
    'AddEditAddressScreen cascades City -> District -> Ward selection accurately',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: AddEditAddressScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // A new address starts without a sample city.
      expect(find.text('TP. Hồ Chí Minh'), findsNothing);

      // 1. Tap Tỉnh / Thành phố and switch to Hà Nội
      await tester.tap(find.text('Tỉnh / Thành phố'));
      await tester.pumpAndSettle();

      expect(find.text('Chọn Tỉnh / Thành phố'), findsWidgets);
      await tester.tap(find.text('Hà Nội').last);
      await tester.pumpAndSettle();

      expect(find.text('Hà Nội'), findsOneWidget);
      expect(find.text('Chọn Quận / Huyện (Hà Nội)'), findsOneWidget);

      // 2. Tap Quận / Huyện and choose Quận Cầu Giấy
      await tester.tap(find.text('Quận / Huyện'));
      await tester.pumpAndSettle();

      expect(find.text('Chọn Quận / Huyện'), findsOneWidget);
      expect(find.text('Thuộc Hà Nội'), findsOneWidget);
      await tester.tap(find.text('Quận Cầu Giấy').last);
      await tester.pumpAndSettle();

      expect(find.text('Quận Cầu Giấy'), findsOneWidget);
      expect(find.text('Chọn Phường / Xã (Quận Cầu Giấy)'), findsOneWidget);

      // 3. Tap Phường / Xã and choose Phường Dịch Vọng Hậu
      await tester.tap(find.text('Phường / Xã'));
      await tester.pumpAndSettle();

      expect(find.text('Chọn Phường / Xã'), findsOneWidget);
      expect(find.text('Thuộc Quận Cầu Giấy, Hà Nội'), findsOneWidget);
      await tester.tap(find.text('Phường Dịch Vọng Hậu').last);
      await tester.pumpAndSettle();

      expect(find.text('Phường Dịch Vọng Hậu'), findsOneWidget);

      // Verify changing City resets District & Ward, then re-select
      await tester.tap(find.text('Tỉnh / Thành phố'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Đà Nẵng').last);
      await tester.pumpAndSettle();

      expect(find.text('Đà Nẵng'), findsOneWidget);
      expect(find.text('Chọn Quận / Huyện (Đà Nẵng)'), findsOneWidget);
      expect(find.text('Chọn Quận / Huyện trước'), findsOneWidget);

      // Select Quận Hải Châu -> Phường Thạch Thang
      await tester.tap(find.text('Quận / Huyện'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Quận Hải Châu').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Phường / Xã'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Phường Thạch Thang').last);
      await tester.pumpAndSettle();

      expect(find.text('Quận Hải Châu'), findsOneWidget);
      expect(find.text('Phường Thạch Thang'), findsOneWidget);

      // 4. Fill recipient name, phone, and street address, then save
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Họ và tên người nhận'),
        'Nguyễn Văn A',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Số điện thoại'),
        '0912345678',
      );
      await tester.enterText(
        find.widgetWithText(
          TextFormField,
          'Địa chỉ cụ thể (Số nhà, đường, toà nhà)',
        ),
        'Số 10 Bạch Đằng',
      );

      await tester.scrollUntilVisible(
        find.text('LƯU ĐỊA CHỈ'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('LƯU ĐỊA CHỈ'));
      await tester.pumpAndSettle();

      final savedAddresses = container.read(addressViewModelProvider).addresses;
      expect(savedAddresses.first.city, 'Đà Nẵng');
      expect(savedAddresses.first.district, 'Quận Hải Châu');
      expect(savedAddresses.first.ward, 'Phường Thạch Thang');
      expect(savedAddresses.first.streetAddress, 'Số 10 Bạch Đằng');
    },
  );
}
