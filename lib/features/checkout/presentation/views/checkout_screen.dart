import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../address/presentation/viewmodels/address_viewmodel.dart';
import '../../../address/presentation/views/address_book_screen.dart';
import '../../../cart/domain/entities/cart_snapshot.dart';
import '../../../cart/presentation/viewmodels/cart_viewmodel.dart';
import '../../../payment_methods/presentation/viewmodels/payment_methods_viewmodel.dart';
import '../../../payment_methods/presentation/views/payment_methods_screen.dart';
import '../../../orders/presentation/viewmodels/order_viewmodel.dart';
import '../../../wallet/presentation/viewmodels/wallet_viewmodel.dart';
import '../../domain/entities/checkout_quote.dart';
import '../../domain/entities/checkout_selection.dart';
import '../viewmodels/checkout_viewmodel.dart';
import 'order_confirmed_screen.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  void _processPayment() async {
    final strings = AppLocalizations.of(context);
    final checkout = ref.read(checkoutViewModelProvider);

    final notifier = ref.read(checkoutViewModelProvider.notifier);
    final order = await notifier.placeOrder();
    if (!mounted) return;
    if (order == null) {
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

    Navigator.pushReplacement(
      context,
      AppRouter.page(
        builder: (_) => OrderConfirmedScreen(
          orderId: order.id,
          paymentMethod: order.paymentMethod,
          estimatedDelivery: checkout.shippingType == ShippingType.express
              ? strings.deliveryTomorrowAtTwo
              : strings.deliveryNextTwoToThreeDays,
          totalAmount: CurrencyFormatter.vnd(order.totalAmount),
        ),
      ),
    );
  }

  Future<void> _managePaymentMethods() async {
    await Navigator.push(
      context,
      AppRouter.page(builder: (_) => const PaymentMethodsScreen()),
    );
    if (!mounted) return;
    final methods = ref.read(paymentMethodsViewModelProvider);
    final selected = ref.read(checkoutViewModelProvider).paymentType;
    final available = switch (selected) {
      PaymentType.cashOnDelivery => true,
      PaymentType.creditCard => methods.cards.isNotEmpty,
      PaymentType.applePay => methods.deviceWalletEnabled,
      PaymentType.momo => methods.momoLinked,
      PaymentType.zalopay => methods.zalopayLinked,
    };
    if (!available) {
      ref
          .read(checkoutViewModelProvider.notifier)
          .setPayment(PaymentType.cashOnDelivery);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final cartState = ref.watch(cartViewModelProvider);
    final checkoutState = ref.watch(checkoutViewModelProvider);
    final checkoutNotifier = ref.read(checkoutViewModelProvider.notifier);
    final paymentMethods = ref.watch(paymentMethodsViewModelProvider);
    final selectedCard =
        paymentMethods.cards.where((card) => card.isDefault).firstOrNull ??
        paymentMethods.cards.firstOrNull;
    final addressState = ref.watch(addressViewModelProvider);
    final selectedAddress = addressState.selectedAddress;
    final quote = CheckoutQuote.calculate(
      CartSnapshot(
        items: cartState.items,
        appliedCoupon: cartState.appliedCoupon,
      ),
      CheckoutSelection(
        shippingType: checkoutState.shippingType,
        paymentType: checkoutState.paymentType,
      ),
      wallet: ref.watch(walletViewModelProvider).toSnapshot(),
      firstOrder: !ref
          .watch(orderViewModelProvider)
          .orders
          .any((order) => order.isUserPlaced),
    );
    final totalText = CurrencyFormatter.vnd(quote.total);

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
                                      'Chọn địa chỉ giao hàng',
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
                              if (selectedAddress != null)
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
                                    selectedAddress.label.toUpperCase(),
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
                                'Vui lòng thêm hoặc chọn địa chỉ giao hàng.',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textSecondary,
                              height: 1.35,
                            ),
                          ),
                          if (selectedAddress != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              selectedAddress.phoneNumber,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
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

            // Payment Radio Options
            _buildOptionTile(
              isSelected: checkoutState.paymentType == PaymentType.applePay,
              onTap: paymentMethods.deviceWalletEnabled
                  ? () => checkoutNotifier.setPayment(PaymentType.applePay)
                  : null,
              title: strings.deviceWalletPaymentTitle,
              subtitle: paymentMethods.deviceWalletEnabled
                  ? strings.mockPaymentLabel
                  : strings.paymentUnavailableLabel,
            ),
            const SizedBox(height: 8),
            _buildOptionTile(
              isSelected: checkoutState.paymentType == PaymentType.creditCard,
              onTap: selectedCard == null
                  ? null
                  : () => checkoutNotifier.setPayment(PaymentType.creditCard),
              title: strings.creditDebitCard,
              subtitle: selectedCard == null
                  ? strings.paymentUnavailableLabel
                  : strings.mockCardEnding(selectedCard.lastFour),
            ),
            const SizedBox(height: 8),
            _buildOptionTile(
              isSelected: checkoutState.paymentType == PaymentType.momo,
              onTap: paymentMethods.momoLinked
                  ? () => checkoutNotifier.setPayment(PaymentType.momo)
                  : null,
              title: 'MoMo',
              subtitle: paymentMethods.momoLinked
                  ? strings.mockPaymentLabel
                  : strings.paymentUnavailableLabel,
            ),
            const SizedBox(height: 8),
            _buildOptionTile(
              isSelected: checkoutState.paymentType == PaymentType.zalopay,
              onTap: paymentMethods.zalopayLinked
                  ? () => checkoutNotifier.setPayment(PaymentType.zalopay)
                  : null,
              title: 'ZaloPay',
              subtitle: paymentMethods.zalopayLinked
                  ? strings.mockPaymentLabel
                  : strings.paymentUnavailableLabel,
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
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _managePaymentMethods,
                icon: const Icon(Icons.settings_outlined, size: 17),
                label: Text(strings.managePaymentMethodsAction),
              ),
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
                    CurrencyFormatter.vnd(quote.subtotal),
                  ),
                  const SizedBox(height: 8),
                  _buildBillLine(
                    strings.shippingFeeLabel,
                    quote.shippingFee == 0
                        ? strings.freeLabel
                        : CurrencyFormatter.vnd(quote.shippingFee),
                  ),
                  if (quote.discount > 0) ...[
                    const SizedBox(height: 8),
                    _buildBillLine(
                      strings.voucherDiscountLabel,
                      '-${CurrencyFormatter.vnd(quote.discount)}',
                    ),
                  ],
                  if (quote.coinReward > 0) ...[
                    const SizedBox(height: 8),
                    _buildBillLine(
                      'Xu hoàn sau đặt hàng',
                      '+${quote.coinReward} xu',
                    ),
                  ],
                  if (quote.giftDescription != null) ...[
                    const SizedBox(height: 8),
                    _buildBillLine('Quà tặng', quote.giftDescription!),
                  ],
                  if (quote.promotionReason != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      quote.promotionReason!,
                      style: const TextStyle(color: AppColors.saleRed),
                    ),
                  ],
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
                onPressed:
                    checkoutState.isProcessing ||
                        cartState.items.isEmpty ||
                        quote.promotionReason != null
                    ? null
                    : _processPayment,
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
    required VoidCallback? onTap,
    required String title,
    required String subtitle,
    String? trailing,
    bool isPositiveTrailing = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.55 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppColors.brandBlack
                  : const Color(0xFFE5E5EA),
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
      ),
    );
  }
}
