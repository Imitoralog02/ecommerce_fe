import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/product_visual_widget.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../navigation/presentation/views/main_nav_screen.dart';
import '../../../reviews/presentation/views/write_review_screen.dart';
import '../../../tracking/presentation/views/order_tracking_screen.dart';
import '../../domain/entities/order_entity.dart';
import '../viewmodels/order_viewmodel.dart';
import 'order_detail_screen.dart';

class OrderHistoryScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;

  const OrderHistoryScreen({super.key, this.initialTabIndex = 0});

  @override
  ConsumerState<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends ConsumerState<OrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabs = [
    'Tất cả',
    'Chờ xác nhận',
    'Chờ lấy hàng',
    'Đang giao',
    'Đã giao',
    'Đã huỷ',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, _tabs.length - 1),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  OrderStatus? _getOrderStatusForTab(int tabIndex) {
    switch (tabIndex) {
      case 1:
        return OrderStatus.pendingConfirmation;
      case 2:
        return OrderStatus.processing;
      case 3:
        return OrderStatus.shipping;
      case 4:
        return OrderStatus.delivered;
      case 5:
        return OrderStatus.cancelled;
      default:
        return null; // Tất cả
    }
  }

  void _handleBuyAgain(OrderEntity order) {
    ref.read(orderViewModelProvider.notifier).buyAgain(order);

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
            Expanded(
              child: Text(
                'Đã thêm ${order.totalItemCount} sản phẩm vào giỏ hàng',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'Xem giỏ',
          textColor: AppColors.coralOrange,
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              AppRouter.page(
                builder: (_) => const MainNavScreen(initialIndex: 2),
              ),
              (route) => false,
            );
          },
        ),
        backgroundColor: AppColors.brandBlack,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(milliseconds: 2500),
      ),
    );
  }

  void _handleCancelOrder(OrderEntity order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text(
          'Huỷ đơn hàng?',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16.5,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Bạn có chắc chắn muốn huỷ đơn hàng #${order.id} không? Bạn vẫn có thể mua lại sau này.',
          style: const TextStyle(
            fontSize: 13.5,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Giữ đơn',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final cancelled = ref
                  .read(orderViewModelProvider.notifier)
                  .cancelOrder(order.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    cancelled
                        ? 'Đã huỷ đơn hàng #${order.id}'
                        : 'Không thể huỷ đơn hàng ở trạng thái hiện tại.',
                  ),
                  backgroundColor: AppColors.saleRed,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.saleRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Huỷ đơn',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  void _handleReview(OrderEntity order) {
    if (order.items.isNotEmpty) {
      Navigator.push(
        context,
        AppRouter.page(
          builder: (_) =>
              WriteReviewScreen(order: order, item: order.items.first),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Đơn mua của tôi',
          style: TextStyle(
            fontSize: 16.5,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFEBE5DC), width: 1),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelPadding: const EdgeInsets.symmetric(horizontal: 16),
              labelColor: AppColors.coralOrange,
              labelStyle: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
              ),
              unselectedLabelColor: AppColors.textSecondary,
              unselectedLabelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              indicatorColor: AppColors.coralOrange,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(_tabs.length, (tabIndex) {
          final targetStatus = _getOrderStatusForTab(tabIndex);
          final orders = orderState.getOrdersByStatus(targetStatus);

          if (orders.isEmpty) {
            return _buildEmptyTab(context, _tabs[tabIndex]);
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 40),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return _buildOrderCard(context, orders[index]);
            },
          );
        }),
      ),
    );
  }

  Widget _buildEmptyTab(BuildContext context, String tabName) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.softPeach,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.receipt_long_outlined,
                  size: 36,
                  color: AppColors.coralOrange,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Chưa có đơn hàng nào',
              style: const TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Bạn chưa có đơn hàng nào trong mục "$tabName".',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  AppRouter.page(
                    builder: (_) => const MainNavScreen(initialIndex: 0),
                  ),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandBlack,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                'KHÁM PHÁ NGAY',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderEntity order) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          AppRouter.page(builder: (_) => OrderDetailScreen(order: order)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF502814).withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: ID + Date + Status Badge
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.softPeach,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.storefront_outlined,
                      size: 16,
                      color: AppColors.primaryBurgundy,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '#${order.id}',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          order.orderDateFormatted,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
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
                      color: order.status.bgColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      order.status.label,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: order.status.textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: Color(0xFFF2ECE4)),

            // Product items list
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: order.items
                    .map((item) => _buildOrderItemRow(item))
                    .toList(),
              ),
            ),

            const Divider(height: 1, color: Color(0xFFF2ECE4)),

            // Total payment row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order.totalItemCount} sản phẩm',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        'Thành tiền: ',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        order.formattedTotal,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryBurgundy,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: Color(0xFFF2ECE4)),

            // Action Buttons Footer
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Tracking button (for shipping / processing)
                  if (order.status == OrderStatus.shipping ||
                      order.status == OrderStatus.processing) ...[
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          AppRouter.page(
                            builder: (_) =>
                                OrderTrackingScreen(orderId: order.id),
                          ),
                        );
                      },
                      icon: const Icon(Icons.local_shipping_outlined, size: 16),
                      label: const Text('Theo dõi đơn'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.cardBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],

                  // Cancel button (only for pending confirmation)
                  if (order.status == OrderStatus.pendingConfirmation) ...[
                    OutlinedButton(
                      onPressed: () => _handleCancelOrder(order),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.saleRed,
                        side: const BorderSide(color: Color(0xFFE8C4C4)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: const Text('Huỷ đơn'),
                    ),
                    const SizedBox(width: 8),
                  ],

                  // Review button (for delivered)
                  if (order.status == OrderStatus.delivered) ...[
                    OutlinedButton.icon(
                      onPressed: () => _handleReview(order),
                      icon: const Icon(Icons.star_outline_rounded, size: 16),
                      label: const Text('Đánh giá'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.coralOrange,
                        side: const BorderSide(color: AppColors.coralOrange),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],

                  // Re-order button (Primary button)
                  ElevatedButton.icon(
                    onPressed: () => _handleBuyAgain(order),
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Mua lại'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandBlack,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 9,
                      ),
                      elevation: 0,
                      textStyle: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemRow(CartItemEntity item) {
    final product = item.product;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 58,
              height: 58,
              color: AppColors.softPeach,
              child: product.imagePath != null
                  ? Image.asset(
                      product.imagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          ProductVisualWidget(
                            imageType: product.imageType,
                            size: 40,
                          ),
                    )
                  : ProductVisualWidget(imageType: product.imageType, size: 40),
            ),
          ),
          const SizedBox(width: 12),

          // Title & size/color & quantity
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Phân loại: ${item.selectedSize}, ${item.selectedColor}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'x${item.quantity}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      item.formattedTotalPrice,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
