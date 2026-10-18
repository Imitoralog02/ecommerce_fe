import '../domain/repositories/connectivity_repository.dart';

class MockConnectivityRepository implements ConnectivityRepository {
  @override
  Future<bool> checkConnection() async {
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    return true;
  }
}
