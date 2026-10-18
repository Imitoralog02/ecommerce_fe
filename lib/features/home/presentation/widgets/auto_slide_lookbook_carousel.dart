import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/product_entity.dart';

class EditorialBannerItem {
  final String tag;
  final String title;
  final String badge;
  final String imagePath;
  final List<Color> gradientColors;

  const EditorialBannerItem({
    required this.tag,
    required this.title,
    required this.badge,
    required this.imagePath,
    required this.gradientColors,
  });
}

class AutoSlideLookbookCarousel extends StatefulWidget {
  final List<ProductEntity> products;
  final Function(ProductEntity) onSelectProduct;

  const AutoSlideLookbookCarousel({
    super.key,
    required this.products,
    required this.onSelectProduct,
  });

  @override
  State<AutoSlideLookbookCarousel> createState() =>
      _AutoSlideLookbookCarouselState();
}

class _AutoSlideLookbookCarouselState extends State<AutoSlideLookbookCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;
  Timer? _autoSlideTimer;
  bool _disableAnimations = false;

  static const List<EditorialBannerItem> banners = [
    EditorialBannerItem(
      tag: 'NEW EDITORIAL / 01',
      title: 'Đường nét của mùa mới.',
      badge: 'Silk & Wool',
      imagePath: 'assets/images/banner_model_clean.png',
      gradientColors: [Color(0xFF262220), Color(0xFF171514)],
    ),
    EditorialBannerItem(
      tag: 'NEW EDITORIAL / 02',
      title: 'Áo blazer Ciel Tailoring.',
      badge: 'May đo Ý',
      imagePath: 'assets/images/model_lookbook_clean.png',
      gradientColors: [Color(0xFF1F1C1A), Color(0xFF141312)],
    ),
    EditorialBannerItem(
      tag: 'NEW EDITORIAL / 03',
      title: 'Đầm lụa Aurora Satin.',
      badge: 'Limited 50',
      imagePath: 'assets/images/model_lookbook.jpg',
      gradientColors: [Color(0xFF2E1920), Color(0xFF1A1115)],
    ),
    EditorialBannerItem(
      tag: 'NEW EDITORIAL / 04',
      title: 'Quần Drapé Noir Minimalist.',
      badge: 'Pure Wool',
      imagePath: 'assets/images/hd_banner.png',
      gradientColors: [Color(0xFF1D2024), Color(0xFF121417)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.90);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _disableAnimations = MediaQuery.disableAnimationsOf(context);
    _disableAnimations ? _stopTimer() : _startTimer();
  }

  void _startTimer() {
    _stopTimer();
    if (_disableAnimations) return;
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final nextIndex = (_currentIndex + 1) % banners.length;
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _stopTimer() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Carousel Header & Controls
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryBurgundy,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        '4 BỘ SƯU TẬP NỔI BẬT',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: AppColors.primaryBurgundy,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      _stopTimer();
                      final prev =
                          (_currentIndex - 1 + banners.length) % banners.length;
                      _pageController.animateToPage(
                        prev,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutQuad,
                      );
                      _startTimer();
                    },
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.cardBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.chevron_left_rounded,
                          size: 18,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      '${_currentIndex + 1} / ${banners.length}',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _stopTimer();
                      final next = (_currentIndex + 1) % banners.length;
                      _pageController.animateToPage(
                        next,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutQuad,
                      );
                      _startTimer();
                    },
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.cardBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Carousel Viewport
        SizedBox(
          height: 215,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification) {
                _stopTimer();
              } else if (notification is ScrollEndNotification) {
                _startTimer();
              }
              return false;
            },
            child: PageView.builder(
              controller: _pageController,
              itemCount: banners.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final banner = banners[index];
                final matchingProduct = widget.products.isNotEmpty
                    ? widget.products[index % widget.products.length]
                    : null;

                return GestureDetector(
                  onTap: () {
                    if (matchingProduct != null) {
                      widget.onSelectProduct(matchingProduct);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(
                      left: 4,
                      right: 10,
                      top: 4,
                      bottom: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        colors: banner.gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        // Background Model Photography
                        Positioned.fill(
                          child: Image.asset(
                            banner.imagePath,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            errorBuilder: (_, _, _) => Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: banner.gradientColors,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Vignette & Contrast Gradient
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                stops: const [0.0, 0.45, 1.0],
                                colors: [
                                  Colors.black.withValues(alpha: 0.8),
                                  Colors.black.withValues(alpha: 0.25),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),

                        // High Fashion Frosted Info Overlay
                        Positioned(
                          left: 12,
                          right: 12,
                          bottom: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 11,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.94),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.6),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        banner.tag,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.8,
                                          color: AppColors.primaryBurgundy,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFBF5E5),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: const Color(
                                            0xFFC59B27,
                                          ).withValues(alpha: 0.4),
                                        ),
                                      ),
                                      child: Text(
                                        banner.badge,
                                        style: const TextStyle(
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFFC59B27),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  banner.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: AppTypography.serifFont,
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.brandBlack,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Khám phá ngay',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryBurgundy,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 13,
                                      color: AppColors.primaryBurgundy,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Bottom Dot Indicators
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(banners.length, (index) {
            final isSelected = _currentIndex == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isSelected ? 20 : 6,
              height: 5,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryBurgundy
                    : const Color(0xFFD8D2C9),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}
