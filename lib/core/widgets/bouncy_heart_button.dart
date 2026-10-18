import 'dart:math' as math;
import 'package:flutter/material.dart';

class BouncyHeartButton extends StatefulWidget {
  final bool isFavorite;
  final ValueChanged<bool>? onFavoriteChanged;
  final double size;
  final Color activeColor;
  final Color inactiveColor;
  final Color? backgroundColor;

  const BouncyHeartButton({
    super.key,
    required this.isFavorite,
    this.onFavoriteChanged,
    this.size = 22,
    this.activeColor = const Color(0xFFFF3B5C),
    this.inactiveColor = const Color(0xFF6E6A64),
    this.backgroundColor,
  });

  @override
  State<BouncyHeartButton> createState() => _BouncyHeartButtonState();
}

class _BouncyHeartButtonState extends State<BouncyHeartButton>
    with SingleTickerProviderStateMixin {
  late bool _liked;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    _liked = widget.isFavorite;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.45,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.45,
          end: 0.88,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.88,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 30,
      ),
    ]).animate(_controller);

    _particleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuad,
    );
  }

  @override
  void didUpdateWidget(BouncyHeartButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite != widget.isFavorite) {
      _liked = widget.isFavorite;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _liked = !_liked;
    });

    if (_liked && !MediaQuery.disableAnimationsOf(context)) {
      _controller.forward(from: 0.0);
    } else {
      _controller.reset();
    }

    widget.onFavoriteChanged?.call(_liked);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      toggled: _liked,
      label: _liked
          ? 'Bỏ khỏi danh sách yêu thích'
          : 'Thêm vào danh sách yêu thích',
      child: InkResponse(
        onTap: _handleTap,
        radius: widget.size,
        child: Container(
          width: widget.size * 1.8,
          height: widget.size * 1.8,
          decoration: widget.backgroundColor != null
              ? BoxDecoration(
                  color: widget.backgroundColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                )
              : null,
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Particles Bursting Outward
                if (_liked)
                  AnimatedBuilder(
                    animation: _particleAnimation,
                    builder: (context, _) {
                      if (!_controller.isAnimating &&
                          _controller.value == 1.0) {
                        return const SizedBox.shrink();
                      }
                      return CustomPaint(
                        size: Size(widget.size * 2.8, widget.size * 2.8),
                        painter: _HeartParticlePainter(
                          progress: _particleAnimation.value,
                          color: widget.activeColor,
                        ),
                      );
                    },
                  ),

                // Bouncy Scaling Heart Icon
                AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _controller.isAnimating
                          ? _scaleAnimation.value
                          : 1.0,
                      child: child,
                    );
                  },
                  child: Icon(
                    _liked
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: widget.size,
                    color: _liked ? widget.activeColor : widget.inactiveColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeartParticlePainter extends CustomPainter {
  final double progress;
  final Color color;

  _HeartParticlePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0 || progress >= 1.0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;
    final currentDistance = progress * maxRadius;
    final particleRadius = (1.0 - progress) * 3.2;
    final alpha = ((1.0 - progress) * 255).clamp(0, 255).toInt();

    final paint = Paint()
      ..color = color.withAlpha(alpha)
      ..style = PaintingStyle.fill;

    const int particleCount = 8;
    for (int i = 0; i < particleCount; i++) {
      final angle = (i * 2 * math.pi / particleCount) + (progress * 0.4);
      final px = center.dx + math.cos(angle) * currentDistance;
      final py = center.dy + math.sin(angle) * currentDistance;
      canvas.drawCircle(Offset(px, py), particleRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _HeartParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
