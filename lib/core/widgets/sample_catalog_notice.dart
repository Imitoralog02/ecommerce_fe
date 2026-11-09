import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class SampleCatalogNotice extends StatelessWidget {
  const SampleCatalogNotice({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: AppColors.softPeach,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        const Expanded(
          child: Text(
            'Đang xem sản phẩm mẫu. Kết nối máy chủ để cập nhật.',
            style: TextStyle(fontSize: 12),
          ),
        ),
        TextButton(onPressed: onRetry, child: const Text('Thử lại')),
      ],
    ),
  );
}
