import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../viewmodels/search_filter_viewmodel.dart';

class NeoraFilterSheet extends ConsumerStatefulWidget {
  final int totalMatching;

  const NeoraFilterSheet({super.key, required this.totalMatching});

  static Future<void> show(BuildContext context, {required int totalMatching}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NeoraFilterSheet(totalMatching: totalMatching),
    );
  }

  @override
  ConsumerState<NeoraFilterSheet> createState() => _NeoraFilterSheetState();
}

class _NeoraFilterSheetState extends ConsumerState<NeoraFilterSheet> {
  static const List<Map<String, dynamic>> _colors = [
    {'name': 'Đen', 'color': Color(0xFF14120E)},
    {'name': 'Trắng', 'color': Color(0xFFFFFFFF)},
    {'name': 'Kem', 'color': Color(0xFFDFC59E)},
    {'name': 'Nâu', 'color': Color(0xFF7A583A)},
    {'name': 'Lavender', 'color': Color(0xFFB8A9C9)},
    {'name': 'Navy', 'color': Color(0xFF1F2937)},
  ];

  static const List<String> _sizes = ['XS', 'S', 'M', 'L', 'XL'];

  static const List<Map<String, String>> _sortOptions = [
    {'id': 'popular', 'label': 'Phổ biến nhất'},
    {'id': 'newest', 'label': 'Mới nhất'},
    {'id': 'priceAsc', 'label': 'Giá tăng dần'},
    {'id': 'priceDesc', 'label': 'Giá giảm dần'},
  ];

  static const List<String> _categories = [
    'Tất cả',
    'Đầm',
    'Hoodie',
    'Áo len',
    'Sơ mi',
    'Túi',
    'Giày',
  ];

  String _formatCurrency(double val) {
    return '${val.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}₫';
  }

  @override
  Widget build(BuildContext context) {
    final filterState = ref.watch(searchFilterViewModelProvider);
    final filterNotifier = ref.read(searchFilterViewModelProvider.notifier);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: const Color(0xFFD6CFC7),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Bộ Lọc Tìm Kiếm',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    filterNotifier.resetFilters();
                  },
                  child: const Text(
                    'Đặt lại',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.saleRed,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE8E2D8)),

          // Scrollable filter options
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                // 1. Sắp xếp theo (Sort By)
                _buildSectionTitle('SẮP XẾP THEO'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _sortOptions.map((opt) {
                    final isSelected = filterState.sortBy == opt['id'];
                    return GestureDetector(
                      onTap: () => filterNotifier.setSortBy(opt['id']!),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.brandBlack
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.brandBlack
                                : AppColors.cardBorder,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          opt['label']!,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // 2. Danh mục
                _buildSectionTitle('PHÂN LOẠI'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories.map((cat) {
                    final isSelected = filterState.selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => filterNotifier.setCategory(cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.brandBlack
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.brandBlack
                                : AppColors.cardBorder,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // 3. Khoảng giá (Price Slider)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionTitle('KHOẢNG GIÁ'),
                    Text(
                      '${_formatCurrency(filterState.priceRange.start)} — ${_formatCurrency(filterState.priceRange.end)}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.coralOrange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                RangeSlider(
                  values: filterState.priceRange,
                  min: 0,
                  max: 2000000,
                  divisions: 20,
                  activeColor: AppColors.brandBlack,
                  inactiveColor: const Color(0xFFDED8D0),
                  onChanged: (newValues) {
                    filterNotifier.setPriceRange(newValues);
                  },
                ),
                const SizedBox(height: 20),

                // 4. Màu sắc NÉORA
                _buildSectionTitle('BẢNG MÀU THỜI TRANG'),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _colors.map((c) {
                    final color = c['color'] as Color;
                    final name = c['name'] as String;
                    final isSelected = filterState.selectedColors.any(
                      (sc) => sc.toARGB32() == color.toARGB32(),
                    );

                    return GestureDetector(
                      onTap: () => filterNotifier.toggleColor(color),
                      child: Column(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.coralOrange
                                    : const Color(0xFFCBC4BB),
                                width: isSelected ? 2.5 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: isSelected
                                ? Icon(
                                    Icons.check,
                                    size: 18,
                                    color: color == const Color(0xFFFFFFFF)
                                        ? Colors.black
                                        : Colors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: isSelected
                                  ? AppColors.brandBlack
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // 5. Kích thước (Size)
                _buildSectionTitle('KÍCH THƯỚC (SIZE)'),
                const SizedBox(height: 10),
                Row(
                  children: _sizes.map((s) {
                    final isSelected = filterState.selectedSizes.contains(s);
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => filterNotifier.toggleSize(s),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 44,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.brandBlack
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.brandBlack
                                  : AppColors.cardBorder,
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              s,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w900
                                    : FontWeight.w700,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              MediaQuery.of(context).padding.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: AppColors.cardBorder, width: 0.8),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandBlack,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Áp dụng bộ lọc (${widget.totalMatching} sản phẩm)',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w800,
        color: AppColors.textMuted,
        letterSpacing: 0.6,
      ),
    );
  }
}
