import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Session-only preview of the disconnected state. Local demo data stays intact.
class DemoConnectivityMode extends Notifier<bool> {
  @override
  bool build() => false;

  void setOffline(bool offline) => state = offline;
}

final demoConnectivityModeProvider =
    NotifierProvider<DemoConnectivityMode, bool>(DemoConnectivityMode.new);
