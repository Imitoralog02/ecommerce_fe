import 'package:flutter/material.dart';

class ProductVisualWidget extends StatelessWidget {
  final String imageType;
  final double? width;
  final double? height;
  final double size;
  final BoxFit fit;

  const ProductVisualWidget({
    super.key,
    required this.imageType,
    this.width,
    this.height,
    this.size = 140,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    final w = width ?? size;
    final h = height ?? size;

    return SizedBox(
      width: w,
      height: h,
      child: CustomPaint(
        painter: _GarmentVectorPainter(imageType: imageType),
        size: Size(w, h),
      ),
    );
  }
}

class _GarmentVectorPainter extends CustomPainter {
  final String imageType;

  _GarmentVectorPainter({required this.imageType});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Contact drop shadow on floor
    final shadowPaint = Paint()
      ..color = const Color(0x18000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w / 2, h * 0.92),
        width: w * 0.65,
        height: h * 0.08,
      ),
      shadowPaint,
    );

    switch (imageType) {
      case 'sculptural_coat':
        _paintSculpturalCoat(canvas, size);
        break;
      case 'pleated_pants':
        _paintPleatedPants(canvas, size);
        break;
      case 'chelsea_boot':
        _paintChelseaBoot(canvas, size);
        break;
      case 'knit_sweater':
        _paintKnitSweater(canvas, size);
        break;
      case 'tailored_blazer':
        _paintTailoredBlazer(canvas, size);
        break;
      default:
        _paintSculpturalCoat(canvas, size);
    }
  }

  void _paintSculpturalCoat(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Coat Body Gradient (Raw Ecru / Chalk)
    final coatPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFAFBFD), Color(0xFFE8ECF2), Color(0xFFD3DAE2)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final lapelPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFB8C2CC), Color(0xFF8F9CA8)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    // Outer Drape Path
    final bodyPath = Path();
    bodyPath.moveTo(w * 0.40, h * 0.12);
    bodyPath.lineTo(w * 0.28, h * 0.32);
    bodyPath.lineTo(w * 0.18, h * 0.60);
    bodyPath.lineTo(w * 0.22, h * 0.88);
    bodyPath.quadraticBezierTo(w * 0.50, h * 0.92, w * 0.78, h * 0.88);
    bodyPath.lineTo(w * 0.82, h * 0.60);
    bodyPath.lineTo(w * 0.72, h * 0.32);
    bodyPath.lineTo(w * 0.60, h * 0.12);
    bodyPath.close();
    canvas.drawPath(bodyPath, coatPaint);

    // Collar & Lapels
    final leftLapel = Path();
    leftLapel.moveTo(w * 0.40, h * 0.12);
    leftLapel.lineTo(w * 0.30, h * 0.35);
    leftLapel.lineTo(w * 0.48, h * 0.48);
    leftLapel.lineTo(w * 0.51, h * 0.28);
    leftLapel.close();
    canvas.drawPath(leftLapel, lapelPaint);

    final rightLapel = Path();
    rightLapel.moveTo(w * 0.60, h * 0.12);
    rightLapel.lineTo(w * 0.70, h * 0.35);
    rightLapel.lineTo(w * 0.50, h * 0.52);
    rightLapel.lineTo(w * 0.49, h * 0.28);
    rightLapel.close();
    canvas.drawPath(rightLapel, lapelPaint);

    // Architectural Seam & Dart Lines
    final linePaint = Paint()
      ..color = const Color(0xFF98A6B3)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(w * 0.50, h * 0.52),
      Offset(w * 0.50, h * 0.88),
      linePaint,
    );
    canvas.drawLine(
      Offset(w * 0.32, h * 0.64),
      Offset(w * 0.40, h * 0.65),
      linePaint,
    );
    canvas.drawLine(
      Offset(w * 0.68, h * 0.64),
      Offset(w * 0.60, h * 0.65),
      linePaint,
    );
  }

  void _paintPleatedPants(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final pantsPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF323742), Color(0xFF1E2128), Color(0xFF111317)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final path = Path();
    path.moveTo(w * 0.30, h * 0.18);
    path.lineTo(w * 0.70, h * 0.18);
    path.lineTo(w * 0.74, h * 0.32);
    path.lineTo(w * 0.80, h * 0.88);
    path.lineTo(w * 0.56, h * 0.88);
    path.lineTo(w * 0.50, h * 0.46);
    path.lineTo(w * 0.44, h * 0.88);
    path.lineTo(w * 0.20, h * 0.88);
    path.lineTo(w * 0.26, h * 0.32);
    path.close();
    canvas.drawPath(path, pantsPaint);

    // Crease Lines
    final creasePaint = Paint()
      ..color = const Color(0x33FFFFFF)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(w * 0.36, h * 0.24),
      Offset(w * 0.32, h * 0.88),
      creasePaint,
    );
    canvas.drawLine(
      Offset(w * 0.64, h * 0.24),
      Offset(w * 0.68, h * 0.88),
      creasePaint,
    );
  }

  void _paintChelseaBoot(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final bootPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF2C3038), Color(0xFF16181D), Color(0xFF090A0D)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final path = Path();
    path.moveTo(w * 0.38, h * 0.25);
    path.lineTo(w * 0.62, h * 0.25);
    path.lineTo(w * 0.65, h * 0.58);
    path.lineTo(w * 0.88, h * 0.70);
    path.quadraticBezierTo(w * 0.90, h * 0.80, w * 0.85, h * 0.84);
    path.lineTo(w * 0.22, h * 0.84);
    path.lineTo(w * 0.22, h * 0.70);
    path.lineTo(w * 0.33, h * 0.58);
    path.close();
    canvas.drawPath(path, bootPaint);

    // Heel Block
    final heelPaint = Paint()..color = const Color(0xFF0D0E11);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.22, h * 0.82, w * 0.25, h * 0.08),
        const Radius.circular(2),
      ),
      heelPaint,
    );
  }

  void _paintKnitSweater(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final knitPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFEBE5DC), Color(0xFFD6CEBF), Color(0xFFC0B7A6)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final path = Path();
    path.moveTo(w * 0.35, h * 0.20);
    path.lineTo(w * 0.65, h * 0.20);
    path.lineTo(w * 0.88, h * 0.48);
    path.lineTo(w * 0.78, h * 0.55);
    path.lineTo(w * 0.68, h * 0.42);
    path.lineTo(w * 0.68, h * 0.80);
    path.lineTo(w * 0.32, h * 0.80);
    path.lineTo(w * 0.32, h * 0.42);
    path.lineTo(w * 0.22, h * 0.55);
    path.lineTo(w * 0.12, h * 0.48);
    path.close();
    canvas.drawPath(path, knitPaint);
  }

  void _paintTailoredBlazer(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final blazerPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF262930), Color(0xFF14161B), Color(0xFF090A0D)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final path = Path();
    path.moveTo(w * 0.38, h * 0.15);
    path.lineTo(w * 0.62, h * 0.15);
    path.lineTo(w * 0.84, h * 0.38);
    path.lineTo(w * 0.75, h * 0.84);
    path.lineTo(w * 0.25, h * 0.84);
    path.lineTo(w * 0.16, h * 0.38);
    path.close();
    canvas.drawPath(path, blazerPaint);
  }

  @override
  bool shouldRepaint(covariant _GarmentVectorPainter oldDelegate) =>
      oldDelegate.imageType != imageType;
}
