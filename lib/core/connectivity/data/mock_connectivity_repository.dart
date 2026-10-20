import '../domain/repositories/connectivity_repository.dart';

class MockConnectivityRepository implements ConnectivityRepository {
  MockConnectivityRepository({required this.isSimulatedOffline});

  final bool Function() isSimulatedOffline;

  @override
  Future<bool> checkConnection() async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    return !isSimulatedOffline();
  }
}
