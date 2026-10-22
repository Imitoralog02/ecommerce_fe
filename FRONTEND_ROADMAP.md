# Lộ trình hoàn thiện frontend NÉORA

Cập nhật tích hợp: 23/10/2026. Frontend đã nối API Gateway cho đăng nhập, catalog, giỏ, địa chỉ, wishlist, COD, lịch sử đơn và thông báo. Các mục hoàn thành bên dưới mô tả đợt phát triển demo trước đó; thanh toán điện tử, voucher/xu, tracking chi tiết, review, đổi trả và hỗ trợ vẫn là demo. Kiến trúc dùng `domain` / `data` / `presentation`, ViewModel với Riverpod và repository qua provider.

## Đã hoàn thành trong đợt này

- [x] Tính lại giá giỏ hàng và checkout từ cùng quy tắc: mã hợp lệ, điều kiện đơn tối thiểu, giảm giá hàng, giảm phí giao hàng.
- [x] Phân biệt biến thể sản phẩm theo mã, kích cỡ và màu; xoá đúng biến thể đã chọn.
- [x] Không tạo đơn khi giỏ trống hoặc thiếu địa chỉ; chỉ xoá giỏ sau khi repository trả đơn thành công.
- [x] Tạo đơn demo từ thông tin giỏ, địa chỉ và lựa chọn giao hàng thay vì tạo đơn trong widget.
- [x] Sửa các đường dẫn ảnh không tồn tại trong mã nguồn `lib`.
- [x] Gắn nhãn demo cho checkout và xác thực; không báo đã thu tiền, gửi email, tạo hoặc xoá tài khoản thật.
- [x] Không thu thập số thẻ đầy đủ/CVV; ví và thẻ có dữ liệu mẫu, có thể bật/tắt hoặc thêm/xoá và dùng trong checkout mô phỏng.
- [x] Lưu và khôi phục giỏ hàng, địa chỉ, yêu thích và đơn hàng mẫu qua `shared_preferences`; kiểm tra bằng cách tạo lại ProviderContainer.
- [x] Dùng catalog chung cho sản phẩm được nạp sẵn vào giỏ mẫu; lưu snapshot sản phẩm trong giỏ và đơn đã tạo.
- [x] Chốt chính sách giá mock: biến thể trong giỏ giữ giá từ lần thêm đầu tiên; đơn hàng giữ snapshot khi đặt; catalog đổi giá chỉ áp dụng cho dòng hàng mới.
- [x] Bỏ banner demo và các nút chỉ để trình diễn trên luồng chính: tải giỏ mẫu, dọn cache giả và lối mở màn offline để xem thử.
- [x] Toàn bộ 12 voucher trong ví có quy tắc áp dụng mock: hạn dùng cố định, trạng thái lưu/đã dùng, đơn tối thiểu, quyền hội viên, sản phẩm đủ điều kiện, giới hạn giảm, giao hoả tốc/đơn đầu tiên, hoàn xu và quà tặng. Checkout chặn mã mất điều kiện; đơn ghi lại mã, xu và quà.
- [x] Lưu số dư xu, trạng thái voucher và giao dịch ví vào `shared_preferences`; kiểm tra hoàn xu và khôi phục sau khởi động lại.
- [x] Xu thưởng cập nhật tiến trình hội viên; khi đạt ngưỡng mẫu, hạng Kim Cương và voucher tương ứng có thể sử dụng.
- [x] Điểm danh nhận 50 xu một lần mỗi ngày địa phương; tự mở lại khi qua nửa đêm hoặc quay lại ứng dụng, giữ trạng thái qua khởi động lại và chuyển dữ liệu cờ cũ sang ngày điểm danh.
- [x] Flash sale dùng bốn khung giờ mỗi ngày và suất mẫu theo sản phẩm; đồng hồ tính từ mốc giờ thật, không khởi động lại khi mở màn. Trang chủ và trang flash sale chia sẻ giá, mức giảm và trạng thái suất. Bỏ mã FLASH50, nút nhắc nhở và chia sẻ chưa có hành vi thật.
- [x] Đồng bộ phương thức giao hàng, trạng thái hủy, voucher/xu giữa checkout, đơn hàng và theo dõi; không hiển thị mã vận đơn giả cho đơn chưa có mã.
- [x] Dữ liệu đánh giá mẫu theo đúng sản phẩm; số đánh giá mới, ảnh minh họa và tìm kiếm ảnh mẫu phản ánh sản phẩm được chọn.
- [x] Lưu đánh giá, yêu cầu đổi trả, thông báo đã đọc, lịch sử xem/tìm kiếm, chat và phương thức thanh toán mẫu qua `shared_preferences`.
- [x] Thống nhất chính sách đổi trả 30 ngày và nội dung giao hàng trên các màn chính; kết quả đổi trả và chat nêu rõ giới hạn demo.
- [x] Bỏ số hotline và thao tác gọi giả; sửa các lời hứa về giao nhận, đồng kiểm, bảo mật thẻ và phản hồi nhân viên trên màn trợ giúp, hồ sơ, checkout, thông báo, đánh giá và đổi trả.
- [x] Đối chiếu các khung đầu của Figma: thay ảnh hero Home bằng ảnh cặp đôi và ảnh phối đồ Stylist bằng ảnh nguyên set công sở có sẵn. Giữ nguyên thương hiệu NÉORA.
- [x] Hoàn thiện phần cuối Home bằng thẻ cảm hứng đi chơi, lối vào ví ưu đãi mẫu và nút trở về đầu trang; các lối mở đúng màn hiện có và phần dưới được kiểm tra ở màn 360/390 px cùng cỡ chữ 150%.
- [x] Thêm chế độ mô phỏng mất kết nối trong Cài đặt, chỉ tồn tại trong phiên chạy; có đường thoát rõ ràng, nút thử lại phản ánh đúng trạng thái demo và bố cục cuộn được ở màn 360 px/cỡ chữ 150%. Chặn cập nhật Home sau khi provider đã bị hủy.
- [x] Kiểm tra `flutter analyze --no-pub` và bộ Flutter test hiện tại.

