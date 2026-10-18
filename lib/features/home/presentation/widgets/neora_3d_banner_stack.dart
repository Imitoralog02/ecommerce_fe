import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class Neora3dBannerStack extends StatefulWidget {
  final VoidCallback? onBannerTap;

  const Neora3dBannerStack({super.key, this.onBannerTap});

  @override
  State<Neora3dBannerStack> createState() => _Neora3dBannerStackState();
}

class _Neora3dBannerStackState extends State<Neora3dBannerStack> {
  int _currentIndex = 0;
  Timer? _autoTimer;

  static const List<Map<String, String>> _banners = [
    {
      'chip': 'BỘ SƯU TẬP MỚI',
      'title': 'Nắng Đầu Mùa',
      'subtitle': 'Vẻ đẹp thanh lịch từ chất liệu lụa tự nhiên',
      'cta': 'Khám phá ngay ›',
      'image': 'assets/images/real/banner_summer.jpg',
    },
    {
      'chip': 'NÉORA 2026',
      'title': 'Thời Trang Tối Giản',
      'subtitle': 'Đường may thủ công, phom dáng chuẩn mực',
      'cta': 'Mua ngay ›',
      'image': 'assets/images/real/onb_shopping.jpg',
    },
    {
      'chip': 'ĐẶC QUYỀN VIP',
      'title': 'BST Thu Đông Mới',
      'subtitle': 'Áo len dệt kim, cardigan mềm mịn ấm áp',
      'cta': 'Xem ngay ›',
      'image': 'assets/images/real/banner_men.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _autoTimer?.cancel();
    } else if (_autoTimer == null || !_autoTimer!.isActive) {
      _startTimer();
    }
  }

  void _startTimer() {
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _banners.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    super.dispose();
  }

  void _nextBanner() {
    _startTimer();
    setState(() {
      _currentIndex = (_currentIndex + 1) % _banners.length;
    });
  }

  void _prevBanner() {
    _startTimer();
    setState(() {
      _currentIndex = (_currentIndex - 1 + _banners.length) % _banners.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final bannerHeight = 185.0 + ((textScale - 1) * 64).clamp(0, 64);

    return Column(
      children: [
        // 3D Stacking Banner Box
        GestureDetector(
          onTap: widget.onBannerTap ?? _nextBanner,
          onHorizontalDragEnd: (details) {
            if ((details.primaryVelocity ?? 0) < -100) {
              _nextBanner();
            } else if ((details.primaryVelocity ?? 0) > 100) {
              _prevBanner();
            }
          },
          child: Container(
            height: bannerHeight,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Stack(
              clipBehavior: Clip.none,
              children: () {
                final indices = List.generate(_banners.length, (i) => i);
                indices.sort((a, b) {
                  int diffA = (a - _currentIndex) % _banners.length;
                  if (diffA < 0) diffA += _banners.length;
                  int diffB = (b - _currentIndex) % _banners.length;
                  if (diffB < 0) diffB += _banners.length;
                  return diffB.compareTo(diffA); // back first, front last
                });

                return indices.map((i) {
                  int diff = (i - _currentIndex) % _banners.length;
                  if (diff < 0) diff += _banners.length;
                  final isFront = diff == 0;
                  final scale = isFront ? 1.0 : (diff == 1 ? 0.94 : 0.88);
                  final offsetY = isFront ? 0.0 : (diff == 1 ? 10.0 : 20.0);
                  final opacity = isFront ? 1.0 : (diff == 1 ? 0.85 : 0.5);

                  return AnimatedPositioned(
                    key: ValueKey('banner_$i'),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    left: 0,
                    right: 0,
                    top: offsetY,
                    bottom: isFront ? 0 : -offsetY,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 500),
                      opacity: opacity,
                      child: Transform.scale(
                        scale: scale,
                        alignment: Alignment.topCenter,
                        child: _buildBannerCard(_banners[i], isFront),
                      ),
                    ),
                  );
                }).toList();
              }(),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Indicator Dots (Active expands from 6px to 20px)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (i) {
            final isActive = i == _currentIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 6,
              width: isActive ? 22 : 6,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.coralOrange
                    : const Color(0xFFEBDDD2),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildBannerCard(Map<String, String> banner, bool isFront) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1C1A),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF502814,
            ).withValues(alpha: isFront ? 0.25 : 0.12),
            blurRadius: isFront ? 24 : 14,
            offset: Offset(0, isFront ? 12 : 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            Image.asset(
              banner['image']!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  Container(color: const Color(0xFFEFE6DD)),
            ),

            if (isFront) ...[
              // Subtle dark-to-light gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withValues(alpha: 0.72),
                      Colors.black.withValues(alpha: 0.45),
                      Colors.black.withValues(alpha: 0.1),
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),

              // Content Left Overlay
              MediaQuery.withClampedTextScaling(
                maxScaleFactor: 1.3,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Chip Tag
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.28),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Text(
                              banner['chip']!,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.6,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Title
                          Text(
                            banner['title']!,
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                              height: 1.15,
                              letterSpacing: -0.3,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 3),

                          // Subtitle
                          Text(
                            banner['subtitle']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.92),
                            ),
                          ),
                        ],
                      ),

                      // Rounded White CTA Button
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7.5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          banner['cta']!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
