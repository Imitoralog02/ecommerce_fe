import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../connectivity/presentation/connectivity_viewmodel.dart';
import '../theme/app_colors.dart';

class NoInternetScreen extends ConsumerStatefulWidget {
  final VoidCallback? onRetry;
  final String? title;
  final String? subtitle;
  final bool isMaintenance;

  const NoInternetScreen({
    super.key,
    this.onRetry,
    this.title,
    this.subtitle,
    this.isMaintenance = false,
  });

  @override
  ConsumerState<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends ConsumerState<NoInternetScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _pulseController
        ..stop()
        ..value = 0.5;
    } else if (!_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleRetry() async {
    final connected = await ref
        .read(connectivityViewModelProvider.notifier)
        .retry();

    if (mounted && connected) {
      if (widget.onRetry case final callback?) {
        callback();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.wifi_rounded, color: Colors.white, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Đã kiểm tra kết nối thành công.',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.brandBlack,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRetrying = ref.watch(
      connectivityViewModelProvider.select((state) => state.isRetrying),
    );
    final title =
        widget.title ??
        (widget.isMaintenance
            ? 'Hệ Thống Đang Nâng Cấp'
            : 'Mất Kết Nối Internet');
    final subtitle =
        widget.subtitle ??
        (widget.isMaintenance
            ? 'NÉORA đang chuẩn bị bộ sưu tập thời trang mới. Hệ thống sẽ trở lại phục vụ bạn trong ít phút tới.'
            : 'Không thể kết nối đến máy chủ NÉORA. Vui lòng kiểm tra lại kết nối Wi-Fi hoặc dữ liệu di động (4G/5G).');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Animated Pulsing Icon Stage
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: child,
                  );
                },
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            (widget.isMaintenance
                                    ? AppColors.camelGold
                                    : AppColors.coralOrange)
                                .withValues(alpha: 0.16),
                        blurRadius: 36,
                        spreadRadius: 8,
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFFEBE5DC),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      widget.isMaintenance
                          ? Icons.auto_awesome_rounded
                          : Icons.wifi_off_rounded,
                      size: 58,
                      color: widget.isMaintenance
                          ? AppColors.camelGold
                          : AppColors.coralOrange,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // Title
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 12),

              // Subtitle
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.55,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 20),

              // Error Code Tag
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Text(
                  widget.isMaintenance
                      ? 'TRẠNG THÁI: NEORA_MAINTENANCE'
                      : 'MÃ LỖI: ERR_NETWORK_DISCONNECTED',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ),

              const Spacer(),

              // Primary Action: Retry Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: isRetrying ? null : _handleRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandBlack,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: isRetrying
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.refresh_rounded, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'THỬ KẾT NỐI LẠI',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 12),

              // Secondary Action: Call VIP Hotline
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Đang kết nối tổng đài NÉORA Concierge 1800 6868 📞 (Miễn phí)...',
                        ),
                        backgroundColor: AppColors.brandBlack,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.brandBlack,
                    side: const BorderSide(
                      color: Color(0xFFD6CFC7),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.headset_mic_outlined, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'TỔNG ĐÀI CONCIERGE 1800 6868',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
