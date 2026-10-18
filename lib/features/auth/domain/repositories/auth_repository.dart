abstract interface class AuthRepository {
  Future<void> login({required String email, required String password});

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  });

  Future<void> requestPasswordReset({required String email});
}
