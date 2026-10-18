import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/currency_formatter.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'product_visual_widget.dart';

class ZeroGravityHeroShowcase extends StatefulWidget {
  final String pieceNumber;
  final String title;
  final String subCategory;
  final double price;
  final String imageType;
  final VoidCallback onExplore;

  const ZeroGravityHeroShowcase({
    super.key,
    required this.pieceNumber,
    required this.title,
    required this.subCategory,
    required this.price,
    required this.imageType,
    required this.onExplore,
  });

  @override
  State<ZeroGravityHeroShowcase> createState() =>
      _ZeroGravityHeroShowcaseState();
}

class _ZeroGravityHeroShowcaseState extends State<ZeroGravityHeroShowcase>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _tiltResetController;
  Offset _dragOffset = Offset.zero;
  bool _showMacroLens = false;

  @override
  void initState() {
    super.initState();
    // Ambient Zero-G float animation
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _tiltResetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
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
    _floatController.dispose();
    _tiltResetController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
      _dragOffset = Offset(
        _dragOffset.dx.clamp(-70.0, 70.0),
        _dragOffset.dy.clamp(-70.0, 70.0),
      );
    });
  }

  void _onPanEnd(DragEndDetails details) {
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
    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Container(
        height: 390,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppColors.cardBorder, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 35,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 1. Giant Architectural Number Watermark (Z-Axis Depth)
            Positioned(
              right: 14,
              top: 6,
              child: Text(
                widget.pieceNumber,
                style: AppTypography.watermarkNumber,
              ),
            ),

            // 2. Top Bar Inside Card: Technical Tags & Macro-Lens Toggle
            Positioned(
              top: 18,
              left: 16,
              right: 16,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: SizedBox(
                  width: 350,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4.5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.studioGray,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: AppColors.titaniumAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'DRAG TO TILT 3D',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Macro-Fiber Toggle Button
                      InkWell(
                        onTap: () {
                          setState(() {
                            _showMacroLens = !_showMacroLens;
                          });
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4.5,
                          ),
                          decoration: BoxDecoration(
                            color: _showMacroLens
                                ? AppColors.brandBlack
                                : AppColors.studioGray,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _showMacroLens
                                  ? AppColors.brandBlack
                                  : AppColors.cardBorder,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.blur_circular_rounded,
                                size: 13,
                                color: _showMacroLens
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'MACRO FIBER',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                  color: _showMacroLens
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Central 3D Floating Garment with Transform Matrix4
            Center(
              child: AnimatedBuilder(
                animation: _floatController,
                builder: (context, child) {
                  final floatVal =
                      math.sin(_floatController.value * 2 * math.pi) * 8.0;
                  final matrix = Matrix4.identity()
                    ..setEntry(3, 2, 0.0012) // Perspective 3D
                    ..rotateX(-_dragOffset.dy * 0.006)
                    ..rotateY(_dragOffset.dx * 0.006)
                    ..translateByDouble(0.0, floatVal, 0.0, 1.0);

                  return Transform(
                    transform: matrix,
                    alignment: FractionalOffset.center,
                    child: ProductVisualWidget(
                      imageType: widget.imageType,
                      width: 200,
                      height: 240,
                    ),
                  );
                },
              ),
            ),

            // 4. Macro-Fiber Zoom Lens Overlay (When toggled)
            if (_showMacroLens)
              Positioned(
                top: 70,
                right: 20,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: 140,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xE611141A),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  '100X WEAVE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.check_circle_outline,
                                size: 13,
                                color: AppColors.liveGreen,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Simulated microscopic weave pattern
                          Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E222B),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: CustomPaint(
                              painter: _WeaveMacroPainter(),
                              size: const Size(double.infinity, 48),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            '100% Virgin Wool Triple-Twist',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // 5. Bottom Metadata & Explore Pill
            Positioned(
              left: 20,
              right: 20,
              bottom: 18,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${widget.subCategory} // N° ${widget.pieceNumber}',
                          style: AppTypography.architecturalCode,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.cardTitle.copyWith(fontSize: 14),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          CurrencyFormatter.vnd(widget.price),
                          style: AppTypography.price,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: widget.onExplore,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandBlack,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 11,
                      ),
                      shape: const StadiumBorder(),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'EXPLORE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                        SizedBox(width: 5),
                        Icon(Icons.arrow_forward_rounded, size: 14),
                      ],
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
}

class _WeaveMacroPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x33FFFFFF)
      ..strokeWidth = 1.0;

    for (double x = 0; x < size.width; x += 6) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 6) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
