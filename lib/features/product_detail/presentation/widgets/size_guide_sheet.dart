import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SizeGuideSheet extends StatefulWidget {
  final Function(String size)? onSelectSize;

  const SizeGuideSheet({super.key, this.onSelectSize});

  static Future<void> show(
    BuildContext context, {
    Function(String size)? onSelectSize,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SizeGuideSheet(onSelectSize: onSelectSize),
    );
  }

  @override
  State<SizeGuideSheet> createState() => _SizeGuideSheetState();
}

class _SizeGuideSheetState extends State<SizeGuideSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Interactive Size Calculator State
  double _userHeight = 162.0; // cm
  double _userWeight = 49.0; // kg

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _calculateSuggestedSize() {
    if (_userWeight < 46) return 'XS';
    if (_userWeight <= 52) return 'S';
    if (_userWeight <= 58) return 'M';
    if (_userWeight <= 65) return 'L';
    return 'XL';
  }

  String _getFitAdvice(String size) {
    switch (size) {
      case 'XS':
        return 'Phù hợp vóc dáng mảnh mai, tôn trọn đường eo thon gọn.';
      case 'S':
        return 'Kích cỡ chuẩn mẫu NÉORA. Vừa vặn thoải mái, tôn phom Á Đông.';
      case 'M':
        return 'Phom dáng thanh lịch, thoải mái cho mọi hoạt động hàng ngày.';
      case 'L':
        return 'Độ rủ mềm mại, che khuyết điểm tinh tế và sang trọng.';
      case 'XL':
      default:
        return 'Phom suông thoáng mát, dễ vận động cả ngày dài.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final suggestedSize = _calculateSuggestedSize();

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
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
                const Row(
                  children: [
                    Text('📏', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 8),
                    Text(
                      'Bảng Quy Chuẩn Kích Thước',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.cardBorder,
                        width: 0.8,
                      ),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Interactive Smart Calculator Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF502814).withValues(alpha: 0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Row(
                        children: [
                          Text('✨', style: TextStyle(fontSize: 14)),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'TÍNH SIZE THÔNG MINH',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.6,
                                color: AppColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.coralOrange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Gợi ý: Size $suggestedSize',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Height Slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Chiều cao:',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${_userHeight.toInt()} cm',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.coralOrange,
                      ),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.coralOrange,
                    inactiveTrackColor: const Color(0xFFEFE8DF),
                    thumbColor: AppColors.coralOrange,
                    overlayColor: AppColors.coralOrange.withValues(alpha: 0.15),
                    trackHeight: 3.5,
                  ),
                  child: Slider(
                    value: _userHeight,
                    min: 145,
                    max: 180,
                    divisions: 35,
                    onChanged: (val) => setState(() => _userHeight = val),
                  ),
                ),

                // Weight Slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Cân nặng:',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${_userWeight.toInt()} kg',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.coralOrange,
                      ),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.coralOrange,
                    inactiveTrackColor: const Color(0xFFEFE8DF),
                    thumbColor: AppColors.coralOrange,
                    overlayColor: AppColors.coralOrange.withValues(alpha: 0.15),
                    trackHeight: 3.5,
                  ),
                  child: Slider(
                    value: _userWeight,
                    min: 38,
                    max: 75,
                    divisions: 37,
                    onChanged: (val) => setState(() => _userWeight = val),
                  ),
                ),

                // Result Box
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.softPeach,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.brandBlack,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            suggestedSize,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _getFitAdvice(suggestedSize),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            height: 1.35,
                          ),
                        ),
                      ),
                      if (widget.onSelectSize != null)
                        TextButton(
                          onPressed: () {
                            widget.onSelectSize?.call(suggestedSize);
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Chọn size này',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              color: AppColors.coralOrange,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // TabBar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEBE5DC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: AppColors.textPrimary,
              unselectedLabelColor: AppColors.textMuted,
              labelStyle: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
              tabs: const [
                Tab(text: '👗 Đầm & Áo'),
                Tab(text: '👖 Quần & Váy'),
                Tab(text: '📏 Cách Đo'),
              ],
            ),
          ),

          // TabBarView Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDressSizeTable(),
                _buildPantsSizeTable(),
                _buildHowToMeasureGuide(),
              ],
            ),
          ),

          // Guarantee Footer
          Container(
            padding: EdgeInsets.fromLTRB(
              20,
              10,
              20,
              MediaQuery.of(context).padding.bottom + 10,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: AppColors.cardBorder, width: 0.8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.verified_outlined,
                  size: 16,
                  color: AppColors.mintGreen,
                ),
                const SizedBox(width: 8),
                Text(
                  'Bản demo: thử gửi yêu cầu đổi size trong 30 ngày',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mintGreen.withValues(alpha: 0.95),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDressSizeTable() {
    final rows = [
      {
        'size': 'XS',
        'bust': '78 - 82',
        'waist': '60 - 64',
        'hip': '84 - 88',
        'height': '150 - 156',
        'weight': '< 46kg',
      },
      {
        'size': 'S',
        'bust': '82 - 86',
        'waist': '64 - 68',
        'hip': '88 - 92',
        'height': '155 - 162',
        'weight': '46 - 52kg',
      },
      {
        'size': 'M',
        'bust': '86 - 90',
        'waist': '68 - 72',
        'hip': '92 - 96',
        'height': '158 - 166',
        'weight': '52 - 58kg',
      },
      {
        'size': 'L',
        'bust': '90 - 94',
        'waist': '72 - 76',
        'hip': '96 - 100',
        'height': '162 - 170',
        'weight': '58 - 65kg',
      },
      {
        'size': 'XL',
        'bust': '94 - 98',
        'waist': '76 - 80',
        'hip': '100 - 104',
        'height': '> 165',
        'weight': '> 65kg',
      },
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      children: [
        _buildTableCard(
          headers: ['Size', 'Ngực (cm)', 'Eo (cm)', 'Mông (cm)', 'Cân nặng'],
          rows: rows
              .map(
                (r) => [
                  r['size']!,
                  r['bust']!,
                  r['waist']!,
                  r['hip']!,
                  r['weight']!,
                ],
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildPantsSizeTable() {
    final rows = [
      {
        'size': '26 (XS)',
        'waist': '62 - 65',
        'hip': '84 - 87',
        'length': '96',
        'thigh': '48',
      },
      {
        'size': '27 (S)',
        'waist': '66 - 69',
        'hip': '88 - 91',
        'length': '98',
        'thigh': '50',
      },
      {
        'size': '28 (M)',
        'waist': '70 - 73',
        'hip': '92 - 95',
        'length': '100',
        'thigh': '52',
      },
      {
        'size': '29 (L)',
        'waist': '74 - 77',
        'hip': '96 - 99',
        'length': '102',
        'thigh': '54',
      },
      {
        'size': '30 (XL)',
        'waist': '78 - 81',
        'hip': '100 - 103',
        'length': '103',
        'thigh': '56',
      },
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      children: [
        _buildTableCard(
          headers: ['Size', 'Vòng eo', 'Vòng mông', 'Dài quần', 'Vòng đùi'],
          rows: rows
              .map(
                (r) => [
                  r['size']!,
                  r['waist']!,
                  r['hip']!,
                  r['length']!,
                  r['thigh']!,
                ],
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildTableCard({
    required List<String> headers,
    required List<List<String>> rows,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            // Header Row
            TableRow(
              decoration: const BoxDecoration(color: Color(0xFFF3EEE6)),
              children: headers
                  .map(
                    (h) => Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 11,
                        horizontal: 6,
                      ),
                      child: Text(
                        h,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            // Data Rows
            ...rows.asMap().entries.map((entry) {
              final isEven = entry.key % 2 == 0;
              final row = entry.value;
              return TableRow(
                decoration: BoxDecoration(
                  color: isEven ? Colors.white : const Color(0xFFFAFAF7),
                ),
                children: row.asMap().entries.map((cell) {
                  final isFirstCol = cell.key == 0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 4,
                    ),
                    child: Text(
                      cell.value,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isFirstCol
                            ? FontWeight.w900
                            : FontWeight.w600,
                        color: isFirstCol
                            ? AppColors.coralOrange
                            : AppColors.textSecondary,
                      ),
                    ),
                  );
                }).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHowToMeasureGuide() {
    final steps = [
      {
        'title': '1. Vòng ngực (Bust)',
        'desc':
            'Quấn thước dây quanh phần nở nhất của ngực, giữ thước phẳng ngang lưng.',
      },
      {
        'title': '2. Vòng eo (Waist)',
        'desc':
            'Đo quanh phần hẹp nhất của thắt lưng (thường nằm phía trên rốn khoảng 2-3 cm).',
      },
      {
        'title': '3. Vòng mông (Hips)',
        'desc':
            'Đứng thẳng 2 chân sát nhau, đo quanh vị trí nở nhất của vòng mông.',
      },
      {
        'title': '4. Chiều dài trang phục',
        'desc': 'Đo từ đỉnh vai xuôi xuống gấu váy hoặc mép gấu áo.',
      },
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      children: steps
          .map(
            (s) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.softPeach,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.straighten_rounded,
                      size: 20,
                      color: AppColors.coralOrange,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s['title']!,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          s['desc']!,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
