import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class CapsuleButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isSecondary;
  final Widget? trailingIcon;
  final double? width;
  final double height;

  const CapsuleButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isSecondary = false,
    this.trailingIcon,
    this.width,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSecondary
              ? AppColors.studioGray
              : AppColors.brandBlack,
          foregroundColor: isSecondary ? AppColors.textPrimary : Colors.white,
          shape: const StadiumBorder(),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22),
        ),
        onPressed: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: AppTypography.button.copyWith(
                color: isSecondary ? AppColors.textPrimary : Colors.white,
              ),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 8),
              trailingIcon!,
            ],
          ],
        ),
      ),
    );
  }
}
