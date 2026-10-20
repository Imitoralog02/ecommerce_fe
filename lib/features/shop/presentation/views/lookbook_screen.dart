import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../cart/presentation/viewmodels/cart_viewmodel.dart';
import '../../../cart/presentation/views/cart_screen.dart';
import '../../../home/presentation/viewmodels/home_viewmodel.dart';
import '../../../product_detail/presentation/views/product_detail_screen.dart';
import '../../domain/services/lookbook_outfits.dart';

class LookbookScreen extends ConsumerStatefulWidget {
  final bool initialShowDetail;
  final String initialOccasion;

  const LookbookScreen({
    super.key,
    this.initialShowDetail = false,
    this.initialOccasion = 'Đi làm',
  });

  @override
  ConsumerState<LookbookScreen> createState() => _LookbookScreenState();
}

class _LookbookScreenState extends ConsumerState<LookbookScreen> {
  late String _selectedOccasion;
  String _selectedGender = 'Tất cả';
  double _budget = 1800000;
  bool _showOutfitDetail = false;
  int _selectedOutfitIndex = 0;
  final Set<int> _checkedItems = {0, 1, 2};
  int _selectedAltBagIndex = -1; // -1 = nâu, 0 = đen

  static const _occasions = [
    (label: 'Đi làm', icon: Icons.work_outline_rounded),
    (label: 'Đi chơi', icon: Icons.local_cafe_outlined),
    (label: 'Dự tiệc', icon: Icons.wine_bar_outlined),
    (label: 'Du lịch', icon: Icons.luggage_outlined),
  ];

  static const _genders = ['Tất cả', 'Nữ', 'Nam'];

  @override
  void initState() {
    super.initState();
    _selectedOccasion =
        _occasions.any((occasion) => occasion.label == widget.initialOccasion)
        ? widget.initialOccasion
        : 'Đi làm';
    _showOutfitDetail = widget.initialShowDetail;
  }

  Alignment _imageAlignment(String path) {
    if (path.contains('banner_men.jpg')) return const Alignment(0.58, -0.1);
    if (path.contains('p_knit.jpg')) return const Alignment(0.0, -0.35);
    return Alignment.center;
  }

