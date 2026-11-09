import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/di/auth_providers.dart';
import '../network/remote_repositories.dart';
import 'app_router.dart';

/// Returns false after opening sign in for a guest in API mode.
bool requireLogin(BuildContext context, WidgetRef ref) {
  final auth = ref.read(authRepositoryProvider);
  if (auth is! RemoteAuthRepository || auth.api.isAuthenticated) return true;
  Navigator.of(context).pushNamed(AppRoutes.auth);
  return false;
}
