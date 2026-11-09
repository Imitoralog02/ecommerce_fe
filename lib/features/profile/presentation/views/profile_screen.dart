import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/network/remote_repositories.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../address/presentation/viewmodels/address_viewmodel.dart';
import '../../../address/presentation/views/address_book_screen.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../../auth/presentation/views/auth_screen.dart';
import '../../../cart/presentation/viewmodels/cart_viewmodel.dart';
import '../../../cart/presentation/views/cart_screen.dart';
import '../../../history/presentation/views/recently_viewed_screen.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/presentation/viewmodels/order_viewmodel.dart';
import '../../../orders/presentation/views/order_history_screen.dart';
import '../../../settings/domain/entities/user_settings.dart';
import '../../../settings/presentation/viewmodels/settings_viewmodel.dart';
import '../../../settings/presentation/views/settings_screen.dart';
import '../../../shop/presentation/views/lookbook_screen.dart';
import '../../../support/presentation/views/help_center_screen.dart';
import '../../../wishlist/presentation/viewmodels/wishlist_viewmodel.dart';
import '../../../wishlist/presentation/views/wishlist_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Interactive Size & Body Profile state for Personal Stylist
  int _heightCm = 165;
  int _weightKg = 52;
  String _topSize = 'M';
  String _bottomSize = 'M';
  String _shoeSize = '37';
  String _fitPreference = 'Tôn dáng vừa vặn';
  bool _hasCustomBodyProfile = false;

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'NA';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  String get _recommendedSize {
    if (_weightKg < 47) return 'S';
    if (_weightKg <= 55) return 'M';
    if (_weightKg <= 63) return 'L';
    return 'XL';
  }

  @override
  Widget build(BuildContext context) {
    final remoteMode = ref.read(authRepositoryProvider) is RemoteAuthRepository;
    final authState = ref.watch(authViewModelProvider);
    final cartCount = ref.watch(cartViewModelProvider).totalItemCount;

    if (remoteMode && !authState.isAuthenticated) {
      return _buildGuestProfileScreen(context, cartCount: cartCount);
    }

    final userSettings = ref.watch(settingsViewModelProvider);
    final wishlistCount = ref.watch(wishlistViewModelProvider).items.length;
    final orderState = ref.watch(orderViewModelProvider);
    final addressState = ref.watch(addressViewModelProvider);

    final profile = userSettings.profile;
    final displayName = profile.name.trim().isNotEmpty
        ? profile.name.trim()
        : (authState.fullName.trim().isNotEmpty
              ? authState.fullName.trim()
              : 'Thành viên NÉORA');
    final displayContact = profile.phone.trim().isNotEmpty
        ? profile.phone.trim()
        : (profile.email.trim().isNotEmpty
              ? profile.email.trim()
              : (authState.email.trim().isNotEmpty
                    ? authState.email.trim()
                    : 'Chưa cập nhật số điện thoại'));

    // Dynamic 4-stage order counts matching Figma layout
    final pendingCount = orderState
        .getOrdersByStatus(OrderStatus.pendingConfirmation)
        .length;
    final processingCount = orderState
        .getOrdersByStatus(OrderStatus.processing)
        .length;
    final shippingCount = orderState
        .getOrdersByStatus(OrderStatus.shipping)
        .length;
    final deliveredCount = orderState
        .getOrdersByStatus(OrderStatus.delivered)
        .length;

    final selectedAddress = addressState.selectedAddress;
    final addressHeaderLine = selectedAddress != null
        ? '${selectedAddress.label} • ${selectedAddress.isDefault ? 'Mặc định' : 'Đã lưu'}'
        : null;
    final defaultAddress =
        selectedAddress?.fullAddress ?? 'Chưa thiết lập địa chỉ mặc định';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Minimalist Brand Masthead: NÉORA | MẶC ĐẸP MỖI NGÀY | Bag
              _buildTopMasthead(context, cartCount: cartCount),
              const SizedBox(height: 10),

              // 2. Editorial Page Headline
              const Text(
                'Cá nhân',
                style: TextStyle(
                  fontFamily: AppTypography.serifFont,
                  fontSize: 27,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.3,
                  height: 1.15,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),

              // 3. Clean Editorial Identity Row (Avatar + Name + Contact + Edit)
              _buildProfileIdentityRow(
                context,
                initials: _initials(displayName),
                name: displayName,
                contact: displayContact,
                onEditProfile: () => _showQuickEditProfileSheet(context),
              ),
              const SizedBox(height: 20),

              // 4. Đơn hàng của tôi (4 clean open-canvas status icons + badges)
              _buildOrdersSection(
                context,
                pendingCount: pendingCount,
                processingCount: processingCount,
                shippingCount: shippingCount,
                deliveredCount: deliveredCount,
              ),
              const SizedBox(height: 16),

              // Thin section divider below order strip
              Container(height: 1, color: AppColors.divider),
              const SizedBox(height: 16),

              // 5. 2-Column Saved & Wishlist White Bento Cards
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _buildCollectionCard(
                        icon: Icons.favorite_border_rounded,
                        title: 'Sản phẩm yêu thích',
                        subtitle: '$wishlistCount sản phẩm',
                        onTap: () => Navigator.push(
                          context,
                          AppRouter.page(
                            builder: (_) => const WishlistScreen(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildCollectionCard(
                        icon: Icons.bookmark_border_rounded,
                        title: 'Outfit đã lưu',
                        subtitle: '4 bản phối',
                        onTap: () => Navigator.push(
                          context,
                          AppRouter.page(
                            builder: (_) => const LookbookScreen(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 6. Soft Sage Personal Stylist Card
              _buildStylistProfileCard(context),
              const SizedBox(height: 20),

              // 7. TÀI KHOẢN & HỖ TRỢ (Open editorial divider list)
              const Text(
                'TÀI KHOẢN & HỖ TRỢ',
                style: TextStyle(
                  fontFamily: AppTypography.sansFont,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              _buildEditorialMenuRow(
                icon: Icons.location_on_outlined,
                title: 'Địa chỉ nhận hàng',
                subtitleLine1: addressHeaderLine,
                subtitleLine2: defaultAddress,
                onTap: () => Navigator.push(
                  context,
                  AppRouter.page(builder: (_) => const AddressBookScreen()),
                ),
              ),
              const Divider(height: 1, color: AppColors.divider),
              _buildEditorialMenuRow(
                icon: Icons.tune_rounded,
                title: 'Cài đặt tài khoản',
                subtitleLine1: 'Bảo mật, thông báo và quyền riêng tư',
                onTap: () => Navigator.push(
                  context,
                  AppRouter.page(builder: (_) => const SettingsScreen()),
                ),
              ),
              const Divider(height: 1, color: AppColors.divider),
              _buildEditorialMenuRow(
                icon: Icons.headset_mic_outlined,
                title: 'Hỗ trợ từ NÉORA',
                subtitleLine1: 'Liên hệ hỗ trợ • Đổi trả • Câu hỏi thường gặp',
                onTap: () => Navigator.push(
                  context,
                  AppRouter.page(builder: (_) => const HelpCenterScreen()),
                ),
              ),
              const Divider(height: 1, color: AppColors.divider),
              _buildLogoutRow(onTap: () => _confirmLogout(context)),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // GUEST PROFILE VIEW
  // ==========================================

  Widget _buildGuestProfileScreen(
    BuildContext context, {
    required int cartCount,
  }) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopMasthead(context, cartCount: cartCount),
              const SizedBox(height: 14),
              const Text(
                'Cá nhân',
                style: TextStyle(
                  fontFamily: AppTypography.serifFont,
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.3,
                  height: 1.15,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 18),

              // Editorial Guest Card in NÉORA Soft Sage Palette
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAEDE4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFDFE4D7),
                    width: 0.8,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.auto_awesome_outlined,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'KHÔNG GIAN THÀNH VIÊN',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: AppTypography.sansFont,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Bạn chưa đăng nhập',
                      style: TextStyle(
                        fontFamily: AppTypography.serifFont,
                        fontSize: 21,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Đăng nhập để theo dõi đơn hàng, lưu bản phối yêu thích và nhận gợi ý số đo vừa vặn.',
                      style: TextStyle(
                        fontFamily: AppTypography.sansFont,
                        fontSize: 12.5,
                        height: 1.45,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              ref
                                  .read(authViewModelProvider.notifier)
                                  .switchTab(AuthTab.login);
                              Navigator.push(
                                context,
                                AppRouter.page(
                                  builder: (_) => const AuthScreen(),
                                ),
                              );
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Đăng nhập',
                              style: TextStyle(
                                fontFamily: AppTypography.sansFont,
                                fontWeight: FontWeight.w600,
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              ref
                                  .read(authViewModelProvider.notifier)
                                  .switchTab(AuthTab.register);
                              Navigator.push(
                                context,
                                AppRouter.page(
                                  builder: (_) => const AuthScreen(),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.7,
                              ),
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Tạo tài khoản',
                              style: TextStyle(
                                fontFamily: AppTypography.sansFont,
                                fontWeight: FontWeight.w600,
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'TIỆN ÍCH KHÁM PHÁ',
                style: TextStyle(
                  fontFamily: AppTypography.sansFont,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              _buildEditorialMenuRow(
                icon: Icons.auto_awesome_outlined,
                title: 'Lookbook & Gợi ý phối đồ',
                subtitleLine1: 'Khám phá các bản phối theo dịp',
                onTap: () => Navigator.push(
                  context,
                  AppRouter.page(builder: (_) => const LookbookScreen()),
                ),
              ),
              const Divider(height: 1, color: AppColors.divider),
              _buildEditorialMenuRow(
                icon: Icons.history_rounded,
                title: 'Sản phẩm đã xem gần đây',
                subtitleLine1: 'Xem lại các thiết kế vừa khám phá',
                onTap: () => Navigator.push(
                  context,
                  AppRouter.page(builder: (_) => const RecentlyViewedScreen()),
                ),
              ),
              const Divider(height: 1, color: AppColors.divider),
              _buildEditorialMenuRow(
                icon: Icons.headset_mic_outlined,
                title: 'Hỗ trợ từ NÉORA',
                subtitleLine1: 'Liên hệ hỗ trợ • Đổi trả • Câu hỏi thường gặp',
                onTap: () => Navigator.push(
                  context,
                  AppRouter.page(builder: (_) => const HelpCenterScreen()),
                ),
              ),
              const Divider(height: 1, color: AppColors.divider),
              _buildEditorialMenuRow(
                icon: Icons.tune_rounded,
                title: 'Cài đặt ứng dụng',
                subtitleLine1: 'Ngôn ngữ hiển thị & Điều khoản',
                onTap: () => Navigator.push(
                  context,
                  AppRouter.page(builder: (_) => const SettingsScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET BUILDERS (FIGMA NODE 20-624)
  // ==========================================

  Widget _buildTopMasthead(BuildContext context, {required int cartCount}) {
    return Row(
      children: [
        Text(
          'NÉORA',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textScaler: MediaQuery.textScalerOf(
            context,
          ).clamp(maxScaleFactor: 1.3),
          style: AppTypography.brandLogo,
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Center(
            child: Text(
              'MẶC ĐẸP MỖI NGÀY',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppTypography.sansFont,
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.4,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              tooltip: 'Giỏ hàng',
              onPressed: () {
                Navigator.push(
                  context,
                  AppRouter.page(builder: (_) => const CartScreen()),
                );
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              icon: const Icon(
                Icons.shopping_bag_outlined,
                size: 21,
                color: AppColors.textPrimary,
              ),
            ),
            if (cartCount > 0)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1.5,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 15,
                    minHeight: 15,
                  ),
                  child: Center(
                    child: Text(
                      '$cartCount',
                      style: const TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileIdentityRow(
    BuildContext context, {
    required String initials,
    required String name,
    required String contact,
    required VoidCallback onEditProfile,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onEditProfile,
          child: Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFEBE7DE),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(
                fontFamily: AppTypography.serifFont,
                fontSize: 19,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.4,
                color: Color(0xFF4B5542),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: AppTypography.sansFont,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                contact,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: AppTypography.sansFont,
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 5),
              GestureDetector(
                onTap: onEditProfile,
                behavior: HitTestBehavior.opaque,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        'Chỉnh sửa hồ sơ',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTypography.sansFont,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    SizedBox(width: 5),
                    Icon(
                      Icons.edit_outlined,
                      size: 13.5,
                      color: AppColors.textPrimary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersSection(
    BuildContext context, {
    required int pendingCount,
    required int processingCount,
    required int shippingCount,
    required int deliveredCount,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Đơn hàng của tôi',
                style: TextStyle(
                  fontFamily: AppTypography.sansFont,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  AppRouter.page(
                    builder: (_) => const OrderHistoryScreen(initialTabIndex: 0),
                  ),
                );
              },
              behavior: HitTestBehavior.opaque,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Xem tất cả',
                    style: TextStyle(
                      fontFamily: AppTypography.sansFont,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildOrderStatusItem(
                context,
                title: 'Chờ xác nhận',
                icon: Icons.assignment_turned_in_outlined,
                count: pendingCount,
                tabIndex: 1,
              ),
            ),
            Expanded(
              child: _buildOrderStatusItem(
                context,
                title: 'Chờ giao',
                icon: Icons.inventory_2_outlined,
                count: processingCount,
                tabIndex: 2,
              ),
            ),
            Expanded(
              child: _buildOrderStatusItem(
                context,
                title: 'Đang giao',
                icon: Icons.local_shipping_outlined,
                count: shippingCount,
                tabIndex: 3,
              ),
            ),
            Expanded(
              child: _buildOrderStatusItem(
                context,
                title: 'Đánh giá',
                icon: Icons.chat_bubble_outline_rounded,
                count: deliveredCount,
                tabIndex: 4,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrderStatusItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required int count,
    required int tabIndex,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          AppRouter.page(
            builder: (_) => OrderHistoryScreen(initialTabIndex: tabIndex),
          ),
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Icon(
                  icon,
                  size: 24,
                  color: const Color(0xFF474E3E),
                ),
              ),
              if (count > 0)
                Positioned(
                  top: -4,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4.5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.background,
                        width: 1.5,
                      ),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 17,
                      minHeight: 17,
                    ),
                    child: Center(
                      child: Text(
                        '$count',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: AppTypography.sansFont,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              title,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: AppTypography.sansFont,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(13, 12, 11, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.cardBorder, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 19, color: const Color(0xFF4A5042)),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 17,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppTypography.sansFont,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppTypography.sansFont,
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStylistProfileCard(BuildContext context) {
    final styleSubtitle = _hasCustomBodyProfile
        ? '$_fitPreference • ${_heightCm}cm, ${_weightKg}kg'
        : 'Tối giản • Tông màu trung tính';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        AppRouter.page(builder: (_) => const LookbookScreen()),
      ),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 15),
        decoration: BoxDecoration(
          color: const Color(0xFFEAEDE4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFDFE4D7), width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.auto_awesome_outlined,
                        size: 14.5,
                        color: Color(0xFF4B5740),
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'STYLIST CỦA RIÊNG BẠN',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppTypography.sansFont,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            color: Color(0xFF4B5740),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _showUpdateBodyProfileSheet(context),
                  behavior: HitTestBehavior.opaque,
                  child: const Text(
                    'Cập nhật',
                    style: TextStyle(
                      fontFamily: AppTypography.sansFont,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Hiểu bạn, để chọn đúng.',
              style: TextStyle(
                fontFamily: AppTypography.serifFont,
                fontSize: 21,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.2,
                height: 1.2,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              styleSubtitle,
              style: const TextStyle(
                fontFamily: AppTypography.sansFont,
                fontSize: 12.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _buildStylePill('Áo · $_topSize'),
                _buildStylePill('Quần · $_bottomSize'),
                const Text(
                  'Gợi ý vừa vặn hơn',
                  style: TextStyle(
                    fontFamily: AppTypography.sansFont,
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStylePill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
      decoration: BoxDecoration(
        color: const Color(0xFFEAEDE4),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFC8CEC0), width: 1),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: AppTypography.sansFont,
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildEditorialMenuRow({
    required IconData icon,
    required String title,
    String? subtitleLine1,
    String? subtitleLine2,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: const Color(0xFF474D40)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: AppTypography.sansFont,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subtitleLine1 != null) ...[
                    const SizedBox(height: 2.5),
                    Text(
                      subtitleLine1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppTypography.sansFont,
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                  if (subtitleLine2 != null) ...[
                    const SizedBox(height: 1.5),
                    Text(
                      subtitleLine2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppTypography.sansFont,
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutRow({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            Icon(
              Icons.logout_rounded,
              size: 20,
              color: AppColors.textSecondary,
            ),
            SizedBox(width: 14),
            Text(
              'Đăng xuất',
              style: TextStyle(
                fontFamily: AppTypography.sansFont,
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // INTERACTIVE MODALS (EDIT PROFILE & SIZE)
  // ==========================================

  void _showQuickEditProfileSheet(BuildContext context) {
    final currentProfile = ref.read(settingsViewModelProvider).profile;
    final authState = ref.read(authViewModelProvider);
    final nameCtrl = TextEditingController(
      text: currentProfile.name.isNotEmpty
          ? currentProfile.name
          : authState.fullName,
    );
    final phoneCtrl = TextEditingController(text: currentProfile.phone);
    final emailCtrl = TextEditingController(
      text: currentProfile.email.isNotEmpty
          ? currentProfile.email
          : authState.email,
    );
    final birthdayCtrl = TextEditingController(
      text: currentProfile.birthday.isNotEmpty
          ? currentProfile.birthday
          : '15/08/1998',
    );
    var selectedGender = currentProfile.gender.isNotEmpty
        ? currentProfile.gender
        : 'Nữ';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.cardBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Chỉnh sửa hồ sơ cá nhân',
                    style: AppTypography.editorialTitle,
                  ),
                  const SizedBox(height: 16),
                  _buildModalField(
                    controller: nameCtrl,
                    label: 'Họ và tên',
                    hint: 'Nhập họ và tên của bạn',
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildModalField(
                    controller: phoneCtrl,
                    label: 'Số điện thoại liên hệ',
                    hint: 'Nhập số điện thoại',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  _buildModalField(
                    controller: birthdayCtrl,
                    label: 'Ngày sinh (Nhận ưu đãi sinh nhật)',
                    hint: 'DD/MM/YYYY',
                    icon: Icons.cake_outlined,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Giới tính',
                    style: TextStyle(
                      fontFamily: AppTypography.sansFont,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: ['Nữ', 'Nam', 'Khác'].map((gender) {
                      final isSelected = selectedGender == gender;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ChoiceChip(
                          label: Text(gender),
                          selected: isSelected,
                          onSelected: (_) =>
                              setModalState(() => selectedGender = gender),
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(this.context);
                        try {
                          await ref
                              .read(settingsViewModelProvider.notifier)
                              .updateProfile(
                                UserProfile(
                                  name: nameCtrl.text.trim(),
                                  phone: phoneCtrl.text.trim(),
                                  email: emailCtrl.text.trim(),
                                  birthday: birthdayCtrl.text.trim(),
                                  gender: selectedGender,
                                ),
                              );
                        } catch (error) {
                          if (!ctx.mounted) return;
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(
                              content: Text('Không lưu được hồ sơ: $error'),
                            ),
                          );
                          return;
                        }
                        if (!mounted || !ctx.mounted) return;
                        Navigator.pop(ctx);
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Đã cập nhật hồ sơ thành công!'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'LƯU THÔNG TIN',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showUpdateBodyProfileSheet(BuildContext context) {
    var tempHeight = _heightCm;
    var tempWeight = _weightKg;
    var tempTop = _topSize;
    var tempBottom = _bottomSize;
    var tempShoe = _shoeSize;
    var tempFit = _fitPreference;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.cardBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Hồ sơ số đo & Cỡ trang phục',
                    style: AppTypography.editorialTitle,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'NÉORA tự động đề xuất size chuẩn khi bạn xem sản phẩm.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Chiều cao',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '$tempHeight cm',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: tempHeight.toDouble(),
                    min: 145,
                    max: 190,
                    divisions: 45,
                    activeColor: AppColors.primary,
                    onChanged: (v) =>
                        setModalState(() => tempHeight = v.round()),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Cân nặng',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '$tempWeight kg',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: tempWeight.toDouble(),
                    min: 40,
                    max: 90,
                    divisions: 50,
                    activeColor: AppColors.primary,
                    onChanged: (v) =>
                        setModalState(() => tempWeight = v.round()),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Size Áo thường mặc',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['S', 'M', 'L', 'XL'].map((size) {
                      final selected = tempTop == size;
                      return ChoiceChip(
                        label: Text('Size $size'),
                        selected: selected,
                        onSelected: (_) => setModalState(() => tempTop = size),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Size Quần / Chân váy thường mặc',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['S', 'M', 'L', 'XL'].map((size) {
                      final selected = tempBottom == size;
                      return ChoiceChip(
                        label: Text('Size $size'),
                        selected: selected,
                        onSelected: (_) =>
                            setModalState(() => tempBottom = size),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Cỡ Giày',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['36', '37', '38', '39', '40', '41'].map((shoe) {
                      final selected = tempShoe == shoe;
                      return ChoiceChip(
                        label: Text(shoe),
                        selected: selected,
                        onSelected: (_) => setModalState(() => tempShoe = shoe),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Sở thích phom dáng',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      'Ôm gọn tôn dáng',
                      'Tôn dáng vừa vặn',
                      'Rộng thoải mái (Relaxed)',
                    ].map((fit) {
                      final selected = tempFit == fit;
                      return ChoiceChip(
                        label: Text(fit),
                        selected: selected,
                        onSelected: (_) => setModalState(() => tempFit = fit),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _heightCm = tempHeight;
                          _weightKg = tempWeight;
                          _topSize = tempTop;
                          _bottomSize = tempBottom;
                          _shoeSize = tempShoe;
                          _fitPreference = tempFit;
                          _hasCustomBodyProfile = true;
                        });
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Đã cập nhật số đo! Cỡ đề xuất: Size $_recommendedSize • Giày $_shoeSize',
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'LƯU SỐ ĐO CÁ NHÂN',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModalField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: AppColors.primary),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Đăng xuất khỏi NÉORA',
                  style: AppTypography.editorialTitle,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Bạn có chắc chắn muốn đăng xuất? Giỏ hàng và danh sách yêu thích của bạn vẫn sẽ được lưu trữ an toàn.',
                  style: TextStyle(
                    fontFamily: AppTypography.sansFont,
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(bottomSheetContext),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          side: const BorderSide(color: AppColors.cardBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text(
                          'Ở lại',
                          style: TextStyle(
                            fontFamily: AppTypography.sansFont,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          ref.read(authViewModelProvider.notifier).logout();
                          Navigator.pop(bottomSheetContext);
                          Navigator.pushAndRemoveUntil(
                            context,
                            AppRouter.page(builder: (_) => const AuthScreen()),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.saleRed,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text(
                          'Đăng xuất',
                          style: TextStyle(
                            fontFamily: AppTypography.sansFont,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
