import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/address_entity.dart';
import '../viewmodels/address_viewmodel.dart';

class AddEditAddressScreen extends ConsumerStatefulWidget {
  final AddressEntity? initialAddress;

  const AddEditAddressScreen({super.key, this.initialAddress});

  @override
  ConsumerState<AddEditAddressScreen> createState() =>
      _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends ConsumerState<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _streetController;
  late TextEditingController _wardController;
  late TextEditingController _districtController;
  late TextEditingController _cityController;

  late bool _isDefault;
  late String _label;

  final List<String> _popularCities = [
    'TP. Hồ Chí Minh',
    'Hà Nội',
    'Đà Nẵng',
    'Hải Phòng',
    'Cần Thơ',
    'Bình Dương',
    'Đồng Nai',
    'Khánh Hoà',
    'Lâm Đồng',
  ];

  @override
  void initState() {
    super.initState();
    final a = widget.initialAddress;
    _nameController = TextEditingController(text: a?.recipientName ?? '');
    _phoneController = TextEditingController(text: a?.phoneNumber ?? '');
    _streetController = TextEditingController(text: a?.streetAddress ?? '');
    _wardController = TextEditingController(text: a?.ward ?? '');
    _districtController = TextEditingController(text: a?.district ?? '');
    _cityController = TextEditingController(text: a?.city ?? 'TP. Hồ Chí Minh');
    _isDefault = a?.isDefault ?? false;
    _label = a?.label ?? 'Nhà riêng';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _wardController.dispose();
    _districtController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _showCityPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Chọn Tỉnh / Thành phố',
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _popularCities.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, color: Color(0xFFF0EBE3)),
                  itemBuilder: (_, index) {
                    final city = _popularCities[index];
                    final isSelected = city == _cityController.text;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      title: Text(
                        city,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: isSelected
                              ? FontWeight.w800
                              : FontWeight.w500,
                          color: isSelected
                              ? AppColors.coralOrange
                              : AppColors.textPrimary,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.coralOrange,
                              size: 20,
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          _cityController.text = city;
                        });
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    final id =
        widget.initialAddress?.id ??
        'addr_${DateTime.now().millisecondsSinceEpoch}';
    final newAddress = AddressEntity(
      id: id,
      recipientName: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      streetAddress: _streetController.text.trim(),
      ward: _wardController.text.trim(),
      district: _districtController.text.trim(),
      city: _cityController.text.trim(),
      isDefault: _isDefault,
      label: _label,
    );

    final vm = ref.read(addressViewModelProvider.notifier);
    if (widget.initialAddress != null) {
      vm.updateAddress(newAddress);
    } else {
      vm.addAddress(newAddress);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.initialAddress != null
              ? 'Đã cập nhật địa chỉ thành công'
              : 'Đã thêm địa chỉ mới',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.brandBlack,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );

    Navigator.pop(context, newAddress);
  }

  void _handleDelete() {
    if (widget.initialAddress == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text(
          'Xoá địa chỉ này?',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16.5,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'Bạn có chắc chắn muốn xoá địa chỉ giao hàng này không?',
          style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Huỷ',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(addressViewModelProvider.notifier)
                  .deleteAddress(widget.initialAddress!.id);
              Navigator.pop(ctx);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Đã xoá địa chỉ',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  backgroundColor: AppColors.saleRed,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
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
              'Xoá',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialAddress != null;

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
        title: Text(
          isEditing ? 'Sửa địa chỉ' : 'Thêm địa chỉ mới',
          style: const TextStyle(
            fontSize: 16.5,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thông tin liên hệ
              _buildSectionTitle('LIÊN HỆ NHẬN HÀNG'),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    _buildTextFormField(
                      controller: _nameController,
                      label: 'Họ và tên người nhận',
                      hint: 'Nhập họ và tên',
                      icon: Icons.person_outline_rounded,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Vui lòng nhập họ tên'
                          : null,
                    ),
                    const Divider(height: 1, color: Color(0xFFF2ECE4)),
                    _buildTextFormField(
                      controller: _phoneController,
                      label: 'Số điện thoại',
                      hint: 'Ví dụ: 0908 123 456',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) => (v == null || v.trim().length < 9)
                          ? 'Số điện thoại không hợp lệ'
                          : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Địa chỉ chi tiết
              _buildSectionTitle('ĐỊA CHỈ GIAO HÀNG'),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    // Tỉnh / Thành phố
                    GestureDetector(
                      onTap: _showCityPicker,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_city_outlined,
                              size: 20,
                              color: AppColors.coralOrange,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Tỉnh / Thành phố',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _cityController.text.isEmpty
                                        ? 'Chọn Tỉnh / Thành phố'
                                        : _cityController.text,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.textMuted,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFF2ECE4)),
                    // Quận / Huyện
                    _buildTextFormField(
                      controller: _districtController,
                      label: 'Quận / Huyện',
                      hint: 'Ví dụ: Quận 1, Cầu Giấy...',
                      icon: Icons.map_outlined,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Vui lòng nhập quận/huyện'
                          : null,
                    ),
                    const Divider(height: 1, color: Color(0xFFF2ECE4)),
                    // Phường / Xã
                    _buildTextFormField(
                      controller: _wardController,
                      label: 'Phường / Xã',
                      hint: 'Ví dụ: Phường Bến Nghé...',
                      icon: Icons.holiday_village_outlined,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Vui lòng nhập phường/xã'
                          : null,
                    ),
                    const Divider(height: 1, color: Color(0xFFF2ECE4)),
                    // Địa chỉ cụ thể
                    _buildTextFormField(
                      controller: _streetController,
                      label: 'Địa chỉ cụ thể (Số nhà, đường, toà nhà)',
                      hint: 'Ví dụ: Tầng 12 Bitexco, 2 Hải Triều',
                      icon: Icons.home_outlined,
                      maxLines: 2,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Vui lòng nhập địa chỉ cụ thể'
                          : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Loại địa chỉ
              _buildSectionTitle('LOẠI ĐỊA CHỈ'),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildLabelChip('Nhà riêng', Icons.home_rounded),
                  const SizedBox(width: 10),
                  _buildLabelChip('Văn phòng', Icons.business_rounded),
                  const SizedBox(width: 10),
                  _buildLabelChip('Khác', Icons.location_on_rounded),
                ],
              ),

              const SizedBox(height: 20),

              // Đặt làm mặc định
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Đặt làm địa chỉ mặc định',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Tự động chọn khi đặt đơn hàng mới',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Switch.adaptive(
                      value: _isDefault,
                      activeTrackColor: AppColors.coralOrange,
                      onChanged: (val) {
                        setState(() => _isDefault = val);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Nút Lưu
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandBlack,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isEditing ? 'CẬP NHẬT ĐỊA CHỈ' : 'LƯU ĐỊA CHỈ',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),

              if (isEditing) ...[
                const SizedBox(height: 14),
                Center(
                  child: TextButton.icon(
                    onPressed: _handleDelete,
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: AppColors.saleRed,
                    ),
                    label: const Text(
                      'Xoá địa chỉ này',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.saleRed,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: AppColors.textMuted,
      ),
    );
  }

  Widget _buildLabelChip(String label, IconData icon) {
    final isSelected = _label == label;
    return GestureDetector(
      onTap: () => setState(() => _label = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.softPeach : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.coralOrange : AppColors.cardBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected
                  ? AppColors.coralOrange
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? AppColors.primaryBurgundy
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(icon, size: 20, color: AppColors.coralOrange),
          labelText: label,
          labelStyle: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Color(0xFFC0BAB0),
          ),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
        ),
      ),
    );
  }
}
