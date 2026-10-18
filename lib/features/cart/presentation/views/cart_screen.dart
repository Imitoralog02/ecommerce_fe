import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animated_price_counter.dart';
import '../../../../core/widgets/product_visual_widget.dart';
import '../../../checkout/presentation/views/checkout_screen.dart';
import '../viewmodels/cart_viewmodel.dart';

class CartScreen extends ConsumerStatefulWidget {
  final VoidCallback? onStartShopping;

  const CartScreen({super.key, this.onStartShopping});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final _couponController = TextEditingController();

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final cartState = ref.watch(cartViewModelProvider);
    final cartNotifier = ref.read(cartViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          strings.cartTitleCount(
            cartState.totalItemCount.toString().padLeft(2, '0'),
          ),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
            color: AppColors.brandBlack,
          ),
        ),
        actions: [
          if (cartState.items.isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                size: 20,
                color: AppColors.textSecondary,
              ),
              tooltip: strings.clearCartTooltip,
              onPressed: () {
                cartNotifier.clearCart();
              },
            ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: cartState.items.isEmpty
            ? Center(
                key: const ValueKey('empty_cart'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: AppColors.softPeach,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.cardBorder,
                            width: 1.5,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.shopping_bag_outlined,
                            size: 40,
                            color: AppColors.coralOrange,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        strings.emptyCartTitle,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          color: AppColors.brandBlack,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        strings.emptyCartSubtitle,
                        style: const TextStyle(
                          fontSize: 13.5,
                          height: 1.45,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: widget.onStartShopping,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.coralOrange,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shadowColor: AppColors.coralOrange.withValues(
                              alpha: 0.4,
                            ),
                            shape: const StadiumBorder(),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                strings.startShoppingAction,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded, size: 16),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => cartNotifier.restoreVideoOrder(),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textMuted,
                        ),
                        child: Text(
                          strings.loadSampleCartAction,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : ListView(
                key: const ValueKey('populated_cart'),
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 12,
                  bottom: 120,
                ),
                children: [
                  // Freeship Progress Bar
                  Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.local_shipping_outlined,
                              size: 16,
                              color: AppColors.coralOrange,
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                cartState.subtotal >= 300000
                                    ? strings.freeShippingReached
                                    : strings.freeShippingRemaining(
                                        (300000 - cartState.subtotal)
                                            .clamp(0, 300000)
                                            .toInt(),
                                      ),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.brandBlack,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (cartState.subtotal / 300000).clamp(
                              0.0,
                              1.0,
                            ),
                            minHeight: 5,
                            backgroundColor: AppColors.softPeach,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.coralOrange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 1. List of Cart Items with Dismissible Swipe-to-Delete
                  ...cartState.items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return Dismissible(
                      key: ValueKey(
                        'cart_item_${item.product.id}_${item.selectedSize}_$index',
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) {
                        cartNotifier.removeFromCart(item.product.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              strings.removedFromCartMessage(
                                item.product.title,
                              ),
                            ),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.only(right: 20),
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(
                          color: AppColors.saleRed,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              strings.deleteAction,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFEFEFEF)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Thumbnail
                            Container(
                              width: 80,
                              height: 85,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4F4F6),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: item.product.imagePath != null
                                    ? Image.asset(
                                        item.product.imagePath!,
                                        fit: BoxFit.contain,
                                        filterQuality: FilterQuality.high,
                                        errorBuilder: (_, _, _) =>
                                            ProductVisualWidget(
                                              imageType: item.product.imageType,
                                              size: 65,
                                            ),
                                      )
                                    : ProductVisualWidget(
                                        imageType: item.product.imageType,
                                        size: 65,
                                      ),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Info & Controls
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.product.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.brandBlack,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => cartNotifier
                                            .removeFromCart(item.product.id),
                                        child: const Icon(
                                          Icons.close_rounded,
                                          size: 18,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    strings.cartVariantLabel(
                                      item.selectedSize,
                                      item.selectedColor,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.formattedTotalPrice,
                                          style: const TextStyle(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.coralOrange,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),

                                      // Quantity Counter
                                      Container(
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF4F4F6),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            InkWell(
                                              onTap: () => cartNotifier
                                                  .decrementQuantity(index),
                                              child: const Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                ),
                                                child: Icon(
                                                  Icons.remove,
                                                  size: 14,
                                                  color: AppColors.brandBlack,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              '${item.quantity}',
                                              style: const TextStyle(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.brandBlack,
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () => cartNotifier
                                                  .incrementQuantity(index),
                                              child: const Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                ),
                                                child: Icon(
                                                  Icons.add,
                                                  size: 14,
                                                  color: AppColors.brandBlack,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 10),

                  // 2. Voucher Input Box
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E5EA)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.confirmation_number_outlined,
                          size: 18,
                          color: AppColors.coralOrange,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _couponController,
                            decoration: InputDecoration(
                              hintText: strings.couponHint,
                              hintStyle: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            if (_couponController.text.isNotEmpty) {
                              cartNotifier.applyCoupon(_couponController.text);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(strings.couponAppliedMessage),
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.coralOrange,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          child: Text(
                            strings.applyAction,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 3. Billing Summary Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE5E5EA)),
                    ),
                    child: Column(
                      children: [
                        _buildBillRow(
                          strings.subtotalLabel,
                          cartState.formattedSubtotal,
                        ),
                        const SizedBox(height: 10),
                        _buildBillRow(
                          strings.shippingFeeLabel,
                          cartState.shippingFee == 0
                              ? strings.freeLabel
                              : '${cartState.shippingFee.toInt()}₫',
                          valueColor: AppColors.liveGreen,
                        ),
                        if (cartState.discount > 0) ...[
                          const SizedBox(height: 10),
                          _buildBillRow(
                            strings.voucherDiscountLabel,
                            cartState.formattedDiscount,
                            valueColor: AppColors.saleRed,
                          ),
                        ],
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(color: Color(0xFFE5E5EA)),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                strings.totalPaymentCartLabel,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.brandBlack,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: AnimatedPriceCounter(
                                price: cartState.total,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.coralOrange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 4. Checkout Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          AppRouter.page(
                            builder: (_) => const CheckoutScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.coralOrange,
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                        elevation: 2,
                        shadowColor: AppColors.coralOrange.withValues(
                          alpha: 0.4,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            strings.proceedToOrderAction(
                              cartState.totalItemCount,
                            ),
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildBillRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
