import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/product_visual_widget.dart';
import '../../domain/entities/product_entity.dart';

class Hero3DLookbookShowcase extends StatefulWidget {
  final List<ProductEntity> heroProducts;
  final Function(ProductEntity) onSelectProduct;

  const Hero3DLookbookShowcase({
    super.key,
    required this.heroProducts,
    required this.onSelectProduct,
  });

  @override
  State<Hero3DLookbookShowcase> createState() => _Hero3DLookbookShowcaseState();
}

class _Hero3DLookbookShowcaseState extends State<Hero3DLookbookShowcase>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _floatController;
  late AnimationController _tiltResetController;

  int _currentIndex = 0;
  Offset _dragOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Zero-G ambient floating sine wave animation
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // Spring reset controller for 3D drag
    _tiltResetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
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
    _pageController.dispose();
    _floatController.dispose();
    _tiltResetController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
      _dragOffset = Offset(
        _dragOffset.dx.clamp(-45.0, 45.0),
        _dragOffset.dy.clamp(-45.0, 45.0),
      );
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_dragOffset.dx < -20 &&
        _currentIndex < widget.heroProducts.length - 1) {
      _currentIndex++;
    } else if (_dragOffset.dx > 20 && _currentIndex > 0) {
      _currentIndex--;
    }
    if (MediaQuery.disableAnimationsOf(context)) {
      setState(() => _dragOffset = Offset.zero);
      return;
    }
    final start = _dragOffset;
    final animation = Tween<Offset>(begin: start, end: Offset.zero).animate(
      CurvedAnimation(parent: _tiltResetController, curve: Curves.easeOutBack),
    );
    animation.addListener(() {
      setState(() {
        _dragOffset = animation.value;
      });
    });
    _tiltResetController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.heroProducts.isEmpty) return const SizedBox.shrink();

    final currentProduct =
        widget.heroProducts[_currentIndex % widget.heroProducts.length];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Column(
        children: [
          // 3D Perspective Card Stage
          GestureDetector(
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            onTap: () => widget.onSelectProduct(currentProduct),
            child: Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // 3D Perspective focal distance
                ..rotateY(_dragOffset.dx * 0.006)
                ..rotateX(-_dragOffset.dy * 0.006),
              alignment: FractionalOffset.center,
              child: Container(
                height: 340,
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2B2826),
                      Color(0xFF1E1B19),
                      Color(0xFF141312),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.22),
                      blurRadius: 30,
                      offset: Offset(
                        _dragOffset.dx * 0.2,
                        16 + _dragOffset.dy * 0.2,
                      ),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Subtle Architectural Watermark Number in Background
                    Positioned(
                      right: 18,
                      bottom: -10,
                      child: Text(
                        currentProduct.pieceNumber,
                        style: TextStyle(
                          fontFamily: AppTypography.serifFont,
                          fontSize: 120,
                          fontWeight: FontWeight.w900,
                          color: Colors.white.withValues(alpha: 0.04),
                          height: 1.0,
                        ),
                      ),
                    ),

                    // Top Status & 3D Interactive Badge
                    Positioned(
                      top: 18,
                      left: 18,
                      right: 18,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBurgundy.withValues(
                                    alpha: 0.85,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white24,
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Text(
                                      '3D LOOKBOOK REEL',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4.5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white10,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.touch_app_outlined,
                                      size: 13,
                                      color: Colors.white70,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Kéo để xoay 3D',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Center 3D Floating Garment with Dynamic Sine Float
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _floatController,
                        builder: (context, child) {
                          final floatY =
                              math.sin(_floatController.value * 2 * math.pi) *
                              8.0;

                          return Center(
                            child: Transform.translate(
                              offset: Offset(0.0, floatY),
                              child: Transform(
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.001)
                                  ..rotateY(_dragOffset.dx * 0.008)
                                  ..rotateX(-_dragOffset.dy * 0.008),
                                alignment: Alignment.center,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Dynamic contact shadow beneath garment
                                    Positioned(
                                      bottom: 30,
                                      child: Container(
                                        width: 140 - (floatY * 2),
                                        height: 16 - (floatY * 0.5),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(
                                            alpha: 0.35,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            100,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.4,
                                              ),
                                              blurRadius: 18,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Garment Visual
                                    ProductVisualWidget(
                                      imageType: currentProduct.imageType,
                                      size: 190,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Bottom Product Information & CTA Overlay
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 18,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currentProduct.subCategory,
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.5,
                                        color: const Color(
                                          0xFFC59B27,
                                        ).withValues(alpha: 0.9),
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      currentProduct.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: AppTypography.serifFont,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                currentProduct.formattedPrice,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Swipe Navigation Progress & Details Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Slide Dots
                              Row(
                                children: List.generate(
                                  widget.heroProducts.length.clamp(1, 4),
                                  (index) => GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _currentIndex = index;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      margin: const EdgeInsets.only(right: 6),
                                      width: _currentIndex == index ? 22 : 6,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: _currentIndex == index
                                            ? const Color(0xFFC59B27)
                                            : Colors.white24,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Explore Button
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  children: [
                                    Text(
                                      'Xem chi tiết',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.brandBlack,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 14,
                                      color: AppColors.brandBlack,
                                    ),
                                  ],
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
          ),
        ],
      ),
    );
  }
}
