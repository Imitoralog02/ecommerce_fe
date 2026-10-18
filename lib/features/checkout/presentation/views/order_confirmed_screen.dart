import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/confetti_celebration_widget.dart';
import '../../../navigation/presentation/views/main_nav_screen.dart';
import '../../../orders/presentation/views/order_history_screen.dart';
import '../../../settings/presentation/viewmodels/settings_viewmodel.dart';
import '../../../tracking/presentation/views/order_tracking_screen.dart';

class OrderConfirmedScreen extends ConsumerStatefulWidget {
  final String orderId;
  final String paymentMethod;
  final String estimatedDelivery;
  final String totalAmount;

  const OrderConfirmedScreen({
    super.key,
    this.orderId = 'NEO-2094',
    this.paymentMethod = 'Apple Pay',
    this.estimatedDelivery = '2-3 ngày tới',
    this.totalAmount = '2.136.000₫',
  });

  @override
  ConsumerState<OrderConfirmedScreen> createState() =>
      _OrderConfirmedScreenState();
}

class _OrderConfirmedScreenState extends ConsumerState<OrderConfirmedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _motionConfigured = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    if (disableAnimations) {
      _animController.value = 1;
    } else if (!_motionConfigured && !_animController.isAnimating) {
      _animController.forward();
    }
    _motionConfigured = true;
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final strings = AppLocalizations.of(context);
    final customerName = ref.watch(settingsViewModelProvider).profile.name;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ConfettiCelebrationWidget(
        isPlaying: !disableAnimations,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 20),

                // 1. Success Animation & Confirmation Headline
                Column(
                  children: [
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.liveGreen.withValues(alpha: 0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.liveGreen.withValues(
                                alpha: 0.15,
                              ),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.check_rounded,
                            size: 42,
                            color: AppColors.liveGreen,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          Text(
                            strings.orderConfirmedTitle,
                            style: const TextStyle(
                              fontFamily: AppTypography.serifFont,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            strings.orderConfirmedThanks(customerName),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.5,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 2. Minimalist Digital Receipt Card (NÉORA Style)
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 20,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.cardBorder),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildReceiptRow(
                              icon: Icons.receipt_long_outlined,
                              label: strings.orderNumberLabel,
                              value: widget.orderId,
                              isBold: true,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(
                                color: AppColors.divider,
                                height: 1,
                              ),
                            ),
                            _buildReceiptRow(
                              icon: Icons.credit_card_outlined,
                              label: strings.paidWithLabel,
                              value: widget.paymentMethod,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(
                                color: AppColors.divider,
                                height: 1,
                              ),
                            ),
                            _buildReceiptRow(
                              icon: Icons.calendar_today_outlined,
                              label: strings.arrivingLabel,
                              value: widget.estimatedDelivery,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(
                                color: AppColors.divider,
                                height: 1,
                              ),
                            ),
                            _buildReceiptRow(
                              icon: Icons.payments_outlined,
                              label: strings.totalLabel,
                              value: widget.totalAmount,
                              isPrice: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // 3. Navigation Actions
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            AppRouter.page(
                              builder: (_) =>
                                  OrderTrackingScreen(orderId: widget.orderId),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandBlack,
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                          elevation: 0,
                        ),
                        child: Text(
                          strings.trackOrderAction,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            AppRouter.page(
                              builder: (_) =>
                                  const OrderHistoryScreen(initialTabIndex: 1),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.brandBlack,
                          side: const BorderSide(
                            color: AppColors.cardBorder,
                            width: 1.2,
                          ),
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          strings.viewMyOrdersAction,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          AppRouter.page(
                            builder: (_) =>
                                const MainNavScreen(initialIndex: 0),
                          ),
                          (route) => false,
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                      ),
                      child: Text(
                        strings.continueShoppingAction,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow({
    required IconData icon,
    required String label,
    required String value,
    bool isBold = false,
    bool isPrice = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textMuted),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isPrice ? 15 : 13.5,
            fontWeight: (isBold || isPrice) ? FontWeight.w700 : FontWeight.w600,
            color: isPrice ? AppColors.brandBlack : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
