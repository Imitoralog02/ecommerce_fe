import 'dart:math' as math;
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

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _floatController;

  static const List<Map<String, dynamic>> _onboardingData = [
    {
      'title': 'Hàng nghìn mẫu mới\nmỗi ngày cho bạn',
      'highlight': 'mỗi ngày',
      'subtitle':
          'Khám phá thời trang hợp gu, hợp túi tiền — được chọn riêng theo phong cách của bạn.',
      'image': 'assets/images/real/onb_shopping.jpg',
      'bgGradient': [Color(0xFFEFE8DE), Color(0xFFF7F4EF)],
      'badge1': {'icon': '🛍️', 'title': '10.000+', 'sub': 'mẫu mới mỗi tuần'},
      'badge2': {'icon': '🔥', 'title': '−50%', 'sub': 'hôm nay'},
    },
    {
      'title': 'Mua sắm dễ dàng\nchỉ với vài chạm',
      'highlight': 'dễ dàng',
      'subtitle':
          'Xem ảnh thật, đánh giá thật từ người mua. Lưu món yêu thích và thanh toán chỉ trong 30 giây.',
      'image': 'assets/images/real/onb_browsing.jpg',
      'bgGradient': [Color(0xFFF2ECE1), Color(0xFFF7F4EF)],
      'badge1': {'icon': '⭐', 'title': '4.9 / 5', 'sub': '2.000+ đánh giá'},
      'badge2': {
        'icon': '💖',
        'title': 'Yêu thích',
        'sub': 'lưu nhanh tiện lợi',
      },
    },
    {
      'title': 'Giao nhanh 2 giờ,\nđổi trả miễn phí',
      'highlight': '2 giờ',
      'subtitle':
          'Nhận hàng ngay trong ngày tại nội thành. Không vừa ý? Đổi trả miễn phí trong 30 ngày.',
      'image': 'assets/images/real/onb_delivery.jpg',
      'bgGradient': [Color(0xFFE8EFE8), Color(0xFFF7F4EF)],
      'badge1': {'icon': '🚚', 'title': 'Giao 2h', 'sub': 'nội thành'},
      'badge2': {'icon': '✅', 'title': '30 ngày', 'sub': 'đổi trả miễn phí'},
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _floatController
        ..stop()
        ..value = 0.5;
    } else if (!_floatController.isAnimating) {
      _floatController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _skipToHome() async {
    await ref.read(onboardingRepositoryProvider).markOnboardingSeen();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.main, arguments: 0);
  }

  void _nextPage(int currentPage) {
    if (currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    } else {
      _skipToHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = ref.watch(onboardingViewModelProvider);
    final currentItem = _onboardingData[currentPage];

    return Scaffold(
      backgroundColor: AppColors.warmBackground,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.65],
            colors: currentItem['bgGradient'] as List<Color>,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 1. Top Header: Bước & Nút Bỏ qua
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        '${currentPage + 1} / ${_onboardingData.length}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.friendlySubText,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _skipToHome,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.85),
                        foregroundColor: AppColors.friendlyText,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Bỏ qua',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. 3D Card Stack với ảnh thật
              Expanded(
                flex: 11,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _onboardingData.length,
                  onPageChanged: ref
                      .read(onboardingViewModelProvider.notifier)
                      .selectPage,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final item = _onboardingData[index];
                    return AnimatedBuilder(
                      animation: Listenable.merge([
                        _pageController,
                        _floatController,
                      ]),
                      builder: (context, child) {
                        double pageOffset = 0.0;
                        if (_pageController.position.haveDimensions) {
                          pageOffset = (_pageController.page ?? 0) - index;
                        }

                        // Hiệu ứng 3D perspective rotation và scale
                        final gauss = math.exp(-math.pow(pageOffset * 1.5, 2));
                        final angle = pageOffset * 0.25;

                        // Hiệu ứng nhấp nhô lơ lửng 3D liên tục (Continuous Idle Floating)
                        final floatProgress = _floatController.value;
                        final floatY1 =
                            math.sin(floatProgress * math.pi * 2) * 7.5;
                        final floatY2 =
                            -math.sin(floatProgress * math.pi * 2) * 7.0;
                        final floatRot1 =
                            math.sin(floatProgress * math.pi * 2) * 0.035;
                        final floatRot2 =
                            -math.cos(floatProgress * math.pi * 2) * 0.035;

                        return Transform(
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(-angle)
                            ..rotateZ(angle * 0.3)
                            ..scaleByDouble(
                              0.92 + 0.08 * gauss,
                              0.92 + 0.08 * gauss,
                              1.0,
                              1.0,
                            ),
                          alignment: Alignment.center,
                          child: Center(
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // Thẻ ảnh chính bo tròn viền trắng sang trọng
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.76,
                                  height:
                                      MediaQuery.of(context).size.height * 0.44,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(36),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 6,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF14120E,
                                        ).withValues(alpha: 0.12),
                                        blurRadius: 36,
                                        offset: const Offset(0, 20),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(30),
                                    child: Image.asset(
                                      item['image'] as String,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                color: AppColors.softPeach,
                                                child: const Icon(
                                                  Icons.image_outlined,
                                                  size: 60,
                                                  color: AppColors.coralOrange,
                                                ),
                                              ),
                                    ),
                                  ),
                                ),

                                // 3D Floating Sticker 1 (Bay lơ lửng liên tục)
                                Positioned(
                                  top: 24,
                                  left: -20,
                                  child: Transform(
                                    transform: Matrix4.identity()
                                      ..translateByDouble(
                                        pageOffset * 20,
                                        floatY1,
                                        0.0,
                                        1.0,
                                      )
                                      ..rotateZ(floatRot1),
                                    child: _buildStickerBadge(
                                      icon: item['badge1']['icon']!,
                                      title: item['badge1']['title']!,
                                      sub: item['badge1']['sub']!,
                                    ),
                                  ),
                                ),

                                // 3D Floating Sticker 2 (Bay lơ lửng liên tục)
                                Positioned(
                                  bottom: 24,
                                  right: -16,
                                  child: Transform(
                                    transform: Matrix4.identity()
                                      ..translateByDouble(
                                        -pageOffset * 24,
                                        floatY2,
                                        0.0,
                                        1.0,
                                      )
                                      ..rotateZ(floatRot2),
                                    child: _buildStickerBadge(
                                      icon: item['badge2']['icon']!,
                                      title: item['badge2']['title']!,
                                      sub: item['badge2']['sub']!,
                                      isAccent: index == 0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // 3. Bottom White Sheet: Tiêu đề tiếng Việt, Indicator & Nút bấm
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 28,
                      offset: Offset(0, -10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tiêu đề nổi bật
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      child: Text(
                        currentItem['title'] as String,
                        key: ValueKey<int>(currentPage),
                        style: const TextStyle(
                          fontFamily: AppTypography.sansFont,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          height: 1.25,
                          color: AppColors.friendlyText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Phụ đề mô tả thân thiện
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      child: Text(
                        currentItem['subtitle'] as String,
                        key: ValueKey<int>(currentPage),
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          height: 1.55,
                          color: AppColors.friendlySubText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Dots Indicator & Nút hành động
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Dots
                        Row(
                          children: List.generate(
                            _onboardingData.length,
                            (idx) => AnimatedContainer(
                              duration: const Duration(milliseconds: 350),
                              margin: const EdgeInsets.only(right: 6),
                              width: currentPage == idx ? 28 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: currentPage == idx
                                    ? AppColors.coralOrange
                                    : AppColors.cardBorder,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),

                        // Nút "Tiếp tục" / "Bắt đầu mua sắm"
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () => _nextPage(currentPage),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.coralOrange,
                              foregroundColor: Colors.white,
                              elevation: 8,
                              shadowColor: AppColors.coralOrange.withValues(
                                alpha: 0.4,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  currentPage == _onboardingData.length - 1
                                      ? 'Bắt đầu mua sắm'
                                      : 'Tiếp tục',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (currentPage == _onboardingData.length - 1) ...[
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            AppRouter.page(builder: (_) => const AuthScreen()),
                          );
                        },
                        child: Center(
                          child: Text.rich(
                            TextSpan(
                              text: 'Đã có tài khoản? ',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.friendlySubText,
                              ),
                              children: const [
                                TextSpan(
                                  text: 'Đăng nhập',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.brandBlack,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStickerBadge({
    required String icon,
    required String title,
    required String sub,
    bool isAccent = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isAccent ? AppColors.coralOrange : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: isAccent ? Colors.white : AppColors.friendlyText,
                ),
              ),
              Text(
                sub,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isAccent ? Colors.white70 : AppColors.friendlySubText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
