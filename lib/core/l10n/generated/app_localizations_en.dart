// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'NÉORA';

  @override
  String get homeTab => 'Home';

  @override
  String get discoverTab => 'Discover';

  @override
  String get notificationsTab => 'Notifications';

  @override
  String get cartTab => 'Cart';

  @override
  String get accountTab => 'Account';

  @override
  String get backTooltip => 'Back';

  @override
  String get closeTooltip => 'Close';

  @override
  String get retryAction => 'Retry';

  @override
  String get loadingLabel => 'Loading';

  @override
  String get noDataTitle => 'No data yet';

  @override
  String get newNotificationLabel => 'has new notifications';

  @override
  String cartItemCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'no items',
    );
    return '$_temp0';
  }

  @override
  String get checkoutTitle => 'Checkout';

  @override
  String get deliveryAddressSection => 'DELIVERY ADDRESS';

  @override
  String get shippingMethodSection => 'SHIPPING METHOD';

  @override
  String get standardShippingTitle => 'Standard delivery (2–3 days)';

  @override
  String get standardShippingSubtitle => 'Free for orders from 300,000₫';

  @override
  String get expressShippingTitle => 'Express delivery (tomorrow)';

  @override
  String get expressShippingSubtitle =>
      'Priority processing with journey tracking';

  @override
  String get freeLabel => 'Free';

  @override
  String get paymentMethodSection => 'PAYMENT METHOD';

  @override
  String get fastSecurePayment => 'Fast and secure payment';

  @override
  String get creditDebitCard => 'Credit / Debit Card';

  @override
  String get cashOnDelivery => 'Cash on delivery';

  @override
  String get cashOnDeliverySubtitle => 'Pay with cash when your order arrives';

  @override
  String get subtotalLabel => 'Subtotal';

  @override
  String get shippingFeeLabel => 'Shipping fee';

  @override
  String get taxLabel => 'Tax';

  @override
  String get taxIncludedLabel => 'Included';

  @override
  String get totalPaymentLabel => 'Total payment:';

  @override
  String get placeOrderAction => 'PLACE ORDER';

  @override
  String get checkoutFailedMessage =>
      'Could not place your order. Please try again.';

  @override
  String get cardholderLabel => 'CARDHOLDER';

  @override
  String get expiresLabel => 'EXPIRES';

  @override
  String get deliveryTomorrowAtTwo => 'Tomorrow, 2:00 PM';

  @override
  String get deliveryNextTwoToThreeDays => 'Within 2–3 days';

  @override
  String get orderConfirmedTitle => 'Order confirmed';

  @override
  String orderConfirmedThanks(String name) {
    return 'Thanks, $name. Your favorite pieces are being prepared.';
  }

  @override
  String get orderNumberLabel => 'Order number';

  @override
  String get paidWithLabel => 'Payment method';

  @override
  String get arrivingLabel => 'Arriving';

  @override
  String get totalLabel => 'Total';

  @override
  String get trackOrderAction => 'TRACK MY ORDER';

  @override
  String get viewMyOrdersAction => 'VIEW MY ORDERS';

  @override
  String get continueShoppingAction => 'Continue shopping';

  @override
  String get guestAction => 'Guest';

  @override
  String get authLoginSuccess =>
      'Entered the NÉORA demo. No real sign-in session was created.';

  @override
  String get forgotPasswordTitle => 'Reset your password';

  @override
  String get createAccountTitle => 'Create an account';

  @override
  String get welcomeBackTitle => 'Welcome back';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your registered email to receive a secure reset link.';

  @override
  String get registerSubtitle =>
      'Discover exclusive premium fashion collections.';

  @override
  String get loginSubtitle =>
      'Sign in to track orders, earn VIP points, and receive offers.';

  @override
  String get sendResetLinkAction => 'SEND RESET LINK';

  @override
  String get createAccountAction => 'CREATE ACCOUNT';

  @override
  String get loginAction => 'SIGN IN';

  @override
  String get backToLoginAction => '← Back to sign in';

  @override
  String get continueWithLabel => 'OR CONTINUE WITH';

  @override
  String get fastDeliveryPerk => '2-hour delivery';

  @override
  String get returnsPerk => '30-day returns';

  @override
  String get vipPointsPerk => 'Earn VIP points';

  @override
  String get continueAsGuestAction => 'Explore and shop without an account';

  @override
  String get registerTab => 'REGISTER';

  @override
  String get recoveryEmailLabel => 'Recovery email';

  @override
  String get fullNameLabel => 'Full name';

  @override
  String get fullNameHint => 'Nguyen Van An';

  @override
  String get emailAddressLabel => 'Email address';

  @override
  String get newPasswordLabel => 'New password (at least 6 characters)';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get termsPrefix => 'I agree to the ';

  @override
  String get serviceTermsLabel => 'Terms of Service';

  @override
  String get termsConjunction => ' & ';

  @override
  String get privacyPolicyLabel => 'Privacy Policy';

  @override
  String get termsSuffix => ' of NÉORA.';

  @override
  String get accountOrEmailLabel => 'Account or email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get rememberLoginLabel => 'Remember me';

  @override
  String get forgotPasswordAction => 'Forgot password?';

  @override
  String cartTitleCount(String count) {
    return 'Cart ($count)';
  }

  @override
  String get clearCartTooltip => 'Clear cart';

  @override
  String get emptyCartTitle => 'Your cart is empty';

  @override
  String get emptyCartSubtitle =>
      'Explore the collection and find something\nyou love for your wardrobe!';

  @override
  String get startShoppingAction => 'START SHOPPING';

  @override
  String get freeShippingReached =>
      '🎉 Great! Your order qualifies for free shipping!';

  @override
  String freeShippingRemaining(int amount) {
    return '🚚 Add $amount₫ more for free shipping!';
  }

  @override
  String removedFromCartMessage(String name) {
    return 'Removed \"$name\" from your cart';
  }

  @override
  String get deleteAction => 'Delete';

  @override
  String cartVariantLabel(String size, String color) {
    return 'Size: $size · Color: $color';
  }

  @override
  String get couponHint => 'Enter promo code (e.g. NEORA20, FREESHIP)...';

  @override
  String get couponAppliedMessage => 'Promo code applied! 🎉';

  @override
  String get couponRejectedMessage =>
      'This promo code is invalid or its conditions are not met.';

  @override
  String get applyAction => 'Apply';

  @override
  String get voucherDiscountLabel => 'Voucher discount';

  @override
  String get totalPaymentCartLabel => 'Total payment';

  @override
  String get shippingCalculatedAtCheckoutLabel => 'Calculated at checkout';

  @override
  String get cartTotalBeforeShippingLabel => 'Subtotal after discounts';

  @override
  String proceedToOrderAction(int count) {
    return 'PROCEED TO CHECKOUT ($count ITEMS)';
  }

  @override
  String get displayLanguageLabel => 'Display language';

  @override
  String get vietnameseLanguage => 'Tiếng Việt';

  @override
  String get englishLanguage => 'English';

  @override
  String get shopSearchHint => 'Search dresses, hoodies, bags, shoes...';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryDress => 'Dresses';

  @override
  String get categoryHoodie => 'Hoodies';

  @override
  String get categoryKnitwear => 'Knitwear';

  @override
  String get categoryShirt => 'Shirts';

  @override
  String get categoryBag => 'Bags';

  @override
  String get categoryShoes => 'Shoes';

  @override
  String searchResultsLabel(String query, int count) {
    return '\"$query\" · $count results';
  }

  @override
  String categoryProductsLabel(String category, int count) {
    return '$category · $count products';
  }

  @override
  String get filtersAction => 'Filters';

  @override
  String activeFiltersAction(int count) {
    return 'Filters ($count)';
  }

  @override
  String get recentSearchesTitle => 'RECENT SEARCHES';

  @override
  String get clearAllAction => 'Clear all';

  @override
  String get trendingSearchesTitle => 'TRENDING SEARCHES 🔥';

  @override
  String get noMatchingProductsTitle => 'No matching products';

  @override
  String get noMatchingProductsSubtitle =>
      'Try widening the price range, clearing the color filter, or using another keyword.';

  @override
  String get resetFiltersAction => 'Reset filters';

  @override
  String helloUser(String name) {
    return 'Hello, $name 👋';
  }

  @override
  String deliverToAddress(String address) {
    return 'Deliver to: $address ▾';
  }

  @override
  String get defaultDeliveryAddress => 'District 1, Ho Chi Minh City';

  @override
  String addedProductToCart(String name) {
    return 'Added \"$name\" to your cart 🛒';
  }

  @override
  String get editorialLookbookLabel => 'EDITORIAL LOOKBOOK';

  @override
  String get lookbookSavingLabel => 'Save 15% on the complete look';

  @override
  String get shopTheLookTitle => 'Shop The Look — Styled For You ✨';

  @override
  String get shopTheLookSubtitle =>
      'Tap to explore Parisian & Athleisure looks >';

  @override
  String get productDetailTitle => 'Product Details';

  @override
  String get shareProductTooltip => 'Share product';

  @override
  String get productShareCopied => 'Product information copied for sharing';

  @override
  String addedSizeToCart(String size) {
    return 'Added to cart · Size $size 🛒';
  }

  @override
  String get touchToRotate3d => 'Touch to rotate 3D';

  @override
  String get authenticImageIndicator => '1 / 4 · 100% authentic photo';

  @override
  String reviewCountLabel(int count) {
    return '($count reviews)';
  }

  @override
  String soldCountLabel(int count) {
    return '$count sold';
  }

  @override
  String get freeShippingThresholdPerk => 'Free shipping over 300k';

  @override
  String get authenticPhotoPerk => 'Authentic photos';

  @override
  String materialLabel(String material) {
    return 'Material: $material';
  }

  @override
  String get styleWithNeoraLabel => 'STYLE WITH NÉORA';

  @override
  String get saveFifteenPercentLabel => '• Save 15%';

  @override
  String get styleSuggestionLabel => 'Find the perfect look for this product';

  @override
  String get colorSection => 'COLOR';

  @override
  String get sizeSection => 'SIZE';

  @override
  String get sizeGuideAction => 'Size guide';

  @override
  String get addToCartAction => 'ADD TO CART';

  @override
  String get buyNowAction => 'BUY NOW';

  @override
  String get wishlistTitle => 'Wishlist';

  @override
  String get clearWishlistAction => 'Clear all';

  @override
  String get viewCartAction => 'View cart';

  @override
  String addedWishlistProductToCart(String name) {
    return 'Added \"$name\" to your cart!';
  }

  @override
  String get onSaleCategory => 'On sale';

  @override
  String get addToCartShortAction => 'Add to cart';

  @override
  String get wishlistNoFilterResultsTitle => 'No products found';

  @override
  String get emptyWishlistTitle => 'Your wishlist is empty';

  @override
  String get wishlistNoFilterResultsSubtitle =>
      'Try another category to see the items you saved.';

  @override
  String get emptyWishlistSubtitle =>
      'Save the designs you love so you can easily find and shop them later.';

  @override
  String get viewAllWishlistAction => 'View all favorites';

  @override
  String get exploreCollectionAction => 'Explore the collection ✨';

  @override
  String get authEmailRequiredError => 'Please enter your email address';

  @override
  String get authInvalidEmailError => 'Please enter a valid email address';

  @override
  String get authResetFailedError =>
      'Could not send the request. Please try again.';

  @override
  String get authFullNameRequiredError => 'Please enter your full name';

  @override
  String get authWeakPasswordError =>
      'Password must contain at least 6 characters';

  @override
  String get authPasswordMismatchError =>
      'The confirmation password does not match';

  @override
  String get authTermsRequiredError =>
      'Please accept the Terms of Service & Privacy Policy';

  @override
  String get authRegistrationFailedError =>
      'Could not create your account. Please try again.';

  @override
  String get authAccountRequiredError => 'Please enter your email or account';

  @override
  String get authPasswordRequiredError => 'Please enter your password';

  @override
  String get authLoginFailedError => 'Sign in failed. Please try again.';

  @override
  String authResetLinkSent(String email) {
    return 'The demo did not send a password reset email to $email.';
  }

  @override
  String get authRegistrationComplete =>
      'Registration was simulated. No account was created.';

  @override
  String get demoOrderNotice => 'Saved on this device; not sent to a store.';

  @override
  String get paymentUnavailableLabel => 'Set up to use';

  @override
  String get mockPaymentLabel => 'Simulated payment';

  @override
  String mockCardEnding(String lastFour) {
    return 'Simulated card •••• $lastFour';
  }

  @override
  String get deviceWalletPaymentTitle => 'Apple Pay / Google Pay';

  @override
  String get managePaymentMethodsAction => 'Manage payment methods';
}
