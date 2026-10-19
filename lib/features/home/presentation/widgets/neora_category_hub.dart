import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class NeoraCategoryHub extends StatelessWidget {
  final VoidCallback? onSeeAll;
  final ValueChanged<String>? onCategorySelected;

  const NeoraCategoryHub({super.key, this.onSeeAll, this.onCategorySelected});

  static const List<Map<String, dynamic>> _categories = [
    {'name': 'Tất cả', 'isAll': true, 'icon': Icons.grid_view_rounded},
    {'name': 'Đầm nữ', 'emoji': '👗', 'bg': Color(0xFFF9F5F0)},
    {'name': 'Áo len', 'emoji': '🧶', 'bg': Color(0xFFF5EEE4)},
    {'name': 'Hoodie', 'emoji': '🧥', 'bg': Color(0xFFF0EBE3)},
    {'name': 'Sơ mi', 'emoji': '👔', 'bg': Color(0xFFEDF2ED)},
    {'name': 'Quần Jeans', 'emoji': '👖', 'bg': Color(0xFFEAF0FF)},
    {'name': 'Sneaker', 'emoji': '👟', 'bg': Color(0xFFF9F0EA)},
    {'name': 'Túi xách', 'emoji': '👜', 'bg': Color(0xFFF6ECE6)},
    {'name': 'Sale 50%', 'emoji': '🔥', 'bg': Color(0xFFFDEEEA)},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Danh mục',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: onSeeAll,
                child: const Text(
                  'Xem tất cả ›',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.coralOrange,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Horizontal Category Row
        SizedBox(
          height: 100,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: _categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isAll = cat['isAll'] == true;
              final name = cat['name'] as String;

              return GestureDetector(
                onTap: () => onCategorySelected?.call(name),
                child: SizedBox(
                  width: 66,
                  child: Column(
                    children: [
                      // 66x66 Rounded Square
                      Container(
                        width: 66,
                        height: 66,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(color: Colors.white, width: 3),
                          gradient: isAll
                              ? const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFE8D9C4),
                                    Color(0xFFC8A97E),
                                  ],
                                )
                              : null,
                          color: isAll
                              ? null
                              : (cat['bg'] as Color? ?? Colors.white),
                          boxShadow: const [],
                        ),
                        child: Center(
                          child: isAll
                              ? const Icon(
                                  Icons.grid_view_rounded,
                                  size: 26,
                                  color: Colors.white,
                                )
                              : Text(
                                  cat['emoji'] as String,
                                  style: const TextStyle(fontSize: 26),
                                ),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Name Label
                      MediaQuery.withClampedTextScaling(
                        maxScaleFactor: 1.35,
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
