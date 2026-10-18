import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In vi, this message translates to:
  /// **'NÉORA'**
  String get appTitle;

  /// No description provided for @homeTab.
  ///
  /// In vi, this message translates to:
  /// **'Trang chủ'**
  String get homeTab;

  /// No description provided for @discoverTab.
  ///
  /// In vi, this message translates to:
  /// **'Khám phá'**
  String get discoverTab;

  /// No description provided for @notificationsTab.
  ///
  /// In vi, this message translates to:
  /// **'Thông báo'**
  String get notificationsTab;

  /// No description provided for @cartTab.
  ///
  /// In vi, this message translates to:
  /// **'Giỏ hàng'**
  String get cartTab;

  /// No description provided for @accountTab.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản'**
  String get accountTab;

  /// No description provided for @backTooltip.
  ///
  /// In vi, this message translates to:
  /// **'Quay lại'**
  String get backTooltip;

  /// No description provided for @closeTooltip.
  ///
  /// In vi, this message translates to:
  /// **'Đóng'**
  String get closeTooltip;

  /// No description provided for @retryAction.
  ///
  /// In vi, this message translates to:
  /// **'Thử lại'**
  String get retryAction;

  /// No description provided for @loadingLabel.
  ///
  /// In vi, this message translates to:
  /// **'Đang tải'**
  String get loadingLabel;

  /// No description provided for @noDataTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có dữ liệu'**
  String get noDataTitle;

  /// No description provided for @newNotificationLabel.
  ///
  /// In vi, this message translates to:
  /// **'có thông báo mới'**
  String get newNotificationLabel;

  /// No description provided for @cartItemCountLabel.
  ///
  /// In vi, this message translates to:
  /// **'{count, plural, =0{không có sản phẩm} =1{1 sản phẩm} other{{count} sản phẩm}}'**
  String cartItemCountLabel(int count);

  /// No description provided for @checkoutTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thanh toán'**
  String get checkoutTitle;

  /// No description provided for @deliveryAddressSection.
  ///
  /// In vi, this message translates to:
  /// **'ĐỊA CHỈ GIAO HÀNG'**
  String get deliveryAddressSection;

  /// No description provided for @shippingMethodSection.
  ///
  /// In vi, this message translates to:
  /// **'PHƯƠNG THỨC GIAO HÀNG'**
  String get shippingMethodSection;

  /// No description provided for @standardShippingTitle.
  ///
  /// In vi, this message translates to:
  /// **'Giao hàng tiêu chuẩn (2–3 ngày)'**
  String get standardShippingTitle;

  /// No description provided for @standardShippingSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Miễn phí cho đơn hàng từ 300.000₫'**
  String get standardShippingSubtitle;

  /// No description provided for @expressShippingTitle.
  ///
  /// In vi, this message translates to:
  /// **'Giao hàng hỏa tốc (ngày mai)'**
  String get expressShippingTitle;

  /// No description provided for @expressShippingSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Ưu tiên xử lý và theo dõi hành trình'**
  String get expressShippingSubtitle;

  /// No description provided for @freeLabel.
  ///
  /// In vi, this message translates to:
  /// **'Miễn phí'**
  String get freeLabel;

  /// No description provided for @paymentMethodSection.
  ///
  /// In vi, this message translates to:
  /// **'PHƯƠNG THỨC THANH TOÁN'**
  String get paymentMethodSection;

  /// No description provided for @fastSecurePayment.
  ///
  /// In vi, this message translates to:
  /// **'Thanh toán nhanh và bảo mật'**
  String get fastSecurePayment;

  /// No description provided for @creditDebitCard.
  ///
  /// In vi, this message translates to:
  /// **'Thẻ tín dụng / ghi nợ'**
  String get creditDebitCard;

  /// No description provided for @cashOnDelivery.
  ///
  /// In vi, this message translates to:
  /// **'Thanh toán khi nhận hàng'**
  String get cashOnDelivery;

  /// No description provided for @cashOnDeliverySubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Thanh toán tiền mặt khi đơn hàng được giao'**
  String get cashOnDeliverySubtitle;

  /// No description provided for @subtotalLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tạm tính'**
  String get subtotalLabel;

  /// No description provided for @shippingFeeLabel.
  ///
  /// In vi, this message translates to:
  /// **'Phí vận chuyển'**
  String get shippingFeeLabel;

  /// No description provided for @taxLabel.
  ///
  /// In vi, this message translates to:
  /// **'Thuế'**
  String get taxLabel;

  /// No description provided for @taxIncludedLabel.
  ///
  /// In vi, this message translates to:
  /// **'Đã bao gồm'**
  String get taxIncludedLabel;

  /// No description provided for @totalPaymentLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tổng thanh toán:'**
  String get totalPaymentLabel;

  /// No description provided for @placeOrderAction.
  ///
  /// In vi, this message translates to:
  /// **'ĐẶT HÀNG'**
  String get placeOrderAction;

  /// No description provided for @checkoutFailedMessage.
  ///
  /// In vi, this message translates to:
  /// **'Không thể đặt hàng. Vui lòng thử lại.'**
  String get checkoutFailedMessage;

  /// No description provided for @cardholderLabel.
  ///
  /// In vi, this message translates to:
  /// **'CHỦ THẺ'**
  String get cardholderLabel;

  /// No description provided for @expiresLabel.
  ///
  /// In vi, this message translates to:
  /// **'HẾT HẠN'**
  String get expiresLabel;

  /// No description provided for @deliveryTomorrowAtTwo.
  ///
  /// In vi, this message translates to:
  /// **'Ngày mai, 14:00'**
  String get deliveryTomorrowAtTwo;

  /// No description provided for @deliveryNextTwoToThreeDays.
  ///
  /// In vi, this message translates to:
  /// **'2–3 ngày tới'**
  String get deliveryNextTwoToThreeDays;

  /// No description provided for @orderConfirmedTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đơn hàng đã được xác nhận'**
  String get orderConfirmedTitle;

  /// No description provided for @orderConfirmedThanks.
  ///
  /// In vi, this message translates to:
  /// **'Cảm ơn {name}. Những món đồ yêu thích của bạn đang được chuẩn bị.'**
  String orderConfirmedThanks(String name);

  /// No description provided for @orderNumberLabel.
  ///
  /// In vi, this message translates to:
  /// **'Mã đơn hàng'**
  String get orderNumberLabel;

  /// No description provided for @paidWithLabel.
  ///
  /// In vi, this message translates to:
  /// **'Thanh toán bằng'**
  String get paidWithLabel;

  /// No description provided for @arrivingLabel.
  ///
  /// In vi, this message translates to:
  /// **'Dự kiến giao'**
  String get arrivingLabel;

  /// No description provided for @totalLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tổng cộng'**
  String get totalLabel;

  /// No description provided for @trackOrderAction.
  ///
  /// In vi, this message translates to:
  /// **'THEO DÕI ĐƠN HÀNG'**
  String get trackOrderAction;

  /// No description provided for @viewMyOrdersAction.
  ///
  /// In vi, this message translates to:
  /// **'XEM ĐƠN MUA CỦA TÔI'**
  String get viewMyOrdersAction;

  /// No description provided for @continueShoppingAction.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục mua sắm'**
  String get continueShoppingAction;

  /// No description provided for @guestAction.
  ///
  /// In vi, this message translates to:
  /// **'Khách'**
  String get guestAction;

  /// No description provided for @authLoginSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập thành công! Chào mừng bạn đến với NÉORA.'**
  String get authLoginSuccess;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In vi, this message translates to:
  /// **'Khôi phục mật khẩu'**
  String get forgotPasswordTitle;

  /// No description provided for @createAccountTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tạo tài khoản mới'**
  String get createAccountTitle;

  /// No description provided for @welcomeBackTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chào mừng bạn trở lại'**
  String get welcomeBackTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Nhập email đã đăng ký để nhận liên kết khôi phục an toàn.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Khám phá những bộ sưu tập thời trang cao cấp độc quyền.'**
  String get registerSubtitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập để theo dõi đơn hàng, tích điểm VIP và nhận ưu đãi.'**
  String get loginSubtitle;

  /// No description provided for @sendResetLinkAction.
  ///
  /// In vi, this message translates to:
  /// **'GỬI LIÊN KẾT ĐẶT LẠI'**
  String get sendResetLinkAction;

  /// No description provided for @createAccountAction.
  ///
  /// In vi, this message translates to:
  /// **'TẠO TÀI KHOẢN'**
  String get createAccountAction;

  /// No description provided for @loginAction.
  ///
  /// In vi, this message translates to:
  /// **'ĐĂNG NHẬP'**
  String get loginAction;

  /// No description provided for @backToLoginAction.
  ///
  /// In vi, this message translates to:
  /// **'← Quay lại Đăng nhập'**
  String get backToLoginAction;

  /// No description provided for @continueWithLabel.
  ///
  /// In vi, this message translates to:
  /// **'HOẶC TIẾP TỤC VỚI'**
  String get continueWithLabel;

  /// No description provided for @fastDeliveryPerk.
  ///
  /// In vi, this message translates to:
  /// **'Giao nhanh 2h'**
  String get fastDeliveryPerk;

  /// No description provided for @returnsPerk.
  ///
  /// In vi, this message translates to:
  /// **'Đổi trả 30 ngày'**
  String get returnsPerk;

  /// No description provided for @vipPointsPerk.
  ///
  /// In vi, this message translates to:
  /// **'Tích điểm VIP'**
  String get vipPointsPerk;

  /// No description provided for @continueAsGuestAction.
  ///
  /// In vi, this message translates to:
  /// **'Khám phá mua sắm ngay không cần tài khoản'**
  String get continueAsGuestAction;

  /// No description provided for @registerTab.
  ///
  /// In vi, this message translates to:
  /// **'ĐĂNG KÝ'**
  String get registerTab;

  /// No description provided for @recoveryEmailLabel.
  ///
  /// In vi, this message translates to:
  /// **'Email nhận mã khôi phục'**
  String get recoveryEmailLabel;

  /// No description provided for @fullNameLabel.
  ///
  /// In vi, this message translates to:
  /// **'Họ và tên'**
  String get fullNameLabel;

  /// No description provided for @fullNameHint.
  ///
  /// In vi, this message translates to:
  /// **'Nguyễn Văn An'**
  String get fullNameHint;

  /// No description provided for @emailAddressLabel.
  ///
  /// In vi, this message translates to:
  /// **'Địa chỉ Email'**
  String get emailAddressLabel;

  /// No description provided for @newPasswordLabel.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu mới (tối thiểu 6 ký tự)'**
  String get newPasswordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận mật khẩu'**
  String get confirmPasswordLabel;

  /// No description provided for @termsPrefix.
  ///
  /// In vi, this message translates to:
  /// **'Tôi đồng ý với '**
  String get termsPrefix;

  /// No description provided for @serviceTermsLabel.
  ///
  /// In vi, this message translates to:
  /// **'Điều khoản dịch vụ'**
  String get serviceTermsLabel;

  /// No description provided for @termsConjunction.
  ///
  /// In vi, this message translates to:
  /// **' & '**
  String get termsConjunction;

  /// No description provided for @privacyPolicyLabel.
  ///
  /// In vi, this message translates to:
  /// **'Chính sách bảo mật'**
  String get privacyPolicyLabel;

  /// No description provided for @termsSuffix.
  ///
  /// In vi, this message translates to:
  /// **' của NÉORA.'**
  String get termsSuffix;

  /// No description provided for @accountOrEmailLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản hoặc Email'**
  String get accountOrEmailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu'**
  String get passwordLabel;

  /// No description provided for @rememberLoginLabel.
  ///
  /// In vi, this message translates to:
  /// **'Ghi nhớ đăng nhập'**
  String get rememberLoginLabel;

  /// No description provided for @forgotPasswordAction.
  ///
  /// In vi, this message translates to:
  /// **'Quên mật khẩu?'**
  String get forgotPasswordAction;

  /// No description provided for @cartTitleCount.
  ///
  /// In vi, this message translates to:
  /// **'Giỏ hàng ({count})'**
  String cartTitleCount(String count);

  /// No description provided for @clearCartTooltip.
  ///
  /// In vi, this message translates to:
  /// **'Xóa giỏ hàng'**
  String get clearCartTooltip;

  /// No description provided for @emptyCartTitle.
  ///
  /// In vi, this message translates to:
  /// **'Giỏ hàng của bạn đang trống'**
  String get emptyCartTitle;

  /// No description provided for @emptyCartSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Hãy dạo một vòng và chọn những món đồ xinh xắn\ncho tủ đồ của bạn nhé!'**
  String get emptyCartSubtitle;

  /// No description provided for @startShoppingAction.
  ///
  /// In vi, this message translates to:
  /// **'BẮT ĐẦU MUA SẮM'**
  String get startShoppingAction;

  /// No description provided for @loadSampleCartAction.
  ///
  /// In vi, this message translates to:
  /// **'Tải giỏ hàng mẫu (2 sản phẩm)'**
  String get loadSampleCartAction;

  /// No description provided for @freeShippingReached.
  ///
  /// In vi, this message translates to:
  /// **'🎉 Tuyệt vời! Bạn đã được FREESHIP toàn quốc!'**
  String get freeShippingReached;

  /// No description provided for @freeShippingRemaining.
  ///
  /// In vi, this message translates to:
  /// **'🚚 Mua thêm {amount}₫ để được FREESHIP!'**
  String freeShippingRemaining(int amount);

  /// No description provided for @removedFromCartMessage.
  ///
  /// In vi, this message translates to:
  /// **'Đã xoá \"{name}\" khỏi giỏ hàng'**
  String removedFromCartMessage(String name);

  /// No description provided for @deleteAction.
  ///
  /// In vi, this message translates to:
  /// **'Xoá'**
  String get deleteAction;

  /// No description provided for @cartVariantLabel.
  ///
  /// In vi, this message translates to:
  /// **'Size: {size} · Màu: {color}'**
  String cartVariantLabel(String size, String color);

  /// No description provided for @couponHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập mã ưu đãi (VD: NEORA20, FREESHIP)...'**
  String get couponHint;

  /// No description provided for @couponAppliedMessage.
  ///
  /// In vi, this message translates to:
  /// **'Đã áp dụng mã ưu đãi thành công! 🎉'**
  String get couponAppliedMessage;

  /// No description provided for @applyAction.
  ///
  /// In vi, this message translates to:
  /// **'Áp dụng'**
  String get applyAction;

  /// No description provided for @voucherDiscountLabel.
  ///
  /// In vi, this message translates to:
  /// **'Giảm giá voucher'**
  String get voucherDiscountLabel;

  /// No description provided for @totalPaymentCartLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tổng thanh toán'**
  String get totalPaymentCartLabel;

  /// No description provided for @proceedToOrderAction.
  ///
  /// In vi, this message translates to:
  /// **'TIẾN HÀNH ĐẶT HÀNG ({count} MÓN)'**
  String proceedToOrderAction(int count);

  /// No description provided for @displayLanguageLabel.
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ hiển thị'**
  String get displayLanguageLabel;

  /// No description provided for @vietnameseLanguage.
  ///
  /// In vi, this message translates to:
  /// **'Tiếng Việt'**
  String get vietnameseLanguage;

  /// No description provided for @englishLanguage.
  ///
  /// In vi, this message translates to:
  /// **'English'**
  String get englishLanguage;

  /// No description provided for @shopSearchHint.
  ///
  /// In vi, this message translates to:
  /// **'Tìm đầm, hoodie, túi xách, giày...'**
  String get shopSearchHint;

  /// No description provided for @categoryAll.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả'**
  String get categoryAll;

  /// No description provided for @categoryDress.
  ///
  /// In vi, this message translates to:
  /// **'Đầm'**
  String get categoryDress;

  /// No description provided for @categoryHoodie.
  ///
  /// In vi, this message translates to:
  /// **'Hoodie'**
  String get categoryHoodie;

  /// No description provided for @categoryKnitwear.
  ///
  /// In vi, this message translates to:
  /// **'Áo len'**
  String get categoryKnitwear;

  /// No description provided for @categoryShirt.
  ///
  /// In vi, this message translates to:
  /// **'Sơ mi'**
  String get categoryShirt;

  /// No description provided for @categoryBag.
  ///
  /// In vi, this message translates to:
  /// **'Túi'**
  String get categoryBag;

  /// No description provided for @categoryShoes.
  ///
  /// In vi, this message translates to:
  /// **'Giày'**
  String get categoryShoes;

  /// No description provided for @searchResultsLabel.
  ///
  /// In vi, this message translates to:
  /// **'\"{query}\" · {count} kết quả'**
  String searchResultsLabel(String query, int count);

  /// No description provided for @categoryProductsLabel.
  ///
  /// In vi, this message translates to:
  /// **'{category} · {count} sản phẩm'**
  String categoryProductsLabel(String category, int count);

  /// No description provided for @filtersAction.
  ///
  /// In vi, this message translates to:
  /// **'Bộ lọc'**
  String get filtersAction;

  /// No description provided for @activeFiltersAction.
  ///
  /// In vi, this message translates to:
  /// **'Bộ lọc ({count})'**
  String activeFiltersAction(int count);

  /// No description provided for @recentSearchesTitle.
  ///
  /// In vi, this message translates to:
  /// **'TÌM KIẾM GẦN ĐÂY'**
  String get recentSearchesTitle;

  /// No description provided for @clearAllAction.
  ///
  /// In vi, this message translates to:
  /// **'Xoá tất cả'**
  String get clearAllAction;

  /// No description provided for @trendingSearchesTitle.
  ///
  /// In vi, this message translates to:
  /// **'TỪ KHOÁ XU HƯỚNG THỊNH HÀNH 🔥'**
  String get trendingSearchesTitle;

  /// No description provided for @noMatchingProductsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy sản phẩm phù hợp'**
  String get noMatchingProductsTitle;

  /// No description provided for @noMatchingProductsSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Hãy thử nới lỏng khoảng giá, xoá bộ lọc màu hoặc tìm kiếm với từ khoá khác nhé.'**
  String get noMatchingProductsSubtitle;

  /// No description provided for @resetFiltersAction.
  ///
  /// In vi, this message translates to:
  /// **'Đặt lại bộ lọc'**
  String get resetFiltersAction;

  /// No description provided for @helloUser.
  ///
  /// In vi, this message translates to:
  /// **'Xin chào, {name} 👋'**
  String helloUser(String name);

  /// No description provided for @deliverToAddress.
  ///
  /// In vi, this message translates to:
  /// **'Giao đến: {address} ▾'**
  String deliverToAddress(String address);

  /// No description provided for @defaultDeliveryAddress.
  ///
  /// In vi, this message translates to:
  /// **'Quận 1, TP.HCM'**
  String get defaultDeliveryAddress;

  /// No description provided for @addedProductToCart.
  ///
  /// In vi, this message translates to:
  /// **'Đã thêm \"{name}\" vào giỏ hàng 🛒'**
  String addedProductToCart(String name);

  /// No description provided for @editorialLookbookLabel.
  ///
  /// In vi, this message translates to:
  /// **'EDITORIAL LOOKBOOK'**
  String get editorialLookbookLabel;

  /// No description provided for @lookbookSavingLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tiết kiệm 15% trọn bộ'**
  String get lookbookSavingLabel;

  /// No description provided for @shopTheLookTitle.
  ///
  /// In vi, this message translates to:
  /// **'Shop The Look — Phối Đồ Chuẩn Gu ✨'**
  String get shopTheLookTitle;

  /// No description provided for @shopTheLookSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Chạm để xem các set đồ Parisian & Athleisure >'**
  String get shopTheLookSubtitle;

  /// No description provided for @productDetailTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chi Tiết Sản Phẩm'**
  String get productDetailTitle;

  /// No description provided for @shareProductTooltip.
  ///
  /// In vi, this message translates to:
  /// **'Chia sẻ sản phẩm'**
  String get shareProductTooltip;

  /// No description provided for @productShareCopied.
  ///
  /// In vi, this message translates to:
  /// **'Đã sao chép thông tin sản phẩm để chia sẻ'**
  String get productShareCopied;

  /// No description provided for @addedSizeToCart.
  ///
  /// In vi, this message translates to:
  /// **'Đã thêm vào giỏ · Size {size} 🛒'**
  String addedSizeToCart(String size);

  /// No description provided for @touchToRotate3d.
  ///
  /// In vi, this message translates to:
  /// **'3D Chạm Xoay'**
  String get touchToRotate3d;

  /// No description provided for @authenticImageIndicator.
  ///
  /// In vi, this message translates to:
  /// **'1 / 4 · Ảnh thật 100%'**
  String get authenticImageIndicator;

  /// No description provided for @reviewCountLabel.
  ///
  /// In vi, this message translates to:
  /// **'({count} đánh giá)'**
  String reviewCountLabel(int count);

  /// No description provided for @soldCountLabel.
  ///
  /// In vi, this message translates to:
  /// **'Đã bán {count}'**
  String soldCountLabel(int count);

  /// No description provided for @freeShippingThresholdPerk.
  ///
  /// In vi, this message translates to:
  /// **'Freeship 300k'**
  String get freeShippingThresholdPerk;

  /// No description provided for @authenticPhotoPerk.
  ///
  /// In vi, this message translates to:
  /// **'Ảnh chụp thật'**
  String get authenticPhotoPerk;

  /// No description provided for @materialLabel.
  ///
  /// In vi, this message translates to:
  /// **'Chất liệu: {material}'**
  String materialLabel(String material);

  /// No description provided for @styleWithNeoraLabel.
  ///
  /// In vi, this message translates to:
  /// **'PHỐI ĐỒ CÙNG NÉORA'**
  String get styleWithNeoraLabel;

  /// No description provided for @saveFifteenPercentLabel.
  ///
  /// In vi, this message translates to:
  /// **'• Tiết kiệm 15%'**
  String get saveFifteenPercentLabel;

  /// No description provided for @styleSuggestionLabel.
  ///
  /// In vi, this message translates to:
  /// **'Gợi ý phối đồ hoàn hảo cùng sản phẩm này'**
  String get styleSuggestionLabel;

  /// No description provided for @colorSection.
  ///
  /// In vi, this message translates to:
  /// **'MÀU SẮC'**
  String get colorSection;

  /// No description provided for @sizeSection.
  ///
  /// In vi, this message translates to:
  /// **'KÍCH THƯỚC'**
  String get sizeSection;

  /// No description provided for @sizeGuideAction.
  ///
  /// In vi, this message translates to:
  /// **'Bảng size'**
  String get sizeGuideAction;

  /// No description provided for @addToCartAction.
  ///
  /// In vi, this message translates to:
  /// **'THÊM VÀO GIỎ'**
  String get addToCartAction;

  /// No description provided for @buyNowAction.
  ///
  /// In vi, this message translates to:
  /// **'MUA NGAY'**
  String get buyNowAction;

  /// No description provided for @wishlistTitle.
  ///
  /// In vi, this message translates to:
  /// **'Sản Phẩm Yêu Thích'**
  String get wishlistTitle;

  /// No description provided for @clearWishlistAction.
  ///
  /// In vi, this message translates to:
  /// **'Xoá hết'**
  String get clearWishlistAction;

  /// No description provided for @viewCartAction.
  ///
  /// In vi, this message translates to:
  /// **'Xem giỏ'**
  String get viewCartAction;

  /// No description provided for @addedWishlistProductToCart.
  ///
  /// In vi, this message translates to:
  /// **'Đã thêm \"{name}\" vào giỏ hàng!'**
  String addedWishlistProductToCart(String name);

  /// No description provided for @onSaleCategory.
  ///
  /// In vi, this message translates to:
  /// **'Đang giảm giá'**
  String get onSaleCategory;

  /// No description provided for @addToCartShortAction.
  ///
  /// In vi, this message translates to:
  /// **'Thêm vào giỏ'**
  String get addToCartShortAction;

  /// No description provided for @wishlistNoFilterResultsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy sản phẩm'**
  String get wishlistNoFilterResultsTitle;

  /// No description provided for @emptyWishlistTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có sản phẩm yêu thích'**
  String get emptyWishlistTitle;

  /// No description provided for @wishlistNoFilterResultsSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Hãy thử chọn phân loại khác để xem các món đồ bạn đã thích.'**
  String get wishlistNoFilterResultsSubtitle;

  /// No description provided for @emptyWishlistSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Lưu lại những thiết kế bạn say đắm để dễ dàng theo dõi và mua sắm sau nhé.'**
  String get emptyWishlistSubtitle;

  /// No description provided for @viewAllWishlistAction.
  ///
  /// In vi, this message translates to:
  /// **'Xem tất cả yêu thích'**
  String get viewAllWishlistAction;

  /// No description provided for @exploreCollectionAction.
  ///
  /// In vi, this message translates to:
  /// **'Khám phá bộ sưu tập ✨'**
  String get exploreCollectionAction;

  /// No description provided for @authEmailRequiredError.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập địa chỉ email'**
  String get authEmailRequiredError;

  /// No description provided for @authInvalidEmailError.
  ///
  /// In vi, this message translates to:
  /// **'Địa chỉ email không hợp lệ'**
  String get authInvalidEmailError;

  /// No description provided for @authResetFailedError.
  ///
  /// In vi, this message translates to:
  /// **'Không thể gửi yêu cầu. Vui lòng thử lại.'**
  String get authResetFailedError;

  /// No description provided for @authFullNameRequiredError.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập họ và tên của bạn'**
  String get authFullNameRequiredError;

  /// No description provided for @authWeakPasswordError.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu phải chứa ít nhất 6 ký tự'**
  String get authWeakPasswordError;

  /// No description provided for @authPasswordMismatchError.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu xác nhận không khớp'**
  String get authPasswordMismatchError;

  /// No description provided for @authTermsRequiredError.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng đồng ý với Điều khoản dịch vụ & Chính sách bảo mật'**
  String get authTermsRequiredError;

  /// No description provided for @authRegistrationFailedError.
  ///
  /// In vi, this message translates to:
  /// **'Không thể tạo tài khoản. Vui lòng thử lại.'**
  String get authRegistrationFailedError;

  /// No description provided for @authAccountRequiredError.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập email hoặc tài khoản'**
  String get authAccountRequiredError;

  /// No description provided for @authPasswordRequiredError.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập mật khẩu'**
  String get authPasswordRequiredError;

  /// No description provided for @authLoginFailedError.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập thất bại. Vui lòng thử lại.'**
  String get authLoginFailedError;

  /// No description provided for @authResetLinkSent.
  ///
  /// In vi, this message translates to:
  /// **'Liên kết đặt lại mật khẩu đã được gửi đến {email}'**
  String authResetLinkSent(String email);

  /// No description provided for @authRegistrationComplete.
  ///
  /// In vi, this message translates to:
  /// **'Tạo tài khoản thành công! Bạn có thể đăng nhập ngay.'**
  String get authRegistrationComplete;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
