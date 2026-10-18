import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/product_visual_widget.dart';
import '../../../cart/presentation/viewmodels/cart_viewmodel.dart';
import '../../../home/domain/entities/product_entity.dart';
import '../../../home/presentation/viewmodels/home_viewmodel.dart';
import '../../../product_detail/presentation/views/product_detail_screen.dart';

class FlashSaleTimeSlot {
  final String time;
  final String status;
  final bool isActive;
  final bool isUpcoming;
  final bool isPast;

  const FlashSaleTimeSlot({
    required this.time,
    required this.status,
    this.isActive = false,
    this.isUpcoming = false,
    this.isPast = false,
  });
}

class FlashSaleScreen extends ConsumerStatefulWidget {
  const FlashSaleScreen({super.key});

  @override
  ConsumerState<FlashSaleScreen> createState() => _FlashSaleScreenState();
}

class _FlashSaleScreenState extends ConsumerState<FlashSaleScreen> {
  int _selectedSlotIndex = 1; // Default to 12:00 (active)
  late int _remainingSeconds;
  Timer? _countdownTimer;

  final Set<String> _reminderSlots = {};

  final List<FlashSaleTimeSlot> _slots = const [
    FlashSaleTimeSlot(time: '09:00', status: 'Đã kết thúc', isPast: true),
    FlashSaleTimeSlot(time: '12:00', status: 'Đang diễn ra 🔥', isActive: true),
    FlashSaleTimeSlot(
      time: '18:00',
      status: 'Sắp diễn ra 🔔',
      isUpcoming: true,
    ),
    FlashSaleTimeSlot(
      time: '21:00',
      status: 'Sắp diễn ra 🔔',
      isUpcoming: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _remainingSeconds = 9520; // 02h 38m 40s
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  String _formatPad(int n) => n.toString().padLeft(2, '0');

  String _formatVnd(double price) {
    final intPrice = price.toInt();
    final s = intPrice.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
      buffer.write(s[i]);
    }
    return '${buffer.toString()}₫';
  }

  void _toggleReminder(String time) {
    setState(() {
      if (_reminderSlots.contains(time)) {
        _reminderSlots.remove(time);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã huỷ nhắc nhở khung giờ $time 🔕'),
            backgroundColor: AppColors.brandBlack,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } else {
        _reminderSlots.add(time);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Đã đặt nhắc nhở khung giờ $time thành công! 🔔 NÉORA sẽ báo trước 10 phút.',
            ),
            backgroundColor: AppColors.brandBlack,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeViewModelProvider);
    final allProducts = homeState.allProducts;

    final hours = _remainingSeconds ~/ 3600;
    final minutes = (_remainingSeconds % 3600) ~/ 60;
    final seconds = _remainingSeconds % 60;

    final selectedSlot = _slots[_selectedSlotIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // 1. Luxury Dark Sliver AppBar with Countdown
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: const Color(0xFF141211),
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.share_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Đã sao chép liên kết Flash Sale NÉORA ✨',
                      ),
                      backgroundColor: AppColors.brandBlack,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF221A15), Color(0xFF110E0D)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.saleRed,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.bolt_rounded,
                                color: Colors.white,
                                size: 15,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'FLASH SALE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'GIỜ VÀNG NÉORA',
                          style: TextStyle(
                            color: AppColors.camelGold,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ưu đãi lên đến -50%',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        // Live Flip Clock
                        if (selectedSlot.isActive)
                          Row(
                            children: [
                              _buildTimeBox(_formatPad(hours)),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 3),
                                child: Text(
                                  ':',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              _buildTimeBox(_formatPad(minutes)),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 3),
                                child: Text(
                                  ':',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              _buildTimeBox(_formatPad(seconds)),
                            ],
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              selectedSlot.isPast
                                  ? 'ĐÃ KẾT THÚC'
                                  : 'SẮP DIỄN RA',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Sticky Time Slot Bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverSlotHeaderDelegate(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: List.generate(_slots.length, (index) {
                      final slot = _slots[index];
                      final isSelected = _selectedSlotIndex == index;

                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedSlotIndex = index);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.brandBlack
                                : const Color(0xFFF6F3EF),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.brandBlack
                                  : const Color(0xFFEBE5DC),
                              width: 1.2,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                slot.time,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.brandBlack,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                slot.status,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? (slot.isActive
                                            ? AppColors.camelGold
                                            : Colors.white70)
                                      : AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),

          // 3. Voucher Strip Promo
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 14, 16, 6),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.softPeach,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.coralOrange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.confirmation_num_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MÃ: FLASH50 — Giảm 50.000₫',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: AppColors.brandBlack,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Áp dụng đơn từ 299K trong khung giờ flash sale',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(const ClipboardData(text: 'FLASH50'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Đã sao chép mã FLASH50! Nhập khi thanh toán 🏷️',
                          ),
                          backgroundColor: AppColors.brandBlack,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.coralOrange),
                      ),
                      child: const Text(
                        'LƯU MÃ',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: AppColors.coralOrange,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. Products List
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final product = allProducts[index % allProducts.length];
                return _buildFlashSaleProductCard(
                  context,
                  product,
                  index,
                  selectedSlot,
                );
              }, childCount: allProducts.isNotEmpty ? allProducts.length : 0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBox(String val) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.coralOrange,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: AppColors.coralOrange.withValues(alpha: 0.35),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        val,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 13,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }

  Widget _buildFlashSaleProductCard(
    BuildContext context,
    ProductEntity product,
    int index,
    FlashSaleTimeSlot slot,
  ) {
    // Generate realistic stock & discount data
    final discounts = [35, 45, 50, 40, 30, 48];
    final soldPercents = [86, 92, 74, 95, 68, 88];
    final remainingCount = [4, 2, 7, 1, 9, 3];

    final discount = discounts[index % discounts.length];
    final soldPercent = soldPercents[index % soldPercents.length];
    final remaining = remainingCount[index % remainingCount.length];

    final originalPrice = product.originalPrice ?? (product.price * 1.5);
    final salePrice = product.price * (1 - discount / 100);

    final isSlotActive = slot.isActive;
    final isSlotUpcoming = slot.isUpcoming;
    final hasReminder = _reminderSlots.contains(slot.time);

    return Container(
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
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            AppRouter.page(
              builder: (_) => ProductDetailScreen(product: product),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image with Discount Badge
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 100,
                      height: 105,
                      color: const Color(0xFFF5EFEB),
                      child: ProductVisualWidget(
                        imageType: product.imageType,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.saleRed,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '-$discount%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 14),

              // Product Info & Stock Progress
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          _formatVnd(salePrice),
                          style: const TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryBurgundy,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatVnd(originalPrice),
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textMuted,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Stock Progress Bar (for Active slot)
                    if (isSlotActive) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Stack(
                          children: [
                            Container(
                              height: 13,
                              width: double.infinity,
                              color: const Color(0xFFFFECE5),
                            ),
                            FractionallySizedBox(
                              widthFactor: (soldPercent / 100).clamp(0.0, 1.0),
                              child: Container(
                                height: 13,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFFFF7E40),
                                      Color(0xFFD9381E),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: Text(
                                  remaining <= 3
                                      ? '🔥 Chỉ còn $remaining suất'
                                      : 'Đã bán $soldPercent%',
                                  style: const TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black45,
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],

                    // Action Button based on Slot State
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (isSlotActive)
                          ElevatedButton(
                            onPressed: () {
                              ref
                                  .read(cartViewModelProvider.notifier)
                                  .addToCart(product, 'M');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Đã thêm "${product.title}" vào giỏ hàng chớp nhoáng ⚡',
                                  ),
                                  backgroundColor: AppColors.brandBlack,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.coralOrange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.bolt_rounded, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'SĂN NGAY',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (isSlotUpcoming)
                          OutlinedButton(
                            onPressed: () => _toggleReminder(slot.time),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: hasReminder
                                  ? AppColors.camelGold
                                  : AppColors.brandBlack,
                              side: BorderSide(
                                color: hasReminder
                                    ? AppColors.camelGold
                                    : const Color(0xFFD6CFC7),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  hasReminder
                                      ? Icons.notifications_active_rounded
                                      : Icons.notifications_none_rounded,
                                  size: 16,
                                  color: hasReminder
                                      ? AppColors.camelGold
                                      : AppColors.brandBlack,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  hasReminder ? 'ĐÃ ĐẶT NHẮC' : 'NHẮC TÔI',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11.5,
                                    color: hasReminder
                                        ? AppColors.camelGold
                                        : AppColors.brandBlack,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2ECE6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'HẾT GIỜ SALE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMuted,
                              ),
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
    );
  }
}

class _SliverSlotHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverSlotHeaderDelegate({required this.child});

  @override
  double get minExtent => 76;

  @override
  double get maxExtent => 76;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _SliverSlotHeaderDelegate oldDelegate) => true;
}
