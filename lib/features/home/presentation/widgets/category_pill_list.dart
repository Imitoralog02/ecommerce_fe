import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class CategoryPillList extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onSelectCategory;

  const CategoryPillList({
    super.key,
    required this.selectedCategory,
    required this.onSelectCategory,
  });

  static const List<String> categories = [
    'Tất cả',
    'Áo',
    'Đầm',
    'Quần',
    'Phụ kiện',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected =
              cat == selectedCategory ||
              (selectedCategory == 'ALL FORMS' && cat == 'Tất cả') ||
              (selectedCategory == 'All' && cat == 'Tất cả');

          return Semantics(
            button: true,
            selected: isSelected,
            label: 'Danh mục $cat',
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () => onSelectCategory(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryBurgundy : Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryBurgundy
                        : AppColors.cardBorder,
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primaryBurgundy.withValues(
                              alpha: 0.25,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    cat,
                    style: AppTypography.categoryTab.copyWith(
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
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
