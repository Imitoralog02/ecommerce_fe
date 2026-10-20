import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/product_visual_widget.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../checkout/domain/entities/checkout_selection.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/presentation/viewmodels/order_viewmodel.dart';
import '../../domain/entities/tracking_snapshot.dart';
import '../viewmodels/tracking_viewmodel.dart';

class OrderTrackingScreen extends ConsumerStatefulWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, this.orderId = 'NEO-2094'});

  @override
  ConsumerState<OrderTrackingScreen> createState() =>
      _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends ConsumerState<OrderTrackingScreen> {
  int _selectedTab = 1; // 0: Processing, 1: Shipped, 2: Delivered
  bool _showAllOrders = false;
  String? _activeOrderId;
  Timer? _cartNavigationTimer;

  OrderEntity get _trackedOrder {
    final orderState = ref.read(orderViewModelProvider);
    return orderState.findById(_activeOrderId ?? widget.orderId) ??
        orderState.orders.first;
  }

  List<CartItemEntity> get _orderItems => _trackedOrder.items;

  void _handleBuyItAgain() {
    ref.read(orderViewModelProvider.notifier).buyAgain(_trackedOrder);

    final totalPieces = _orderItems.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );

    // Show floating black toast exactly like video 2 (0:13)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(
              '$totalPieces pieces are back in your bag',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.brandBlack,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(milliseconds: 1800),
      ),
    );

    // Navigate to Cart tab in MainNavScreen
    _cartNavigationTimer?.cancel();
    _cartNavigationTimer = Timer(const Duration(milliseconds: 600), () {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.main,
          (route) => false,
          arguments: 2,
        );
      }
    });
  }

  @override
  void dispose() {
    _cartNavigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Center(
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: AppColors.textPrimary,
            ),
            onPressed: () {
              if (_showAllOrders) {
                setState(() => _showAllOrders = false);
              } else {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.main,
                  (route) => false,
                  arguments: 0,
                );
              }
            },
          ),
        ),
        centerTitle: true,
        title: Text(
          _showAllOrders ? 'Đơn hàng của tôi' : widget.orderId,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: _showAllOrders ? 'Theo dõi một đơn' : 'Tất cả đơn hàng',
            icon: Icon(
              _showAllOrders
                  ? Icons.receipt_long
                  : Icons.format_list_bulleted_rounded,
              size: 20,
              color: AppColors.textPrimary,
            ),
            onPressed: () {
              setState(() => _showAllOrders = !_showAllOrders);
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.shopping_bag_outlined,
              size: 20,
              color: AppColors.textPrimary,
            ),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.main,
                (route) => false,
                arguments: 2,
              );
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: _showAllOrders ? _buildMyOrdersView() : _buildTrackingDetailView(),
    );
  }

  // 1. Single Order Tracking Detail View (NÉORA Video 2: 0:06 - 0:14)
  Widget _buildTrackingDetailView() {
    final tracking = ref.watch(
      trackingViewModelProvider((
        orderId: _trackedOrder.id,
        status: _trackedOrder.status,
      )),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header with Status Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _trackedOrder.status == OrderStatus.cancelled
                          ? 'Đơn hàng đã huỷ'
                          : _trackedOrder.status == OrderStatus.delivered
                          ? 'Đơn hàng đã giao'
                          : _trackedOrder.shippingType ==
                                ShippingType.storePickup
                          ? 'Dự kiến nhận: ${_trackedOrder.estimatedDelivery ?? _trackedOrder.shippingType.demoEstimatedDelivery}'
                          : 'Dự kiến giao: ${_trackedOrder.estimatedDelivery ?? _trackedOrder.shippingType.demoEstimatedDelivery}',
                      style: TextStyle(
                        fontFamily: AppTypography.serifFont,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Đặt ngày ${_trackedOrder.orderDateFormatted} · ${_trackedOrder.shippingType.displayLabel}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _trackedOrder.status.bgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 6,
                      color: _trackedOrder.status.textColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      tracking.statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _trackedOrder.status.textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),

          // 3-Step Horizontal Stepper (Processing -> Shipped -> Delivered)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStepIcon(
                      Icons.inventory_2_outlined,
                      isDone: tracking.isStepDone(TrackingStage.processing),
                      isActive: tracking.isStepActive(TrackingStage.processing),
                    ),
                    Expanded(
                      child: Container(
                        height: 2,
                        color: tracking.isStepDone(TrackingStage.shipping)
                            ? AppColors.brandBlack
                            : AppColors.divider,
                      ),
                    ),
                    _buildStepIcon(
                      Icons.local_shipping_outlined,
                      isDone: tracking.isStepDone(TrackingStage.shipping),
                      isActive: tracking.isStepActive(TrackingStage.shipping),
                    ),
                    Expanded(
                      child: Container(
                        height: 2,
                        color: tracking.isStepDone(TrackingStage.delivered)
                            ? AppColors.brandBlack
                            : AppColors.divider,
                      ),
                    ),
                    _buildStepIcon(
                      Icons.check_circle_outline_rounded,
                      isDone: tracking.isStepDone(TrackingStage.delivered),
                      isActive: tracking.isStepActive(TrackingStage.delivered),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Đang xử lý',
                        style: _stepLabelStyle(
                          tracking,
                          TrackingStage.processing,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Đang giao',
                        textAlign: TextAlign.center,
                        style: _stepLabelStyle(
                          tracking,
                          TrackingStage.shipping,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Đã giao',
                        textAlign: TextAlign.right,
                        style: _stepLabelStyle(
                          tracking,
                          TrackingStage.delivered,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Items List Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sản phẩm',
                style: TextStyle(
                  fontFamily: AppTypography.serifFont,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${_trackedOrder.totalItemCount} sản phẩm',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ..._orderItems.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.studioGray,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: item.product.imagePath != null
                          ? Image.asset(
                              item.product.imagePath!,
                              width: 54,
                              height: 54,
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => ProductVisualWidget(
                                imageType: item.product.imageType,
                                size: 50,
                              ),
                            )
                          : ProductVisualWidget(
                              imageType: item.product.imageType,
                              size: 50,
                            ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product.title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Kích thước ${item.selectedSize} · Số lượng ${item.quantity}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    item.formattedTotalPrice,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 20),

          // Delivery Details Card
          const Text(
            'Giao hàng',
            style: TextStyle(
              fontFamily: AppTypography.serifFont,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
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
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      tracking.deliveryMethod,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(color: AppColors.divider, height: 1),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _trackedOrder.shippingAddress.fullAddress,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textPrimary,
                              height: 1.3,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            '${_trackedOrder.shippingAddress.recipientName} · ${_trackedOrder.shippingAddress.phoneNumber}',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(color: AppColors.divider, height: 1),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.payment_outlined,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                    SizedBox(width: 10),
                    Text(
                      _trackedOrder.paymentMethod,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Payment Summary Card
          const Text(
            'Tóm tắt thanh toán',
            style: TextStyle(
              fontFamily: AppTypography.serifFont,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                _buildSummaryLine('Tạm tính', _trackedOrder.formattedSubtotal),
                const SizedBox(height: 8),
                _buildSummaryLine(
                  'Phí vận chuyển',
                  _trackedOrder.formattedShippingFee,
                ),
                const SizedBox(height: 8),
                _buildSummaryLine('Thuế', 'Đã bao gồm'),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(color: AppColors.divider, height: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Tổng thanh toán',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _trackedOrder.formattedTotal,
                      style: const TextStyle(
                        fontFamily: AppTypography.sansFont,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // BUY IT AGAIN Capsule Button (Video 2: 0:12)
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _handleBuyItAgain,
              icon: const Icon(Icons.shopping_bag_outlined, size: 18),
              label: const Text(
                'MUA LẠI',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandBlack,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // 2. Full "My Orders" View (NÉORA Video 2: 0:17)
  Widget _buildMyOrdersView() {
    final tabs = ['Đang xử lý', 'Đang giao', 'Đã giao'];
    final allOrders = ref.watch(orderViewModelProvider).orders;
    final orders = allOrders.where((order) {
      return switch (_selectedTab) {
        0 =>
          order.status == OrderStatus.pendingConfirmation ||
              order.status == OrderStatus.processing,
        1 => order.status == OrderStatus.shipping,
        _ => order.status == OrderStatus.delivered,
      };
    }).toList();

    return Column(
      children: [
        // Tabs: Processing, Shipped, Delivered
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          height: 44,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.studioGray,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: tabs.asMap().entries.map((entry) {
              final idx = entry.key;
              final name = entry.value;
              final isSelected = _selectedTab == idx;
              return Expanded(
                child: Semantics(
                  button: true,
                  selected: isSelected,
                  label: 'Lọc đơn hàng: $name',
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => setState(() => _selectedTab = idx),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Orders List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            itemCount: orders.length,
            itemBuilder: (context, idx) {
              final ord = orders[idx];
              return Semantics(
                button: true,
                label: 'Xem đơn hàng ${ord.id}',
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => setState(() {
                    _activeOrderId = ord.id;
                    _showAllOrders = false;
                  }),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.cardBorder),
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
                        Container(
                          width: 54,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.studioGray,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: ProductVisualWidget(
                              imageType: ord.items.first.product.imageType,
                              size: 42,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ord.id,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Đặt ngày ${ord.orderDateFormatted}',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text(
                                    '${ord.totalItemCount} sản phẩm',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    ord.formattedTotal,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: ord.status.bgColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '• ${ord.status.label}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: ord.status.textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStepIcon(
    IconData icon, {
    required bool isDone,
    required bool isActive,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.brandBlack
            : (isDone ? AppColors.brandBlack : Colors.transparent),
        shape: BoxShape.circle,
        border: Border.all(
          color: (isActive || isDone)
              ? AppColors.brandBlack
              : AppColors.divider,
          width: 1.5,
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 18,
          color: (isActive || isDone) ? Colors.white : AppColors.textMuted,
        ),
      ),
    );
  }

  TextStyle _stepLabelStyle(TrackingSnapshot tracking, TrackingStage stage) =>
      TextStyle(
        fontSize: 10.5,
        fontWeight: tracking.isStepActive(stage)
            ? FontWeight.w700
            : FontWeight.w600,
        color: tracking.isStepDone(stage)
            ? AppColors.textPrimary
            : AppColors.textMuted,
      );

  Widget _buildSummaryLine(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
