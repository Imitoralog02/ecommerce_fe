import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/network/remote_repositories.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/product_visual_widget.dart';
import '../../../home/di/home_providers.dart';
import '../../../product_detail/presentation/views/product_detail_screen.dart';
import '../../domain/entities/remote_flash_sale_campaign.dart';

class RemoteFlashSaleScreen extends ConsumerStatefulWidget {
  const RemoteFlashSaleScreen({super.key});

  @override
  ConsumerState<RemoteFlashSaleScreen> createState() =>
      _RemoteFlashSaleScreenState();
}

class _RemoteFlashSaleScreenState extends ConsumerState<RemoteFlashSaleScreen> {
  late Future<List<RemoteFlashSaleCampaign>> _campaigns;
  Timer? _timer;
  Timer? _refreshTimer;
  DateTime _now = DateTime.now();

  RemoteProductRepository get _repository =>
      ref.read(productRepositoryProvider) as RemoteProductRepository;

  @override
  void initState() {
    super.initState();
    _campaigns = _repository.getActiveFlashSales();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) _reload();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _reload() =>
      setState(() => _campaigns = _repository.getActiveFlashSales());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Flash Sale')),
      body: FutureBuilder<List<RemoteFlashSaleCampaign>>(
        future: _campaigns,
        builder: (context, snapshot) {
          if (!snapshot.hasData && !snapshot.hasError) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Không tải được Flash Sale.'),
                  TextButton(onPressed: _reload, child: const Text('Thử lại')),
                ],
              ),
            );
          }
          final campaigns = snapshot.data!;
          if (campaigns.isEmpty ||
              campaigns.every((item) => item.endsAt.isBefore(_now))) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Hiện chưa có Flash Sale đang diễn ra.'),
                  TextButton(onPressed: _reload, child: const Text('Tải lại')),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              _reload();
              await _campaigns;
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                for (final campaign in campaigns.where(
                  (item) => item.endsAt.isAfter(_now),
                )) ...[
                  Text(
                    campaign.title,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Còn ${_remaining(campaign.endsAt)}'),
                  const SizedBox(height: 12),
                  if (campaign.products.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Các sản phẩm trong đợt sale này đã hết lượt.',
                      ),
                    ),
                  for (final product in campaign.products)
                    Card(
                      child: ListTile(
                        leading: SizedBox(
                          width: 56,
                          height: 56,
                          child: product.imagePath == null
                              ? ProductVisualWidget(
                                  imageType: product.imageType,
                                )
                              : Image.asset(
                                  product.imagePath!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) =>
                                      ProductVisualWidget(
                                        imageType: product.imageType,
                                      ),
                                ),
                        ),
                        title: Text(product.title, maxLines: 2),
                        subtitle: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${product.formattedPrice}  ·  Giá trước sale ${product.formattedOriginalPrice ?? ''}',
                            ),
                            if (product.flashSaleRemaining != null)
                              Text('Còn ${product.flashSaleRemaining} suất'),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          try {
                            final latest = await _repository.getProductById(
                              product.id,
                            );
                            if (!context.mounted || latest == null) return;
                            if (latest.flashSaleId != campaign.id ||
                                latest.flashSaleRemaining == null ||
                                latest.flashSaleRemaining! <= 0 ||
                                latest.price != product.price) {
                              _reload();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Ưu đãi vừa thay đổi. Giá hiện tại đã được cập nhật.',
                                  ),
                                ),
                              );
                            }
                            await Navigator.push(
                              context,
                              AppRouter.page(
                                builder: (_) =>
                                    ProductDetailScreen(product: latest),
                              ),
                            );
                            if (mounted) _reload();
                          } catch (_) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Không cập nhật được giá. Vui lòng thử lại.',
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  const SizedBox(height: 20),
                ],
                const Text(
                  'Giá trong giỏ hàng được cập nhật từ catalog khi thanh toán.',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _remaining(DateTime endsAt) {
    final seconds = endsAt.difference(_now).inSeconds.clamp(0, 999999999);
    final days = seconds ~/ 86400;
    final hours = (seconds % 86400) ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    return days > 0 ? '$days ngày $hours giờ' : '$hours giờ $minutes phút';
  }
}
