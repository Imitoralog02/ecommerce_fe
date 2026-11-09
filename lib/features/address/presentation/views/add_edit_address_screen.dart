import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/vietnam_locations_data.dart';
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

  @override
  void initState() {
    super.initState();
    final a = widget.initialAddress;
    _nameController = TextEditingController(text: a?.recipientName ?? '');
    _phoneController = TextEditingController(text: a?.phoneNumber ?? '');
    _streetController = TextEditingController(text: a?.streetAddress ?? '');
    _wardController = TextEditingController(text: a?.ward ?? '');
    _districtController = TextEditingController(text: a?.district ?? '');
    _cityController = TextEditingController(text: a?.city ?? '');
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
    _showLocationPicker(
      title: 'Chọn Tỉnh / Thành phố',
      searchHint: 'Tìm Tỉnh / Thành phố...',
      items: VietnamLocationsData.cities,
      selectedValue: _cityController.text,
      onSelected: (city) {
        if (_cityController.text != city) {
          setState(() {
            _cityController.text = city;
            _districtController.text = '';
            _wardController.text = '';
          });
        }
      },
    );
  }

  void _showDistrictPicker() {
    final selectedCity = _cityController.text.trim();
    if (selectedCity.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Vui lòng chọn Tỉnh / Thành phố trước',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          backgroundColor: AppColors.brandBlack,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
      _showCityPicker();
      return;
    }

    final districts = VietnamLocationsData.districtsForCity(selectedCity);
    _showLocationPicker(
      title: 'Chọn Quận / Huyện',
      subtitle: 'Thuộc $selectedCity',
      searchHint: 'Tìm Quận / Huyện...',
      items: districts,
      selectedValue: _districtController.text,
      onSelected: (district) {
        if (_districtController.text != district) {
          setState(() {
            _districtController.text = district;
            _wardController.text = '';
          });
        }
      },
    );
  }

  void _showWardPicker() {
    final selectedCity = _cityController.text.trim();
    if (selectedCity.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Vui lòng chọn Tỉnh / Thành phố trước',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          backgroundColor: AppColors.brandBlack,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
      _showCityPicker();
      return;
    }

    final selectedDistrict = _districtController.text.trim();
    if (selectedDistrict.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Vui lòng chọn Quận / Huyện trước',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          backgroundColor: AppColors.brandBlack,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
      _showDistrictPicker();
      return;
    }

    final wards = VietnamLocationsData.wardsForDistrict(
      selectedCity,
      selectedDistrict,
    );
    _showLocationPicker(
      title: 'Chọn Phường / Xã',
      subtitle: 'Thuộc $selectedDistrict, $selectedCity',
      searchHint: 'Tìm Phường / Xã...',
      items: wards,
      selectedValue: _wardController.text,
      onSelected: (ward) {
        setState(() {
          _wardController.text = ward;
        });
      },
    );
  }

  void _showLocationPicker({
    required String title,
    String? subtitle,
    required String searchHint,
    required List<String> items,
    required String selectedValue,
    required ValueChanged<String> onSelected,
  }) {
    var searchQuery = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredItems = searchQuery.trim().isEmpty
                ? items
                : items
                      .where(
                        (item) => item.toLowerCase().contains(
                          searchQuery.trim().toLowerCase(),
                        ),
                      )
                      .toList();

            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.72,
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 16,
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                ),
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
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (subtitle != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  subtitle,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 20,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      onChanged: (value) {
                        setModalState(() {
                          searchQuery = value;
                        });
                      },
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: searchHint,
                        hintStyle: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          size: 19,
                          color: AppColors.textMuted,
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 11,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColors.cardBorder,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColors.cardBorder,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColors.coralOrange,
                            width: 1.2,
                          ),
                        ),
                      ),
                    ),
                    if (searchQuery.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {
                          onSelected(searchQuery.trim());
                          Navigator.pop(ctx);
                        },
                        icon: const Icon(Icons.edit_location_alt_outlined),
                        label: Text(
                          'Dùng địa phương tôi nhập: ${searchQuery.trim()}',
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Flexible(
                      child: filteredItems.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 28),
                              child: Center(
                                child: Text(
                                  'Không tìm thấy kết quả phù hợp',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              itemCount: filteredItems.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(
                                    height: 1,
                                    color: Color(0xFFF0EBE3),
                                  ),
                              itemBuilder: (_, index) {
                                final item = filteredItems[index];
                                final isSelected = item == selectedValue;
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 2,
                                  ),
                                  title: Text(
                                    item,
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
                                    onSelected(item);
                                    Navigator.pop(ctx);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleSave() async {
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
    final saved = widget.initialAddress != null
        ? await vm.updateAddress(newAddress)
        : await vm.addAddress(newAddress);
    if (!mounted) return;
    if (!saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ref.read(addressViewModelProvider).errorMessage ??
                'Không thể lưu địa chỉ',
          ),
        ),
      );
      return;
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
            onPressed: () async {
              final deleted = await ref
                  .read(addressViewModelProvider.notifier)
                  .deleteAddress(widget.initialAddress!.id);
              if (!mounted || !ctx.mounted) return;
              final messenger = ScaffoldMessenger.of(context);
              if (!deleted) {
                Navigator.pop(ctx);
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      ref.read(addressViewModelProvider).errorMessage ??
                          'Không thể xoá địa chỉ',
                    ),
                  ),
                );
                return;
              }
              Navigator.pop(ctx);
              messenger.showSnackBar(
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
              Navigator.pop(context);
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
                      validator: (v) =>
                          (v == null ||
                              !RegExp(
                                r'^[0-9+ .()-]{8,20}$',
                              ).hasMatch(v.trim()))
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
                    // 1. Tỉnh / Thành phố
                    _buildLocationSelectorField(
                      controller: _cityController,
                      label: 'Tỉnh / Thành phố',
                      placeholder: 'Chọn Tỉnh / Thành phố',
                      icon: Icons.location_city_outlined,
                      onTap: _showCityPicker,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Vui lòng chọn Tỉnh / Thành phố'
                          : null,
                    ),
                    const Divider(height: 1, color: Color(0xFFF2ECE4)),
                    // 2. Quận / Huyện (phụ thuộc Tỉnh / Thành phố)
                    _buildLocationSelectorField(
                      controller: _districtController,
                      label: 'Quận / Huyện',
                      placeholder: _cityController.text.isEmpty
                          ? 'Chọn Tỉnh / Thành phố trước'
                          : 'Chọn Quận / Huyện (${_cityController.text})',
                      icon: Icons.map_outlined,
                      enabled: _cityController.text.isNotEmpty,
                      onTap: _showDistrictPicker,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Vui lòng chọn quận/huyện'
                          : null,
                    ),
                    const Divider(height: 1, color: Color(0xFFF2ECE4)),
                    // 3. Phường / Xã (phụ thuộc Quận / Huyện)
                    _buildLocationSelectorField(
                      controller: _wardController,
                      label: 'Phường / Xã',
                      placeholder: _districtController.text.isEmpty
                          ? 'Chọn Quận / Huyện trước'
                          : 'Chọn Phường / Xã (${_districtController.text})',
                      icon: Icons.holiday_village_outlined,
                      enabled: _districtController.text.isNotEmpty,
                      onTap: _showWardPicker,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Vui lòng chọn phường/xã'
                          : null,
                    ),
                    const Divider(height: 1, color: Color(0xFFF2ECE4)),
                    // 4. Địa chỉ cụ thể
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
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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

  Widget _buildLocationSelectorField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    required IconData icon,
    required VoidCallback onTap,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return FormField<String>(
      key: ValueKey('${label}_${controller.text}'),
      initialValue: controller.text,
      validator: (_) => validator?.call(controller.text),
      builder: (fieldState) {
        final hasValue = controller.text.trim().isNotEmpty;
        return GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: enabled
                          ? AppColors.coralOrange
                          : AppColors.textMuted,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            hasValue ? controller.text : placeholder,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: hasValue
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: hasValue
                                  ? AppColors.textPrimary
                                  : const Color(0xFFC0BAB0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: enabled
                          ? AppColors.textMuted
                          : const Color(0xFFD5CFC7),
                    ),
                  ],
                ),
                if (fieldState.hasError) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 32),
                    child: Text(
                      fieldState.errorText!,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.saleRed,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
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
