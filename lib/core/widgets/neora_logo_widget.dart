import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class NeoraLogoWidget extends StatelessWidget {
  final double size;
  final Color color;

  const NeoraLogoWidget({
    super.key,
    this.size = 28,
    this.color = AppColors.brandBlack,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 0.9),
      painter: _NeoraLogoPainter(color: color),
    );
  }
}

class _NeoraLogoPainter extends CustomPainter {
  final Color color;

  _NeoraLogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Draw the iconic angular geometric "N" from DailyFlutterUI / NÉORA
    final w = size.width;
    final h = size.height;

    // Left vertical stem
    final leftPath = Path()
      ..moveTo(0, 0)
      ..lineTo(w * 0.28, 0)
      ..lineTo(w * 0.28, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(leftPath, paint);

    // Diagonal fold
    final diagPath = Path()
      ..moveTo(w * 0.28, 0)
      ..lineTo(w * 0.62, 0)
      ..lineTo(w * 0.72, h * 0.45)
      ..lineTo(w * 0.38, h * 0.45)
      ..close();
    canvas.drawPath(diagPath, paint);

    // Right vertical stem with diagonal cut
    final rightPath = Path()
      ..moveTo(w * 0.72, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h)
      ..lineTo(w * 0.72, h)
      ..close();
    canvas.drawPath(rightPath, paint);
  }

  @override
  bool shouldRepaint(covariant _NeoraLogoPainter oldDelegate) =>
      oldDelegate.color != color;
}
