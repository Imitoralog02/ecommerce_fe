import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/address_entity.dart';
import '../viewmodels/address_viewmodel.dart';
import 'add_edit_address_screen.dart';

class AddressBookScreen extends ConsumerWidget {
  final bool isSelectMode;

  const AddressBookScreen({super.key, this.isSelectMode = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressState = ref.watch(addressViewModelProvider);
    final addressNotifier = ref.read(addressViewModelProvider.notifier);
    final addresses = addressState.addresses;

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
          isSelectMode ? 'Chọn địa chỉ nhận hàng' : 'Sổ địa chỉ',
          style: const TextStyle(
            fontSize: 16.5,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_rounded,
              size: 24,
              color: AppColors.textPrimary,
            ),
            tooltip: 'Thêm địa chỉ mới',
            onPressed: () {
              Navigator.push(
                context,
                AppRouter.page(builder: (_) => const AddEditAddressScreen()),
              );
            },
          ),
        ],
      ),
      body: addresses.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 100),
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final address = addresses[index];
                final isSelected = address.id == addressState.selectedAddressId;

                return _buildAddressCard(
                  context: context,
                  ref: ref,
                  address: address,
                  isSelected: isSelected,
                  isSelectMode: isSelectMode,
                  onSelect: () {
                    addressNotifier.selectAddress(address.id);
                    if (isSelectMode) {
                      Navigator.pop(context, address);
                    }
                  },
                );
              },
            ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF502814).withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  AppRouter.page(builder: (_) => const AddEditAddressScreen()),
                );
              },
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text(
                'THÊM ĐỊA CHỈ MỚI',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
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
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.softPeach,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.location_off_outlined,
                  size: 38,
                  color: AppColors.coralOrange,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Chưa có địa chỉ nào',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hãy thêm địa chỉ giao hàng để đặt hàng nhanh chóng và chính xác hơn.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard({
    required BuildContext context,
    required WidgetRef ref,
    required AddressEntity address,
    required bool isSelected,
    required bool isSelectMode,
    required VoidCallback onSelect,
  }) {
    return GestureDetector(
      onTap: onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.coralOrange : AppColors.cardBorder,
            width: isSelected ? 1.8 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(
                0xFF502814,
              ).withValues(alpha: isSelected ? 0.08 : 0.04),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Name, Phone, Badges & Radio indicator
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Radio indicator in select mode
                Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  size: 20,
                  color: isSelected
                      ? AppColors.coralOrange
                      : AppColors.textMuted,
                ),
                const SizedBox(width: 10),

                // Name & phone
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          address.recipientName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '|  ${address.phoneNumber}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Edit button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      AppRouter.page(
                        builder: (_) =>
                            AddEditAddressScreen(initialAddress: address),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.softPeach,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: AppColors.primaryBurgundy,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Row 2: Address full text
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Text(
                address.fullAddress,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Row 3: Badges (Default, Label) & Quick set default
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Row(
                children: [
                  if (address.isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: AppColors.coralOrange,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'MẶC ĐỊNH',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0EBE3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      address.label,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (!address.isDefault)
                    GestureDetector(
                      onTap: () {
                        ref
                            .read(addressViewModelProvider.notifier)
                            .setDefaultAddress(address.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Đã đặt "${address.recipientName}" làm mặc định',
                            ),
                            backgroundColor: AppColors.brandBlack,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            duration: const Duration(milliseconds: 1400),
                          ),
                        );
                      },
                      child: const Text(
                        'Đặt mặc định',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.coralOrange,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
