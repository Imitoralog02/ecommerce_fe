import 'dart:math' as math;
import 'package:flutter/material.dart';

class ConfettiCelebrationWidget extends StatefulWidget {
  final Widget child;
  final bool isPlaying;

  const ConfettiCelebrationWidget({
    super.key,
    required this.child,
    this.isPlaying = true,
  });

  @override
  State<ConfettiCelebrationWidget> createState() =>
      _ConfettiCelebrationWidgetState();
}

class _ConfettiCelebrationWidgetState extends State<ConfettiCelebrationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_ConfettiPiece> _pieces;

  static const List<Color> _colors = [
    Color(0xFFFF6A3D),
    Color(0xFFFFC23C),
    Color(0xFF22A86A),
    Color(0xFF5B8CFF),
    Color(0xFFFF3B5C),
    Color(0xFFC8A97E),
    Color(0xFF8B6840),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    final random = math.Random(42);
    _pieces = List.generate(70, (index) {
      return _ConfettiPiece(
        xRatio: random.nextDouble(),
        driftX: (random.nextDouble() - 0.5) * 160.0,
        speed: 0.65 + random.nextDouble() * 0.7,
        delay: random.nextDouble() * 0.45,
        width: 6.0 + random.nextDouble() * 6.0,
        height: 9.0 + random.nextDouble() * 8.0,
        rotationSpeed: (random.nextDouble() - 0.5) * 12.0,
        color: _colors[index % _colors.length],
      );
    });

    if (widget.isPlaying) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(ConfettiCelebrationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying &&
        !oldWidget.isPlaying &&
        !MediaQuery.disableAnimationsOf(context)) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller
        ..stop()
        ..value = 1;
    } else if (widget.isPlaying && _controller.value == 0) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isPlaying && !MediaQuery.disableAnimationsOf(context))
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _ConfettiPainter(
                      progress: _controller.value,
                      pieces: _pieces,
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _ConfettiPiece {
  final double xRatio;
  final double driftX;
  final double speed;
  final double delay;
  final double width;
  final double height;
  final double rotationSpeed;
  final Color color;

  _ConfettiPiece({
    required this.xRatio,
    required this.driftX,
    required this.speed,
    required this.delay,
    required this.width,
    required this.height,
    required this.rotationSpeed,
    required this.color,
  });
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final List<_ConfettiPiece> pieces;

  _ConfettiPainter({required this.progress, required this.pieces});

  @override
  void paint(Canvas canvas, Size size) {
    for (final piece in pieces) {
      if (progress < piece.delay) continue;

      final normalizedT = ((progress - piece.delay) / (1.0 - piece.delay))
          .clamp(0.0, 1.0);
      final currentY =
          -20.0 + (size.height + 60.0) * (normalizedT * piece.speed);
      final currentX =
          (piece.xRatio * size.width) +
          (math.sin(normalizedT * math.pi * 3) * piece.driftX);
      final rotation = normalizedT * piece.rotationSpeed * math.pi;
      final opacity =
          (1.0 - (normalizedT > 0.85 ? (normalizedT - 0.85) / 0.15 : 0.0))
              .clamp(0.0, 1.0);

      final paint = Paint()
        ..color = piece.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(rotation);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: piece.width,
            height: piece.height,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
