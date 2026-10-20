import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/auth_providers.dart';
export '../../di/auth_providers.dart';

enum AuthTab { login, register, forgot }

enum AuthErrorCode {
  emailRequired,
  invalidEmail,
  resetFailed,
  fullNameRequired,
  weakPassword,
  passwordMismatch,
  termsRequired,
  registrationFailed,
  accountRequired,
  passwordRequired,
  loginFailed,
}

enum AuthSuccessCode { resetLinkSent, registrationComplete }

class AuthState {
  final AuthTab currentTab;
  final String email;
  final String password;
  final String confirmPassword;
  final String fullName;
  final bool rememberMe;
  final bool agreeToTerms;
  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;
  final bool isLoading;
  final bool isAuthenticated;
  final AuthErrorCode? errorCode;
  final AuthSuccessCode? successCode;

  const AuthState({
    this.currentTab = AuthTab.login,
    this.email = 'demo@neora.vn',
    this.password = '',
    this.confirmPassword = '',
    this.fullName = '',
    this.rememberMe = true,
    this.agreeToTerms = true,
    this.isPasswordVisible = false,
    this.isConfirmPasswordVisible = false,
    this.isLoading = false,
    this.isAuthenticated = false,
    this.errorCode,
    this.successCode,
  });

  bool get isLogin => currentTab == AuthTab.login;
  bool get isRegister => currentTab == AuthTab.register;
  bool get isForgot => currentTab == AuthTab.forgot;

  AuthState copyWith({
    AuthTab? currentTab,
    String? email,
    String? password,
    String? confirmPassword,
    String? fullName,
    bool? rememberMe,
    bool? agreeToTerms,
    bool? isPasswordVisible,
    bool? isConfirmPasswordVisible,
    bool? isLoading,
    bool? isAuthenticated,
    AuthErrorCode? errorCode,
    AuthSuccessCode? successCode,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return AuthState(
      currentTab: currentTab ?? this.currentTab,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      fullName: fullName ?? this.fullName,
      rememberMe: rememberMe ?? this.rememberMe,
      agreeToTerms: agreeToTerms ?? this.agreeToTerms,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isConfirmPasswordVisible:
          isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
      successCode: clearSuccess ? null : (successCode ?? this.successCode),
    );
  }
}

class AuthViewModel extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState();
  }

  void switchTab(AuthTab tab) {
    state = state.copyWith(
      currentTab: tab,
      clearError: true,
      clearSuccess: true,
    );
  }

  void updateEmail(String email) {
    state = state.copyWith(email: email, clearError: true);
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password, clearError: true);
  }

  void updateConfirmPassword(String confirmPassword) {
    state = state.copyWith(confirmPassword: confirmPassword, clearError: true);
  }

  void updateFullName(String fullName) {
    state = state.copyWith(fullName: fullName, clearError: true);
  }

  void toggleRememberMe() {
    state = state.copyWith(rememberMe: !state.rememberMe);
  }

  void toggleAgreeToTerms() {
    state = state.copyWith(agreeToTerms: !state.agreeToTerms);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(
      isConfirmPasswordVisible: !state.isConfirmPasswordVisible,
    );
  }

  void logout() {
    state = const AuthState();
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email.trim());
  }

  Future<bool> submit() async {
    final email = state.email.trim();
    final password = state.password;

    if (state.currentTab == AuthTab.forgot) {
      if (email.isEmpty) {
        state = state.copyWith(errorCode: AuthErrorCode.emailRequired);
        return false;
      }
      if (!_isValidEmail(email)) {
        state = state.copyWith(errorCode: AuthErrorCode.invalidEmail);
        return false;
      }
      state = state.copyWith(
        isLoading: true,
        clearError: true,
        clearSuccess: true,
      );
      try {
        await ref
            .read(authRepositoryProvider)
            .requestPasswordReset(email: email);
      } catch (_) {
        state = state.copyWith(
          isLoading: false,
          errorCode: AuthErrorCode.resetFailed,
        );
        return false;
      }
      state = state.copyWith(
        isLoading: false,
        successCode: AuthSuccessCode.resetLinkSent,
      );
      return true;
    }

    if (state.currentTab == AuthTab.register) {
      if (state.fullName.trim().isEmpty) {
        state = state.copyWith(errorCode: AuthErrorCode.fullNameRequired);
        return false;
      }
      if (email.isEmpty) {
        state = state.copyWith(errorCode: AuthErrorCode.emailRequired);
        return false;
      }
      if (!_isValidEmail(email)) {
        state = state.copyWith(errorCode: AuthErrorCode.invalidEmail);
        return false;
      }
      if (password.length < 8 ||
          !RegExp(r'[A-Z]').hasMatch(password) ||
          !RegExp(r'[a-z]').hasMatch(password) ||
          !RegExp(r'[0-9]').hasMatch(password)) {
        state = state.copyWith(errorCode: AuthErrorCode.weakPassword);
        return false;
      }
      if (state.confirmPassword != password) {
        state = state.copyWith(errorCode: AuthErrorCode.passwordMismatch);
        return false;
      }
      if (!state.agreeToTerms) {
        state = state.copyWith(errorCode: AuthErrorCode.termsRequired);
        return false;
      }

      state = state.copyWith(
        isLoading: true,
        clearError: true,
        clearSuccess: true,
      );
      try {
        await ref
            .read(authRepositoryProvider)
            .register(
              fullName: state.fullName.trim(),
              email: email,
              password: password,
            );
      } catch (_) {
        state = state.copyWith(
          isLoading: false,
          errorCode: AuthErrorCode.registrationFailed,
        );
        return false;
      }
      state = state.copyWith(
        isLoading: false,
        currentTab: AuthTab.login,
        successCode: AuthSuccessCode.registrationComplete,
        password: '',
        confirmPassword: '',
      );
      return true;
    }

    // Login mode
    if (email.isEmpty) {
      state = state.copyWith(errorCode: AuthErrorCode.accountRequired);
      return false;
    }
    if (!_isValidEmail(email)) {
      state = state.copyWith(errorCode: AuthErrorCode.invalidEmail);
      return false;
    }
    if (password.isEmpty) {
      state = state.copyWith(errorCode: AuthErrorCode.passwordRequired);
      return false;
    }

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );
    try {
      await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorCode: AuthErrorCode.loginFailed,
      );
      return false;
    }
    state = state.copyWith(isLoading: false, isAuthenticated: true);
    return true;
  }
}

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(() {
  return AuthViewModel();
});
