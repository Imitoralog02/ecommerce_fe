import 'package:ecommerce_fe/features/auth/domain/repositories/auth_repository.dart';
import 'package:ecommerce_fe/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:ecommerce_fe/features/checkout/domain/entities/checkout_selection.dart';
import 'package:ecommerce_fe/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:ecommerce_fe/features/checkout/presentation/viewmodels/checkout_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository implements AuthRepository {
  bool loginCalled = false;
  bool shouldFail = false;

  @override
  Future<void> login({required String email, required String password}) async {
    loginCalled = true;
    if (shouldFail) throw Exception('mock login error');
  }

  @override
  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> requestPasswordReset({required String email}) async {}
}

class _FakeCheckoutRepository implements CheckoutRepository {
  CheckoutSelection? receivedSelection;
  bool shouldFail = false;

  @override
  Future<void> placeOrder(CheckoutSelection selection) async {
    receivedSelection = selection;
    if (shouldFail) throw Exception('mock checkout error');
  }
}

void main() {
  test('AuthViewModel delegates login to AuthRepository', () async {
    final repository = _FakeAuthRepository();
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final viewModel = container.read(authViewModelProvider.notifier);
    viewModel.updateEmail('demo@neora.vn');
    viewModel.updatePassword('123456');

    expect(await viewModel.submit(), isTrue);
    expect(repository.loginCalled, isTrue);
    expect(container.read(authViewModelProvider).isLoading, isFalse);
  });

  test('AuthViewModel converts repository failures into UI state', () async {
    final repository = _FakeAuthRepository()..shouldFail = true;
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final viewModel = container.read(authViewModelProvider.notifier);
    viewModel.updateEmail('demo@neora.vn');
    viewModel.updatePassword('123456');

    expect(await viewModel.submit(), isFalse);
    expect(container.read(authViewModelProvider).errorCode, isNotNull);
    expect(container.read(authViewModelProvider).isLoading, isFalse);
  });

  test(
    'CheckoutViewModel delegates the selected mock checkout options',
    () async {
      final repository = _FakeCheckoutRepository();
      final container = ProviderContainer(
        overrides: [checkoutRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final viewModel = container.read(checkoutViewModelProvider.notifier);
      viewModel.setShipping(ShippingType.standard);
      viewModel.setPayment(PaymentType.cashOnDelivery);

      expect(await viewModel.placeOrder(), isTrue);
      expect(repository.receivedSelection?.shippingType, ShippingType.standard);
      expect(
        repository.receivedSelection?.paymentType,
        PaymentType.cashOnDelivery,
      );
      expect(container.read(checkoutViewModelProvider).shippingFee, 0);
      expect(container.read(checkoutViewModelProvider).isProcessing, isFalse);
    },
  );
}
