import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// A quiet editorial ending for the Home feed, with paths into existing flows.
class HomeClosingSection extends StatelessWidget {
  final VoidCallback onOpenWeekendLooks;
  final VoidCallback onOpenVouchers;
  final VoidCallback onBackToTop;

  const HomeClosingSection({
    super.key,
    required this.onOpenWeekendLooks,
    required this.onOpenVouchers,
    required this.onBackToTop,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 34, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 22, height: 1, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'CẢM HỨNG MỖI NGÀY',
                style: AppTypography.architecturalCode.copyWith(
                  color: AppColors.primary,
                  fontSize: 10,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          const Text(
            'Mặc theo nhịp riêng.',
            style: AppTypography.editorialHeadline,
          ),
          const SizedBox(height: 6),
          const Text(
            'Một vài gợi ý nhẹ nhàng để bạn bắt đầu bộ đồ tiếp theo.',
            style: AppTypography.body,
          ),
          const SizedBox(height: 18),
          Semantics(
            button: true,
            label: 'Xem gợi ý phối đồ cuối tuần',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onOpenWeekendLooks,
                borderRadius: BorderRadius.circular(6),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: AspectRatio(
                    aspectRatio: 1.22,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          'assets/images/real/splash_3_women.jpg',
                          fit: BoxFit.cover,
                          alignment: const Alignment(0, -0.2),
                        ),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: [0, .5, 1],
                              colors: [
                                Color(0x3D1A1D17),
                                Colors.transparent,
                                Color(0xD91A1D17),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 14,
                          left: 14,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            color: AppColors.background,
                            child: const Text(
                              'NÉORA GỢI Ý',
                              style: TextStyle(
                                fontFamily: AppTypography.sansFont,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.1,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 18,
                          right: 18,
                          bottom: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Cuối tuần, cứ là bạn.',
                                style: TextStyle(
                                  fontFamily: AppTypography.serifFont,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                'Phối một bộ vừa vặn với ngày đi chơi.',
                                style: TextStyle(
                                  fontFamily: AppTypography.sansFont,
                                  fontSize: 12,
                                  color: Color(0xFFF2F0EA),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Flexible(
                                    child: Text(
                                      'Xem gợi ý phối đồ',
                                      style: TextStyle(
                                        fontFamily: AppTypography.sansFont,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 15,
                                    color: Colors.white,
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
              ),
            ),
          ),
          const SizedBox(height: 22),
          Material(
            color: AppColors.studioGray,
            borderRadius: BorderRadius.circular(6),
            child: InkWell(
              onTap: onOpenVouchers,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.cardBorder),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE6EBE3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.loyalty_outlined,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 13),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NÉORA CLUB',
                            style: TextStyle(
                              fontFamily: AppTypography.sansFont,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Ưu đãi cho tủ đồ của bạn',
                            style: TextStyle(
                              fontFamily: AppTypography.serifFont,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Xem voucher và xu trong bản demo',
                            style: TextStyle(
                              fontFamily: AppTypography.sansFont,
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 19,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 18),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('NÉORA', style: AppTypography.brandLogo),
                    SizedBox(height: 2),
                    Text('Mặc đẹp mỗi ngày.', style: AppTypography.bodySmall),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: onBackToTop,
                icon: const Icon(Icons.arrow_upward_rounded, size: 15),
                label: const Text('Lên đầu trang'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
