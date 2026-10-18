import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/views/auth_screen.dart';
import '../../../address/presentation/views/address_book_screen.dart';
import '../../../orders/presentation/views/order_history_screen.dart';
import '../../../wallet/presentation/viewmodels/wallet_viewmodel.dart';
import '../../../wallet/presentation/views/voucher_wallet_screen.dart';
import '../../../wishlist/presentation/views/wishlist_screen.dart';
import '../../../support/presentation/views/help_center_screen.dart';
import '../../../settings/presentation/views/settings_screen.dart';
import '../../../settings/presentation/viewmodels/settings_viewmodel.dart';
import '../../../history/presentation/views/recently_viewed_screen.dart';
import '../../../payment_methods/presentation/views/payment_methods_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  bool _isCardFlipped = false;
  late AnimationController _cardFlipController;
  late Animation<double> _cardFlipAnimation;

  @override
  void initState() {
    super.initState();
    _cardFlipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _cardFlipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardFlipController, curve: Curves.easeInOutBack),
    );
  }

  @override
  void dispose() {
    _cardFlipController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _cardFlipController.value = _isCardFlipped ? 1 : 0;
    }
  }

  void _toggleCardFlip() {
    if (_cardFlipController.isAnimating) return;
    final nextFlipped = !_isCardFlipped;
    if (MediaQuery.disableAnimationsOf(context)) {
      _cardFlipController.value = nextFlipped ? 1 : 0;
      setState(() => _isCardFlipped = nextFlipped);
      return;
    }
    if (_isCardFlipped) {
      _cardFlipController.reverse();
    } else {
      _cardFlipController.forward();
    }
    setState(() => _isCardFlipped = nextFlipped);
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.brandBlack,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletViewModelProvider);
    final userSettings = ref.watch(settingsViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          children: [
            // 1. Dark Luxury Header (.phd)
            Container(
              height: 220,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 0),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(36),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF231F1D), Color(0xFF14120E)],
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar 66x66 with gold border
                  Container(
                    width: 66,
                    height: 66,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.coralOrange,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(33),
                      child: Image.asset(
                        'assets/images/real/onb_shopping.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Name & VIP Badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(
                          userSettings.profile.name,
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.coralOrange.withValues(
                              alpha: 0.22,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            '👑 Thành viên Vàng',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w900,
                              color: AppColors.coralOrange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Settings Button
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        AppRouter.page(builder: (_) => const SettingsScreen()),
                      );
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.settings_outlined,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Overlapping 3D 180° Flippable VIP Member Card (.mcw)
            Transform.translate(
              offset: const Offset(0, -68),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _toggleCardFlip,
                      child: AnimatedBuilder(
                        animation: _cardFlipAnimation,
                        builder: (context, child) {
                          final angle = _cardFlipAnimation.value * math.pi;
                          final isBack = angle >= (math.pi / 2);

                          return Transform(
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(angle),
                            alignment: Alignment.center,
                            child: isBack
                                ? Transform(
                                    transform: Matrix4.identity()
                                      ..rotateY(math.pi),
                                    alignment: Alignment.center,
                                    child: _buildCardBack(),
                                  )
                                : _buildCardFront(walletState),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Chạm vào thẻ để lật ↺',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Order Status Row (.card3 & .ost)
            Transform.translate(
              offset: const Offset(0, -52),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF502814).withValues(alpha: 0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Đơn mua',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                AppRouter.page(
                                  builder: (_) => const OrderHistoryScreen(
                                    initialTabIndex: 0,
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              'Xem lịch sử ›',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.coralOrange,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _buildOrderStatusItem(
                              'Chờ xác nhận',
                              Icons.account_balance_wallet_outlined,
                              1,
                              const Color(0xFFF5EEE4),
                              const Color(0xFF8B6840),
                              tabIndex: 1,
                            ),
                          ),
                          Expanded(
                            child: _buildOrderStatusItem(
                              'Chờ lấy hàng',
                              Icons.inventory_2_outlined,
                              1,
                              const Color(0xFFEAF0FF),
                              const Color(0xFF4C6FE0),
                              tabIndex: 2,
                            ),
                          ),
                          Expanded(
                            child: _buildOrderStatusItem(
                              'Đang giao',
                              Icons.local_shipping_outlined,
                              1,
                              const Color(0xFFEDF2ED),
                              const Color(0xFF4F7A4F),
                              tabIndex: 3,
                            ),
                          ),
                          Expanded(
                            child: _buildOrderStatusItem(
                              'Đánh giá',
                              Icons.star_outline_rounded,
                              1,
                              const Color(0xFFE9E2D6),
                              const Color(0xFFC8A97E),
                              tabIndex: 4,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 4. Wallet Stats 3-Box Grid (.wal)
            Transform.translate(
              offset: const Offset(0, -40),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildWalletBox(
                        '🪙',
                        walletState.formattedCoinBalance,
                        'Xu NÉORA',
                        onTap: () {
                          Navigator.push(
                            context,
                            AppRouter.page(
                              builder: (_) =>
                                  const VoucherWalletScreen(initialTab: 0),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildWalletBox(
                        '🎟️',
                        '${walletState.vouchers.length}',
                        'Voucher',
                        onTap: () {
                          Navigator.push(
                            context,
                            AppRouter.page(
                              builder: (_) =>
                                  const VoucherWalletScreen(initialTab: 0),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildWalletBox(
                        '💳',
                        '150K',
                        'Ví NÉORA',
                        onTap: () {
                          Navigator.push(
                            context,
                            AppRouter.page(
                              builder: (_) =>
                                  const VoucherWalletScreen(initialTab: 0),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 5. Menu Items List (.menu)
            Transform.translate(
              offset: const Offset(0, -28),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF502814).withValues(alpha: 0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildMenuItem(
                        '👀',
                        'Đã xem gần đây',
                        const Color(0xFFF5EEE4),
                      ),
                      const Divider(height: 1, color: Color(0xFFEAE4DC)),
                      _buildMenuItem(
                        '💖',
                        'Sản phẩm yêu thích',
                        const Color(0xFFE9E2D6),
                      ),
                      const Divider(height: 1, color: Color(0xFFEAE4DC)),
                      _buildMenuItem(
                        '📍',
                        'Sổ địa chỉ',
                        const Color(0xFFEDF2ED),
                      ),
                      const Divider(height: 1, color: Color(0xFFEAE4DC)),
                      _buildMenuItem(
                        '💳',
                        'Phương thức thanh toán',
                        const Color(0xFFF1EBFB),
                      ),
                      const Divider(height: 1, color: Color(0xFFEAE4DC)),
                      _buildMenuItem(
                        '🎧',
                        'Trung tâm trợ giúp',
                        const Color(0xFFEAF0FF),
                      ),
                      const Divider(height: 1, color: Color(0xFFEAE4DC)),
                      _buildMenuItem(
                        '🚪',
                        'Đăng xuất',
                        const Color(0xFFF0EBE3),
                        isLogout: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardFront(WalletState walletState) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final cardHeight = 168.0 + ((textScale - 1) * 176).clamp(0, 176);

    return Container(
      width: double.infinity,
      height: cardHeight,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFDFC59E), Color(0xFFC8A97E), Color(0xFFB89260)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0E0E0E).withValues(alpha: 0.28),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned(
            right: 0,
            top: 0,
            child: Text('👑', style: TextStyle(fontSize: 36)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ĐIỂM THƯỞNG NÉORA',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: Color(0xD01A1815),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${walletState.formattedCoinBalance} xu',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1A1815),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      height: 8,
                      width: double.infinity,
                      color: const Color(0xFF1A1815).withValues(alpha: 0.16),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: walletState.tierProgress,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1815),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Text(
                        'Vàng',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1815),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Còn ${walletState.coinsToNextTier} xu để lên Kim Cương 💎',
                          maxLines: 2,
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1815),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack() {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final cardHeight = 168.0 + ((textScale - 1) * 176).clamp(0, 176);

    return Container(
      width: double.infinity,
      height: cardHeight,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0E0E0E).withValues(alpha: 0.2),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'MÃ THÀNH VIÊN',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          // Barcode Graphic
          SizedBox(
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(42, (i) {
                final isThick = (i % 3 == 0) || (i % 7 == 0);
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1.2),
                  width: isThick ? 3.0 : 1.5,
                  height: double.infinity,
                  color: const Color(0xFF2B2420),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'NEO 2026 0815',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 3.5,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatusItem(
    String title,
    IconData icon,
    int count,
    Color bg,
    Color iconColor, {
    int tabIndex = 0,
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
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(child: Icon(icon, size: 22, color: iconColor)),
              ),
              if (count > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.coralOrange,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
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
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletBox(
    String emoji,
    String value,
    String label, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF502814).withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    String emoji,
    String title,
    Color emojiBg, {
    bool isLogout = false,
  }) {
    return GestureDetector(
      onTap: () {
        if (isLogout) {
          Navigator.pushAndRemoveUntil(
            context,
            AppRouter.page(builder: (_) => const AuthScreen()),
            (route) => false,
          );
        } else if (title == 'Sổ địa chỉ') {
          Navigator.push(
            context,
            AppRouter.page(builder: (_) => const AddressBookScreen()),
          );
        } else if (title == 'Sản phẩm yêu thích') {
          Navigator.push(
            context,
            AppRouter.page(builder: (_) => const WishlistScreen()),
          );
        } else if (title == 'Đã xem gần đây') {
          Navigator.push(
            context,
            AppRouter.page(builder: (_) => const RecentlyViewedScreen()),
          );
        } else if (title == 'Phương thức thanh toán') {
          Navigator.push(
            context,
            AppRouter.page(builder: (_) => const PaymentMethodsScreen()),
          );
        } else if (title == 'Trung tâm trợ giúp') {
          Navigator.push(
            context,
            AppRouter.page(builder: (_) => const HelpCenterScreen()),
          );
        } else {
          _showToast(title);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: emojiBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 17)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isLogout ? AppColors.saleRed : AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
