import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CategoryAvatarItem {
  final String name;
  final String imagePath;

  const CategoryAvatarItem({required this.name, required this.imagePath});
}

class CuratedCategoriesGrid extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onSelectCategory;
  final VoidCallback? onSeeAll;

  const CuratedCategoriesGrid({
    super.key,
    required this.selectedCategory,
    required this.onSelectCategory,
    this.onSeeAll,
  });

  static const List<CategoryAvatarItem> categories = [
    CategoryAvatarItem(name: 'Women', imagePath: 'assets/images/cat_women.png'),
    CategoryAvatarItem(name: 'Men', imagePath: 'assets/images/cat_men.png'),
    CategoryAvatarItem(name: 'Teens', imagePath: 'assets/images/cat_teens.png'),
    CategoryAvatarItem(name: 'Kids', imagePath: 'assets/images/cat_kids.png'),
    CategoryAvatarItem(name: 'Baby', imagePath: 'assets/images/cat_baby.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row (thumb1.jpeg: "Shop By Category" ... "See All")
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Shop By Category',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onSeeAll,
                child: const Text(
                  'See All',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 5 Circular Avatars Row matching thumb1.jpeg
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: categories.map((cat) {
                final isSelected =
                    selectedCategory.toLowerCase() == cat.name.toLowerCase();
                return GestureDetector(
                  onTap: () => onSelectCategory(cat.name),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFF3F3F5),
                          border: isSelected
                              ? Border.all(
                                  color: AppColors.brandBlack,
                                  width: 2,
                                )
                              : null,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            cat.imagePath,
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.high,
                            errorBuilder: (_, _, _) => const Center(
                              child: Icon(
                                Icons.person_outline,
                                size: 24,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        cat.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? AppColors.brandBlack
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
