import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/remote_repositories.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../checkout/di/checkout_providers.dart';
import '../../../checkout/domain/entities/promotion_offer.dart';

class RemoteVoucherWalletScreen extends ConsumerStatefulWidget {
  const RemoteVoucherWalletScreen({super.key});

  @override
  ConsumerState<RemoteVoucherWalletScreen> createState() =>
      _RemoteVoucherWalletScreenState();
}

class _RemoteVoucherWalletScreenState
    extends ConsumerState<RemoteVoucherWalletScreen> {
  late Future<List<PromotionOffer>> _offers;

  @override
  void initState() {
    super.initState();
    _offers = _repository.loadPromotions();
  }

  RemoteCheckoutRepository get _repository =>
      ref.read(checkoutRepositoryProvider) as RemoteCheckoutRepository;

  void _reload() => setState(() => _offers = _repository.loadPromotions());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Mã ưu đãi của bạn')),
      body: FutureBuilder<List<PromotionOffer>>(
        future: _offers,
        builder: (context, snapshot) {
          if (!snapshot.hasData && !snapshot.hasError) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Không tải được mã ưu đãi.'),
                  TextButton(onPressed: _reload, child: const Text('Thử lại')),
                ],
              ),
            );
          }
          final offers = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async {
              _reload();
              await _offers;
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Mã được kiểm tra lại khi thanh toán. Bạn có thể sao chép mã để dùng tại checkout.',
                ),
                const SizedBox(height: 16),
                if (offers.isEmpty)
                  const Text('Hiện chưa có mã ưu đãi đang hoạt động.'),
                for (final offer in offers)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offer.title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            offer.code,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (offer.minSubtotal > 0)
                            Text('Đơn tối thiểu ${offer.minSubtotal.toInt()}₫'),
                          Text(
                            offer.available
                                ? 'Còn ${offer.remainingUses?.toString() ?? 'không giới hạn'} lượt cho bạn'
                                : 'Đã hết lượt sử dụng',
                          ),
                          if (offer.endsAt != null)
                            Text(
                              'Hết hạn: ${offer.endsAt!.toLocal().day}/${offer.endsAt!.toLocal().month}/${offer.endsAt!.toLocal().year}',
                            ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: offer.available
                                  ? () async {
                                      await Clipboard.setData(
                                        ClipboardData(text: offer.code),
                                      );
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Đã sao chép ${offer.code}',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  : null,
                              icon: const Icon(Icons.copy),
                              label: const Text('Sao chép mã'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
