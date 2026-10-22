# NÉORA — ứng dụng mua sắm thời trang

NÉORA là ứng dụng thương mại thời trang được xây dựng bằng Flutter. Đăng nhập, catalog, giỏ hàng, địa chỉ, wishlist, đặt COD, lịch sử đơn và thông báo đã gọi backend qua API Gateway. Các tính năng ngoài phạm vi COD vẫn là demo; chưa có cổng thanh toán điện tử thật.

Tiến độ và các việc cần làm được theo dõi trong [FRONTEND_ROADMAP.md](FRONTEND_ROADMAP.md).

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

Khởi động backend và hạ tầng theo README của `ecommerce_be` trước khi dùng các luồng API. URL mặc định `http://10.0.2.2:8080/api/v1` dành cho Android emulator. Đổi URL bằng `--dart-define=API_BASE_URL=https://<gateway>/api/v1` khi chạy trên thiết bị hoặc môi trường khác. Android debug cho phép HTTP local; bản phát hành nên dùng HTTPS. Đăng nhập để tải giỏ, địa chỉ, wishlist, đơn và thông báo. Refresh token được lưu bằng `flutter_secure_storage`.

Các lệnh kiểm tra:

```bash
flutter analyze
flutter test
```

Workflow [Flutter CI](.github/workflows/flutter-ci.yml) kiểm tra format, analyze, test và build APK debug cho mỗi lần push hoặc mở pull request. Workflow dùng Flutter 3.44.0; APK debug chỉ để kiểm tra khả năng build, không phải bản phát hành đã ký.

Khi sửa nội dung trong `lib/l10n/app_vi.arb` hoặc `lib/l10n/app_en.arb`, chạy `flutter gen-l10n` để cập nhật mã trong `lib/core/l10n/generated/`.

## Dữ liệu và giới hạn hiện tại

Các repository `Remote...Repository` được dùng cho luồng mua sắm COD chính. Onboarding, một số cài đặt, ví voucher/xu, đánh giá, đổi trả, lịch sử xem/tìm kiếm, chat và phương thức thanh toán mẫu vẫn dùng mock hoặc `shared_preferences`. Quên mật khẩu, tìm kiếm bằng ảnh, chat hỗ trợ và kiểm tra kết nối vẫn là demo. Backend chưa hỗ trợ voucher, xu hay thanh toán điện tử; các lựa chọn này bị khóa ở checkout API. Dữ liệu local còn lại chưa phải kho lưu trữ an toàn cho thông tin cá nhân hoặc thanh toán thật.

Chọn ảnh trong tìm kiếm, đánh giá hoặc đổi trả hiện lấy **ảnh minh họa có sẵn trong app**; ảnh đánh giá/đổi trả khớp với sản phẩm được chọn. Tìm kiếm ảnh chỉ so khớp các asset trong catalog mẫu. Để thử màn mất kết nối, mở **Cá nhân → Cài đặt → Trạng thái demo** và bật **Mô phỏng mất kết nối**. Nút **Thử lại** giữ nguyên màn khi chế độ mẫu còn bật; **Tiếp tục dùng app** sẽ thoát. Trạng thái này chỉ tồn tại trong phiên chạy, không kiểm tra mạng thật và không xóa dữ liệu mẫu.

Ví điện tử và thẻ vẫn hiển thị dữ liệu mẫu trong màn quản lý nhưng không dùng được khi đặt đơn COD thật. Ứng dụng chỉ dùng 4 số cuối cho thẻ thêm vào; không nhận số thẻ đầy đủ hoặc CVV. Giỏ và đơn COD dùng giá do backend trả. `POST /orders` ban đầu có thể trả trạng thái chờ giữ hàng; ứng dụng đọc lại trạng thái và không coi `PENDING` là đã xác nhận.

Voucher trong ví cần được lưu trước khi dùng. Các mã chỉ áp dụng khi đạt đơn tối thiểu, còn hạn và đáp ứng điều kiện hội viên, nhóm sản phẩm hoặc cách giao hàng ghi trên voucher. Một đơn dùng một mã; hoàn xu được cộng sau khi tạo đơn mock, quà tặng được ghi vào chi tiết đơn. Ngày hết hạn mẫu được tạo ở lần mở đầu và lưu cục bộ; sau ngày đó voucher không thể dùng.

Điểm danh thưởng 50 xu một lần theo ngày địa phương của thiết bị. Màn ví tự cập nhật khi qua nửa đêm hoặc khi ứng dụng trở lại, và ngày điểm danh gần nhất được lưu cùng dữ liệu ví.

Flash sale mẫu chạy theo các khung giờ địa phương 09:00–12:00, 12:00–18:00, 18:00–21:00 và 21:00–00:00. Đồng hồ và số suất mẫu được tính theo thời gian, nên mở lại màn hình không đặt lại tiến trình. Giá flash sale hiển thị là giá catalog được đưa vào giỏ; chưa có dịch vụ tồn kho hay thông báo nhắc giờ thực.

Các tính năng demo còn lại có thể được nối backend bằng repository tương ứng trong `lib/features/<feature>/domain/repositories/`. Không đưa API key, khóa ký ứng dụng hoặc thông tin môi trường cá nhân vào Git.

## Lưu ý về Git

`.gitignore` loại file build/cache, cấu hình IDE và máy cục bộ, cũng như khóa ký ứng dụng. `pubspec.lock`, mã localization sinh ra trong `lib/core/l10n/generated/`, cấu hình nền tảng và assets vẫn được theo dõi để các máy có cùng dependencies và tài nguyên.
