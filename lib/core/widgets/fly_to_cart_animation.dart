import 'dart:math' as math;
import 'package:flutter/material.dart';

class FlyToCartHelper {
  static void run(
    BuildContext context, {
    required GlobalKey startKey,
    GlobalKey? targetKey,
    required Widget thumbnail,
    VoidCallback? onComplete,
  }) {
    if (MediaQuery.disableAnimationsOf(context)) {
      onComplete?.call();
      return;
    }
    final overlay = Overlay.of(context);
    final renderBox = startKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      onComplete?.call();
      return;
    }

    final startOffset = renderBox.localToGlobal(Offset.zero);
    final startSize = renderBox.size;
    final startCenter = Offset(
      startOffset.dx + startSize.width / 2,
      startOffset.dy + startSize.height / 2,
    );

    // Target cart position (either from targetKey or default to top-right AppBar action)
    Offset targetCenter;
    if (targetKey?.currentContext != null) {
      final targetBox =
          targetKey!.currentContext!.findRenderObject() as RenderBox?;
      if (targetBox != null) {
        final tOffset = targetBox.localToGlobal(Offset.zero);
        final tSize = targetBox.size;
        targetCenter = Offset(
          tOffset.dx + tSize.width / 2,
          tOffset.dy + tSize.height / 2,
        );
      } else {
        targetCenter = Offset(MediaQuery.of(context).size.width - 40, 56);
      }
    } else {
      targetCenter = Offset(MediaQuery.of(context).size.width - 40, 56);
    }

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _FlyToCartWidget(
        startPos: startCenter,
        targetPos: targetCenter,
        thumbnail: thumbnail,
        onFinished: () {
          entry.remove();
          onComplete?.call();
        },
      ),
    );

    overlay.insert(entry);
  }
}

class _FlyToCartWidget extends StatefulWidget {
  final Offset startPos;
  final Offset targetPos;
  final Widget thumbnail;
  final VoidCallback onFinished;

  const _FlyToCartWidget({
    required this.startPos,
    required this.targetPos,
    required this.thumbnail,
    required this.onFinished,
  });

  @override
  State<_FlyToCartWidget> createState() => _FlyToCartWidgetState();
}

class _FlyToCartWidgetState extends State<_FlyToCartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _curveAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    _curveAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    _controller.forward().then((_) {
      widget.onFinished();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final x0 = widget.startPos.dx;
    final y0 = widget.startPos.dy;
    final x1 = widget.targetPos.dx;
    final y1 = widget.targetPos.dy;
    final peakY = math.min(y0, y1) - 110.0;

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _curveAnimation,
        builder: (context, _) {
          final t = _curveAnimation.value;

          // Parabolic Bezier Curve Calculation
          final x = (1 - t) * x0 + t * x1;
          final y =
              (1 - t) * (1 - t) * y0 + 2 * (1 - t) * t * peakY + t * t * y1;

          // Scaling: 1.3 -> 1.0 -> 0.22
          final scale = t < 0.4
              ? 1.3 - (t / 0.4) * 0.3
              : 1.0 - ((t - 0.4) / 0.6) * 0.78;

          // Rotation: 0 -> -35 degrees
          final rotation = -t * 0.65;

          // Opacity: 1.0 until 80%, then fading into the bag
          final opacity = (1.0 - (t > 0.85 ? (t - 0.85) / 0.15 : 0.0)).clamp(
            0.0,
            1.0,
          );

          return Positioned(
            left: x - 32,
            top: y - 32,
            child: Opacity(
              opacity: opacity,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..scaleByDouble(scale, scale, 1.0, 1.0)
                  ..rotateZ(rotation),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: widget.thumbnail,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
