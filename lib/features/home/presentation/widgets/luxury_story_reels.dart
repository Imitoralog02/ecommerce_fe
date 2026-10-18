import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class LuxuryStoryItem {
  final String label;
  final String categoryKey;
  final IconData icon;
  final bool isNew;

  const LuxuryStoryItem({
    required this.label,
    required this.categoryKey,
    required this.icon,
    this.isNew = false,
  });
}

class LuxuryStoryReels extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onSelectCategory;

  const LuxuryStoryReels({
    super.key,
    required this.selectedCategory,
    required this.onSelectCategory,
  });

  static const List<LuxuryStoryItem> items = [
    LuxuryStoryItem(
      label: 'Tất cả',
      categoryKey: 'Tất cả',
      icon: Icons.auto_awesome_rounded,
      isNew: true,
    ),
    LuxuryStoryItem(
      label: 'Áo Blazer',
      categoryKey: 'Áo',
      icon: Icons.checkroom_rounded,
    ),
    LuxuryStoryItem(
      label: 'Đầm Lụa',
      categoryKey: 'Đầm',
      icon: Icons.woman_rounded,
    ),
    LuxuryStoryItem(
      label: 'Quần Drapé',
      categoryKey: 'Quần',
      icon: Icons.dry_cleaning_rounded,
    ),
    LuxuryStoryItem(
      label: 'Phụ kiện',
      categoryKey: 'Phụ kiện',
      icon: Icons.watch_outlined,
      isNew: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected =
              selectedCategory == item.categoryKey ||
              (selectedCategory == 'ALL FORMS' &&
                  item.categoryKey == 'Tất cả') ||
              (selectedCategory == 'All' && item.categoryKey == 'Tất cả');

          return _StoryCircleItem(
            item: item,
            isSelected: isSelected,
            onTap: () => onSelectCategory(item.categoryKey),
          );
        },
      ),
    );
  }
}

class _StoryCircleItem extends StatefulWidget {
  final LuxuryStoryItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _StoryCircleItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_StoryCircleItem> createState() => _StoryCircleItemState();
}

class _StoryCircleItemState extends State<_StoryCircleItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar Circle with Haute Couture Ring
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 58,
                  height: 58,
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: widget.isSelected
                        ? const LinearGradient(
                            colors: [
                              Color(0xFFC59B27),
                              AppColors.primaryBurgundy,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.15),
                              Colors.black.withValues(alpha: 0.06),
                            ],
                          ),
                    boxShadow: widget.isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primaryBurgundy.withValues(
                                alpha: 0.28,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.background,
                    ),
                    padding: const EdgeInsets.all(2.5),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.isSelected
                            ? AppColors.primaryBurgundy
                            : Colors.white,
                      ),
                      child: Center(
                        child: Icon(
                          widget.item.icon,
                          size: 24,
                          color: widget.isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),

                // "NEW" / Gold Monogram Badge
                if (widget.item.isNew && !widget.isSelected)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC59B27),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white, width: 1.2),
                      ),
                      child: const Text(
                        'NEW',
                        style: TextStyle(
                          fontSize: 7.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),

            // Reel Title
            SizedBox(
              width: 68,
              child: Text(
                widget.item.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppTypography.sansFont,
                  fontSize: 11,
                  fontWeight: widget.isSelected
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: widget.isSelected
                      ? AppColors.primaryBurgundy
                      : AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
