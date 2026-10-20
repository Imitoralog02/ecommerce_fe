import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/product_visual_widget.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../domain/entities/return_request.dart';
import '../viewmodels/return_request_viewmodel.dart';

class ReturnRequestScreen extends ConsumerStatefulWidget {
  final OrderEntity order;

  const ReturnRequestScreen({super.key, required this.order});

  @override
  ConsumerState<ReturnRequestScreen> createState() =>
      _ReturnRequestScreenState();
}

class _ReturnRequestScreenState extends ConsumerState<ReturnRequestScreen> {
  final TextEditingController _noteController = TextEditingController();

  ReturnRequestSeed get _seed => (
    orderId: widget.order.id,
    firstItemId: widget.order.items.firstOrNull?.product.id,
  );

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _submitRequest() {
    final viewModel = ref.read(returnRequestViewModelProvider(_seed).notifier);
    final note = _noteController.text.trim();
    final validationMessage = viewModel.validate(note);
    if (validationMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationMessage),
          backgroundColor: AppColors.saleRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final receipt = viewModel.submit(note: note)!;

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
                width: 68,
                height: 68,
                decoration: const BoxDecoration(
                  color: AppColors.liveGreenSoft,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_rounded,
                    size: 38,
                    color: AppColors.liveGreen,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Yêu Cầu Đã Được Tiếp Nhận',
                style: TextStyle(
                  fontSize: 17.5,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F4EF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Mã yêu cầu: #${receipt.code}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.coralOrange,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                receipt.draft.solution == ReturnSolution.exchange
                    ? 'Yêu cầu đổi sang size ${receipt.draft.targetSize} đã được lưu trong bản demo. Chưa có nhân viên hoặc shipper liên hệ thực tế.'
                    : 'Yêu cầu trả hàng đã được lưu trong bản demo. Chưa có thu hồi hàng hoặc hoàn tiền thực tế.',
                textAlign: TextAlign.center,
                style: const TextStyle(
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
                    Navigator.pop(ctx);
                    Navigator.pop(context, true);
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
                    'ĐÃ HIỂU',
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

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(returnRequestViewModelProvider(_seed));
    final viewModel = ref.read(returnRequestViewModelProvider(_seed).notifier);

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
          'Yêu Cầu Đổi / Trả Hàng',
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
            onPressed: _submitRequest,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandBlack,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              'GỬI YÊU CẦU ĐỔI TRẢ 30 NGÀY',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Policy Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F3ED),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.liveGreen.withValues(alpha: 0.25),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    color: AppColors.liveGreen,
                    size: 24,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Đặc Quyền Đổi Trả 30 Ngày NÉORA',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF20523A),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Thử tạo yêu cầu đổi size trong 30 ngày. Bản demo chưa có giao nhận thực tế.',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF336B50),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 1. Select Items
            _buildSectionTitle('1. CHỌN SẢN PHẨM CẦN ĐỔI / TRẢ'),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: widget.order.items.map((item) {
                  final isSelected = draft.selectedItemIds.contains(
                    item.product.id,
                  );
                  return Column(
                    children: [
                      InkWell(
                        onTap: () => viewModel.setItemSelected(
                          item.product.id,
                          !isSelected,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Checkbox(
                                value: isSelected,
                                activeColor: AppColors.brandBlack,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                onChanged: (value) => viewModel.setItemSelected(
                                  item.product.id,
                                  value ?? false,
                                ),
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox(
                                  width: 54,
                                  height: 54,
                                  child: item.product.imagePath != null
                                      ? Image.asset(
                                          item.product.imagePath!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) =>
                                              ProductVisualWidget(
                                                imageType:
                                                    item.product.imageType,
                                              ),
                                        )
                                      : ProductVisualWidget(
                                          imageType: item.product.imageType,
                                        ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'Size: ${item.selectedSize} · Màu: ${item.selectedColor}',
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.formattedTotalPrice,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.primaryBurgundy,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 18),

            // 2. Select Reason
            _buildSectionTitle('2. LÝ DO ĐỔI / TRẢ'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: ReturnRequestOptions.reasons.map((reason) {
                  final isSelected = draft.selectedReason == reason;
                  return InkWell(
                    onTap: () => viewModel.selectReason(reason),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 9,
                        horizontal: 4,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: isSelected
                                ? AppColors.brandBlack
                                : AppColors.textMuted,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              reason,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: isSelected
                                    ? AppColors.brandBlack
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 18),

            // 3. Solution Method
            _buildSectionTitle('3. PHƯƠNG ÁN XỬ LÝ MONG MUỐN'),
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
                  // Option A: Exchange
                  GestureDetector(
                    onTap: () =>
                        viewModel.selectSolution(ReturnSolution.exchange),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: draft.solution == ReturnSolution.exchange
                            ? AppColors.softPeach
                            : const Color(0xFFF7F4EF),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: draft.solution == ReturnSolution.exchange
                              ? AppColors.coralOrange
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            draft.solution == ReturnSolution.exchange
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: draft.solution == ReturnSolution.exchange
                                ? AppColors.coralOrange
                                : AppColors.textMuted,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Đổi size (demo)',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'KHUYÊN DÙNG',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.coralOrange,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Lưu lựa chọn size mới để thử luồng đổi hàng; chưa có giao nhận thực tế.',
                                  style: TextStyle(
                                    fontSize: 11,
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
                  ),

                  // Target Size Picker if exchange selected
                  if (draft.solution == ReturnSolution.exchange) ...[
                    const SizedBox(height: 14),
                    const Text(
                      'Chọn kích cỡ bạn muốn đổi sang:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: ReturnRequestOptions.sizes.map((s) {
                        final isSize = draft.targetSize == s;
                        return GestureDetector(
                          onTap: () => viewModel.selectTargetSize(s),
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            width: 44,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isSize
                                  ? AppColors.brandBlack
                                  : const Color(0xFFF7F4EF),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSize
                                    ? AppColors.brandBlack
                                    : AppColors.cardBorder,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                s,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: isSize
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Option B: Refund
                  GestureDetector(
                    onTap: () =>
                        viewModel.selectSolution(ReturnSolution.refund),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: draft.solution == ReturnSolution.refund
                            ? AppColors.softPeach
                            : const Color(0xFFF7F4EF),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: draft.solution == ReturnSolution.refund
                              ? AppColors.coralOrange
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            draft.solution == ReturnSolution.refund
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: draft.solution == ReturnSolution.refund
                                ? AppColors.coralOrange
                                : AppColors.textMuted,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Trả hàng & Hoàn tiền',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Bản demo chỉ lưu lựa chọn hoàn tiền; chưa có thu hồi hàng hoặc chuyển tiền thực tế.',
                                  style: TextStyle(
                                    fontSize: 11,
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
                  ),

                  if (draft.solution == ReturnSolution.refund) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => viewModel.selectRefundMethod(
                              RefundMethod.wallet,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: draft.refundMethod == RefundMethod.wallet
                                    ? AppColors.brandBlack
                                    : const Color(0xFFF7F4EF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '🪙 Ví NÉORA (Tức thì)',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color:
                                      draft.refundMethod == RefundMethod.wallet
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                viewModel.selectRefundMethod(RefundMethod.bank),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: draft.refundMethod == RefundMethod.bank
                                    ? AppColors.brandBlack
                                    : const Color(0xFFF7F4EF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '🏦 Thẻ ATM (1-3 ngày)',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: draft.refundMethod == RefundMethod.bank
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 4. Evidence Photos
            _buildSectionTitle('4. ẢNH SẢN PHẨM MẪU'),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: SizedBox(
                height: 74,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    ...draft.evidencePhotos.map(
                      (photo) => Container(
                        width: 74,
                        height: 74,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: Image.asset(photo, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    Tooltip(
                      message: 'Thêm ảnh minh họa từ bộ sưu tập mẫu',
                      child: GestureDetector(
                        onTap: viewModel.pickEvidencePhoto,
                        child: Container(
                          width: 74,
                          height: 74,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F4EF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: const Icon(
                            Icons.add_a_photo_outlined,
                            size: 22,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // 5. Additional Note
            _buildSectionTitle('5. GHI CHÚ THÊM CHO CONCIERGE'),
            TextField(
              controller: _noteController,
              maxLines: 3,
              style: const TextStyle(fontSize: 13, color: AppColors.brandBlack),
              decoration: InputDecoration(
                hintText: 'Ghi chú thêm cho yêu cầu đổi trả mẫu...',
                hintStyle: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
