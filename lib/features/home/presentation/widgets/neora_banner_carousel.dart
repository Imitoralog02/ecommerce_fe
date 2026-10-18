import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class BannerSlideData {
  final String tag;
  final String headline;
  final String subtitle;
  final String buttonText;
  final String? imagePath;
  final List<Color> gradientColors;
  final bool isSpecialHero;

  const BannerSlideData({
    required this.tag,
    required this.headline,
    required this.subtitle,
    required this.buttonText,
    this.imagePath,
    required this.gradientColors,
    this.isSpecialHero = false,
  });
}

class NeoraBannerCarousel extends StatefulWidget {
  final VoidCallback? onShopNow;

  const NeoraBannerCarousel({super.key, this.onShopNow});

  @override
  State<NeoraBannerCarousel> createState() => _NeoraBannerCarouselState();
}

class _NeoraBannerCarouselState extends State<NeoraBannerCarousel> {
  late final PageController _pageController;
  int _currentIndex = 0;
  Timer? _timer;
  bool _disableAnimations = false;

  static const List<BannerSlideData> _slides = [
    BannerSlideData(
      tag: 'NEW ARRIVALS',
      headline: 'NEW COLLECTIONS 20% OFF',
      subtitle: 'Summer Streetwear & Modern Silhouettes',
      buttonText: 'SHOP NOW',
      imagePath: 'assets/images/neora_hero_banner.png',
      gradientColors: [Color(0xFFEBEAE6), Color(0xFFD6D5D0)],
      isSpecialHero: true,
    ),
    BannerSlideData(
      tag: 'SEASONAL DROP / 02',
      headline: 'UP TO 30% OFF AIR-TEX',
      subtitle: 'Engineered breathable cotton weaves',
      buttonText: 'DISCOVER',
      imagePath: 'assets/images/banner_model_clean.png',
      gradientColors: [Color(0xFF1E1E22), Color(0xFF101012)],
      isSpecialHero: false,
    ),
    BannerSlideData(
      tag: 'LIMITED EDITION',
      headline: 'OBSIDIAN HOODIES',
      subtitle: 'Strictly limited to 150 pieces worldwide',
      buttonText: 'VIEW DROP',
      imagePath: 'assets/images/prod_utility_jacket.png',
      gradientColors: [Color(0xFF27272A), Color(0xFF18181B)],
      isSpecialHero: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _disableAnimations = MediaQuery.disableAnimationsOf(context);
    _disableAnimations ? _stopAutoSlide() : _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer?.cancel();
    if (_disableAnimations) return;
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_currentIndex + 1) % _slides.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 650),
        curve: Curves.fastOutSlowIn,
      );
    });
  }

  void _stopAutoSlide() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopAutoSlide();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            height: 172,
            child: Listener(
              onPointerDown: (_) => _stopAutoSlide(),
              onPointerUp: (_) => _startAutoSlide(),
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (idx) {
                  setState(() {
                    _currentIndex = idx;
                  });
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return _buildSlideCard(slide);
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Animated Dots Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_slides.length, (idx) {
            final isActive = idx == _currentIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 22 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.brandBlack
                    : const Color(0xFFD6D6DC),
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSlideCard(BannerSlideData slide) {
    if (slide.isSpecialHero && slide.imagePath != null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFFEBEAE6),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              slide.imagePath!,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
              errorBuilder: (_, _, _) => _buildGraphicSlide(slide),
            ),
            Positioned(
              left: 18,
              bottom: 18,
              child: GestureDetector(
                onTap: widget.onShopNow,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.brandBlack,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    slide.buttonText,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return _buildGraphicSlide(slide);
  }

  Widget _buildGraphicSlide(BannerSlideData slide) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: slide.gradientColors,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background graphic accent circles
          Positioned(
            right: -30,
            bottom: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          if (slide.imagePath != null)
            Positioned(
              right: 12,
              bottom: 10,
              top: 10,
              width: 130,
              child: Image.asset(
                slide.imagePath!,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    slide.tag,
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  slide.headline,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  slide.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: widget.onShopNow,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 7.5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      slide.buttonText,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: AppColors.brandBlack,
                      ),
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
}
