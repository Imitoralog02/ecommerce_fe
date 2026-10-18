// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'NÉORA';

  @override
  String get homeTab => 'Trang chủ';

  @override
  String get discoverTab => 'Khám phá';

  @override
  String get notificationsTab => 'Thông báo';

  @override
  String get cartTab => 'Giỏ hàng';

  @override
  String get accountTab => 'Tài khoản';

  @override
  String get backTooltip => 'Quay lại';

  @override
  String get closeTooltip => 'Đóng';

  @override
  String get retryAction => 'Thử lại';

  @override
  String get loadingLabel => 'Đang tải';

  @override
  String get noDataTitle => 'Chưa có dữ liệu';

  @override
  String get newNotificationLabel => 'có thông báo mới';

  @override
  String cartItemCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sản phẩm',
      one: '1 sản phẩm',
      zero: 'không có sản phẩm',
    );
    return '$_temp0';
  }

  @override
  String get checkoutTitle => 'Thanh toán';

  @override
  String get deliveryAddressSection => 'ĐỊA CHỈ GIAO HÀNG';

  @override
  String get shippingMethodSection => 'PHƯƠNG THỨC GIAO HÀNG';

  @override
  String get standardShippingTitle => 'Giao hàng tiêu chuẩn (2–3 ngày)';

  @override
  String get standardShippingSubtitle => 'Miễn phí cho đơn hàng từ 300.000₫';

  @override
  String get expressShippingTitle => 'Giao hàng hỏa tốc (ngày mai)';

  @override
  String get expressShippingSubtitle => 'Ưu tiên xử lý và theo dõi hành trình';

  @override
  String get freeLabel => 'Miễn phí';

  @override
  String get paymentMethodSection => 'PHƯƠNG THỨC THANH TOÁN';

  @override
  String get fastSecurePayment => 'Thanh toán nhanh và bảo mật';

  @override
  String get creditDebitCard => 'Thẻ tín dụng / ghi nợ';

  @override
  String get cashOnDelivery => 'Thanh toán khi nhận hàng';

  @override
  String get cashOnDeliverySubtitle =>
      'Thanh toán tiền mặt khi đơn hàng được giao';

  @override
  String get subtotalLabel => 'Tạm tính';

  @override
  String get shippingFeeLabel => 'Phí vận chuyển';

  @override
  String get taxLabel => 'Thuế';

  @override
  String get taxIncludedLabel => 'Đã bao gồm';

  @override
  String get totalPaymentLabel => 'Tổng thanh toán:';

  @override
  String get placeOrderAction => 'ĐẶT HÀNG';

  @override
  String get checkoutFailedMessage => 'Không thể đặt hàng. Vui lòng thử lại.';

  @override
  String get cardholderLabel => 'CHỦ THẺ';

  @override
  String get expiresLabel => 'HẾT HẠN';

  @override
  String get deliveryTomorrowAtTwo => 'Ngày mai, 14:00';

  @override
  String get deliveryNextTwoToThreeDays => '2–3 ngày tới';

  @override
  String get orderConfirmedTitle => 'Đơn hàng đã được xác nhận';

  @override
  String orderConfirmedThanks(String name) {
    return 'Cảm ơn $name. Những món đồ yêu thích của bạn đang được chuẩn bị.';
  }

  @override
  String get orderNumberLabel => 'Mã đơn hàng';

  @override
  String get paidWithLabel => 'Thanh toán bằng';

  @override
  String get arrivingLabel => 'Dự kiến giao';

  @override
  String get totalLabel => 'Tổng cộng';

  @override
  String get trackOrderAction => 'THEO DÕI ĐƠN HÀNG';

  @override
  String get viewMyOrdersAction => 'XEM ĐƠN MUA CỦA TÔI';

  @override
  String get continueShoppingAction => 'Tiếp tục mua sắm';

  @override
  String get guestAction => 'Khách';

  @override
  String get authLoginSuccess =>
      'Đăng nhập thành công! Chào mừng bạn đến với NÉORA.';

  @override
  String get forgotPasswordTitle => 'Khôi phục mật khẩu';

  @override
  String get createAccountTitle => 'Tạo tài khoản mới';

  @override
  String get welcomeBackTitle => 'Chào mừng bạn trở lại';

  @override
  String get forgotPasswordSubtitle =>
      'Nhập email đã đăng ký để nhận liên kết khôi phục an toàn.';

  @override
  String get registerSubtitle =>
      'Khám phá những bộ sưu tập thời trang cao cấp độc quyền.';

  @override
  String get loginSubtitle =>
      'Đăng nhập để theo dõi đơn hàng, tích điểm VIP và nhận ưu đãi.';

  @override
  String get sendResetLinkAction => 'GỬI LIÊN KẾT ĐẶT LẠI';

  @override
  String get createAccountAction => 'TẠO TÀI KHOẢN';

  @override
  String get loginAction => 'ĐĂNG NHẬP';

  @override
  String get backToLoginAction => '← Quay lại Đăng nhập';

  @override
  String get continueWithLabel => 'HOẶC TIẾP TỤC VỚI';

  @override
  String get fastDeliveryPerk => 'Giao nhanh 2h';

  @override
  String get returnsPerk => 'Đổi trả 30 ngày';

  @override
  String get vipPointsPerk => 'Tích điểm VIP';

  @override
  String get continueAsGuestAction =>
      'Khám phá mua sắm ngay không cần tài khoản';

  @override
  String get registerTab => 'ĐĂNG KÝ';

  @override
  String get recoveryEmailLabel => 'Email nhận mã khôi phục';

  @override
  String get fullNameLabel => 'Họ và tên';

  @override
  String get fullNameHint => 'Nguyễn Văn An';

  @override
  String get emailAddressLabel => 'Địa chỉ Email';

  @override
  String get newPasswordLabel => 'Mật khẩu mới (tối thiểu 6 ký tự)';

  @override
  String get confirmPasswordLabel => 'Xác nhận mật khẩu';

  @override
  String get termsPrefix => 'Tôi đồng ý với ';

  @override
  String get serviceTermsLabel => 'Điều khoản dịch vụ';

  @override
  String get termsConjunction => ' & ';

  @override
  String get privacyPolicyLabel => 'Chính sách bảo mật';

  @override
  String get termsSuffix => ' của NÉORA.';

  @override
  String get accountOrEmailLabel => 'Tài khoản hoặc Email';

  @override
  String get passwordLabel => 'Mật khẩu';

  @override
  String get rememberLoginLabel => 'Ghi nhớ đăng nhập';

  @override
  String get forgotPasswordAction => 'Quên mật khẩu?';

  @override
  String cartTitleCount(String count) {
    return 'Giỏ hàng ($count)';
  }

  @override
  String get clearCartTooltip => 'Xóa giỏ hàng';

  @override
  String get emptyCartTitle => 'Giỏ hàng của bạn đang trống';

  @override
  String get emptyCartSubtitle =>
      'Hãy dạo một vòng và chọn những món đồ xinh xắn\ncho tủ đồ của bạn nhé!';

  @override
  String get startShoppingAction => 'BẮT ĐẦU MUA SẮM';

  @override
  String get loadSampleCartAction => 'Tải giỏ hàng mẫu (2 sản phẩm)';

  @override
  String get freeShippingReached =>
      '🎉 Tuyệt vời! Bạn đã được FREESHIP toàn quốc!';

  @override
  String freeShippingRemaining(int amount) {
    return '🚚 Mua thêm $amount₫ để được FREESHIP!';
  }

  @override
  String removedFromCartMessage(String name) {
    return 'Đã xoá \"$name\" khỏi giỏ hàng';
  }

  @override
  String get deleteAction => 'Xoá';

  @override
  String cartVariantLabel(String size, String color) {
    return 'Size: $size · Màu: $color';
  }

  @override
  String get couponHint => 'Nhập mã ưu đãi (VD: NEORA20, FREESHIP)...';

  @override
  String get couponAppliedMessage => 'Đã áp dụng mã ưu đãi thành công! 🎉';

  @override
  String get applyAction => 'Áp dụng';

  @override
  String get voucherDiscountLabel => 'Giảm giá voucher';

  @override
  String get totalPaymentCartLabel => 'Tổng thanh toán';

  @override
  String proceedToOrderAction(int count) {
    return 'TIẾN HÀNH ĐẶT HÀNG ($count MÓN)';
  }

  @override
  String get displayLanguageLabel => 'Ngôn ngữ hiển thị';

  @override
  String get vietnameseLanguage => 'Tiếng Việt';

  @override
  String get englishLanguage => 'English';

  @override
  String get shopSearchHint => 'Tìm đầm, hoodie, túi xách, giày...';

  @override
  String get categoryAll => 'Tất cả';

  @override
  String get categoryDress => 'Đầm';

  @override
  String get categoryHoodie => 'Hoodie';

  @override
  String get categoryKnitwear => 'Áo len';

  @override
  String get categoryShirt => 'Sơ mi';

  @override
  String get categoryBag => 'Túi';

  @override
  String get categoryShoes => 'Giày';

  @override
  String searchResultsLabel(String query, int count) {
    return '\"$query\" · $count kết quả';
  }

  @override
  String categoryProductsLabel(String category, int count) {
    return '$category · $count sản phẩm';
  }

  @override
  String get filtersAction => 'Bộ lọc';

  @override
  String activeFiltersAction(int count) {
    return 'Bộ lọc ($count)';
  }

  @override
  String get recentSearchesTitle => 'TÌM KIẾM GẦN ĐÂY';

  @override
  String get clearAllAction => 'Xoá tất cả';

  @override
  String get trendingSearchesTitle => 'TỪ KHOÁ XU HƯỚNG THỊNH HÀNH 🔥';

  @override
  String get noMatchingProductsTitle => 'Không tìm thấy sản phẩm phù hợp';

  @override
  String get noMatchingProductsSubtitle =>
      'Hãy thử nới lỏng khoảng giá, xoá bộ lọc màu hoặc tìm kiếm với từ khoá khác nhé.';

  @override
  String get resetFiltersAction => 'Đặt lại bộ lọc';

  @override
  String helloUser(String name) {
    return 'Xin chào, $name 👋';
  }

  @override
  String deliverToAddress(String address) {
    return 'Giao đến: $address ▾';
  }

  @override
  String get defaultDeliveryAddress => 'Quận 1, TP.HCM';

  @override
  String addedProductToCart(String name) {
    return 'Đã thêm \"$name\" vào giỏ hàng 🛒';
  }

  @override
  String get editorialLookbookLabel => 'EDITORIAL LOOKBOOK';

  @override
  String get lookbookSavingLabel => 'Tiết kiệm 15% trọn bộ';

  @override
  String get shopTheLookTitle => 'Shop The Look — Phối Đồ Chuẩn Gu ✨';

  @override
  String get shopTheLookSubtitle =>
      'Chạm để xem các set đồ Parisian & Athleisure >';

  @override
  String get productDetailTitle => 'Chi Tiết Sản Phẩm';

  @override
  String get shareProductTooltip => 'Chia sẻ sản phẩm';

  @override
  String get productShareCopied => 'Đã sao chép thông tin sản phẩm để chia sẻ';

  @override
  String addedSizeToCart(String size) {
    return 'Đã thêm vào giỏ · Size $size 🛒';
  }

  @override
  String get touchToRotate3d => '3D Chạm Xoay';

  @override
  String get authenticImageIndicator => '1 / 4 · Ảnh thật 100%';

  @override
  String reviewCountLabel(int count) {
    return '($count đánh giá)';
  }

  @override
  String soldCountLabel(int count) {
    return 'Đã bán $count';
  }

  @override
  String get freeShippingThresholdPerk => 'Freeship 300k';

  @override
  String get authenticPhotoPerk => 'Ảnh chụp thật';

  @override
  String materialLabel(String material) {
    return 'Chất liệu: $material';
  }

  @override
  String get styleWithNeoraLabel => 'PHỐI ĐỒ CÙNG NÉORA';

  @override
  String get saveFifteenPercentLabel => '• Tiết kiệm 15%';

  @override
  String get styleSuggestionLabel => 'Gợi ý phối đồ hoàn hảo cùng sản phẩm này';

  @override
  String get colorSection => 'MÀU SẮC';

  @override
  String get sizeSection => 'KÍCH THƯỚC';

  @override
  String get sizeGuideAction => 'Bảng size';

  @override
  String get addToCartAction => 'THÊM VÀO GIỎ';

  @override
  String get buyNowAction => 'MUA NGAY';

  @override
  String get wishlistTitle => 'Sản Phẩm Yêu Thích';

  @override
  String get clearWishlistAction => 'Xoá hết';

  @override
  String get viewCartAction => 'Xem giỏ';

  @override
  String addedWishlistProductToCart(String name) {
    return 'Đã thêm \"$name\" vào giỏ hàng!';
  }

  @override
  String get onSaleCategory => 'Đang giảm giá';

  @override
  String get addToCartShortAction => 'Thêm vào giỏ';

  @override
  String get wishlistNoFilterResultsTitle => 'Không tìm thấy sản phẩm';

  @override
  String get emptyWishlistTitle => 'Chưa có sản phẩm yêu thích';

  @override
  String get wishlistNoFilterResultsSubtitle =>
      'Hãy thử chọn phân loại khác để xem các món đồ bạn đã thích.';

  @override
  String get emptyWishlistSubtitle =>
      'Lưu lại những thiết kế bạn say đắm để dễ dàng theo dõi và mua sắm sau nhé.';

  @override
  String get viewAllWishlistAction => 'Xem tất cả yêu thích';

  @override
  String get exploreCollectionAction => 'Khám phá bộ sưu tập ✨';

  @override
  String get authEmailRequiredError => 'Vui lòng nhập địa chỉ email';

  @override
  String get authInvalidEmailError => 'Địa chỉ email không hợp lệ';

  @override
  String get authResetFailedError => 'Không thể gửi yêu cầu. Vui lòng thử lại.';

  @override
  String get authFullNameRequiredError => 'Vui lòng nhập họ và tên của bạn';

  @override
  String get authWeakPasswordError => 'Mật khẩu phải chứa ít nhất 6 ký tự';

  @override
  String get authPasswordMismatchError => 'Mật khẩu xác nhận không khớp';

  @override
  String get authTermsRequiredError =>
      'Vui lòng đồng ý với Điều khoản dịch vụ & Chính sách bảo mật';

  @override
  String get authRegistrationFailedError =>
      'Không thể tạo tài khoản. Vui lòng thử lại.';

  @override
  String get authAccountRequiredError => 'Vui lòng nhập email hoặc tài khoản';

  @override
  String get authPasswordRequiredError => 'Vui lòng nhập mật khẩu';

  @override
  String get authLoginFailedError => 'Đăng nhập thất bại. Vui lòng thử lại.';

  @override
  String authResetLinkSent(String email) {
    return 'Liên kết đặt lại mật khẩu đã được gửi đến $email';
  }

  @override
  String get authRegistrationComplete =>
      'Tạo tài khoản thành công! Bạn có thể đăng nhập ngay.';
}
