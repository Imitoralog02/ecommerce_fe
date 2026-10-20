import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../cart/presentation/viewmodels/cart_viewmodel.dart';
import '../../domain/entities/voucher_entity.dart';
import '../viewmodels/wallet_viewmodel.dart';

class VoucherWalletScreen extends ConsumerStatefulWidget {
  final int initialTab;

  const VoucherWalletScreen({super.key, this.initialTab = 0});

  @override
  ConsumerState<VoucherWalletScreen> createState() =>
      _VoucherWalletScreenState();
}

class _VoucherWalletScreenState extends ConsumerState<VoucherWalletScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;

  final List<VoucherType> _tabTypes = [
    VoucherType.all,
    VoucherType.shipping,
    VoucherType.discount,
    VoucherType.vipOnly,
    VoucherType.coinReward,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(
      length: _tabTypes.length,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, _tabTypes.length - 1),
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ref
            .read(walletViewModelProvider.notifier)
            .selectTab(_tabTypes[_tabController.index]);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    if (lifecycleState == AppLifecycleState.resumed) {
      ref.read(walletViewModelProvider.notifier).refreshDailyStatus();
    }
  }

  void _handleCheckIn() {
    final success = ref.read(walletViewModelProvider.notifier).checkInDaily();
    if (success) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Text('🎉', style: TextStyle(fontSize: 20)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Điểm danh thành công! Bạn nhận được +50 Xu NÉORA 🪙',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.brandBlack,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _copyVoucherCode(VoucherEntity voucher) {
    Clipboard.setData(ClipboardData(text: voucher.code));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.liveGreen,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Đã sao chép mã "${voucher.code}" vào bộ nhớ tạm! 📋',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.brandBlack,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _useVoucher(VoucherEntity voucher) {
    final applied = ref
        .read(cartViewModelProvider.notifier)
        .applyCoupon(voucher.code);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          applied
              ? 'Đã áp dụng voucher ${voucher.code} cho giỏ hàng.'
              : ref
                        .read(cartViewModelProvider.notifier)
                        .couponRejection(voucher.code) ??
                    'Voucher này chưa áp dụng được cho giỏ hàng hiện tại.',
        ),
        backgroundColor: AppColors.brandBlack,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 2),
      ),
    );
    if (applied) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletViewModelProvider);
    final filteredVouchers = walletState.filteredVouchers;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: Center(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cardBorder, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        title: const Text(
          'Ví Voucher & Điểm Thưởng',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.help_outline_rounded,
              size: 22,
              color: AppColors.textSecondary,
            ),
            onPressed: () {
              _showRulesModal(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. VIP Member Card & Coin Balance
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: _buildRewardCard(walletState),
            ),

            const SizedBox(height: 14),

            // 2. 3 Wallet Summary Boxes
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatBox(
                      '🪙',
                      walletState.formattedCoinBalance,
                      'Xu NÉORA',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatBox(
                      '🎟️',
                      '${walletState.savedCount}',
                      'Voucher đã lưu',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: _buildStatBox('💳', '150K', 'Ví NÉORA')),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 3. Voucher Classification TabBar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 44,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder, width: 1),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicator: BoxDecoration(
                    color: AppColors.brandBlack,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  tabs: [
                    Tab(text: 'Tất cả (${walletState.vouchers.length})'),
                    Tab(text: 'Freeship (${walletState.freeshipCount})'),
                    Tab(text: 'Giảm giá (${walletState.discountCount})'),
                    Tab(text: 'VIP (${walletState.vipCount})'),
                    Tab(text: 'Hoàn xu (${walletState.coinRewardCount})'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 4. Voucher Tickets List
            if (filteredVouchers.isEmpty)
              _buildEmptyVoucherState()
            else
              ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredVouchers.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final voucher = filteredVouchers[index];
                  return _buildVoucherTicket(voucher);
                },
              ),

            const SizedBox(height: 24),

            // 5. Recent Points Activity / Transactions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lịch sử tích & dùng xu',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.cardBorder, width: 1),
                    ),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: walletState.transactions.length,
                      separatorBuilder: (_, _) =>
                          const Divider(height: 1, color: AppColors.cardBorder),
                      itemBuilder: (context, index) {
                        final tx = walletState.transactions[index];
                        final isPositive = tx.coinDelta > 0;
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: AppColors.softPeach,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    tx.icon,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tx.title,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      tx.date,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${isPositive ? "+" : ""}${tx.coinDelta} xu',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w900,
                                  color: isPositive
                                      ? AppColors.liveGreen
                                      : AppColors.saleRed,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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

  Widget _buildRewardCard(WalletState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFDFC59E), Color(0xFFC8A97E), Color(0xFFB89260)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF502814).withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ĐIỂM THƯỞNG NÉORA',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: Color(0xD01A1815),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        state.formattedCoinBalance,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1A1815),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'xu',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1815),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1815),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Text('👑', style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 4),
                    Text(
                      state.memberTier,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFDFC59E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Container(
              height: 7,
              width: double.infinity,
              color: const Color(0xFF1A1815).withValues(alpha: 0.16),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: state.tierProgress,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1815),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 6),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                state.memberTier.contains('Kim Cương') ? 'Kim Cương' : 'Vàng',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1815),
                ),
              ),
              Text(
                state.memberTier.contains('Kim Cương')
                    ? 'Đã đạt hạng Kim Cương 💎'
                    : 'Còn ${state.coinsToNextTier} xu để lên Kim Cương 💎',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1815),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Interactive Daily Check-in Button
          GestureDetector(
            onTap: state.checkedInToday ? null : _handleCheckIn,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: state.checkedInToday
                    ? const Color(0xFF1A1815).withValues(alpha: 0.75)
                    : const Color(0xFF1A1815),
                borderRadius: BorderRadius.circular(14),
                boxShadow: state.checkedInToday
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    state.checkedInToday
                        ? Icons.check_circle_rounded
                        : Icons.calendar_today_rounded,
                    size: 16,
                    color: state.checkedInToday
                        ? AppColors.mintGreen
                        : const Color(0xFFDFC59E),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      state.checkedInToday
                          ? '✓ Đã điểm danh hôm nay (+50 xu)'
                          : 'Điểm danh ngay · Nhận +50 Xu mỗi ngày ✨',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        color: state.checkedInToday
                            ? Colors.white70
                            : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String emoji, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF502814).withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoucherTicket(VoucherEntity voucher) {
    final isMint = voucher.isMint;

    return Container(
      height: 106,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF502814).withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            children: [
              // 1. Left Ticket Stomp with Value
              Container(
                width: 90,
                decoration: BoxDecoration(
                  color: isMint ? AppColors.liveGreenSoft : AppColors.softPeach,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(20),
                  ),
                  border: const Border(
                    right: BorderSide(
                      color: Color(0xFFDCD6CE),
                      width: 1.2,
                      style: BorderStyle.solid,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      voucher.discountLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: isMint
                            ? AppColors.liveGreen
                            : AppColors.lyraWarmText,
                      ),
                    ),
                    Text(
                      voucher.discountValue,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                        color: isMint
                            ? AppColors.liveGreen
                            : AppColors.lyraWarmText,
                      ),
                    ),
                    if (voucher.minOrderValue > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'Đơn từ ${(voucher.minOrderValue / 1000).toInt()}K',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: isMint
                                ? AppColors.liveGreen
                                : AppColors.lyraWarmText,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // 2. Right Ticket Info & Actions
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  voucher.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (voucher.tag.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: voucher.tag == 'ĐỘC QUYỀN VIP'
                                        ? AppColors.primaryBurgundySoft
                                        : AppColors.warmYellow,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    voucher.tag,
                                    style: TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w900,
                                      color: voucher.tag == 'ĐỘC QUYỀN VIP'
                                          ? AppColors.lyraWarmText
                                          : const Color(0xFF4A2E00),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            voucher.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),

                      // Footer with Expiry & Actions
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.access_time_rounded,
                                  size: 12,
                                  color: AppColors.textMuted,
                                ),
                                const SizedBox(width: 3),
                                Expanded(
                                  child: Tooltip(
                                    message: voucher.expiryDate,
                                    child: Text(
                                      voucher.expiryDate,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),

                          // Action Buttons
                          Row(
                            children: [
                              // Copy Code Button
                              GestureDetector(
                                onTap: () => _copyVoucherCode(voucher),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.cardBorder,
                                      width: 0.8,
                                    ),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.copy_rounded,
                                        size: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Mã',
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(width: 6),

                              // Apply / Save Button
                              GestureDetector(
                                onTap: voucher.isUsed
                                    ? null
                                    : () {
                                        if (voucher.isSaved) {
                                          _useVoucher(voucher);
                                        } else {
                                          ref
                                              .read(
                                                walletViewModelProvider
                                                    .notifier,
                                              )
                                              .toggleSaveVoucher(voucher.id);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).hideCurrentSnackBar();
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Đã lưu mã "${voucher.code}" vào ví! 🎟️',
                                              ),
                                              backgroundColor:
                                                  AppColors.brandBlack,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              duration: const Duration(
                                                seconds: 2,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 11,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: voucher.isSaved
                                        ? AppColors.brandBlack
                                        : AppColors.coralOrange,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    voucher.isUsed
                                        ? 'Đã dùng'
                                        : voucher.isSaved
                                        ? 'Dùng ngay'
                                        : 'Lưu',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w900,
                                      color: voucher.isSaved
                                          ? Colors.white
                                          : const Color(0xFF1A1815),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Perforated notches at line separator (top & bottom circles)
          Positioned(
            left: 82,
            top: -8,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 82,
            bottom: -8,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyVoucherState() {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.softPeach,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🎟️', style: TextStyle(fontSize: 34)),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Chưa có voucher trong mục này',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Hãy quay lại vào các khung giờ vàng để săn thêm nhiều mã ưu đãi hấp dẫn nhé.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showRulesModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Row(
                children: [
                  Text('🪙', style: TextStyle(fontSize: 22)),
                  SizedBox(width: 8),
                  Text(
                    'Quy chế Điểm thưởng & Hạng VIP',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildRuleItem(
                '1',
                'Tích xu mua sắm',
                'Mỗi 10.000₫ chi tiêu tại NÉORA tích luỹ 1 xu thưởng.',
              ),
              _buildRuleItem(
                '2',
                'Điểm danh hàng ngày',
                'Chạm nhận ngay +50 xu mỗi ngày khi mở ứng dụng.',
              ),
              _buildRuleItem(
                '3',
                'Thăng hạng Hội viên',
                'Vàng (2.000 xu) · Kim Cương (3.000 xu) hưởng chiết khấu tới 15% và freeship vô hạn.',
              ),
              _buildRuleItem(
                '4',
                'Sử dụng xu',
                'Xu NÉORA dùng để giảm giá trực tiếp khi thanh toán hoặc đổi voucher độc quyền.',
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandBlack,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Đã hiểu',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRuleItem(String step, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: AppColors.softPeach,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: AppColors.lyraWarmText,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
