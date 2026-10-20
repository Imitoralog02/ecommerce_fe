import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Pill filter row used by the "Món cơ bản mỗi ngày" section.
class NeoraSlidingFeedTabs extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const NeoraSlidingFeedTabs({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  static const List<String> tabs = ['Tất cả', 'Nữ', 'Nam', 'Phụ kiện'];

  @override
  State<NeoraSlidingFeedTabs> createState() => _NeoraSlidingFeedTabsState();
}

class _NeoraSlidingFeedTabsState extends State<NeoraSlidingFeedTabs> {
  final List<GlobalKey> _tabKeys = List.generate(4, (_) => GlobalKey());

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: NeoraSlidingFeedTabs.tabs.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = widget.selectedIndex == index;
          final tabTitle = NeoraSlidingFeedTabs.tabs[index];

          return Semantics(
            key: _tabKeys[index],
            button: true,
            selected: isSelected,
            label: 'Bộ lọc $tabTitle',
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => widget.onTabSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.background,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.cardBorder,
                  ),
                ),
                child: Text(
                  tabTitle,
                  style: TextStyle(
                    fontFamily: AppTypography.sansFont,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
