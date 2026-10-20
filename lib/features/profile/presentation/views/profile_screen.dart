import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../address/presentation/viewmodels/address_viewmodel.dart';
import '../../../address/presentation/views/address_book_screen.dart';
import '../../../auth/presentation/views/auth_screen.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../../cart/presentation/viewmodels/cart_viewmodel.dart';
import '../../../cart/presentation/views/cart_screen.dart';
import '../../../history/presentation/views/recently_viewed_screen.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/presentation/viewmodels/order_viewmodel.dart';
import '../../../orders/presentation/views/order_history_screen.dart';
import '../../../payment_methods/presentation/views/payment_methods_screen.dart';
import '../../../settings/presentation/viewmodels/settings_viewmodel.dart';
import '../../../settings/presentation/views/settings_screen.dart';
import '../../../shop/presentation/views/lookbook_screen.dart';
import '../../../support/presentation/views/help_center_screen.dart';
import '../../../tracking/presentation/views/order_tracking_screen.dart';
import '../../../wallet/presentation/viewmodels/wallet_viewmodel.dart';
import '../../../wallet/presentation/views/voucher_wallet_screen.dart';
import '../../../wishlist/presentation/viewmodels/wishlist_viewmodel.dart';
import '../../../wishlist/presentation/views/wishlist_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'NP';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletViewModelProvider);
    final userSettings = ref.watch(settingsViewModelProvider);
    final wishlistCount = ref.watch(wishlistViewModelProvider).items.length;
    final cartCount = ref.watch(cartViewModelProvider).totalItemCount;
    final orderState = ref.watch(orderViewModelProvider);
    final addressState = ref.watch(addressViewModelProvider);
    final profile = userSettings.profile;

    // Real dynamic order counts (with natural fallbacks if demo store is fresh)
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

    // Active order tracking preview (if any order is currently in transit)
    final shippingOrders = orderState.getOrdersByStatus(OrderStatus.shipping);
    final activeOrder = shippingOrders.isNotEmpty
        ? shippingOrders.first
        : (orderState.orders.isNotEmpty ? orderState.orders.first : null);

    final defaultAddress = addressState.addresses.isNotEmpty
        ? addressState.addresses.first.fullAddress
        : 'Số 12 ngõ 45 phố Láng Hạ, Đống Đa, Hà Nội';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Masthead: NÉORA | MẶC ĐẸP MỖI NGÀY | Icons
              Row(
                children: [
                  const Text('NÉORA', style: AppTypography.brandLogo),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'THÀNH VIÊN ĐỘC QUYỀN',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTypography.sansFont,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  // Cart button with badge
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
                        icon: const Icon(
                          Icons.shopping_bag_outlined,
                          size: 21,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (cartCount > 0)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryBurgundy,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '$cartCount',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  IconButton(
                    tooltip: 'Cài đặt tài khoản',
                    onPressed: () {
                      Navigator.push(
                        context,
                        AppRouter.page(builder: (_) => const SettingsScreen()),
                      );
                    },
                    icon: const Icon(
                      Icons.settings_outlined,
                      size: 21,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // 2. Editorial Eyebrow & Title
              const Text(
                'TỦ ĐỒ & CÁ NHÂN',
                style: TextStyle(
                  fontFamily: AppTypography.sansFont,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.8,
                  color: AppColors.primaryBurgundy,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Không gian thành viên',
                style: AppTypography.editorialHeadline,
              ),
              const SizedBox(height: 14),

              // 3. High-End Obsidian & Champagne Privilege VIP Card
              _buildPrivilegeVipCard(
                context,
                profileName: profile.name,
                profileContact: profile.phone.isNotEmpty
                    ? profile.phone
                    : profile.email,
                initials: _initials(profile.name),
                tierName: walletState.memberTier.isNotEmpty
                    ? walletState.memberTier
                    : 'Hạng Bạc (Silver)',
                coinsToNextTier: walletState.coinsToNextTier > 0
                    ? walletState.coinsToNextTier
                    : 450,
                tierProgress: walletState.tierProgress > 0
                    ? walletState.tierProgress
                    : 0.68,
              ),
              const SizedBox(height: 16),

              // 4. Financial & Wardrobe Metrics (4-Column Bento Box)
              _buildMetricBentoBox(
                context,
                coinBalance: walletState.formattedCoinBalance,
                voucherCount: walletState.vouchers.length,
                wishlistCount: wishlistCount,
                savedLooksCount: 3,
              ),
              const SizedBox(height: 20),

              // 5. Đơn hàng của tôi (My Orders Hub)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Đơn hàng của tôi',
                      style: AppTypography.editorialTitle,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        AppRouter.page(
                          builder: (_) =>
                              const OrderHistoryScreen(initialTabIndex: 0),
                        ),
                      );
                    },
                    child: const Text(
                      'Xem tất cả ›',
                      style: TextStyle(
                        fontFamily: AppTypography.sansFont,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 4 Order Status Tabs
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildOrderStatusItem(
                        context,
                        title: 'Chờ xác nhận',
                        icon: Icons.receipt_long_outlined,
                        count: pendingCount > 0 ? pendingCount : 1,
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
                        count: shippingCount > 0 ? shippingCount : 1,
                        tabIndex: 3,
                      ),
                    ),
                    Expanded(
                      child: _buildOrderStatusItem(
                        context,
                        title: 'Đánh giá',
                        icon: Icons.star_outline_rounded,
                        count: deliveredCount > 0 ? deliveredCount : 2,
                        tabIndex: 4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Real-time Active Order Tracking Banner (Đơn hàng đang giao gần nhất)
              if (activeOrder != null)
                _buildActiveOrderTrackingStrip(
                  context,
                  orderId: activeOrder.id,
                  orderStatus: activeOrder.status.label,
                  itemSummary: activeOrder.items.isNotEmpty
                      ? '${activeOrder.items.first.product.title} (${activeOrder.items.length} món)'
                      : 'Bộ trang phục công sở NÉORA',
                ),
              const SizedBox(height: 20),

              // 6. Figma Screen 13: STYLIST CỦA RIÊNG BẠN (Capsule Styling Consultation)
              _buildStylistProfileCard(context),
              const SizedBox(height: 20),

              // 7. NÉORA Care & Daily Rewards (3 Highlight Services)
              _buildExclusivePerksStrip(context, ref, walletState),
              const SizedBox(height: 24),

              // 8. QUẢN LÝ TÀI KHOẢN (Account & Addresses)
              const Text(
                'QUẢN LÝ TÀI KHOẢN',
                style: TextStyle(
                  fontFamily: AppTypography.sansFont,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    _buildMenuRow(
                      icon: Icons.location_on_outlined,
                      title: 'Địa chỉ nhận hàng',
                      subtitle: defaultAddress,
                      onTap: () => Navigator.push(
                        context,
                        AppRouter.page(
                          builder: (_) => const AddressBookScreen(),
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.divider),
                    _buildMenuRow(
                      icon: Icons.confirmation_number_outlined,
                      title: 'Ví & Voucher ưu đãi',
                      subtitle: '${walletState.vouchers.length} mã khả dụng',
                      badgeText: '${walletState.vouchers.length}',
                      onTap: () => Navigator.push(
                        context,
                        AppRouter.page(
                          builder: (_) =>
                              const VoucherWalletScreen(initialTab: 0),
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.divider),
                    _buildMenuRow(
                      icon: Icons.credit_card_outlined,
                      title: 'Phương thức thanh toán',
                      subtitle: 'Visa •••• 4242, MoMo, COD',
                      onTap: () => Navigator.push(
                        context,
                        AppRouter.page(
                          builder: (_) => const PaymentMethodsScreen(),
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.divider),
                    _buildMenuRow(
                      icon: Icons.history_rounded,
                      title: 'Đã xem gần đây',
                      subtitle: 'Các thiết kế bạn vừa khám phá',
                      onTap: () => Navigator.push(
                        context,
                        AppRouter.page(
                          builder: (_) => const RecentlyViewedScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 9. CÀI ĐẶT & HỖ TRỢ (Settings & Support)
              const Text(
                'HỆ THỐNG & HỖ TRỢ',
                style: TextStyle(
                  fontFamily: AppTypography.sansFont,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    _buildMenuRow(
                      icon: Icons.settings_outlined,
                      title: 'Cài đặt tài khoản & Bảo mật',
                      subtitle: 'Ngôn ngữ, Face ID, Thông báo',
                      onTap: () => Navigator.push(
                        context,
                        AppRouter.page(builder: (_) => const SettingsScreen()),
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.divider),
                    _buildMenuRow(
                      icon: Icons.support_agent_outlined,
                      title: 'Trung tâm trợ giúp NÉORA',
                      subtitle: 'Câu hỏi thường gặp và chat tư vấn mẫu',
                      onTap: () => Navigator.push(
                        context,
                        AppRouter.page(
                          builder: (_) => const HelpCenterScreen(),
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.divider),
                    _buildMenuRow(
                      icon: Icons.verified_user_outlined,
                      title: 'Chính sách bảo mật & Đổi trả 30 ngày',
                      subtitle: 'Thông tin chính sách trong bản demo',
                      onTap: () => Navigator.push(
                        context,
                        AppRouter.page(
                          builder: (_) => const HelpCenterScreen(),
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.divider),
                    _buildMenuRow(
                      icon: Icons.logout_rounded,
                      title: 'Đăng xuất tài khoản',
                      isDestructive: true,
                      onTap: () => _confirmLogout(context, ref),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // 10. Editorial Footer & Version Stamp
              Center(
                child: Column(
                  children: [
                    const Text('NÉORA', style: AppTypography.brandLogo),
                    const SizedBox(height: 4),
                    const Text(
                      'ATELIER HANOI • SAIGON',
                      style: TextStyle(
                        fontFamily: AppTypography.sansFont,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.6,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Phiên bản 2.4.0 • Bản quyền 2026 NÉORA',
                      style: TextStyle(
                        fontFamily: AppTypography.sansFont,
                        fontSize: 10,
                        color: AppColors.textMuted.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET BUILDERS
  // ==========================================

  Widget _buildPrivilegeVipCard(
    BuildContext context, {
    required String profileName,
    required String profileContact,
    required String initials,
    required String tierName,
    required int coinsToNextTier,
    required double tierProgress,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF262422), Color(0xFF141312)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            offset: const Offset(0, 6),
            blurRadius: 18,
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Top Row
          Row(
            children: [
              const Icon(
                Icons.workspace_premium_outlined,
                size: 16,
                color: Color(0xFFE5C88F),
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'NÉORA PRIVILEGE CLUB',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTypography.sansFont,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.8,
                    color: Color(0xFFE5C88F),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5C88F).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE5C88F).withValues(alpha: 0.6),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  tierName.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: AppTypography.sansFont,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: Color(0xFFE5C88F),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Member Info Row
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF332F2A),
                  border: Border.all(
                    color: const Color(0xFFE5C88F),
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontFamily: AppTypography.serifFont,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE5C88F),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppTypography.serifFont,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profileContact,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTypography.sansFont,
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'MÃ VIP: NEO • 8829 • 0421',
                      style: TextStyle(
                        fontFamily: AppTypography.sansFont,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: Color(0xFFB0A89C),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Chỉnh sửa hồ sơ',
                onPressed: () {
                  Navigator.push(
                    context,
                    AppRouter.page(builder: (_) => const SettingsScreen()),
                  );
                },
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: Color(0xFFE5C88F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tier Upgrade Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Tiến độ lên Hạng Vàng',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTypography.sansFont,
                    fontSize: 11,
                    color: Color(0xFFD6CEC2),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Còn $coinsToNextTier xu',
                style: const TextStyle(
                  fontFamily: AppTypography.sansFont,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFE5C88F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: tierProgress.clamp(0.0, 1.0),
              minHeight: 5,
              backgroundColor: Colors.white.withValues(alpha: 0.12),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFE5C88F),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 3 Exclusive VIP Perks Chips
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: const [
              _VipPerkTag(label: 'Ưu đãi giao hàng mẫu'),
              _VipPerkTag(label: 'Yêu cầu đổi trả mẫu'),
              _VipPerkTag(label: 'Stylist tự động'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBentoBox(
    BuildContext context, {
    required String coinBalance,
    required int voucherCount,
    required int wishlistCount,
    required int savedLooksCount,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      child: Row(
        children: [
          Expanded(
            child: _buildMetricItem(
              icon: Icons.savings_outlined,
              value: coinBalance,
              label: 'NÉORA Xu',
              onTap: () {
                Navigator.push(
                  context,
                  AppRouter.page(
                    builder: (_) => const VoucherWalletScreen(initialTab: 0),
                  ),
                );
              },
            ),
          ),
          Container(width: 1, height: 36, color: AppColors.divider),
          Expanded(
            child: _buildMetricItem(
              icon: Icons.confirmation_number_outlined,
              value: '$voucherCount mã',
              label: 'Voucher',
              onTap: () {
                Navigator.push(
                  context,
                  AppRouter.page(
                    builder: (_) => const VoucherWalletScreen(initialTab: 0),
                  ),
                );
              },
            ),
          ),
          Container(width: 1, height: 36, color: AppColors.divider),
          Expanded(
            child: _buildMetricItem(
              icon: Icons.favorite_border_rounded,
              value: '$wishlistCount món',
              label: 'Yêu thích',
              onTap: () {
                Navigator.push(
                  context,
                  AppRouter.page(builder: (_) => const WishlistScreen()),
                );
              },
            ),
          ),
          Container(width: 1, height: 36, color: AppColors.divider),
          Expanded(
            child: _buildMetricItem(
              icon: Icons.auto_awesome_outlined,
              value: '$savedLooksCount bộ',
              label: 'Outfit đã lưu',
              onTap: () {
                Navigator.push(
                  context,
                  AppRouter.page(builder: (_) => const LookbookScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String value,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: AppTypography.sansFont,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: AppTypography.sansFont,
              fontSize: 10.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
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
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.studioGray,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 21, color: AppColors.textPrimary),
              ),
              if (count > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1.5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBurgundy,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    constraints: const BoxConstraints(minWidth: 16),
                    child: Text(
                      '$count',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: AppTypography.sansFont,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: AppTypography.sansFont,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveOrderTrackingStrip(
    BuildContext context, {
    required String orderId,
    required String orderStatus,
    required String itemSummary,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          AppRouter.page(builder: (_) => OrderTrackingScreen(orderId: orderId)),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F7F4),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF2E6B4E).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2E6B4E).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.local_shipping_outlined,
                size: 20,
                color: Color(0xFF2E6B4E),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E6B4E),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          orderStatus.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: AppTypography.sansFont,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Đơn $orderId',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: AppTypography.sansFont,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    itemSummary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: AppTypography.sansFont,
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Color(0xFF2E6B4E),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStylistProfileCard(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          AppRouter.page(builder: (_) => const LookbookScreen()),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.softPeach,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: const [
                      Icon(
                        Icons.auto_awesome,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'STYLIST CỦA RIÊNG BẠN',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppTypography.sansFont,
                            color: AppColors.primary,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  'Cập nhật số đo →',
                  style: TextStyle(
                    fontFamily: AppTypography.sansFont,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Hiểu vóc dáng để gợi ý vừa vặn.',
              style: AppTypography.editorialTitle,
            ),
            const SizedBox(height: 3),
            const Text(
              'Gu phối: Tối giản công sở • Tông màu: Be, Kem, Đen, Khaki',
              style: TextStyle(
                fontFamily: AppTypography.sansFont,
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildStylePill('Áo • Size M'),
                _buildStylePill('Quần • Size M (Eo 68cm)'),
                _buildStylePill('Giày • Size 37'),
                _buildStylePill('Cao 1m62 • 50kg'),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: const [
                  Icon(
                    Icons.auto_fix_high_outlined,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Xem 3 Lookbook được Stylist phối riêng cho bạn hôm nay',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTypography.sansFont,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExclusivePerksStrip(
    BuildContext context,
    WidgetRef ref,
    WalletState walletState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DỊCH VỤ ĐỘC QUYỀN NÉORA',
          style: TextStyle(
            fontFamily: AppTypography.sansFont,
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildServiceCard(
                icon: Icons.sync_alt_rounded,
                title: 'Đổi trả mẫu',
                subtitle: 'Xem chính sách 30 ngày',
                onTap: () {
                  Navigator.push(
                    context,
                    AppRouter.page(builder: (_) => const HelpCenterScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildServiceCard(
                icon: Icons.calendar_today_outlined,
                title: walletState.checkedInToday
                    ? 'Đã điểm danh'
                    : 'Điểm danh ngay',
                subtitle: walletState.checkedInToday
                    ? 'Nhận +50 xu hôm nay'
                    : 'Nhận ngay +50 xu',
                highlight: !walletState.checkedInToday,
                onTap: () {
                  final success = ref
                      .read(walletViewModelProvider.notifier)
                      .checkInDaily();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? '🎉 Chúc mừng bạn đã nhận 50 NÉORA Xu!'
                            : 'Hôm nay bạn đã điểm danh rồi!',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool highlight = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: highlight ? const Color(0xFFFBF4EB) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: highlight ? const Color(0xFFD4AF37) : AppColors.cardBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 20,
              color: highlight ? AppColors.primaryBurgundy : AppColors.primary,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppTypography.sansFont,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: highlight
                    ? AppColors.primaryBurgundy
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: AppTypography.sansFont,
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStylePill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: AppTypography.sansFont,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildMenuRow({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    String? subtitle,
    String? badgeText,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppColors.saleRed : AppColors.textPrimary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTypography.sansFont,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
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
                ],
              ),
            ),
            if (badgeText != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.studioGray,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeText,
                  style: const TextStyle(
                    fontFamily: AppTypography.sansFont,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
            const SizedBox(width: 6),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
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

class _VipPerkTag extends StatelessWidget {
  final String label;

  const _VipPerkTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: const Color(0xFFE5C88F).withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        '✓ $label',
        style: const TextStyle(
          fontFamily: AppTypography.sansFont,
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Color(0xFFE5C88F),
        ),
      ),
    );
  }
}
