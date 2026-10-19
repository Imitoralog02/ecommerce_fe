import 'package:flutter/material.dart';
import '../../../../core/navigation/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../wallet/domain/entities/voucher_entity.dart';
import '../../../wallet/presentation/viewmodels/wallet_viewmodel.dart';
import '../../../wallet/presentation/views/voucher_wallet_screen.dart';

class NeoraVoucherStrip extends ConsumerWidget {
  const NeoraVoucherStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletViewModelProvider);
    final vouchers = walletState.vouchers.take(6).toList();
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final cardHeight = 76.0 + ((textScale - 1) * 20).clamp(0, 20);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Voucher cho bạn 🎁',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    AppRouter.page(builder: (_) => const VoucherWalletScreen()),
                  );
                },
                child: const Text(
                  'Xem tất cả ›',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.coralOrange,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: cardHeight + 2,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: vouchers.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final v = vouchers[index];
              return _buildVoucherCard(context, ref, v, cardHeight);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVoucherCard(
    BuildContext context,
    WidgetRef ref,
    VoucherEntity v,
    double cardHeight,
  ) {
    final isSaved = v.isSaved;
    final isMint = v.isMint;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          AppRouter.page(builder: (_) => const VoucherWalletScreen()),
        );
      },
      child: Container(
        width: 236,
        height: cardHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(3),
          boxShadow: const [],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              children: [
                // Left part with dashed border
                Container(
                  width: 72,
                  height: cardHeight,
                  decoration: BoxDecoration(
                    color: isMint
                        ? AppColors.liveGreenSoft
                        : AppColors.softPeach,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(18),
                    ),
                    border: const Border(
                      right: BorderSide(
                        color: Color(0xFFD0CAC4),
                        width: 1.5,
                        style: BorderStyle.solid,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        v.discountLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isMint
                              ? AppColors.liveGreen
                              : AppColors.lyraWarmText,
                        ),
                      ),
                      Text(
                        v.discountValue,
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          height: 1.05,
                          color: isMint
                              ? AppColors.liveGreen
                              : AppColors.lyraWarmText,
                        ),
                      ),
                    ],
                  ),
                ),

                // Right part with details & action
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          v.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          v.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Notch cutouts (top & bottom half-circles)
            Positioned(
              left: 64,
              top: -7,
              child: Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: 64,
              bottom: -7,
              child: Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Save Button
            Positioned(
              right: 10,
              bottom: 10,
              child: GestureDetector(
                onTap: () {
                  ref
                      .read(walletViewModelProvider.notifier)
                      .toggleSaveVoucher(v.id);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isSaved
                            ? 'Đã xoá voucher khỏi ví!'
                            : 'Đã lưu voucher vào ví thành công! 🎟️',
                      ),
                      backgroundColor: AppColors.brandBlack,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4.5,
                  ),
                  decoration: BoxDecoration(
                    color: isSaved
                        ? const Color(0xFFD9CFC7)
                        : (isMint
                              ? AppColors.liveGreen
                              : AppColors.coralOrange),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isSaved ? 'Đã lưu' : 'Lưu',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSaved
                          ? Colors.white
                          : (isMint ? Colors.white : const Color(0xFF1A1815)),
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
}