## Việc tiếp theo, theo thứ tự ưu tiên

### 1. Dữ liệu cục bộ và tính nhất quán của demo

- [ ] Rà tiếp toàn bộ nội dung tĩnh và dữ liệu mẫu, kể cả các màn chưa đối chiếu trực quan, để chúng không bị hiểu là giao dịch, nhân viên hay vận chuyển thật.
- [x] Làm rõ chế độ giả lập offline: bật/tắt trong Cài đặt để thử màn mất kết nối; repository trả theo trạng thái mô phỏng. Chưa kiểm tra mạng thật.
- [ ] Bộ chọn ảnh hiện chỉ trả ảnh asset mẫu; đã gắn nhãn ảnh minh họa và khớp với sản phẩm, nhưng chưa thể chọn ảnh từ thiết bị.
- [ ] Quyết định phạm vi dữ liệu cá nhân được lưu cục bộ và cách bảo vệ/xoá dữ liệu demo trước khi dùng thông tin thật. Các repository cục bộ hiện chỉ phục vụ bản demo.
- [ ] Thiết kế giao dịch nguyên tử cho luồng đặt đơn–ví–giỏ khi chuyển sang backend; `shared_preferences` hiện lưu từng phần riêng.

### 2. Chất lượng UI và kiến trúc

- [ ] Đưa chuỗi hiển thị còn hardcode vào ARB và hoàn thiện tiếng Việt/Anh trên 28 màn hình. Hiện 9 màn hình gọi `AppLocalizations` trực tiếp.
- [ ] Đối chiếu trực quan từng màn với Figma trên thiết bị thật, đặc biệt màn nhỏ, bàn phím và cỡ chữ lớn. Các khung đầu đã được đối chiếu trên trình duyệt; ảnh sản phẩm, giá và thứ tự catalog vẫn khác bản thiết kế, cần bộ asset/dữ liệu thiết kế trước khi chốt pixel-level.
- [ ] Chuẩn hoá trạng thái loading, rỗng, lỗi và retry cho từng feature; bổ sung trạng thái offline dựa trên kết nối thật khi có tích hợp mạng.
- [ ] Giảm nghiệp vụ còn nằm trong widget, đưa validation và chuyển trạng thái vào use case/ViewModel; giữ `domain` độc lập với Flutter.
- [ ] Rà lại route, tham số điều hướng và hành vi back/deep link cho các luồng mua hàng và tài khoản.
- [ ] Kiểm tra bố cục ở cỡ chữ lớn, màn hình nhỏ, bàn phím và trình đọc màn hình trên toàn bộ màn hình, không chỉ các trường hợp test hiện có.

### 3. Kiểm thử và phát hành

- [ ] Thêm widget/integration test cho hành trình từ sản phẩm → giỏ → địa chỉ → đặt đơn mẫu → lịch sử đơn, cùng các nhánh thất bại. Đã có test repository/ViewModel cho việc khôi phục sau khởi động lại.
- [ ] Kiểm thử trường hợp dữ liệu cục bộ hỏng/phiên bản cũ, voucher hết điều kiện, bấm đặt hàng nhiều lần, điều hướng back và xoay màn hình.
- [x] Thiết lập CI chạy format, analyze, test và build APK debug bằng Flutter 3.44.0; đã kiểm tra các lệnh tương ứng trên máy phát triển. Cần xác nhận workflow trên GitHub sau khi đẩy mã.
- [ ] Kiểm tra Android/iOS release: khoá ký riêng cho bản phát hành (Android hiện dùng debug signing), tên/icon/splash, quyền truy cập cần thiết, version và smoke test trên thiết bị thật.
- [ ] Bổ sung hướng dẫn chạy demo, dữ liệu mẫu, giới hạn tính năng và quy trình build/release trong README.

## Chờ hợp đồng backend

- [ ] Thay các repository mock bằng data source/API cho tài khoản, catalog, giỏ, địa chỉ, voucher, đơn hàng, thanh toán, thông báo, media và hỗ trợ.
- [ ] Xác định OpenAPI/base URL, xác thực, cấu trúc lỗi, phân trang, retry, đồng bộ dữ liệu và môi trường dev/staging/prod.
- [ ] Chỉ bật thanh toán điện tử, xác thực sinh trắc học/2FA, xoá tài khoản và thông báo đẩy khi có dịch vụ tương ứng và kiểm thử đầu cuối.

Không coi đơn hàng hay tài khoản demo là giao dịch/dữ liệu thật. Các mục chờ backend sẽ được triển khai sau khi có hợp đồng API.
