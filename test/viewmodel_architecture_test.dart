import 'package:ecommerce_fe/features/auth/domain/repositories/auth_repository.dart';
import 'package:ecommerce_fe/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:ecommerce_fe/features/checkout/domain/entities/checkout_selection.dart';
import 'package:ecommerce_fe/features/checkout/domain/entities/checkout_request.dart';
import 'package:ecommerce_fe/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:ecommerce_fe/features/checkout/presentation/viewmodels/checkout_viewmodel.dart';
import 'package:ecommerce_fe/features/cart/presentation/viewmodels/cart_viewmodel.dart';
import 'package:ecommerce_fe/features/orders/domain/entities/order_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository implements AuthRepository {
  bool loginCalled = false;
  bool shouldFail = false;
  String? resetEmail;
  String? resetCode;
  String? resetPassword;

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
  Future<void> requestPasswordReset({required String email}) async {
    resetEmail = email;
  }

  @override
  Future<void> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    resetEmail = email;
    resetCode = code;
    resetPassword = newPassword;
  }
}

class _FakeCheckoutRepository implements CheckoutRepository {
  CheckoutRequest? receivedRequest;
  bool shouldFail = false;
  String? resetEmail;
  String? resetCode;
  String? resetPassword;

  @override
  Future<OrderEntity> placeOrder(CheckoutRequest request) async {
    receivedRequest = request;
    if (shouldFail) throw Exception('mock checkout error');
    return OrderEntity(
      id: 'NEO-TEST',
      orderDate: DateTime(2026, 10, 18),
      status: OrderStatus.pendingConfirmation,
      items: request.items,
      subtotal: request.quote.subtotal,
      shippingFee: request.quote.shippingFee,
      discountAmount: request.quote.discount,
      totalAmount: request.quote.total,
      shippingAddress: request.address,
    );
  }
}

void main() {
  test('password reset moves from email to code and back to login', () async {
    final repository = _FakeAuthRepository();
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final viewModel = container.read(authViewModelProvider.notifier);
    viewModel.switchTab(AuthTab.forgot);
    viewModel.updateEmail('demo@neora.vn');
    expect(await viewModel.submit(), isTrue);
    expect(repository.resetEmail, 'demo@neora.vn');
    expect(container.read(authViewModelProvider).isReset, isTrue);

    viewModel.updateResetCode('12345678');
    viewModel.updatePassword('NewPassword123');
    viewModel.updateConfirmPassword('NewPassword123');
    expect(await viewModel.submit(), isTrue);
    expect(repository.resetCode, '12345678');
    expect(repository.resetPassword, 'NewPassword123');
    expect(container.read(authViewModelProvider).isLogin, isTrue);
    expect(
      container.read(authViewModelProvider).successCode,
      AuthSuccessCode.passwordResetComplete,
    );
  });

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
      expect(
        container.read(checkoutViewModelProvider).paymentType,
        PaymentType.cashOnDelivery,
      );
      container.read(cartViewModelProvider.notifier).restoreVideoOrder();
      viewModel.setShipping(ShippingType.standard);
      viewModel.setPayment(PaymentType.cashOnDelivery);

      expect(await viewModel.placeOrder(), isNotNull);
      expect(
        repository.receivedRequest?.selection.shippingType,
        ShippingType.standard,
      );
      expect(
        repository.receivedRequest?.selection.paymentType,
        PaymentType.cashOnDelivery,
      );
      expect(container.read(checkoutViewModelProvider).shippingFee, 0);
      expect(container.read(checkoutViewModelProvider).isProcessing, isFalse);
      expect(container.read(cartViewModelProvider).items, isEmpty);
    },
  );
}
