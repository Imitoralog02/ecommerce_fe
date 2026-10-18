import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/floating_liquid_glass_dock.dart';
import '../../../cart/presentation/viewmodels/cart_viewmodel.dart';
import '../../../cart/presentation/views/cart_screen.dart';
import '../../../home/presentation/views/home_screen.dart';
import '../../../notifications/presentation/views/notifications_screen.dart';
import '../../../notifications/presentation/viewmodels/notification_viewmodel.dart';
import '../../../profile/presentation/views/profile_screen.dart';
import '../../../shop/presentation/views/shop_screen.dart';

class MainNavScreen extends ConsumerStatefulWidget {
  final int initialIndex;

  const MainNavScreen({super.key, this.initialIndex = 0});

  @override
  ConsumerState<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends ConsumerState<MainNavScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _selectTab(int index) {
    if (_currentIndex == index) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartViewModelProvider);
    final unreadNotifications = ref.watch(unreadNotificationCountProvider);

    final screens = [
      HomeScreen(
        onOpenCart: () => _selectTab(3),
        onOpenSearch: () => _selectTab(1),
      ),
      const ShopScreen(),
      const NotificationsScreen(showBackButton: false),
      CartScreen(onStartShopping: () => _selectTab(1)),
      const ProfileScreen(),
    ];

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _currentIndex != 0) {
          _selectTab(0);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(index: _currentIndex, children: screens),
        bottomNavigationBar: FloatingLiquidGlassDock(
          selectedIndex: _currentIndex,
          cartItemCount: cartState.totalItemCount,
          unreadNotificationsCount: unreadNotifications,
          onItemSelected: _selectTab,
        ),
      ),
    );
  }
}
