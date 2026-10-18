import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../address/domain/entities/address_entity.dart';
import '../../../address/presentation/viewmodels/address_viewmodel.dart';
import '../../../address/presentation/views/address_book_screen.dart';
import '../../../cart/presentation/viewmodels/cart_viewmodel.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/presentation/viewmodels/order_viewmodel.dart';
import '../../../settings/presentation/viewmodels/settings_viewmodel.dart';
import '../../domain/entities/checkout_selection.dart';
import '../viewmodels/checkout_viewmodel.dart';
import 'order_confirmed_screen.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  void _processPayment(String totalAmount) async {
    final strings = AppLocalizations.of(context);
    final profile = ref.read(settingsViewModelProvider).profile;
    final cartState = ref.read(cartViewModelProvider);
    final addressState = ref.read(addressViewModelProvider);
    final selectedAddress =
        addressState.selectedAddress ??
        AddressEntity(
          id: 'addr_default',
          recipientName: profile.name,
          phoneNumber: profile.phone,
          streetAddress: 'Tầng 12, Toà nhà Bitexco, 2 Hải Triều',
          ward: 'Phường Bến Nghé',
          district: 'Quận 1',
          city: 'TP. Hồ Chí Minh',
          isDefault: true,
          label: 'Văn phòng',
        );

    final newOrderId = 'NEO-${DateTime.now().millisecondsSinceEpoch % 10000}';
    final checkout = ref.read(checkoutViewModelProvider);
    final paymentName = switch (checkout.paymentType) {
      PaymentType.applePay => 'Apple Pay',
      PaymentType.creditCard => strings.creditDebitCard,
      PaymentType.cashOnDelivery => strings.cashOnDelivery,
    };

    final subtotal = cartState.subtotal > 0 ? cartState.subtotal : 1964000.0;
    final shippingFee = checkout.shippingFee;
    final total = subtotal + shippingFee;

    final notifier = ref.read(checkoutViewModelProvider.notifier);
    final success = await notifier.placeOrder();
    if (!mounted) return;
    if (!success) {
      final message = ref.read(checkoutViewModelProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message ?? strings.checkoutFailedMessage),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.saleRed,
        ),
      );
      return;
    }

    ref
        .read(orderViewModelProvider.notifier)
        .addOrder(
          OrderEntity(
            id: newOrderId,
            orderDate: DateTime.now(),
            status: OrderStatus.pendingConfirmation,
            items: List.from(cartState.items),
            subtotal: subtotal,
            shippingFee: shippingFee,
            discountAmount: 0.0,
            totalAmount: total,
            shippingAddress: selectedAddress,
            estimatedDelivery: checkout.shippingType == ShippingType.express
                ? strings.deliveryTomorrowAtTwo
                : strings.deliveryNextTwoToThreeDays,
            paymentMethod: paymentName,
          ),
        );

    if (mounted) {
      Navigator.pushReplacement(
        context,
        AppRouter.page(
          builder: (_) => OrderConfirmedScreen(
            orderId: newOrderId,
            paymentMethod: paymentName,
            estimatedDelivery: checkout.shippingType == ShippingType.express
                ? strings.deliveryTomorrowAtTwo
                : strings.deliveryNextTwoToThreeDays,
            totalAmount: totalAmount,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final profile = ref.watch(settingsViewModelProvider).profile;
    final cartState = ref.watch(cartViewModelProvider);
    final checkoutState = ref.watch(checkoutViewModelProvider);
    final checkoutNotifier = ref.read(checkoutViewModelProvider.notifier);
    final addressState = ref.watch(addressViewModelProvider);
    final selectedAddress = addressState.selectedAddress;
    final subtotal = cartState.subtotal > 0 ? cartState.subtotal : 1964000.0;
    final shippingFee = checkoutState.shippingFee;
    const tax = 0.0;
    final total = subtotal + shippingFee + tax;
    final totalText = CurrencyFormatter.vnd(total);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Center(
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: AppColors.brandBlack,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        centerTitle: true,
        title: Text(
          strings.checkoutTitle,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
            color: AppColors.brandBlack,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: 120,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Delivery Address Card (thumb2.jpeg)
            Text(
              strings.deliveryAddressSection,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  AppRouter.page(
                    builder: (_) => const AddressBookScreen(isSelectMode: true),
                  ),
                );
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE5E5EA)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF4F4F6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on_outlined,
                        size: 20,
                        color: AppColors.brandBlack,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  selectedAddress?.recipientName ??
                                      profile.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.brandBlack,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F0F2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  (selectedAddress?.label ?? 'HOME')
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            selectedAddress?.fullAddress ??
                                'Tầng 12, Toà nhà Bitexco, 2 Hải Triều, Phường Bến Nghé, Quận 1, TP. Hồ Chí Minh',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textSecondary,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            selectedAddress?.phoneNumber ?? profile.phone,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 2. Shipping Method
            Text(
              strings.shippingMethodSection,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 10),
            _buildOptionTile(
              isSelected: checkoutState.shippingType == ShippingType.standard,
              onTap: () => checkoutNotifier.setShipping(ShippingType.standard),
              title: strings.standardShippingTitle,
              subtitle: strings.standardShippingSubtitle,
              trailing: strings.freeLabel,
              isPositiveTrailing: true,
            ),
            const SizedBox(height: 8),
            _buildOptionTile(
              isSelected: checkoutState.shippingType == ShippingType.express,
              onTap: () => checkoutNotifier.setShipping(ShippingType.express),
              title: strings.expressShippingTitle,
              subtitle: strings.expressShippingSubtitle,
              trailing: CurrencyFormatter.vnd(30000),
            ),
            const SizedBox(height: 24),

            // 3. Payment Method & NÉORA Obsidian Card
            Text(
              strings.paymentMethodSection,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 12),

            // Obsidian Card
            Container(
              width: double.infinity,
              height: 175,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF232326),
                    Color(0xFF18181A),
                    Color(0xFF101011),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Flexible(
                        child: Text(
                          'NÉORA BLACK',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'VISA',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    '••••  ••••  ••••  4242',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 3.0,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.cardholderLabel,
                            style: const TextStyle(
                              fontSize: 8.5,
                              letterSpacing: 1.0,
                              color: Colors.white54,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            profile.name.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.expiresLabel,
                            style: const TextStyle(
                              fontSize: 8.5,
                              letterSpacing: 1.0,
                              color: Colors.white54,
                            ),
                          ),
                          SizedBox(height: 2),
                          const Text(
                            '08/29',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Payment Radio Options
            _buildOptionTile(
              isSelected: checkoutState.paymentType == PaymentType.applePay,
              onTap: () => checkoutNotifier.setPayment(PaymentType.applePay),
              title: 'Apple Pay',
              subtitle: strings.fastSecurePayment,
            ),
            const SizedBox(height: 8),
            _buildOptionTile(
              isSelected: checkoutState.paymentType == PaymentType.creditCard,
              onTap: () => checkoutNotifier.setPayment(PaymentType.creditCard),
              title: strings.creditDebitCard,
              subtitle: 'Visa •••• 4242',
            ),
            const SizedBox(height: 8),
            _buildOptionTile(
              isSelected:
                  checkoutState.paymentType == PaymentType.cashOnDelivery,
              onTap: () =>
                  checkoutNotifier.setPayment(PaymentType.cashOnDelivery),
              title: strings.cashOnDelivery,
              subtitle: strings.cashOnDeliverySubtitle,
            ),
            const SizedBox(height: 24),

            // 4. Order Total Breakdown
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE5E5EA)),
              ),
              child: Column(
                children: [
                  _buildBillLine(
                    strings.subtotalLabel,
                    CurrencyFormatter.vnd(subtotal),
                  ),
                  const SizedBox(height: 8),
                  _buildBillLine(
                    strings.shippingFeeLabel,
                    shippingFee == 0
                        ? strings.freeLabel
                        : CurrencyFormatter.vnd(shippingFee),
                  ),
                  const SizedBox(height: 8),
                  _buildBillLine(strings.taxLabel, strings.taxIncludedLabel),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(color: Color(0xFFE5E5EA), height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          strings.totalPaymentLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.brandBlack,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          totalText,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.brandBlack,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 5. Place Order Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: checkoutState.isProcessing
                    ? null
                    : () => _processPayment(totalText),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandBlack,
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  elevation: 0,
                ),
                child: checkoutState.isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.lock_outline_rounded, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              strings.placeOrderAction,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
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

  Widget _buildBillLine(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: AppColors.brandBlack,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionTile({
    required bool isSelected,
    required VoidCallback onTap,
    required String title,
    required String subtitle,
    String? trailing,
    bool isPositiveTrailing = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.brandBlack : const Color(0xFFE5E5EA),
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.brandBlack
                      : AppColors.textMuted,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppColors.brandBlack,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w600,
                      color: AppColors.brandBlack,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              Text(
                trailing,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: isPositiveTrailing
                      ? AppColors.liveGreen
                      : AppColors.brandBlack,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
