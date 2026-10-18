import 'package:flutter/material.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import 'live_chat_screen.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  int? _expandedIndex;

  final List<Map<String, dynamic>> _categories = [
    {
      'icon': '📦',
      'title': 'Đơn hàng & Giao vận',
      'sub': 'Mã vận đơn, giao 2h',
      'bg': Color(0xFFFBF4EB),
    },
    {
      'icon': '🔄',
      'title': 'Đổi trả & Hoàn tiền',
      'sub': '30 ngày tận nhà',
      'bg': Color(0xFFEDF4ED),
    },
    {
      'icon': '💎',
      'title': 'Hội viên & Điểm xu',
      'sub': 'Quyền lợi VIP, voucher',
      'bg': Color(0xFFF7EFF5),
    },
    {
      'icon': '💳',
      'title': 'Thanh toán & Hoá đơn',
      'sub': 'COD, MoMo, VAT',
      'bg': Color(0xFFEFF5FB),
    },
  ];

  final List<Map<String, String>> _faqs = [
    {
      'q': 'Làm thế nào để chọn size trang phục chuẩn xác?',
      'a':
          'Bảng kích cỡ của NÉORA được may đo chuẩn phom dáng Á Đông. Bạn có thể tham khảo bảng Size Chart tại từng sản phẩm hoặc bấm "Chat với Stylist" để được chuyên viên tư vấn trực tiếp theo số đo chiều cao & cân nặng của bạn nhé.',
    },
    {
      'q': 'Chính sách đổi trả 30 ngày hoạt động như thế nào?',
      'a':
          'NÉORA hỗ trợ đổi size, đổi mẫu hoàn toàn miễn phí tận nhà trong vòng 30 ngày kể từ khi nhận hàng. Sản phẩm chỉ cần còn nguyên tem mác và chưa qua giặt ủi. Shipper sẽ mang sản phẩm mới đến và thu hồi sản phẩm cũ.',
    },
    {
      'q': 'Thời gian giao hàng tiêu chuẩn và giao hỏa tốc?',
      'a':
          'NÉORA hỗ trợ giao hỏa tốc trong 2 giờ tại nội thành Hà Nội & TP.HCM. Với các tỉnh thành khác, thời gian giao hàng từ 2 - 3 ngày làm việc. Tất cả đơn hàng từ 300.000₫ đều được miễn phí vận chuyển.',
    },
    {
      'q': 'Làm sao để tích luỹ và sử dụng Xu NÉORA?',
      'a':
          'Bạn nhận ngay 50 xu mỗi ngày khi bấm "Điểm danh" tại Ví Voucher, và được hoàn 5% giá trị mỗi đơn hàng hoàn tất. 1.000 xu tương đương 1.000₫ và có thể dùng khấu trừ trực tiếp khi thanh toán đơn hàng.',
    },
    {
      'q': 'Tôi có được kiểm tra sản phẩm trước khi thanh toán không?',
      'a':
          'Có, NÉORA luôn đồng kiểm sản phẩm khi giao hàng. Bạn hoàn toàn có thể mở hộp kiểm tra chất lượng vải, đường may và mẫu mã trước khi thanh toán tiền cho nhân viên giao hàng.',
    },
  ];

  void _callHotline() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.phone_in_talk_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              'Đang kết nối Hotline NÉORA: 1900 8821...',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        backgroundColor: AppColors.brandBlack,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: Center(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cardBorder, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        title: const Text(
          'Trung Tâm Trợ Giúp',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Concierge Banner Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.brandBlack,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.camelGold.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.camelGold,
                            width: 0.8,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('✨', style: TextStyle(fontSize: 11)),
                            SizedBox(width: 4),
                            Text(
                              'NÉORA CONCIERGE 24/7',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                                color: AppColors.camelGold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.support_agent_rounded,
                        color: Colors.white70,
                        size: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Bạn cần hỗ trợ gì hôm nay?',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Đội ngũ Stylist và chuyên viên chăm sóc khách hàng của NÉORA luôn sẵn sàng phục vụ bạn.',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFD6CFC7),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // 2. 4 Quick Topic Boxes
            const Text(
              'CHỦ ĐỀ HỖ TRỢ PHỔ BIẾN',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.textMuted,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.55,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.cardBorder, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: cat['bg'] as Color,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            cat['icon'] as String,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cat['title'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        cat['sub'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // 3. FAQ Accordion Section
            const Text(
              'CÂU HỎI THƯỜNG GẶP (FAQ)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.textMuted,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _faqs.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final faq = _faqs[index];
                final isExpanded = _expandedIndex == index;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isExpanded
                          ? AppColors.camelGold
                          : AppColors.cardBorder,
                      width: isExpanded ? 1.4 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        onTap: () {
                          setState(() {
                            _expandedIndex = isExpanded ? null : index;
                          });
                        },
                        title: Text(
                          faq['q']!,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: isExpanded
                                ? AppColors.brandBlack
                                : AppColors.textPrimary,
                          ),
                        ),
                        trailing: AnimatedRotation(
                          turns: isExpanded ? 0.25 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 15,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      if (isExpanded)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Text(
                            faq['a']!,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // 4. Hotline Contact Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.softPeach,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.cardBorder, width: 0.8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.headset_mic_rounded,
                      color: AppColors.coralOrange,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hotline CSKH: 1900 8821',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Hỗ trợ từ 8:30 – 22:00 tất cả các ngày trong tuần',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _callHotline,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandBlack,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Gọi ngay',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          MediaQuery.of(context).padding.bottom + 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppColors.cardBorder, width: 0.8),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                AppRouter.page(builder: (_) => const LiveChatScreen()),
              );
            },
            icon: const Text('💬', style: TextStyle(fontSize: 16)),
            label: const Text(
              'Trò chuyện trực tiếp với Stylist',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
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
    );
  }
}
