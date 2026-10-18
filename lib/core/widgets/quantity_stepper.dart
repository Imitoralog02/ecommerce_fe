import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class QuantityStepper extends StatelessWidget {
  final int quantity;
  final ValueChanged<int>? onChanged;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  const QuantityStepper({
    super.key,
    required this.quantity,
    this.onChanged,
    this.onIncrement,
    this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.studioGray,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            button: true,
            label: 'Giảm số lượng',
            enabled: quantity > 1,
            child: InkResponse(
              onTap: quantity > 1
                  ? () {
                      if (onDecrement != null) {
                        onDecrement!();
                      } else if (onChanged != null) {
                        onChanged!(quantity - 1);
                      }
                    }
                  : null,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Text(
                  '–',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '$quantity',
              style: AppTypography.price.copyWith(fontSize: 13),
            ),
          ),
          Semantics(
            button: true,
            label: 'Tăng số lượng',
            child: InkResponse(
              onTap: () {
                if (onIncrement != null) {
                  onIncrement!();
                } else if (onChanged != null) {
                  onChanged!(quantity + 1);
                }
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Text(
                  '+',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
