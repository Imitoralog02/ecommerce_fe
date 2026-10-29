import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/connectivity/presentation/demo_connectivity_mode.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/network/remote_repositories.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../address/presentation/views/address_book_screen.dart';
import '../../../auth/di/auth_providers.dart';
import '../../../payment_methods/presentation/views/payment_methods_screen.dart';
import '../../domain/entities/user_settings.dart';
import '../viewmodels/settings_viewmodel.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  UserSettings get _settings => ref.read(settingsViewModelProvider);
  String get _userName => _settings.profile.name;
  String get _userEmail => _settings.profile.email;
  String get _userPhone => _settings.profile.phone;
  String get _userBirthday => _settings.profile.birthday;
  String get _userGender => _settings.profile.gender;

  void _showSingleOptionMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.brandBlack,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  void _showLanguagePicker() {
    final strings = AppLocalizations.of(context);
    final current = ref.read(settingsViewModelProvider).languageCode;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.displayLanguageLabel,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              for (final option in [
                ('vi', strings.vietnameseLanguage),
                ('en', strings.englishLanguage),
              ])
                ListTile(
                  title: Text(option.$2),
                  trailing: current == option.$1
                      ? const Icon(
                          Icons.check_rounded,
                          color: AppColors.coralOrange,
                        )
                      : null,
                  onTap: () {
                    ref
                        .read(settingsViewModelProvider.notifier)
                        .setLanguage(option.$1);
                    Navigator.pop(sheetContext);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVersionInfo() {
    showAboutDialog(
      context: context,
      applicationName: 'NÉORA',
      applicationVersion: '1.0.0+1',
      applicationIcon: const Icon(
        Icons.auto_awesome_rounded,
        color: AppColors.camelGold,
        size: 34,
      ),
      children: const [Text('Ứng dụng mua sắm thời trang NÉORA.')],
    );
  }

  void _showEditProfileSheet() {
    final nameCtrl = TextEditingController(text: _userName);
    final phoneCtrl = TextEditingController(text: _userPhone);
    final emailCtrl = TextEditingController(text: _userEmail);
    final birthdayCtrl = TextEditingController(text: _userBirthday);
    String selectedGender = _userGender;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(26),
              topRight: Radius.circular(26),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6CFC7),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Chỉnh Sửa Hồ Sơ Cá Nhân',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 18),

                // Full Name
                _buildFieldLabel('Họ và tên'),
                _buildTextField(nameCtrl, 'Nhập họ và tên'),
                const SizedBox(height: 14),

                // Phone
                _buildFieldLabel('Số điện thoại'),
                _buildTextField(
                  phoneCtrl,
                  'Nhập số điện thoại',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 14),

                // Email
                _buildFieldLabel('Email đăng nhập (không chỉnh sửa tại đây)'),
                _buildTextField(
                  emailCtrl,
                  'Nhập email',
                  keyboardType: TextInputType.emailAddress,
                  readOnly: true,
                ),
                const SizedBox(height: 14),

                // Birthday
                _buildFieldLabel('Ngày sinh'),
                _buildTextField(
                  birthdayCtrl,
                  'DD/MM/YYYY',
                  keyboardType: TextInputType.datetime,
                ),
                const SizedBox(height: 14),

                // Gender Selector
                _buildFieldLabel('Giới tính'),
                Row(
                  children: ['Nữ', 'Nam', 'Khác'].map((g) {
                    final isSelected = selectedGender == g;
                    return GestureDetector(
                      onTap: () => setSheetState(() => selectedGender = g),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
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
                          g,
                          style: TextStyle(
                            fontSize: 13,
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
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await ref
                            .read(settingsViewModelProvider.notifier)
                            .updateProfile(
                              UserProfile(
                                name: nameCtrl.text.trim(),
                                phone: phoneCtrl.text.trim(),
                                email: emailCtrl.text.trim(),
                                birthday: birthdayCtrl.text.trim(),
                                gender: selectedGender,
                              ),
                            );
                      } catch (error) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            content: Text('Không lưu được hồ sơ: $error'),
                          ),
                        );
                        return;
                      }
                      if (!mounted || !ctx.mounted) return;
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Đã cập nhật hồ sơ cá nhân thành công ✨',
                          ),
                          backgroundColor: AppColors.brandBlack,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          duration: const Duration(seconds: 2),
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
                    child: const Text(
                      'Lưu thay đổi',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text(
          'Đổi mật khẩu',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'Chức năng đổi mật khẩu cần dịch vụ tài khoản. Bản demo chưa xử lý mật khẩu.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Đã hiểu',
              style: TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text(
          'Xoá tài khoản',
          style: TextStyle(
            fontSize: 16.5,
            fontWeight: FontWeight.w900,
            color: AppColors.saleRed,
          ),
        ),
        content: const Text(
          'Chức năng xoá tài khoản cần dịch vụ tài khoản. Bản demo chưa thực hiện xoá dữ liệu.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Đã hiểu',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPolicySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.80,
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(26),
            topRight: Radius.circular(26),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6CFC7),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Điều Khoản Dịch Vụ & Bảo Mật',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            const Expanded(
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Text(
                  '1. Phiên bản demo: Sản phẩm, đơn hàng, thanh toán và dịch vụ trong ứng dụng hiện là dữ liệu mẫu; không phát sinh giao dịch thật.\n\n'
                  '2. Đổi trả: Bạn có thể thử tạo yêu cầu đổi trả trong 30 ngày theo chính sách hiển thị. Yêu cầu chỉ được lưu cục bộ; chưa có giao nhận hoặc hoàn tiền thực tế.\n\n'
                  '3. Dữ liệu cục bộ: Ứng dụng lưu dữ liệu demo trên thiết bị. Không nhập thông tin thẻ hoặc dữ liệu cá nhân thật vào bản mẫu.\n\n'
                  '4. Hội viên NÉORA Club: Xu và voucher mẫu dùng để thử tính giá đơn trong ứng dụng, không quy đổi thành tiền mặt.',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textSecondary,
                    height: 1.55,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandBlack,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Tôi đã hiểu',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remoteMode = ref.read(authRepositoryProvider) is RemoteAuthRepository;
    final strings = AppLocalizations.of(context);
    final settings = ref.watch(settingsViewModelProvider);
    final settingsNotifier = ref.read(settingsViewModelProvider.notifier);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cardBorder, width: 0.8),
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
          'Cài Đặt Hệ Thống',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        children: [
          // User Card
          _buildUserProfileHeader(),

          const SizedBox(height: 20),

          // 1. Tài khoản & Hồ sơ
          _buildSectionHeader('TÀI KHOẢN & HỒ SƠ'),
          _buildCardWrapper([
            _buildSettingTile(
              icon: Icons.person_outline_rounded,
              title: 'Chỉnh sửa hồ sơ cá nhân',
              subtitle: '$_userName · $_userPhone · $_userBirthday',
              onTap: _showEditProfileSheet,
            ),
            const Divider(height: 1, color: Color(0xFFF0EBE3)),
            _buildSettingTile(
              icon: Icons.location_on_outlined,
              title: 'Sổ địa chỉ nhận hàng',
              subtitle: 'Quản lý địa chỉ giao hàng',
              onTap: () {
                Navigator.push(
                  context,
                  AppRouter.page(builder: (_) => const AddressBookScreen()),
                );
              },
            ),
            if (!remoteMode) ...[
              const Divider(height: 1, color: Color(0xFFF0EBE3)),
              _buildSettingTile(
                icon: Icons.credit_card_outlined,
                title: 'Phương thức thanh toán & Thẻ',
                subtitle: 'Quản lý thẻ ngân hàng & ví điện tử',
                onTap: () {
                  Navigator.push(
                    context,
                    AppRouter.page(
                      builder: (_) => const PaymentMethodsScreen(),
                    ),
                  );
                },
              ),
            ],
          ]),

          const SizedBox(height: 20),

          // 2. Bảo mật
          _buildSectionHeader('BẢO MẬT & ĐĂNG NHẬP'),
          _buildCardWrapper([
            _buildSettingTile(
              icon: Icons.lock_outline_rounded,
              title: 'Đổi mật khẩu',
              subtitle: 'Chưa khả dụng trong bản demo',
              onTap: _showChangePasswordDialog,
            ),
            const Divider(height: 1, color: Color(0xFFF0EBE3)),
            _buildSwitchTile(
              icon: Icons.fingerprint_rounded,
              title: 'Đăng nhập sinh trắc học',
              subtitle: 'Cần tích hợp xác thực thiết bị',
              value: false,
              onChanged: null,
            ),
            const Divider(height: 1, color: Color(0xFFF0EBE3)),
            _buildSwitchTile(
              icon: Icons.security_rounded,
              title: 'Xác thực 2 yếu tố (2FA)',
              subtitle: 'Cần dịch vụ OTP và tài khoản',
              value: false,
              onChanged: null,
            ),
          ]),

          if (!remoteMode) ...[
            const SizedBox(height: 20),

            // 3. Thông báo đẩy
            _buildSectionHeader('CÀI ĐẶT THÔNG BÁO'),
            _buildCardWrapper([
              _buildSwitchTile(
                icon: Icons.local_shipping_outlined,
                title: 'Cập nhật đơn hàng',
                subtitle: 'Nhận thông báo khi bưu kiện thay đổi lộ trình',
                value: settings.notifyOrders,
                onChanged: settingsNotifier.setOrderNotifications,
              ),
              const Divider(height: 1, color: Color(0xFFF0EBE3)),
              _buildSwitchTile(
                icon: Icons.card_giftcard_rounded,
                title: 'Ưu đãi & Voucher VIP',
                subtitle: 'Nhận tin voucher mới và sự kiện Flash Sale',
                value: settings.notifyPromotions,
                onChanged: settingsNotifier.setPromotionNotifications,
              ),
              const Divider(height: 1, color: Color(0xFFF0EBE3)),
              _buildSwitchTile(
                icon: Icons.support_agent_rounded,
                title: 'Tin nhắn Stylist Concierge',
                subtitle: 'Nhắc nhở khi stylist phản hồi tư vấn',
                value: settings.notifyStylist,
                onChanged: settingsNotifier.setStylistNotifications,
              ),
            ]),
          ],

          if (!remoteMode) ...[
            const SizedBox(height: 20),

            _buildSectionHeader('TRẠNG THÁI DEMO'),
            _buildCardWrapper([
              _buildSwitchTile(
                icon: Icons.wifi_off_rounded,
                title: 'Mô phỏng mất kết nối',
                subtitle: 'Bật để xem màn offline; dữ liệu mẫu vẫn còn',
                value: ref.watch(demoConnectivityModeProvider),
                onChanged: (value) {
                  ref
                      .read(demoConnectivityModeProvider.notifier)
                      .setOffline(value);
                  if (value && Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ]),
          ],

          const SizedBox(height: 20),

          // 4. Hệ thống & Pháp lý
          _buildSectionHeader('ỨNG DỤNG & ĐIỀU KHOẢN'),
          _buildCardWrapper([
            _buildSettingTile(
              icon: Icons.language_rounded,
              title: strings.displayLanguageLabel,
              trailingText: settings.languageCode == 'en'
                  ? strings.englishLanguage
                  : strings.vietnameseLanguage,
              onTap: _showLanguagePicker,
            ),
            const Divider(height: 1, color: Color(0xFFF0EBE3)),
            _buildSettingTile(
              icon: Icons.monetization_on_outlined,
              title: 'Đơn vị tiền tệ',
              trailingText: 'VNĐ (₫)',
              onTap: () => _showSingleOptionMessage(
                'Phiên bản hiện tại chỉ hỗ trợ đơn vị VNĐ (₫).',
              ),
            ),
            const Divider(height: 1, color: Color(0xFFF0EBE3)),
            _buildSettingTile(
              icon: Icons.description_outlined,
              title: 'Điều khoản dịch vụ & Bảo mật',
              onTap: _showPolicySheet,
            ),
            const Divider(height: 1, color: Color(0xFFF0EBE3)),
            _buildSettingTile(
              icon: Icons.info_outline_rounded,
              title: 'Phiên bản ứng dụng',
              trailingText: '1.0.0+1',
              onTap: _showVersionInfo,
            ),
          ]),

          const SizedBox(height: 20),

          // 5. Nguy cơ
          _buildCardWrapper([
            _buildSettingTile(
              icon: Icons.delete_outline_rounded,
              title: 'Yêu cầu xoá tài khoản',
              subtitle: 'Chưa khả dụng trong bản demo',
              isDanger: true,
              onTap: _showDeleteAccountDialog,
            ),
          ]),

          const SizedBox(height: 36),
        ],
      ),
    );
  }

  Widget _buildUserProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF502814).withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.coralOrange, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(29),
              child: Image.asset(
                'assets/images/real/onb_shopping.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    const Icon(Icons.person, color: AppColors.coralOrange),
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
                      _userName,
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.softPeach,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'VIP',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: AppColors.coralOrange,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  _userEmail,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _showEditProfileSheet,
            icon: const Icon(
              Icons.edit_outlined,
              size: 20,
              color: AppColors.coralOrange,
            ),
          ),
        ],
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
          fontWeight: FontWeight.w800,
          color: AppColors.textMuted,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildCardWrapper(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF502814).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          type: MaterialType.transparency,
          child: Column(children: children),
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    String? trailingText,
    bool isDanger = false,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDanger ? const Color(0xFFFDEEEA) : const Color(0xFFF7F4EF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 19,
          color: isDanger ? AppColors.saleRed : AppColors.brandBlack,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: isDanger ? AppColors.saleRed : AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11.5,
                color: AppColors.textMuted,
              ),
            )
          : null,
      trailing: trailingText != null
          ? Text(
              trailingText,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            )
          : const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Color(0xFFB8B0A8),
            ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F4EF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 19, color: AppColors.brandBlack),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppColors.coralOrange,
        activeThumbColor: Colors.white,
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    bool obscure = false,
    bool readOnly = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      readOnly: readOnly,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.brandBlack,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
        filled: true,
        fillColor: const Color(0xFFF7F4EF),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
