import 'package:flutter/material.dart';

import '../../features/auth/presentation/views/auth_screen.dart';
import '../../features/navigation/presentation/views/main_nav_screen.dart';
import '../../features/onboarding/presentation/views/onboarding_screen.dart';
import '../../features/tracking/presentation/views/order_tracking_screen.dart';

abstract final class AppRoutes {
  static const onboarding = '/onboarding';
  static const main = '/main';
  static const auth = '/auth';
  static const tracking = '/orders/tracking';
}

abstract final class AppRouter {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.onboarding:
        return _page(const OnboardingScreen(), settings);
      case AppRoutes.auth:
        return _page(const AuthScreen(), settings);
      case AppRoutes.tracking:
        return _page(
          OrderTrackingScreen(
            orderId: settings.arguments as String? ?? 'NEO-2094',
          ),
          settings,
        );
      case AppRoutes.main:
        return _page(
          MainNavScreen(initialIndex: settings.arguments as int? ?? 0),
          settings,
        );
      default:
        return _page(const MainNavScreen(), settings);
    }
  }

  static MaterialPageRoute<T> page<T>({
    required WidgetBuilder builder,
    String? name,
  }) => MaterialPageRoute<T>(
    builder: builder,
    settings: name == null ? null : RouteSettings(name: name),
  );

  static MaterialPageRoute<dynamic> _page(
    Widget child,
    RouteSettings settings,
  ) => MaterialPageRoute<dynamic>(builder: (_) => child, settings: settings);
}
