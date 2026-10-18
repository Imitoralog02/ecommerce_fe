# Lộ trình hoàn thiện frontend NÉORA

Cập nhật: 19/10/2026. Dự án chưa có backend; các đơn hàng, đăng nhập và thanh toán hiện là luồng mock data. Kiến trúc hiện dùng `domain` / `data` / `presentation`, ViewModel với Riverpod và repository qua provider.

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
- [x] Kiểm tra `dart analyze lib test` và 58 Flutter test.

## Việc tiếp theo, theo thứ tự ưu tiên

### 1. Dữ liệu cục bộ và tính nhất quán của demo

- [ ] Rà các hành động còn mô phỏng như xu ngoài voucher, theo dõi đơn, đổi trả và chat; hoàn thiện hành vi mock nhất quán hoặc ghi rõ không khả dụng.
- [ ] Lưu các thay đổi mock còn mất khi khởi động lại: đánh giá, đổi trả, thông báo, sản phẩm đã xem và lịch sử chat theo phạm vi sử dụng mong muốn. Thẻ thanh toán mẫu hiện chỉ tồn tại trong phiên và phải tiếp tục được ghi rõ như vậy.
- [ ] Làm rõ chế độ giả lập offline và chọn ảnh: kiểm tra kết nối hiện luôn trả `true`, chọn ảnh luôn trả asset mẫu. Cung cấp cách thử các trạng thái này trong demo hoặc ghi rõ ở UI.
- [ ] Quyết định phạm vi dữ liệu cá nhân được lưu cục bộ và cách bảo vệ/xoá dữ liệu demo trước khi dùng thông tin thật. Các repository cục bộ hiện chỉ phục vụ bản demo.

### 2. Chất lượng UI và kiến trúc

- [ ] Đưa chuỗi hiển thị còn hardcode vào ARB và hoàn thiện tiếng Việt/Anh trên 28 màn hình. Hiện 9 màn hình gọi `AppLocalizations` trực tiếp.
- [ ] Chuẩn hoá trạng thái loading, rỗng, lỗi và retry cho từng feature; bổ sung trạng thái offline dựa trên kết nối thật khi có tích hợp mạng.
- [ ] Giảm nghiệp vụ còn nằm trong widget, đưa validation và chuyển trạng thái vào use case/ViewModel; giữ `domain` độc lập với Flutter.
- [ ] Rà lại route, tham số điều hướng và hành vi back/deep link cho các luồng mua hàng và tài khoản.
- [ ] Kiểm tra bố cục ở cỡ chữ lớn, màn hình nhỏ, bàn phím và trình đọc màn hình trên toàn bộ màn hình, không chỉ các trường hợp test hiện có.

### 3. Kiểm thử và phát hành

- [ ] Thêm widget/integration test cho hành trình từ sản phẩm → giỏ → địa chỉ → đặt đơn mẫu → lịch sử đơn, cùng các nhánh thất bại. Đã có test repository/ViewModel cho việc khôi phục sau khởi động lại.
- [ ] Kiểm thử trường hợp dữ liệu cục bộ hỏng/phiên bản cũ, voucher hết điều kiện, bấm đặt hàng nhiều lần, điều hướng back và xoay màn hình.
- [ ] Thiết lập CI chạy format, analyze, test và build kiểm tra.
- [ ] Kiểm tra Android/iOS release: khoá ký riêng cho bản phát hành (Android hiện dùng debug signing), tên/icon/splash, quyền truy cập cần thiết, version và smoke test trên thiết bị thật.
- [ ] Bổ sung hướng dẫn chạy demo, dữ liệu mẫu, giới hạn tính năng và quy trình build/release trong README.

## Chờ hợp đồng backend

- [ ] Thay các repository mock bằng data source/API cho tài khoản, catalog, giỏ, địa chỉ, voucher, đơn hàng, thanh toán, thông báo, media và hỗ trợ.
- [ ] Xác định OpenAPI/base URL, xác thực, cấu trúc lỗi, phân trang, retry, đồng bộ dữ liệu và môi trường dev/staging/prod.
- [ ] Chỉ bật thanh toán điện tử, xác thực sinh trắc học/2FA, xoá tài khoản và thông báo đẩy khi có dịch vụ tương ứng và kiểm thử đầu cuối.

Không coi đơn hàng hay tài khoản demo là giao dịch/dữ liệu thật. Các mục chờ backend sẽ được triển khai sau khi có hợp đồng API.
