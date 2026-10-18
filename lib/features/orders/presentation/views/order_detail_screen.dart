import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/product_visual_widget.dart';
import '../../../product_detail/presentation/views/product_detail_screen.dart';
import '../../../returns/presentation/views/return_request_screen.dart';
import '../../../reviews/presentation/views/write_review_screen.dart';
import '../../../support/presentation/views/live_chat_screen.dart';
import '../../../tracking/presentation/views/order_tracking_screen.dart';
import '../../domain/entities/order_entity.dart';
import '../viewmodels/order_viewmodel.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final OrderEntity order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  late OrderEntity _currentOrder;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã sao chép $label ✨'),
        backgroundColor: AppColors.brandBlack,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _handleCancelOrder() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text(
          'Huỷ đơn hàng?',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.5),
        ),
        content: Text(
          'Bạn có chắc chắn muốn huỷ đơn hàng #${_currentOrder.id}? Đơn hàng sẽ không thể khôi phục.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Không huỷ',
              style: TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(orderViewModelProvider.notifier)
                  .cancelOrder(_currentOrder.id);
              setState(() {
                _currentOrder = _currentOrder.copyWith(
                  status: OrderStatus.cancelled,
                );
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Đã huỷ đơn hàng thành công.'),
                  backgroundColor: AppColors.brandBlack,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
              'Xác nhận huỷ',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = _currentOrder.status;

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
          'Chi Tiết Đơn Hàng',
          style: TextStyle(
            fontSize: 16.5,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.chat_outlined,
              size: 20,
              color: AppColors.textPrimary,
            ),
            onPressed: () {
              Navigator.push(
                context,
                AppRouter.page(
                  builder: (_) => LiveChatScreen(
                    initialProduct: _currentOrder.items.isNotEmpty
                        ? _currentOrder.items.first.product
                        : null,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActionBar(context),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Status Hero Banner
            _buildStatusHeroBanner(status),

            const SizedBox(height: 18),

            // 2. Shipping Address Card
            _buildDeliveryCard(),

            const SizedBox(height: 18),

            // 3. Ordered Items List
            _buildItemsListCard(),

            const SizedBox(height: 18),

            // 4. Payment & Invoice Breakdown
            _buildInvoiceCard(),

            const SizedBox(height: 18),

            // 5. Order Metadata (ID, Timestamps, Tracking)
            _buildOrderMetadataCard(),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeroBanner(OrderStatus status) {
    IconData statusIcon = Icons.local_shipping_outlined;
    String statusTitle = status.label;
    String statusSubtitle = 'Đơn hàng đang được hệ thống xử lý.';

    if (status == OrderStatus.delivered) {
      statusIcon = Icons.task_alt_rounded;
      statusSubtitle = 'Kiện hàng đã được giao thành công tới bạn.';
    } else if (status == OrderStatus.shipping) {
      statusIcon = Icons.local_shipping_rounded;
      statusSubtitle = 'Shipper đang trên đường giao kiện hàng tới bạn.';
    } else if (status == OrderStatus.processing) {
      statusIcon = Icons.inventory_2_outlined;
      statusSubtitle = 'NÉORA đang đóng gói cẩn thận trang phục của bạn.';
    } else if (status == OrderStatus.pendingConfirmation) {
      statusIcon = Icons.hourglass_top_rounded;
      statusSubtitle = 'Đang chờ xác nhận thanh toán & tiếp nhận đơn.';
    } else if (status == OrderStatus.cancelled) {
      statusIcon = Icons.cancel_outlined;
      statusSubtitle = 'Đơn hàng đã được huỷ theo yêu cầu.';
    }

    // Step index for progress bar
    int currentStep = 1;
    if (status == OrderStatus.processing) currentStep = 2;
    if (status == OrderStatus.shipping) currentStep = 3;
    if (status == OrderStatus.delivered) currentStep = 4;
    if (status == OrderStatus.cancelled) currentStep = 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF502814).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: status.bgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(statusIcon, color: status.textColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusTitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: status.textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      statusSubtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (status != OrderStatus.cancelled) ...[
            const SizedBox(height: 18),
            const Divider(height: 1, color: Color(0xFFF2ECE4)),
            const SizedBox(height: 16),

            // 4-Step Mini Timeline
            Row(
              children: [
                _buildTimelineStep(1, 'Đặt hàng', currentStep >= 1),
                _buildTimelineLine(currentStep >= 2),
                _buildTimelineStep(2, 'Chuẩn bị', currentStep >= 2),
                _buildTimelineLine(currentStep >= 3),
                _buildTimelineStep(3, 'Đang giao', currentStep >= 3),
                _buildTimelineLine(currentStep >= 4),
                _buildTimelineStep(4, 'Đã giao', currentStep >= 4),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineStep(int stepNum, String title, bool isCompleted) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isCompleted ? AppColors.brandBlack : const Color(0xFFF7F4EF),
            shape: BoxShape.circle,
            border: Border.all(
              color: isCompleted ? AppColors.brandBlack : AppColors.cardBorder,
            ),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : Text(
                    '$stepNum',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMuted,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: isCompleted ? FontWeight.w800 : FontWeight.w500,
            color: isCompleted ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineLine(bool isCompleted) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 2,
        color: isCompleted ? AppColors.brandBlack : const Color(0xFFE5DDD3),
      ),
    );
  }

  Widget _buildDeliveryCard() {
    final addr = _currentOrder.shippingAddress;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.softPeach,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.coralOrange,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Địa Chỉ Nhận Hàng',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${addr.recipientName} · ${addr.phoneNumber}',
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: AppColors.brandBlack,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${addr.streetAddress}, ${addr.district}, ${addr.city}',
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F4EF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.bolt_rounded,
                  size: 16,
                  color: AppColors.coralOrange,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Đơn vị vận chuyển: GHN Express 2h (Mã: ${_currentOrder.trackingNumber ?? "GHN-VN-882194"})',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsListCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sản Phẩm Đã Mua',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${_currentOrder.totalItemCount} sản phẩm',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF0EBE3)),
          ..._currentOrder.items.map((item) {
            return Column(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      AppRouter.page(
                        builder: (_) =>
                            ProductDetailScreen(product: item.product),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: 64,
                            height: 64,
                            child: item.product.imagePath != null
                                ? Image.asset(
                                    item.product.imagePath!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) =>
                                        ProductVisualWidget(
                                          imageType: item.product.imageType,
                                        ),
                                  )
                                : ProductVisualWidget(
                                    imageType: item.product.imageType,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Phân loại: ${item.selectedColor} / Size ${item.selectedSize}',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item.formattedTotalPrice,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primaryBurgundy,
                                    ),
                                  ),
                                  Text(
                                    'x${item.quantity}',
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textSecondary,
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
                ),
                const Divider(height: 1, color: Color(0xFFF0EBE3)),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chi Tiết Thanh Toán',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildReceiptRow(
            'Tiền hàng (Tạm tính)',
            _currentOrder.formattedSubtotal,
          ),
          _buildReceiptRow(
            'Phí vận chuyển',
            _currentOrder.shippingFee == 0
                ? 'Miễn phí'
                : '${_currentOrder.shippingFee.toInt()}₫',
            isGreen: _currentOrder.shippingFee == 0,
          ),
          if (_currentOrder.discountAmount > 0)
            _buildReceiptRow(
              'Giảm giá Voucher NÉORA',
              '- ${_currentOrder.discountAmount.toInt()}₫',
              isGreen: true,
            ),
          if (_currentOrder.couponCode != null)
            _buildReceiptRow('Mã ưu đãi', _currentOrder.couponCode!),
          if (_currentOrder.coinReward > 0)
            _buildReceiptRow(
              'Xu đã hoàn',
              '+${_currentOrder.coinReward} xu',
              isGreen: true,
            ),
          if (_currentOrder.giftDescription != null)
            _buildReceiptRow(
              'Quà tặng',
              _currentOrder.giftDescription!,
              isGreen: true,
            ),
          const Divider(height: 20, color: Color(0xFFF0EBE3)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng thanh toán:',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                _currentOrder.formattedTotal,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryBurgundy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F4EF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.payment_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Phương thức: ${_currentOrder.paymentMethod}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderMetadataCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
              const Text(
                'Mã đơn hàng:',
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
              Row(
                children: [
                  Text(
                    '#${_currentOrder.id}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: AppColors.brandBlack,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () =>
                        _copyToClipboard(_currentOrder.id, 'mã đơn hàng'),
                    child: const Icon(
                      Icons.copy_rounded,
                      size: 14,
                      color: AppColors.coralOrange,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Thời gian đặt hàng:',
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                _currentOrder.orderDateFormatted,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brandBlack,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String title, String value, {bool isGreen = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: isGreen ? AppColors.liveGreen : AppColors.brandBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context) {
    final status = _currentOrder.status;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          // If Pending Confirmation: Cancel button
          if (status == OrderStatus.pendingConfirmation) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _handleCancelOrder,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.saleRed,
                  side: const BorderSide(color: Color(0xFFE8C4C4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Huỷ đơn hàng',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
              ),
            ),
          ],

          // If Shipping or Processing: Tracking Button
          if (status == OrderStatus.shipping ||
              status == OrderStatus.processing) ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    AppRouter.page(
                      builder: (_) =>
                          OrderTrackingScreen(orderId: _currentOrder.id),
                    ),
                  );
                },
                icon: const Icon(Icons.local_shipping_outlined, size: 18),
                label: const Text(
                  'THEO DÕI VẬN CHUYỂN',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandBlack,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
              ),
            ),
          ],

          // If Delivered: 30-Day Returns + Review buttons
          if (status == OrderStatus.delivered) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    AppRouter.page(
                      builder: (_) => ReturnRequestScreen(order: _currentOrder),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.cardBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Đổi / Trả 30 ngày',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_currentOrder.items.isNotEmpty) {
                    Navigator.push(
                      context,
                      AppRouter.page(
                        builder: (_) => WriteReviewScreen(
                          order: _currentOrder,
                          item: _currentOrder.items.first,
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(
                  Icons.star_rounded,
                  size: 18,
                  color: Color(0xFFC8A97E),
                ),
                label: const Text(
                  'Đánh giá (+50 xu)',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandBlack,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
              ),
            ),
          ],

          // If Cancelled: Buy Again button
          if (status == OrderStatus.cancelled) ...[
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  ref
                      .read(orderViewModelProvider.notifier)
                      .buyAgain(_currentOrder);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandBlack,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                child: const Text(
                  'ĐẶT LẠI ĐƠN HÀNG',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
