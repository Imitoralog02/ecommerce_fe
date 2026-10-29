import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/network/remote_repositories.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../onboarding/presentation/views/onboarding_screen.dart';
import '../viewmodels/auth_viewmodel.dart';

/// Modal BottomSheet wrapper for Auth
class AuthBottomSheet extends StatelessWidget {
  const AuthBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AuthBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 4.5,
            decoration: BoxDecoration(
              color: AppColors.cardBorder,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 8),
          const Expanded(child: AuthContent(isBottomSheet: true)),
        ],
      ),
    );
  }
}

/// Standalone Full-screen AuthScreen
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: AuthContent(isBottomSheet: false)),
    );
  }
}

/// The core AuthContent widget used by both AuthScreen and AuthBottomSheet
class AuthContent extends ConsumerStatefulWidget {
  final bool isBottomSheet;

  const AuthContent({super.key, required this.isBottomSheet});

  @override
  ConsumerState<AuthContent> createState() => _AuthContentState();
}

class _AuthContentState extends ConsumerState<AuthContent> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _errorMessage(AppLocalizations strings, AuthErrorCode code) =>
      switch (code) {
        AuthErrorCode.emailRequired => strings.authEmailRequiredError,
        AuthErrorCode.invalidEmail => strings.authInvalidEmailError,
        AuthErrorCode.resetFailed => strings.authResetFailedError,
        AuthErrorCode.fullNameRequired => strings.authFullNameRequiredError,
        AuthErrorCode.weakPassword => strings.authWeakPasswordError,
        AuthErrorCode.passwordMismatch => strings.authPasswordMismatchError,
        AuthErrorCode.termsRequired => strings.authTermsRequiredError,
        AuthErrorCode.registrationFailed => strings.authRegistrationFailedError,
        AuthErrorCode.accountRequired => strings.authAccountRequiredError,
        AuthErrorCode.passwordRequired => strings.authPasswordRequiredError,
        AuthErrorCode.loginFailed => strings.authLoginFailedError,
      };

  String _successMessage(
    AppLocalizations strings,
    AuthSuccessCode code,
    String email,
  ) {
    if (code == AuthSuccessCode.registrationComplete &&
        ref.read(authRepositoryProvider) is RemoteAuthRepository) {
      return strings.localeName.startsWith('en')
          ? 'Account created. Please sign in.'
          : 'Tài khoản đã được tạo. Vui lòng đăng nhập.';
    }
    return switch (code) {
      AuthSuccessCode.resetLinkSent => strings.authResetLinkSent(email),
      AuthSuccessCode.registrationComplete => strings.authRegistrationComplete,
    };
  }

  Future<void> _handleAuthSubmit() async {
    final strings = AppLocalizations.of(context);
    final notifier = ref.read(authViewModelProvider.notifier);
    final state = ref.read(authViewModelProvider);

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final fullName = _nameController.text.trim();

    notifier.updateEmail(email);
    notifier.updatePassword(password);
    notifier.updateFullName(fullName);
    notifier.updateConfirmPassword(_confirmPasswordController.text);

    final success = await notifier.submit();
    if (!mounted) return;

    if (success && state.currentTab == AuthTab.register) {
      _passwordController.clear();
      _confirmPasswordController.clear();
      return;
    }

    if (success && state.currentTab == AuthTab.login) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.brandBlack,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  ref.read(authRepositoryProvider) is RemoteAuthRepository
                      ? (strings.localeName.startsWith('en')
                            ? 'Signed in successfully.'
                            : 'Đăng nhập thành công.')
                      : strings.authLoginSuccess,
                  style: const TextStyle(
                    fontFamily: AppTypography.sansFont,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      final navigator = Navigator.of(context);
      if (widget.isBottomSheet) navigator.pop();
      navigator.pushReplacementNamed(AppRoutes.main, arguments: 0);
    }
  }

  void _backToOnboarding() {
    if (widget.isBottomSheet) {
      Navigator.pop(context);
      return;
    }
    Navigator.pushReplacement(
      context,
      AppRouter.page(builder: (_) => const OnboardingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final state = ref.watch(authViewModelProvider);
    final notifier = ref.read(authViewModelProvider.notifier);

    final eyebrowText = state.isForgot
        ? 'KHÔI PHỤC MẬT KHẨU'
        : state.isRegister
        ? 'ĐĂNG KÝ'
        : 'ĐĂNG NHẬP';

    final headlineText = state.isForgot
        ? strings.forgotPasswordTitle
        : state.isRegister
        ? 'Bắt đầu cùng NÉORA.'
        : 'Mừng bạn trở lại.';

    final subtitleText = state.isForgot
        ? strings.forgotPasswordSubtitle
        : state.isRegister
        ? 'Một tài khoản, nhiều cảm hứng. Cùng tìm phong cách của riêng bạn.'
        : 'Đăng nhập để lưu món yêu thích và tiếp tục hành trình mặc đẹp cùng NÉORA.';

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: (constraints.maxHeight - 36).clamp(
                0.0,
                double.infinity,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Header: NÉORA | ← Quay lại
                    Row(
                      children: [
                        const Expanded(
                          child: Text('NÉORA', style: AppTypography.brandLogo),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            if (state.isRegister || state.isForgot) {
                              notifier.switchTab(AuthTab.login);
                            } else if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            } else {
                              _backToOnboarding();
                            }
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          icon: const Icon(Icons.arrow_back, size: 14),
                          label: const Text(
                            'Quay lại',
                            style: TextStyle(
                              fontFamily: AppTypography.sansFont,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Text(
                      eyebrowText,
                      style: AppTypography.architecturalCode.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      headlineText,
                      style: AppTypography.editorialHeadline.copyWith(
                        fontSize: 30,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      subtitleText,
                      style: AppTypography.body.copyWith(
                        fontSize: 13,
                        height: 1.55,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (state.errorCode != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          _errorMessage(strings, state.errorCode!),
                          style: const TextStyle(
                            fontFamily: AppTypography.sansFont,
                            color: AppColors.saleRed,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    if (state.successCode != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          _successMessage(
                            strings,
                            state.successCode!,
                            state.email,
                          ),
                          style: const TextStyle(
                            fontFamily: AppTypography.sansFont,
                            color: AppColors.liveGreen,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    _buildFormFields(state, notifier),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: state.isLoading ? null : _handleAuthSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: state.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                state.isForgot
                                    ? strings.sendResetLinkAction
                                    : state.isRegister
                                    ? 'Tạo tài khoản  →'
                                    : 'Đăng nhập  →',
                                style: const TextStyle(
                                  fontFamily: AppTypography.sansFont,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: GestureDetector(
                        onTap: () => notifier.switchTab(
                          state.isRegister || state.isForgot
                              ? AuthTab.login
                              : AuthTab.register,
                        ),
                        child: Text.rich(
                          TextSpan(
                            text: state.isRegister || state.isForgot
                                ? 'Đã có tài khoản? '
                                : 'Chưa có tài khoản? ',
                            style: const TextStyle(
                              fontFamily: AppTypography.sansFont,
                              fontSize: 12.5,
                              color: AppColors.textSecondary,
                            ),
                            children: [
                              TextSpan(
                                text: state.isRegister || state.isForgot
                                    ? 'Đăng nhập'
                                    : 'Đăng ký',
                                style: const TextStyle(
                                  fontFamily: AppTypography.sansFont,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Bottom Editorial Quote on Login Screen
                if (!state.isRegister)
                  Padding(
                    padding: const EdgeInsets.only(top: 36),
                    child: Center(
                      child: Column(
                        children: [
                          Container(
                            width: 36,
                            height: 1,
                            color: AppColors.divider,
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'Ít hơn, đúng chất bạn.',
                            style: TextStyle(
                              fontFamily: AppTypography.serifFont,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'MẶC ĐẸP MỖI NGÀY',
                            style: TextStyle(
                              fontFamily: AppTypography.sansFont,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.6,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormFields(AuthState state, AuthViewModel notifier) {
    final strings = AppLocalizations.of(context);
    if (state.isForgot) {
      return Column(
        key: const ValueKey('forgot_form'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel(strings.recoveryEmailLabel),
          _buildTextField(
            controller: _emailController,
            hint: 'Nhập địa chỉ email của bạn',
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      );
    }

    if (state.isRegister) {
      return Column(
        key: const ValueKey('register_form'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel('Họ và tên'),
          _buildTextField(
            controller: _nameController,
            hint: 'NÉORA nên gọi bạn là gì?',
          ),
          const SizedBox(height: 16),
          _buildFieldLabel('Email'),
          _buildTextField(
            controller: _emailController,
            hint: 'Nhập địa chỉ email của bạn',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _buildFieldLabel('Mật khẩu'),
          _buildTextField(
            controller: _passwordController,
            hint: 'Tạo mật khẩu của bạn',
            isPassword: true,
            isObscured: !state.isPasswordVisible,
            onToggleVisibility: notifier.togglePasswordVisibility,
          ),
          const SizedBox(height: 6),
          const Text(
            'Ít nhất 8 ký tự, gồm chữ hoa, chữ thường và số.',
            style: TextStyle(
              fontFamily: AppTypography.sansFont,
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          _buildFieldLabel('Nhập lại mật khẩu'),
          _buildTextField(
            controller: _confirmPasswordController,
            hint: 'Xác nhận mật khẩu của bạn',
            isPassword: true,
            isObscured: !state.isConfirmPasswordVisible,
            onToggleVisibility: notifier.toggleConfirmPasswordVisibility,
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: notifier.toggleAgreeToTerms,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: Checkbox(
                    value: state.agreeToTerms,
                    onChanged: (_) => notifier.toggleAgreeToTerms(),
                    activeColor: AppColors.primary,
                    checkColor: Colors.white,
                    side: const BorderSide(
                      color: AppColors.cardBorder,
                      width: 1.3,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: 'Tôi đồng ý với ',
                      style: TextStyle(
                        fontFamily: AppTypography.sansFont,
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(
                          text: 'Điều khoản sử dụng',
                          style: TextStyle(
                            fontFamily: AppTypography.sansFont,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        TextSpan(text: ' và '),
                        TextSpan(
                          text: 'Chính sách quyền riêng tư',
                          style: TextStyle(
                            fontFamily: AppTypography.sansFont,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        TextSpan(text: ' của NÉORA.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Login Form
    return Column(
      key: const ValueKey('login_form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Email'),
        _buildTextField(
          controller: _emailController,
          hint: 'Nhập địa chỉ email của bạn',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildFieldLabel('Mật khẩu'),
        _buildTextField(
          controller: _passwordController,
          hint: 'Nhập mật khẩu',
          isPassword: true,
          isObscured: !state.isPasswordVisible,
          onToggleVisibility: notifier.togglePasswordVisibility,
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () => notifier.switchTab(AuthTab.forgot),
            child: const Text(
              'Quên mật khẩu?',
              style: TextStyle(
                fontFamily: AppTypography.sansFont,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: AppTypography.sansFont,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool isPassword = false,
    bool isObscured = false,
    VoidCallback? onToggleVisibility,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && isObscured,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontFamily: AppTypography.sansFont,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          suffixIcon: isPassword
              ? TextButton(
                  onPressed: onToggleVisibility,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isObscured
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isObscured ? 'Hiện' : 'Ẩn',
                        style: const TextStyle(
                          fontFamily: AppTypography.sansFont,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : null,
          hintText: hint,
          hintStyle: const TextStyle(
            fontFamily: AppTypography.sansFont,
            fontSize: 12.5,
            color: AppColors.textMuted,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 13,
            horizontal: 14,
          ),
        ),
      ),
    );
  }
}
