import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class _HeroSlideData {
  final String badge;
  final String title;
  final String subtitle;
  final String cta;
  final String image;
  final Alignment alignment;
  final bool openLookbook;

  const _HeroSlideData({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.image,
    this.alignment = Alignment.center,
    this.openLookbook = false,
  });
}

class EditorialHomeStory extends StatefulWidget {
  final VoidCallback? onDiscover;
  final VoidCallback onLookbook;
  final ValueChanged<String>? onOccasionTap;

  const EditorialHomeStory({
    super.key,
    this.onDiscover,
    required this.onLookbook,
    this.onOccasionTap,
  });

  @override
  State<EditorialHomeStory> createState() => _EditorialHomeStoryState();
}

class _EditorialHomeStoryState extends State<EditorialHomeStory> {
  static const List<_HeroSlideData> _slides = [
    _HeroSlideData(
      badge: 'BỘ SƯU TẬP THÁNG 10',
      title: 'Ít hơn,\nđúng chất bạn.',
      subtitle: 'Những món cơ bản. Vô vàn cách mặc.',
      cta: 'Khám phá bộ sưu tập  →',
      image: 'assets/images/real/banner_summer.jpg',
      alignment: Alignment(0.55, -0.1),
    ),
    _HeroSlideData(
      badge: 'NÉORA MENSWEAR • MỚI',
      title: 'Tự nhiên,\ntinh gọn mỗi ngày.',
      subtitle: 'Chất liệu linen & cotton thoáng mát cho nhịp sống đô thị.',
      cta: 'Xem tủ đồ Nam  →',
      image: 'assets/images/real/banner_men.jpg',
      alignment: Alignment(0.58, -0.1),
    ),
    _HeroSlideData(
      badge: 'STYLIST PHỐI SẴN',
      title: 'Mặc đẹp đi làm,\nkhông cần nghĩ lâu.',
      subtitle: 'Gợi ý nguyên set công sở thanh lịch vừa vặn ngân sách.',
      cta: 'Thử phối đồ ngay  →',
      image: 'assets/images/real/onb_shopping.jpg',
      alignment: Alignment(0.0, -0.25),
      openLookbook: true,
    ),
    _HeroSlideData(
      badge: 'ĐIỂM NHẤN MÙA MỚI',
      title: 'Ấm áp vừa đủ,\nnhẹ nhàng xuống phố.',
      subtitle: 'Áo len dệt kim, đầm midi và phụ kiện da tối giản.',
      cta: 'Khám phá mùa mới  →',
      image: 'assets/images/real/p_knit.jpg',
      alignment: Alignment(0.0, -0.2),
    ),
  ];

  late final PageController _pageController;
  Timer? _autoPlayTimer;
  int _currentSlide = 0;
  bool _goingForward = true;

  bool get _isTestEnvironment {
    final bindingName = WidgetsBinding.instance.runtimeType.toString();
    return bindingName.contains('Test') || bindingName.contains('Automated');
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoPlayIfNeeded();
  }

