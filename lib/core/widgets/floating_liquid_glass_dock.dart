import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_colors.dart';

class FloatingLiquidGlassDock extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final int cartItemCount;
  final int unreadNotificationsCount;

  const FloatingLiquidGlassDock({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.cartItemCount = 0,
    this.unreadNotificationsCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    final strings = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF502814).withValues(alpha: 0.14),
            blurRadius: 28,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 72,
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: strings?.homeTab ?? 'Trang chủ',
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.grid_view_outlined,
                activeIcon: Icons.grid_view_rounded,
                label: strings?.discoverTab ?? 'Khám phá',
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.notifications_none_rounded,
                activeIcon: Icons.notifications_rounded,
                label: strings?.notificationsTab ?? 'Thông báo',
                badgeCount: unreadNotificationsCount,
                isDotOnly: true,
                badgeDescription:
                    strings?.newNotificationLabel ?? 'có thông báo mới',
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.shopping_bag_outlined,
                activeIcon: Icons.shopping_bag_rounded,
                label: strings?.cartTab ?? 'Giỏ hàng',
                badgeCount: cartItemCount,
                badgeDescription: strings?.cartItemCountLabel(cartItemCount),
              ),
              _buildNavItem(
                index: 4,
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: strings?.accountTab ?? 'Tài khoản',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    int badgeCount = 0,
    bool isDotOnly = false,
    String? badgeDescription,
  }) {
    final isSelected = selectedIndex == index;

    final semanticSuffix = badgeCount > 0
        ? ', ${badgeDescription ?? badgeCount}'
        : '';

    return Semantics(
      button: true,
      selected: isSelected,
      label: '$label$semanticSuffix',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () => onItemSelected(index),
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 66,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pill Container for Active State (.tic)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                width: 48,
                height: 32,
                transform: Matrix4.translationValues(0, isSelected ? -2 : 0, 0),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.softPeach : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        isSelected ? activeIcon : icon,
                        size: 22,
                        color: isSelected
                            ? AppColors.coralOrange
                            : AppColors.textMuted,
                      ),
                      if (badgeCount > 0)
                        Positioned(
                          top: isDotOnly ? -2 : -4,
                          right: isDotOnly ? -2 : -8,
                          child: isDotOnly
                              ? Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AppColors.coralOrange,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1.5,
                                    ),
                                  ),
                                )
                              : Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 1.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.coralOrange,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1.5,
                                    ),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Text(
                                    badgeCount > 9 ? '9+' : '$badgeCount',
                                    style: const TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      height: 1.0,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 3),

              // Label Text
              MediaQuery.withClampedTextScaling(
                maxScaleFactor: 1.4,
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                    color: isSelected
                        ? AppColors.coralOrange
                        : AppColors.textMuted,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
