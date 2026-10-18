# NÉORA — ứng dụng mua sắm thời trang

NÉORA là ứng dụng thương mại thời trang được xây dựng bằng Flutter. Dự án hiện tập trung vào trải nghiệm giao diện và luồng mua sắm: khám phá sản phẩm, tìm kiếm, giỏ hàng, đặt hàng, theo dõi đơn và quản lý tài khoản. Dữ liệu nghiệp vụ chủ yếu đến từ các repository giả lập trong ứng dụng; dự án chưa kết nối backend hay cổng thanh toán thật.

## Chức năng

| Khu vực | Nội dung |
| --- | --- |
| Bắt đầu | Onboarding và màn hình đăng nhập, đăng ký, đặt lại mật khẩu. |
| Khám phá | Trang chủ, danh mục, lookbook, flash sale, voucher và danh sách sản phẩm. |
| Mua sắm | Tìm kiếm, bộ lọc, tìm bằng ảnh mô phỏng, chi tiết sản phẩm, hướng dẫn chọn cỡ, đánh giá và yêu thích. |
| Đặt hàng | Giỏ hàng, mã giảm giá, địa chỉ, chọn giao hàng và thanh toán, xác nhận đơn. |
| Sau mua | Lịch sử và chi tiết đơn, theo dõi giao hàng, yêu cầu đổi trả, thông báo. |
| Tài khoản | Hồ sơ, phương thức thanh toán, ví voucher, sản phẩm đã xem, cài đặt, trung tâm trợ giúp và chat hỗ trợ mô phỏng. |

Thanh điều hướng chính gồm **Trang chủ**, **Cửa hàng**, **Thông báo**, **Giỏ hàng** và **Cá nhân**. Ứng dụng hỗ trợ tiếng Việt và tiếng Anh.

## Công nghệ và cấu trúc

- Flutter/Dart; yêu cầu Dart SDK `^3.12.0` theo [`pubspec.yaml`](pubspec.yaml).
- `flutter_riverpod` quản lý state và dependency injection; `shared_preferences` lưu trạng thái onboarding và cài đặt cá nhân; `intl` hỗ trợ định dạng.
- Mã nguồn trong `lib/features/` chia theo chức năng. Phần lớn feature tách thành `data/repositories`, `domain` (entity và interface), `di` (provider), `presentation` (viewmodel, view, widget).
- `lib/core/` chứa điều hướng, theme, widget dùng chung, kết nối và chọn ảnh mô phỏng. `assets/` chứa ảnh và font; `lib/l10n/` chứa bản dịch ARB.
- `test/` chứa các bài kiểm tra widget, điều hướng, state/repository, cài đặt, bố cục và khả năng truy cập.

Điểm vào ứng dụng là `lib/main.dart`. Khi khởi động, app kiểm tra cờ onboarding đã lưu để mở onboarding hoặc màn hình chính. `AppRouter` ở `lib/core/navigation/app_router.dart` quản lý các route được đặt tên.

## Chạy dự án

1. Cài Flutter SDK có Dart phù hợp với `pubspec.yaml`, cùng bộ công cụ của nền tảng muốn chạy. Dùng `flutter doctor` để kiểm tra môi trường.
2. Tại thư mục gốc dự án, cài dependencies và chạy app:

   ```bash
   flutter pub get
   flutter run
   ```

3. Nếu có nhiều thiết bị, dùng `flutter devices` rồi `flutter run -d <device-id>`. Dự án có thư mục cấu hình Android, iOS, web, Windows, macOS và Linux; cần công cụ build tương ứng cho từng nền tảng (ví dụ Xcode cho iOS/macOS).

Các lệnh kiểm tra:

```bash
flutter analyze
flutter test
```

Khi sửa nội dung trong `lib/l10n/app_vi.arb` hoặc `lib/l10n/app_en.arb`, chạy `flutter gen-l10n` để cập nhật mã trong `lib/core/l10n/generated/`.

## Dữ liệu và giới hạn hiện tại

Các repository `Mock...Repository` cung cấp catalog, giỏ hàng, đơn hàng, tài khoản, thông báo, thanh toán và các luồng khác. Đăng nhập, tìm kiếm bằng ảnh, chat hỗ trợ, kiểm tra kết nối và đặt hàng đang được mô phỏng. Thao tác đặt hàng không gửi giao dịch tới máy chủ hoặc cổng thanh toán. Phần lớn state từ mock repository chỉ tồn tại trong phiên chạy ứng dụng; riêng onboarding và cài đặt được lưu bằng `shared_preferences`.

Muốn tích hợp backend, triển khai các interface trong `lib/features/<feature>/domain/repositories/` và thay provider tương ứng trong `di/`. Không đưa API key, khóa ký ứng dụng hoặc thông tin môi trường cá nhân vào Git.

## Lưu ý về Git

`.gitignore` loại file build/cache, cấu hình IDE và máy cục bộ, cũng như khóa ký ứng dụng. `pubspec.lock`, mã localization sinh ra trong `lib/core/l10n/generated/`, cấu hình nền tảng và assets vẫn được theo dõi để các máy có cùng dependencies và tài nguyên.