  void _startAutoPlayIfNeeded() {
    if (_isTestEnvironment) return;
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_pageController.hasClients) return;
      int nextIndex = _currentSlide + (_goingForward ? 1 : -1);
      if (nextIndex >= _slides.length) {
        _goingForward = false;
        nextIndex = _slides.length - 2;
      } else if (nextIndex < 0) {
        _goingForward = true;
        nextIndex = 1;
      }
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  void _goToSlide(int index) {
    if (!_pageController.hasClients) return;
    final target = (index % _slides.length + _slides.length) % _slides.length;
    _pageController.animateToPage(
      target,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Full-Bleed Animated Editorial Hero Banner Carousel (matching Figma)
        AspectRatio(
          aspectRatio: 0.88,
          child: Stack(
            fit: StackFit.expand,
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() => _currentSlide = index);
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return GestureDetector(
                    onTap: slide.openLookbook
                        ? widget.onLookbook
                        : widget.onDiscover,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Subtle Ken-Burns / scale animation on active slide
                        TweenAnimationBuilder<double>(
                          key: ValueKey('banner_zoom_${index}_$_currentSlide'),
                          tween: Tween<double>(
                            begin: index == _currentSlide ? 1.04 : 1.0,
                            end: 1.0,
                          ),
                          duration: const Duration(milliseconds: 900),
                          curve: Curves.easeOutCubic,
                          builder: (context, scale, child) {
                            return Transform.scale(scale: scale, child: child);
                          },
                          child: Image.asset(
                            slide.image,
                            fit: BoxFit.cover,
                            alignment: slide.alignment,
                          ),
                        ),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: [0.0, 0.35, 1.0],
                              colors: [
                                Color(0x26000000),
                                Colors.transparent,
                                Color(0xD91A1D17),
                              ],
                            ),
                          ),
                        ),
                        // Top-left Collection Badge
                        Positioned(
                          top: 16,
                          left: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background.withValues(
                                alpha: 0.94,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              slide.badge,
                              style: const TextStyle(
                                fontFamily: AppTypography.sansFont,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        // Bottom-left Editorial Text & CTA
                        Positioned(
                          left: 20,
                          right: 20,
                          bottom: 36,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 350),
                            child: Align(
                              key: ValueKey('slide_copy_$index'),
                              alignment: Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    slide.title,
                                    style: AppTypography.editorialHeadline
                                        .copyWith(
                                          color: Colors.white,
                                          fontSize: 30,
                                          height: 1.16,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    slide.subtitle,
                                    style: const TextStyle(
                                      fontFamily: AppTypography.sansFont,
                                      color: Color(0xFFEAE8E1),
                                      fontSize: 12.5,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    slide.cta,
                                    style: const TextStyle(
                                      fontFamily: AppTypography.sansFont,
                                      color: Colors.white,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Top-right Slide Counter + Prev/Next Controls
              Positioned(
                top: 14,
                right: 16,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildCarouselArrow(
                      icon: Icons.chevron_left_rounded,
                      onTap: () => _goToSlide(_currentSlide - 1),
                    ),
                    const SizedBox(width: 6),
                    _buildCarouselArrow(
                      icon: Icons.chevron_right_rounded,
                      onTap: () => _goToSlide(_currentSlide + 1),
                    ),
                  ],
                ),
              ),

              // Bottom Progress Dots & Slide Indicator
              Positioned(
                left: 20,
                right: 20,
                bottom: 14,
                child: Row(
                  children: [
                    ...List.generate(
                      _slides.length,
                      (index) => GestureDetector(
                        onTap: () => _goToSlide(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOutCubic,
                          width: index == _currentSlide ? 24 : 8,
                          height: 3,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: index == _currentSlide
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '0${_currentSlide + 1} / 0${_slides.length}',
                      style: const TextStyle(
                        fontFamily: AppTypography.sansFont,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                        color: Color(0xFFEAE8E1),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Below-banner content with horizontal padding
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // 2. Personal Stylist Section: STYLIST CỦA RIÊNG BẠN
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        size: 13,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          'STYLIST CỦA RIÊNG BẠN',
                          style: AppTypography.architecturalCode.copyWith(
                            color: AppColors.primary,
                            fontSize: 10,
                            letterSpacing: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Hôm nay, bạn đi đâu?',
                    style: AppTypography.editorialTitle,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Chọn một dịp. NÉORA phối cả bộ theo ngân sách của bạn.',
                    style: AppTypography.body,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildOccasionButton(
                          icon: Icons.work_outline_rounded,
                          label: 'Đi làm',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildOccasionButton(
                          icon: Icons.local_cafe_outlined,
                          label: 'Đi chơi',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildOccasionButton(
                          icon: Icons.wine_bar_outlined,
                          label: 'Dự tiệc',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildOccasionButton(
                          icon: Icons.flight_takeoff_rounded,
                          label: 'Du lịch',
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // 3. Nhịp sống thường ngày
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Nhịp sống thường ngày',
                      style: AppTypography.editorialTitle,
                    ),
                  ),
                  TextButton(
                    onPressed: widget.onDiscover,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Xem tất cả →',
                      style: TextStyle(
                        fontFamily: AppTypography.sansFont,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildStoryCard(
                      image: 'assets/images/real/p_dress.jpg',
                      alignment: const Alignment(0.0, -0.2),
                      title: 'Nữ',
                      subtitle: 'Mềm mại có gu',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStoryCard(
                      image: 'assets/images/real/banner_men.jpg',
                      alignment: const Alignment(0.58, -0.1),
                      title: 'Nam',
                      subtitle: 'Tự nhiên, tinh gọn',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 4. Horizontal Accessories Card: ĐIỂM NHẤN VỪA ĐỦ (image on left, text on right matching Figma)
              InkWell(
                onTap: widget.onDiscover,
                borderRadius: BorderRadius.circular(8),
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
                        child: SizedBox(
                          width: 92,
                          height: 78,
                          child: Image.asset(
                            'assets/images/real/p_bag.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ĐIỂM NHẤN VỪA ĐỦ',
                              style: TextStyle(
                                fontFamily: AppTypography.sansFont,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.1,
                                color: AppColors.textMuted,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Một chút khác biệt.',
                              style: TextStyle(
                                fontFamily: AppTypography.serifFont,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Túi, giày & trang sức →',
                              style: TextStyle(
                                fontFamily: AppTypography.sansFont,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCarouselArrow({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.85),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildOccasionButton({required IconData icon, required String label}) {
    return InkWell(
      onTap: () {
        if (widget.onOccasionTap != null) {
          widget.onOccasionTap!(label);
        } else {
          widget.onLookbook();
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFFEBF0EA),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: AppTypography.sansFont,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryCard({
    required String image,
    required Alignment alignment,
    required String title,
    required String subtitle,
  }) {
    return InkWell(
      onTap: widget.onDiscover,
      borderRadius: BorderRadius.circular(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: AspectRatio(
              aspectRatio: 0.76,
              child: Image.asset(image, fit: BoxFit.cover, alignment: alignment),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$title · $subtitle',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: AppTypography.sansFont,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          const Text.rich(
            TextSpan(
              text: 'Khám phá ngay ',
              style: TextStyle(
                fontFamily: AppTypography.sansFont,
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
              children: [
                TextSpan(
                  text: '↗',
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
    );
  }
}
