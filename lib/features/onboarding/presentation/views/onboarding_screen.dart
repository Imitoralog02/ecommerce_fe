import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/views/auth_screen.dart';
import '../viewmodels/onboarding_viewmodel.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;
  String _selectedOccasion = 'Đi làm';

  static const _pages = [
    (
      title: 'Ít hơn,\nđúng chất bạn.',
      subtitle:
          'Chào mừng đến NÉORA. Cùng tìm cảm hứng mặc đẹp, tự nhiên trong từng ngày.',
      image: 'assets/images/real/splash_1_couple.jpg',
      label: 'PHONG CÁCH BẮT ĐẦU TỪ BẠN',
    ),
    (
      title: 'Đúng dịp, đúng gu.\nVừa ngân sách.',
      subtitle:
          'Bạn chọn hoàn cảnh và mức chi. NÉORA gợi ý cả bộ, để bạn tự tin là chính mình.',
      image: 'assets/images/real/splash_2_work.jpg',
      label: 'STYLIST CỦA RIÊNG BẠN',
    ),
    (
      title: 'Tủ đồ có gu.\nChọn theo cách bạn.',
      subtitle:
          'Thời trang nam, nữ và phụ kiện có chọn lọc. Tìm món bạn yêu, mua sắm cùng NÉORA.',
      image: 'assets/images/real/splash_3_women.jpg',
      label: 'KHÁM PHÁ & MUA SẮM',
    ),
  ];

  @override
  void initState() {
    super.initState();
    final initialPage = ref.read(onboardingViewModelProvider);
    _pageController = PageController(initialPage: initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _skipToHome({int tabIndex = 0}) async {
    await ref.read(onboardingRepositoryProvider).markOnboardingSeen();
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.main,
      arguments: tabIndex,
    );
  }

  Future<void> _startWithNeora() async {
    await ref.read(onboardingRepositoryProvider).markOnboardingSeen();
    if (!mounted) return;
    Navigator.push(context, AppRouter.page(builder: (_) => const AuthScreen()));
  }

  void _nextPage(int page) {
    if (page < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _startWithNeora();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = ref.watch(onboardingViewModelProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header: NÉORA | Bỏ qua (Screens 1-2) or MẶC ĐẸP MỖI NGÀY (Screen 3)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 10),
              child: Row(
                children: [
                  const Text('NÉORA', style: AppTypography.splashLogo),
                  const Spacer(),
                  if (currentPage == 2)
                    const Text(
                      'MẶC ĐẸP MỖI NGÀY',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTypography.sansFont,
                        fontSize: 9.5,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    )
                  else
                    TextButton(
                      onPressed: _startWithNeora,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Bỏ qua',
                        style: TextStyle(
                          fontFamily: AppTypography.sansFont,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 3 Splash / Onboarding Slides
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: ref
                    .read(onboardingViewModelProvider.notifier)
                    .selectPage,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final visualHeight = (constraints.maxHeight * 0.58).clamp(
                        180.0,
                        390.0,
                      );
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: visualHeight,
                              width: double.infinity,
                              child: _buildPageVisual(index, page.image),
                            ),
                            const SizedBox(height: 22),
                            Text(
                              page.label,
                              style: AppTypography.architecturalCode.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                                letterSpacing: 1.4,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              page.title,
                              style: AppTypography.splashHeadline.copyWith(
                                fontSize: 28,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              page.subtitle,
                              style: AppTypography.body.copyWith(
                                fontSize: 13,
                                height: 1.55,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Bottom Progress & CTA Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      ...List.generate(
                        _pages.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          width: index == currentPage ? 22 : 8,
                          height: 3,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: index == currentPage
                                ? AppColors.primary
                                : AppColors.divider,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '0${currentPage + 1} / 03',
                        style: AppTypography.bodySmall.copyWith(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _nextPage(currentPage),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: Text(
                        currentPage == 2
                            ? 'Bắt đầu cùng NÉORA  →'
                            : 'Tiếp tục  →',
                        style: const TextStyle(
                          fontFamily: AppTypography.sansFont,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
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

  Widget _buildPageVisual(int index, String imagePath) {
    // Splash Screen 1 (01 / 03): Chào đón · NÉORA
    if (index == 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(imagePath, fit: BoxFit.cover),
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'CHÀO BẠN, NÉORA ĐÂY.',
                  style: TextStyle(
                    fontFamily: AppTypography.sansFont,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Splash Screen 2 (02 / 03): Phối đồ mỗi ngày · NÉORA
    if (index == 1) {
      final occasionImage = switch (_selectedOccasion) {
        'Đi chơi' => 'assets/images/real/p_knit.jpg',
        'Dự tiệc' => 'assets/images/real/p_dress.jpg',
        _ => imagePath,
      };
      final occasionPrice = switch (_selectedOccasion) {
        'Đi chơi' => '1.470.000 ₫',
        'Dự tiệc' => '1.680.000 ₫',
        _ => '1.770.000 ₫',
      };

      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(occasionImage, fit: BoxFit.cover),
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _buildOccasionChip(
                    'Đi làm',
                    active: _selectedOccasion == 'Đi làm',
                  ),
                  _buildOccasionChip(
                    'Đi chơi',
                    active: _selectedOccasion == 'Đi chơi',
                  ),
                  _buildOccasionChip(
                    'Dự tiệc',
                    active: _selectedOccasion == 'Dự tiệc',
                  ),
                ],
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ngân sách cả bộ',
                          style: TextStyle(
                            fontFamily: AppTypography.sansFont,
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '1.800.000 ₫',
                          style: TextStyle(
                            fontFamily: AppTypography.sansFont,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Divider(height: 1, color: AppColors.divider),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '3 món · NÉORA chọn cho bạn',
                          style: TextStyle(
                            fontFamily: AppTypography.sansFont,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          occasionPrice,
                          style: const TextStyle(
                            fontFamily: AppTypography.sansFont,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Splash Screen 3 (03 / 03): Khám phá phong cách · NÉORA
    return Column(
      children: [
        Expanded(
          flex: 6,
          child: Row(
            children: [
              Expanded(
                child: _buildCategoryCard(
                  'assets/images/real/splash_3_women.jpg',
                  'Nữ ↗',
                  onTap: () => _skipToHome(tabIndex: 1),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildCategoryCard(
                  'assets/images/real/splash_3_men.jpg',
                  'Nam ↗',
                  alignment: const Alignment(0, -0.5),
                  onTap: () => _skipToHome(tabIndex: 1),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          flex: 3,
          child: GestureDetector(
            onTap: () => _skipToHome(tabIndex: 1),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.studioGray,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: AspectRatio(
                      aspectRatio: 1.25,
                      child: Image.asset(
                        'assets/images/real/splash_3_acc.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ĐIỂM NHẤN VỪA ĐỦ',
                          style: TextStyle(
                            fontFamily: AppTypography.sansFont,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            color: AppColors.textMuted,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text.rich(
                          TextSpan(
                            text: 'Phụ kiện ',
                            style: TextStyle(
                              fontFamily: AppTypography.bookSerifFont,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            children: [
                              TextSpan(
                                text: '↗',
                                style: TextStyle(
                                  fontFamily: AppTypography.sansFont,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Túi, giày & trang sức',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppTypography.sansFont,
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOccasionChip(String text, {required bool active}) {
    return GestureDetector(
      onTap: () => setState(() => _selectedOccasion = text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary
              : AppColors.background.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: AppTypography.sansFont,
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    String image,
    String label, {
    Alignment alignment = Alignment.center,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(image, fit: BoxFit.cover, alignment: alignment),
            Positioned(
              left: 10,
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: AppTypography.sansFont,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
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
