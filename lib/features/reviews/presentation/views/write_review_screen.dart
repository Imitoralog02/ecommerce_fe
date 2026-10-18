import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/product_visual_widget.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../settings/presentation/viewmodels/settings_viewmodel.dart';
import '../../../wallet/presentation/viewmodels/wallet_viewmodel.dart';
import '../../domain/entities/review_entity.dart';
import '../viewmodels/review_viewmodel.dart';

class WriteReviewScreen extends ConsumerStatefulWidget {
  final OrderEntity? order;
  final CartItemEntity item;

  const WriteReviewScreen({super.key, this.order, required this.item});

  @override
  ConsumerState<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends ConsumerState<WriteReviewScreen> {
  int _rating = 5;
  String _selectedFit = 'Vừa vặn hoàn hảo';
  final TextEditingController _heightController = TextEditingController(
    text: '162',
  );
  final TextEditingController _weightController = TextEditingController(
    text: '48',
  );
  final TextEditingController _reviewController = TextEditingController();

  final List<String> _fitOptions = ['Hơi chật', 'Vừa vặn hoàn hảo', 'Hơi rộng'];

  final List<String> _quickTags = [
    'Chất vải mềm mại ✨',
    'Đường may sắc sảo 🧵',
    'Chuẩn phom tôn dáng 👗',
    'Màu đẹp hơn ảnh 📸',
    'Giao hàng 2h siêu tốc 🚀',
    'Đóng gói NÉORA sang trọng 🎁',
  ];

  final List<String> _uploadedPhotos = [
    'assets/images/real/lookbook_summer_1.jpg',
    'assets/images/real/lookbook_summer_2.jpg',
  ];

  String get _ratingLabel {
    switch (_rating) {
      case 1:
        return 'Rất không hài lòng 😞';
      case 2:
        return 'Chưa ưng ý 🙁';
      case 3:
        return 'Bình thường 😐';
      case 4:
        return 'Hài lòng, đúng mô tả 😊';
      case 5:
      default:
        return 'Tuyệt vời, vượt mong đợi! ✨';
    }
  }

  void _addQuickTag(String tag) {
    setState(() {
      if (_reviewController.text.isEmpty) {
        _reviewController.text = tag;
      } else {
        _reviewController.text = '${_reviewController.text}, $tag';
      }
    });
  }

  void _submitReview() {
    final height = int.tryParse(_heightController.text.trim());
    final weight = int.tryParse(_weightController.text.trim());
    final comment = _reviewController.text.trim();
    if (height == null || height < 80 || height > 250) {
      _showValidationMessage('Vui lòng nhập chiều cao hợp lệ từ 80–250 cm.');
      return;
    }
    if (weight == null || weight < 20 || weight > 300) {
      _showValidationMessage('Vui lòng nhập cân nặng hợp lệ từ 20–300 kg.');
      return;
    }
    if (comment.length < 10) {
      _showValidationMessage('Hãy chia sẻ cảm nhận ít nhất 10 ký tự.');
      return;
    }

    final reviewId = 'review_${DateTime.now().millisecondsSinceEpoch}';
    final profile = ref.read(settingsViewModelProvider).profile;
    final review = ReviewEntity(
      id: reviewId,
      userName: profile.name,
      userAvatar: 'assets/images/real/onb_shopping.jpg',
      rating: _rating.toDouble(),
      date: 'Vừa xong',
      purchasedSize: 'Size ${widget.item.selectedSize}',
      purchasedColor: widget.item.selectedColor,
      buyerHeight: '${height}cm',
      buyerWeight: '${weight}kg',
      fitFeedback: _selectedFit,
      comment: comment,
      reviewImages: List.unmodifiable(_uploadedPhotos),
    );
    final added = ref
        .read(reviewViewModelProvider(widget.item.product.id).notifier)
        .submitReview(
          review: review,
          submissionKey:
              '${widget.order?.id ?? 'standalone'}:${widget.item.product.id}',
        );
    if (!added) {
      _showValidationMessage('Sản phẩm trong đơn hàng này đã được đánh giá.');
      return;
    }
    ref.read(walletViewModelProvider.notifier).addReviewReward(reviewId);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.softPeach,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🪙', style: TextStyle(fontSize: 36)),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '+50 XU NÉORA',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: AppColors.coralOrange,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Cảm ơn bạn đã gửi đánh giá chi tiết!\nXu thưởng đã được cộng trực tiếp vào Ví NÉORA Club của bạn.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx); // Close dialog
                    Navigator.pop(context, true); // Pop screen with success
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandBlack,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'TUYỆT VỜI',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showValidationMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.brandBlack,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _pickReviewImage() async {
    if (_uploadedPhotos.length >= 5) return;
    final path = await ref
        .read(reviewViewModelProvider(widget.item.product.id).notifier)
        .pickReviewImage();
    if (!mounted || path == null) return;
    setState(() => _uploadedPhotos.add(path));
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Đánh Giá Sản Phẩm',
          style: TextStyle(
            fontSize: 16.5,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: _submitReview,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandBlack,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🪙', style: TextStyle(fontSize: 16)),
                SizedBox(width: 8),
                Text(
                  'GỬI ĐÁNH GIÁ (+50 XU)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Reward Callout Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.softPeach,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.coralOrange.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                children: [
                  Text('✨', style: TextStyle(fontSize: 22)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tặng 50 Xu NÉORA Club',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: AppColors.coralOrange,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Đánh giá kèm hình ảnh thực tế để tích xu mua sắm cho đơn hàng tiếp theo.',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2. Product Summary Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: ProductVisualWidget(
                        imageType: widget.item.product.imageType,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.product.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Phân loại: ${widget.item.selectedColor} / Size ${widget.item.selectedSize}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 3. Interactive Star Rating
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  const Text(
                    'Chất lượng sản phẩm thế nào?',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starValue = index + 1;
                      return GestureDetector(
                        onTap: () => setState(() => _rating = starValue),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            starValue <= _rating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 38,
                            color: const Color(0xFFC8A97E),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _ratingLabel,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.coralOrange,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 4. Fit Assessment
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text('👗', style: TextStyle(fontSize: 15)),
                      SizedBox(width: 8),
                      Text(
                        'Độ vừa vặn thực tế',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: _fitOptions.map((fit) {
                      final isSelected = _selectedFit == fit;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedFit = fit),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.brandBlack
                                  : const Color(0xFFF7F4EF),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.brandBlack
                                    : AppColors.cardBorder,
                              ),
                            ),
                            child: Text(
                              fit,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Color(0xFFF0EBE3)),
                  const SizedBox(height: 14),

                  // Buyer Measurements (Height / Weight)
                  const Text(
                    'Số đo của bạn (giúp người mua sau tham khảo size):',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Text(
                              'Cao: ',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: AppColors.textMuted,
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 42,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF7F4EF),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: TextField(
                                  controller: _heightController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  decoration: const InputDecoration(
                                    suffixText: 'cm ',
                                    suffixStyle: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textMuted,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Row(
                          children: [
                            const Text(
                              'Nặng: ',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: AppColors.textMuted,
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 42,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF7F4EF),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: TextField(
                                  controller: _weightController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  decoration: const InputDecoration(
                                    suffixText: 'kg ',
                                    suffixStyle: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textMuted,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 5. Review Text with Quick Tag Prompts
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chia sẻ cảm nhận chi tiết',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _reviewController,
                    maxLines: 4,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: AppColors.brandBlack,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          'Chất vải có mềm mại không? Phom đầm lên dáng ra sao? Đường may và bao bì đóng gói thế nào?...',
                      hintStyle: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textMuted,
                        height: 1.4,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF7F4EF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Gợi ý nhanh:',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: _quickTags.map((tag) {
                      return GestureDetector(
                        onTap: () => _addQuickTag(tag),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F4EF),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 6. Photo Attachments
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Text('📸', style: TextStyle(fontSize: 15)),
                          SizedBox(width: 8),
                          Text(
                            'Hình ảnh thực tế',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${_uploadedPhotos.length}/5 ảnh',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 84,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        ..._uploadedPhotos.map((photoPath) {
                          return Container(
                            width: 84,
                            height: 84,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(13),
                                  child: Image.asset(
                                    photoPath,
                                    width: 84,
                                    height: 84,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Container(
                                      color: const Color(0xFFF7F4EF),
                                      child: const Icon(
                                        Icons.image,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _uploadedPhotos.remove(photoPath);
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        // Add Button
                        GestureDetector(
                          onTap: _pickReviewImage,
                          child: Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F4EF),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.cardBorder,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo_outlined,
                                  size: 24,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Thêm ảnh',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
