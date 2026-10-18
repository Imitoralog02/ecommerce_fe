import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/payment_method_entities.dart';
import '../viewmodels/payment_methods_viewmodel.dart';

class PaymentMethodsScreen extends ConsumerStatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  ConsumerState<PaymentMethodsScreen> createState() =>
      _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends ConsumerState<PaymentMethodsScreen> {
  void _setDefaultCard(String id) {
    ref.read(paymentMethodsViewModelProvider.notifier).setDefaultCard(id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã cập nhật phương thức thanh toán mặc định ✨'),
        backgroundColor: AppColors.brandBlack,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _deleteCard(PaymentCardEntity card) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text(
          'Xoá thẻ thanh toán?',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.5),
        ),
        content: Text(
          'Bạn có chắc chắn muốn gỡ thẻ ${card.cardType} kết thúc bằng ${card.lastFour}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Huỷ',
              style: TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(paymentMethodsViewModelProvider.notifier)
                  .deleteCard(card.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Đã gỡ thẻ thành công.'),
                  backgroundColor: AppColors.brandBlack,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.saleRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Xoá thẻ',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCardSheet() {
    final numberCtrl = TextEditingController();
    final holderCtrl = TextEditingController();
    final expiryCtrl = TextEditingController();
    bool makeDefault = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          final cardNumber =
              '•••• •••• •••• ${numberCtrl.text.isEmpty ? '••••' : numberCtrl.text}';
          final cardHolder = holderCtrl.text.isEmpty
              ? 'NGUYEN LINH'
              : holderCtrl.text.toUpperCase();
          final cardExpiry = expiryCtrl.text.isEmpty
              ? 'MM/YY'
              : expiryCtrl.text;

          const detectedType = 'DEMO';

          return Container(
            height: MediaQuery.of(context).size.height * 0.88,
            padding: EdgeInsets.fromLTRB(
              20,
              14,
              20,
              MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4.5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD6CFC7),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Thêm thẻ thanh toán',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Semantics(
                        button: true,
                        label: 'Đóng biểu mẫu thêm thẻ',
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => Navigator.pop(ctx),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F4EF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Live Credit Card Visual
                  Container(
                    width: double.infinity,
                    height: 175,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF2C241E), Color(0xFF16120E)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.22),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 38,
                              height: 28,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD1A96A),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.nfc_rounded,
                                size: 18,
                                color: Color(0xFF6B4810),
                              ),
                            ),
                            Text(
                              detectedType,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                fontStyle: FontStyle.italic,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          cardNumber,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.2,
                            color: Colors.white,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'CARD HOLDER',
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    letterSpacing: 0.8,
                                    color: Colors.white54,
                                  ),
                                ),
                                Text(
                                  cardHolder,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'EXPIRES',
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    letterSpacing: 0.8,
                                    color: Colors.white54,
                                  ),
                                ),
                                Text(
                                  cardExpiry,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Fields
                  _buildSheetLabel('4 số cuối của thẻ'),
                  _buildSheetTextField(
                    numberCtrl,
                    '4242',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    onChanged: (_) => setSheetState(() {}),
                  ),

                  const SizedBox(height: 8),
                  const Text(
                    'Liên kết mô phỏng trong ứng dụng. Không nhập số thẻ đầy đủ hoặc CVV.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textMuted,
                    ),
                  ),

                  const SizedBox(height: 14),

                  _buildSheetLabel('Tên in trên thẻ (không dấu)'),
                  _buildSheetTextField(
                    holderCtrl,
                    'NGUYEN LINH',
                    textCapitalization: TextCapitalization.characters,
                    onChanged: (_) => setSheetState(() {}),
                  ),

                  const SizedBox(height: 14),

                  _buildSheetLabel('Ngày hết hạn'),
                  _buildSheetTextField(
                    expiryCtrl,
                    'MM/YY',
                    keyboardType: TextInputType.datetime,
                    onChanged: (_) => setSheetState(() {}),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Checkbox(
                        value: makeDefault,
                        activeColor: AppColors.brandBlack,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        onChanged: (v) =>
                            setSheetState(() => makeDefault = v ?? false),
                      ),
                      const Text(
                        'Đặt làm thẻ thanh toán mặc định',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        final last4 = numberCtrl.text.trim();
                        if (!RegExp(r'^\d{4}$').hasMatch(last4)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Vui lòng nhập đúng 4 chữ số.'),
                            ),
                          );
                          return;
                        }

                        final newCard = PaymentCardEntity(
                          id: 'card-${DateTime.now().millisecondsSinceEpoch}',
                          bankName: 'Thẻ mô phỏng',
                          cardType: detectedType,
                          lastFour: last4,
                          holderName: holderCtrl.text.trim().isEmpty
                              ? 'NGUYEN LINH'
                              : holderCtrl.text.toUpperCase(),
                          expiry: expiryCtrl.text.trim().isEmpty
                              ? '12/28'
                              : expiryCtrl.text.trim(),
                          gradientValues: const [0xFF2C241E, 0xFF16120E],
                          isDefault: makeDefault,
                        );

                        ref
                            .read(paymentMethodsViewModelProvider.notifier)
                            .addCard(newCard);

                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Đã thêm thẻ mô phỏng. Không có kết nối ngân hàng.',
                            ),
                            backgroundColor: AppColors.brandBlack,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
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
                          Icon(Icons.shield_outlined, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'LƯU THẺ',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13.5,
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
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentMethodsViewModelProvider);
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
          'Phương Thức Thanh Toán',
          style: TextStyle(
            fontSize: 16.5,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline_rounded,
              color: AppColors.brandBlack,
            ),
            onPressed: _showAddCardSheet,
          ),
        ],
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
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _showAddCardSheet,
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text(
              'THÊM THẺ THANH TOÁN',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandBlack,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
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
            // 1. Saved Bank Cards
            _buildSectionHeader('THẺ THANH TOÁN'),
            if (paymentState.cards.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Chưa có thẻ nào.'),
              ),
            ...paymentState.cards.map((card) => _buildCardTile(card)),

            const SizedBox(height: 20),

            // 2. E-Wallets
            _buildSectionHeader('VÍ ĐIỆN TỬ & CỔNG THANH TOÁN'),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  _buildWalletTile(
                    logoAsset: 'assets/images/real/onb_browsing.jpg',
                    name: 'Ví MoMo',
                    subtitle: paymentState.momoLinked
                        ? 'Đã bật liên kết mô phỏng'
                        : 'Bật để dùng trong đơn hàng mẫu',
                    isLinked: paymentState.momoLinked,
                    badgeColor: const Color(0xFFA50064),
                    onToggle: ref
                        .read(paymentMethodsViewModelProvider.notifier)
                        .setMomoLinked,
                  ),
                  const Divider(height: 1, color: Color(0xFFF0EBE3)),
                  _buildWalletTile(
                    logoAsset: 'assets/images/real/onb_delivery.jpg',
                    name: 'Ví ZaloPay',
                    subtitle: paymentState.zalopayLinked
                        ? 'Đã bật liên kết mô phỏng'
                        : 'Bật để dùng trong đơn hàng mẫu',
                    isLinked: paymentState.zalopayLinked,
                    badgeColor: const Color(0xFF0068FF),
                    onToggle: ref
                        .read(paymentMethodsViewModelProvider.notifier)
                        .setZalopayLinked,
                  ),
                  const Divider(height: 1, color: Color(0xFFF0EBE3)),
                  _buildWalletTile(
                    logoAsset: 'assets/images/real/onb_shopping.jpg',
                    name: 'Apple Pay / Google Pay',
                    subtitle: paymentState.deviceWalletEnabled
                        ? 'Đã bật liên kết mô phỏng'
                        : 'Bật để dùng trong đơn hàng mẫu',
                    isLinked: paymentState.deviceWalletEnabled,
                    badgeColor: AppColors.brandBlack,
                    onToggle: ref
                        .read(paymentMethodsViewModelProvider.notifier)
                        .setDeviceWalletEnabled,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 3. COD
            _buildSectionHeader('THANH TOÁN TRỰC TIẾP'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.softPeach,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.money_rounded,
                      size: 22,
                      color: AppColors.coralOrange,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Thanh toán khi nhận hàng (COD)',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Kiểm tra và thử trang phục tại nhà trước khi trả tiền cho shipper.',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.liveGreen,
                    size: 22,
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

  Widget _buildCardTile(PaymentCardEntity card) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: card.isDefault ? AppColors.coralOrange : AppColors.cardBorder,
          width: card.isDefault ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF502814).withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Card visual mini
              Container(
                width: 62,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    colors: card.gradientValues.map(Color.new).toList(),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text(
                    card.cardType,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${card.cardType} •••• ${card.lastFour}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (card.isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.softPeach,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'MẶC ĐỊNH',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: AppColors.coralOrange,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${card.bankName} · Hết hạn ${card.expiry}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                onSelected: (val) {
                  if (val == 'default') {
                    _setDefaultCard(card.id);
                  } else if (val == 'delete') {
                    _deleteCard(card);
                  }
                },
                itemBuilder: (_) => [
                  if (!card.isDefault)
                    const PopupMenuItem(
                      value: 'default',
                      child: Text(
                        'Đặt làm mặc định',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'Gỡ thẻ này',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.saleRed,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWalletTile({
    required String logoAsset,
    required String name,
    required String subtitle,
    required bool isLinked,
    required Color badgeColor,
    required ValueChanged<bool> onToggle,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F4EF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Icon(
            Icons.account_balance_wallet_outlined,
            size: 20,
            color: badgeColor,
          ),
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
      ),
      trailing: Switch.adaptive(
        value: isLinked,
        onChanged: onToggle,
        activeTrackColor: AppColors.coralOrange,
        activeThumbColor: Colors.white,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
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

  static Widget _buildSheetLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  static Widget _buildSheetTextField(
    TextEditingController controller,
    String hint, {
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      onChanged: onChanged,
      style: const TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w700,
        color: AppColors.brandBlack,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
        filled: true,
        fillColor: const Color(0xFFF7F4EF),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 11,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
