import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: Text(
            'Gợi ý hôm nay ✨',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
        ),
        Container(
          height: 38,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: List.generate(NeoraSlidingFeedTabs.tabs.length, (index) {
              final isSelected = widget.selectedIndex == index;
              final tabTitle = NeoraSlidingFeedTabs.tabs[index];

              return Semantics(
                key: _tabKeys[index],
                button: true,
                selected: isSelected,
                label: 'Bộ lọc $tabTitle',
                child: InkWell(
                  borderRadius: BorderRadius.circular(13),
                  onTap: () => widget.onTabSelected(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF0E0E0E)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Center(
                      child: Text(
                        tabTitle,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