  String _formatVnd(double price) {
    final intPrice = price.round();
    final s = intPrice.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
      buffer.write(s[i]);
    }
    return '${buffer.toString()} ₫';
  }

  void _openOutfit(int index, LookbookThemeModel outfit) {
    setState(() {
      _selectedOutfitIndex = index;
      _checkedItems
        ..clear()
        ..addAll(List.generate(outfit.items.length, (itemIndex) => itemIndex));
      _selectedAltBagIndex = -1;
      _showOutfitDetail = true;
    });
  }

  void _addSelectedToCart(LookbookThemeModel outfit) {
    final notifier = ref.read(cartViewModelProvider.notifier);
    int addedCount = 0;
    for (int i = 0; i < outfit.items.length; i++) {
      if (_checkedItems.contains(i)) {
        final item = outfit.items[i];
        if (notifier.addToCart(
          item.product,
          item.selectedSize,
          item.selectedColor,
        )) {
          addedCount++;
        }
      }
    }
    if (addedCount == 0) return;

    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã thêm $addedCount món từ "${outfit.title}" vào giỏ hàng',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        action: SnackBarAction(
          label: 'XEM GIỎ',
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              AppRouter.page(builder: (_) => const CartScreen()),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeViewModelProvider);
    if (homeState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }
    final outfits = LookbookOutfits.select(
      homeState.allProducts,
      occasion: _selectedOccasion,
      gender: _selectedGender,
      budget: _budget,
      bagColor: _selectedAltBagIndex == 0 ? 'Đen' : 'Nâu Da Bò',
    );
    if (outfits.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Stylist mỗi ngày')),
        body: const Center(
          child: Text('Chưa có outfit phù hợp với lựa chọn này.'),
        ),
      );
    }
    final selectedOutfit =
        outfits[_selectedOutfitIndex.clamp(0, outfits.length - 1)];

    if (_showOutfitDetail) {
      return _buildOutfitDetailScreen(selectedOutfit);
    }
    return _buildStylistOverviewScreen(outfits);
  }

  // ===========================================================================
  // Stylist gợi ý outfit - NÉORA
  // ===========================================================================
  Widget _buildStylistOverviewScreen(List<LookbookThemeModel> outfits) {
    final cartCount = ref.watch(cartViewModelProvider).totalItemCount;
    final primaryOutfit = outfits.first;
    final secondaryOutfit = outfits.length > 1 ? outfits[1] : outfits.first;
    final diffFromBudget = _budget - primaryOutfit.totalPrice;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            size: 20,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Stylist mỗi ngày',
          style: TextStyle(
            fontFamily: AppTypography.serifFont,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.shopping_bag_outlined,
                  size: 20,
                  color: AppColors.textPrimary,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    AppRouter.page(builder: (_) => const CartScreen()),
                  );
                },
              ),
              if (cartCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Center(
                      child: Text(
                        '$cartCount',
                        style: const TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  size: 13,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'BẠN CHỌN DỊP, NÉORA CHỌN ĐỒ',
                    style: AppTypography.architecturalCode.copyWith(
                      color: AppColors.primary,
                      fontSize: 10,
                      letterSpacing: 1.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Một ngày đẹp,\nbắt đầu từ bạn.',
              style: AppTypography.editorialHeadline.copyWith(fontSize: 28),
            ),
            const SizedBox(height: 6),
            const Text(
              'Phối vừa gu. Chi vừa đủ. Tự tin là chính mình.',
              style: AppTypography.body,
            ),
            const SizedBox(height: 20),

            // 1. Bạn đi đâu?
            const Text(
              'Bạn đi đâu?',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: _occasions.map((occ) {
                final isSelected = _selectedOccasion == occ.label;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: occ.label == _occasions.last.label ? 0 : 8,
                    ),
                    child: InkWell(
                      onTap: () =>
                          setState(() => _selectedOccasion = occ.label),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.studioGray,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.cardBorder,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              occ.icon,
                              size: 18,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              occ.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),

            // 2. Ngân sách cả bộ
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.studioGray,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ngân sách cả bộ',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        _formatVnd(_budget),
                        style: const TextStyle(
                          fontFamily: AppTypography.sansFont,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: AppColors.divider,
                      thumbColor: AppColors.primary,
                      overlayColor: AppColors.primary.withValues(alpha: 0.12),
                      trackHeight: 3,
                    ),
                    child: Slider(
                      value: _budget,
                      min: 500000,
                      max: 3000000,
                      divisions: 25,
                      onChanged: (v) => setState(() => _budget = v),
                    ),
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '500.000 ₫',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                      Text(
                        '3.000.000 ₫',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Dành cho (Gender chips)
            Row(
              children: [
                const Text(
                  'Dành cho:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 10),
                ..._genders.map((g) {
                  final active = _selectedGender == g;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedGender = g),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.primary
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: active
                                ? AppColors.primary
                                : AppColors.cardBorder,
                          ),
                        ),
                        child: Text(
                          g,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: active
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 20),

            // 4. Outfits Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${outfits.length} outfit vừa ngân sách',
                    style: AppTypography.editorialTitle,
                  ),
                ),
                Text(
                  _selectedOccasion,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Featured Outfit Card (Nữ)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(5),
                    ),
                    child: AspectRatio(
                      aspectRatio: 1.05,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            primaryOutfit.imagePath,
                            fit: BoxFit.cover,
                            alignment: _imageAlignment(primaryOutfit.imagePath),
                          ),
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.background.withValues(
                                  alpha: 0.92,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.auto_awesome,
                                    size: 11,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    primaryOutfit.badge,
                                    style: const TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.8,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                primaryOutfit.title,
                                style: AppTypography.editorialTitle,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.softPeach,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                diffFromBudget > 0
                                    ? 'Thấp hơn ngân sách ${_formatVnd(diffFromBudget)}'
                                    : 'Vừa ngân sách',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          primaryOutfit.subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1, color: AppColors.divider),
                        ),
                        ...primaryOutfit.items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '• ${item.title}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                Text(
                                  _formatVnd(item.price),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton(
                            onPressed: () => _openOutfit(0, primaryOutfit),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: Text(
                              'Xem outfit • ${_formatVnd(primaryOutfit.totalPrice)} →',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (outfits.length > 1) const SizedBox(height: 14),

            // Secondary Outfit Card
            if (outfits.length > 1)
              InkWell(
                onTap: () => _openOutfit(1, secondaryOutfit),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.studioGray,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: SizedBox(
                          width: 82,
                          height: 96,
                          child: Image.asset(
                            secondaryOutfit.imagePath,
                            fit: BoxFit.cover,
                            alignment: _imageAlignment(
                              secondaryOutfit.imagePath,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              secondaryOutfit.badge,
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              secondaryOutfit.title,
                              style: const TextStyle(
                                fontFamily: AppTypography.serifFont,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              secondaryOutfit.subtitle,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatVnd(secondaryOutfit.totalPrice),
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const Text(
                                  'Xem chi tiết →',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // SCREEN 9: Chi tiết outfit - NÉORA
  // ===========================================================================
  Widget _buildOutfitDetailScreen(LookbookThemeModel outfit) {
    final selectedCount = outfit.items
        .asMap()
        .keys
        .where(_checkedItems.contains)
        .length;
    final selectedTotal = outfit.items.asMap().entries.fold<double>(
      0,
      (sum, entry) =>
          _checkedItems.contains(entry.key) ? sum + entry.value.price : sum,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            size: 20,
            color: AppColors.textPrimary,
          ),
          onPressed: () {
            if (widget.initialShowDetail) {
              Navigator.maybePop(context);
            } else {
              setState(() => _showOutfitDetail = false);
            }
          },
        ),
        centerTitle: true,
        title: const Text(
          'Outfit của bạn',
          style: TextStyle(
            fontFamily: AppTypography.serifFont,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.shopping_bag_outlined,
              size: 20,
              color: AppColors.textPrimary,
            ),
            onPressed: () {
              Navigator.push(
                context,
                AppRouter.page(builder: (_) => const CartScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: AspectRatio(
                aspectRatio: 0.95,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      outfit.imagePath,
                      fit: BoxFit.cover,
                      alignment: _imageAlignment(outfit.imagePath),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${outfit.occasion} • ${outfit.gender}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title & Budget Pill
            Text(outfit.title, style: AppTypography.editorialHeadline),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  _formatVnd(selectedTotal),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.softPeach,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    selectedTotal <= _budget
                        ? 'Trong ngân sách (${_formatVnd(_budget)})'
                        : 'Vượt ngân sách (${_formatVnd(_budget)})',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Stylist Tip Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.softPeach,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.auto_awesome_outlined,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      outfit.inspiration,
                      style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.45,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Các món trong outfit
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Các món trong outfit',
                    style: AppTypography.editorialTitle,
                  ),
                ),
                Text(
                  'Đã chọn $selectedCount/${outfit.items.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ...outfit.items.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              final isChecked = _checkedItems.contains(idx);

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isChecked ? AppColors.primary : AppColors.cardBorder,
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: Checkbox(
                        value: isChecked,
                        activeColor: AppColors.primary,
                        onChanged: (_) {
                          setState(() {
                            if (isChecked) {
                              _checkedItems.remove(idx);
                            } else {
                              _checkedItems.add(idx);
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          AppRouter.page(
                            builder: (_) =>
                                ProductDetailScreen(product: item.product),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: SizedBox(
                          width: 58,
                          height: 66,
                          child: Image.asset(item.imagePath, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.studioGray,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.category,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _formatVnd(item.price),
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),

            if (outfit.items.any(
              (item) => item.product.id == 'prod_leather_bag',
            )) ...[
              const SizedBox(height: 20),

              // Chọn màu có sẵn của túi trong catalog
              const Text(
                'Đổi một chút, vẫn là bạn',
                style: AppTypography.editorialTitle,
              ),
              const SizedBox(height: 4),
              const Text(
                'Đổi màu túi, giữ nguyên giá sản phẩm.',
                style: AppTypography.body,
              ),
              const SizedBox(height: 12),
              _buildAlternativeCard(
                index: 0,
                image: 'assets/images/real/p_bag.jpg',
                title: 'Túi vai da - Đen',
                price: _formatVnd(
                  outfit.items
                      .firstWhere(
                        (item) => item.product.id == 'prod_leather_bag',
                      )
                      .price,
                ),
                note: 'Cùng mức giá',
              ),
            ],
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tổng $selectedCount món đã chọn',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      _formatVnd(selectedTotal),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: selectedCount == 0
                    ? null
                    : () => _addSelectedToCart(outfit),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Text('Thêm $selectedCount món vào giỏ'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlternativeCard({
    required int index,
    required String image,
    required String title,
    required String price,
    required String note,
  }) {
    final isSelected = _selectedAltBagIndex == index;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.cardBorder,
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: AspectRatio(
              aspectRatio: 1.15,
              child: Image.asset(image, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            price,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            note,
            style: const TextStyle(
              fontSize: 10.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 32,
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _selectedAltBagIndex = isSelected ? -1 : index;
                });
              },
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: isSelected
                    ? AppColors.primary
                    : Colors.transparent,
                foregroundColor: isSelected
                    ? Colors.white
                    : AppColors.textPrimary,
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.cardBorder,
                ),
              ),
              child: Text(
                isSelected ? 'Đã chọn ✓' : 'Chọn thay thế',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
