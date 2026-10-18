import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnimatedPriceCounter extends StatelessWidget {
  final double price;
  final TextStyle? style;
  final String suffix;
  final Duration duration;

  const AnimatedPriceCounter({
    super.key,
    required this.price,
    this.style,
    this.suffix = '₫',
    this.duration = const Duration(milliseconds: 750),
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###', 'vi_VN');

    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0.0, end: price),
      builder: (context, currentVal, child) {
        return Text(
          '${formatter.format(currentVal.round())}$suffix',
          style: style,
        );
      },
    );
  }
}
