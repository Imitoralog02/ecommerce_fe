import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/editorial_heading.dart';
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
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _processPayment() async {
    final strings = AppLocalizations.of(context);
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
          estimatedDelivery:
              order.estimatedDelivery ??
              order.shippingType.demoEstimatedDelivery,
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            size: 20,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Thanh toán',
          style: TextStyle(
            fontFamily: AppTypography.serifFont,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const EditorialHeading(
              title: 'Sắp đến tay bạn.',
              subtitle: 'Đặt đơn mẫu, chưa phát sinh thanh toán',
              padding: EdgeInsets.fromLTRB(0, 8, 0, 20),
            ),

            // 1. Địa chỉ nhận hàng
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Địa chỉ nhận hàng',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.editorialTitle,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      AppRouter.page(
                        builder: (_) =>
                            const AddressBookScreen(isSelectMode: true),
                      ),
                    );
                  },
                  child: const Text(
                    'Thay đổi',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
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
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.studioGray,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            selectedAddress != null
                                ? '${selectedAddress.recipientName} • ${selectedAddress.phoneNumber}'
                                : 'Chọn địa chỉ giao hàng',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (selectedAddress != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.softPeach,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              selectedAddress.label.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      selectedAddress?.fullAddress ??
                          'Vui lòng thêm hoặc chọn địa chỉ giao hàng.',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),

            // 2. Giao hàng
            const Text('Giao hàng', style: AppTypography.editorialTitle),
            const SizedBox(height: 10),
            _buildOptionTile(
              isSelected: checkoutState.shippingType == ShippingType.standard,
              onTap: () => checkoutNotifier.setShipping(ShippingType.standard),
              title: 'Giao tiêu chuẩn',
              subtitle: ShippingType.standard.demoEstimatedDelivery,
              trailing: strings.freeLabel,
              isPositiveTrailing: true,
            ),
            const SizedBox(height: 8),
            _buildOptionTile(
              isSelected: checkoutState.shippingType == ShippingType.express,
              onTap: () => checkoutNotifier.setShipping(ShippingType.express),
              title: 'Giao hỏa tốc',
              subtitle: ShippingType.express.demoEstimatedDelivery,
              trailing: CurrencyFormatter.vnd(30000),
            ),
            const SizedBox(height: 22),

            // 3. Thanh toán bằng
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Thanh toán bằng',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.editorialTitle,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: GestureDetector(
                    onTap: _managePaymentMethods,
                    child: Text(
                      strings.managePaymentMethodsAction,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildOptionTile(
              isSelected:
                  checkoutState.paymentType == PaymentType.cashOnDelivery,
              onTap: () =>
                  checkoutNotifier.setPayment(PaymentType.cashOnDelivery),
              title: 'Trả tiền khi nhận hàng',
              subtitle: 'Lựa chọn COD cho đơn hàng mẫu',
            ),
            const SizedBox(height: 8),
            _buildOptionTile(
              isSelected: checkoutState.paymentType == PaymentType.creditCard,
              onTap: selectedCard == null
                  ? null
                  : () => checkoutNotifier.setPayment(PaymentType.creditCard),
              title: 'Thẻ ATM / Visa / Mastercard',
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
                  ? 'Ví MoMo mẫu cho checkout demo'
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
              isSelected: checkoutState.paymentType == PaymentType.applePay,
              onTap: paymentMethods.deviceWalletEnabled
                  ? () => checkoutNotifier.setPayment(PaymentType.applePay)
                  : null,
              title: strings.deviceWalletPaymentTitle,
              subtitle: paymentMethods.deviceWalletEnabled
                  ? strings.mockPaymentLabel
                  : strings.paymentUnavailableLabel,
            ),
            const SizedBox(height: 22),

            // 4. Đơn hàng của bạn (compact items + note)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Đơn hàng của bạn',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.editorialTitle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${cartState.totalItemCount} sản phẩm',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  ...cartState.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item.quantity}x ${item.product.title} (${item.selectedSize})',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item.formattedTotalPrice,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 16, color: AppColors.divider),
                  TextField(
                    controller: _noteController,
                    style: const TextStyle(fontSize: 12.5),
                    decoration: const InputDecoration(
                      hintText: 'Ghi chú cho đơn hàng (không bắt buộc)',
                      hintStyle: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                      isDense: true,
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // 5. Order Total Breakdown
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.studioGray,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.cardBorder),
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
                    child: Divider(color: AppColors.divider, height: 1),
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
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          totalText,
                          style: const TextStyle(
                            fontFamily: AppTypography.sansFont,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // 6. Place Order Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed:
                    checkoutState.isProcessing ||
                        cartState.items.isEmpty ||
                        quote.promotionReason != null
                    ? null
                    : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
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
                        child: Text(
                          'Đặt hàng • $totalText →',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
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
            color: AppColors.textPrimary,
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
            color: isSelected ? AppColors.softPeach : Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.cardBorder,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.textMuted,
                    width: 1.8,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
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
                        color: AppColors.textPrimary,
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
                        : AppColors.textPrimary,
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
