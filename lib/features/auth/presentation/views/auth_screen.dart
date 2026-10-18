import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
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
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
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
          // Drag handle
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: const SafeArea(child: AuthContent(isBottomSheet: false)),
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
  final _emailController = TextEditingController(text: 'demo@neora.vn');
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  double _tiltX = 0.0;
  double _tiltY = 0.0;
  bool _isInteracting = false;

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
  ) => switch (code) {
    AuthSuccessCode.resetLinkSent => strings.authResetLinkSent(email),
    AuthSuccessCode.registrationComplete => strings.authRegistrationComplete,
  };

  void _onPointerMove(PointerMoveEvent event, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final deltaX = (event.localPosition.dx - centerX) / centerX;
    final deltaY = (event.localPosition.dy - centerY) / centerY;

    setState(() {
      _tiltX = (-deltaY * 0.05).clamp(-0.06, 0.06);
      _tiltY = (deltaX * 0.05).clamp(-0.06, 0.06);
      _isInteracting = true;
    });
  }

  void _onPointerLeave() {
    setState(() {
      _tiltX = 0.0;
      _tiltY = 0.0;
      _isInteracting = false;
    });
  }

  void _onHover(PointerEvent event, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final deltaX = (event.localPosition.dx - centerX) / centerX;
    final deltaY = (event.localPosition.dy - centerY) / centerY;

    setState(() {
      _tiltX = (-deltaY * 0.06).clamp(-0.07, 0.07);
      _tiltY = (deltaX * 0.06).clamp(-0.07, 0.07);
      _isInteracting = true;
    });
  }

  Future<void> _handleAuthSubmit() async {
    final strings = AppLocalizations.of(context);
    final notifier = ref.read(authViewModelProvider.notifier);
    final state = ref.read(authViewModelProvider);

    notifier.updateEmail(_emailController.text);
    notifier.updatePassword(_passwordController.text);
    notifier.updateFullName(_nameController.text);
    notifier.updateConfirmPassword(_confirmPasswordController.text);

    final success = await notifier.submit();
    if (!mounted) return;

    if (success && state.currentTab == AuthTab.login) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.brandBlack,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
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
                  strings.authLoginSuccess,
                  style: const TextStyle(
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

      if (widget.isBottomSheet) {
        Navigator.pop(context);
      }
      Navigator.pushReplacementNamed(context, AppRoutes.main, arguments: 0);
    }
  }

  void _continueAsGuest() {
    if (widget.isBottomSheet) {
      Navigator.pop(context);
    }
    Navigator.pushReplacementNamed(context, AppRoutes.main, arguments: 0);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final authState = ref.watch(authViewModelProvider);
    final authNotifier = ref.read(authViewModelProvider.notifier);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Top Navigation Row
          if (!widget.isBottomSheet)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.maybePop(context),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                // Brand Name
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      strings.appTitle,
                      style: const TextStyle(
                        fontFamily: AppTypography.serifFont,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.2,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: _continueAsGuest,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.softPeach,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      strings.guestAction,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBurgundy,
                      ),
                    ),
                  ),
                ),
              ],
            ),

          const SizedBox(height: 18),

          // 3D tilting NÉORA card
          LayoutBuilder(
            builder: (context, constraints) {
              final cardSize = Size(constraints.maxWidth, 500);

              return MouseRegion(
                onHover: (e) => _onHover(e, cardSize),
                onExit: (_) => _onPointerLeave(),
                child: Listener(
                  onPointerMove: (e) => _onPointerMove(e, cardSize),
                  onPointerUp: (_) => _onPointerLeave(),
                  onPointerCancel: (_) => _onPointerLeave(),
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    tween: Tween<double>(begin: 0.0, end: _tiltX),
                    builder: (context, tX, child) {
                      return TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutCubic,
                        tween: Tween<double>(begin: 0.0, end: _tiltY),
                        builder: (context, tY, innerChild) {
                          return Transform(
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.0012)
                              ..rotateX(tX)
                              ..rotateY(tY),
                            alignment: Alignment.center,
                            child: innerChild,
                          );
                        },
                        child: child,
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: AppColors.cardBorder,
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF14120E,
                            ).withValues(alpha: _isInteracting ? 0.12 : 0.06),
                            blurRadius: _isInteracting ? 32 : 20,
                            offset: Offset(0, _isInteracting ? 16 : 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Top Logo Badge & Monogram
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.18,
                                  ),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'L',
                                style: TextStyle(
                                  fontFamily: AppTypography.serifFont,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.brandBlack,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Animated Headline based on Mode
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: Text(
                              authState.isForgot
                                  ? strings.forgotPasswordTitle
                                  : authState.isRegister
                                  ? strings.createAccountTitle
                                  : strings.welcomeBackTitle,
                              key: ValueKey(authState.currentTab),
                              style: const TextStyle(
                                fontFamily: AppTypography.serifFont,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                                color: AppColors.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          const SizedBox(height: 6),

                          // Subtitle
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: Text(
                              authState.isForgot
                                  ? strings.forgotPasswordSubtitle
                                  : authState.isRegister
                                  ? strings.registerSubtitle
                                  : strings.loginSubtitle,
                              key: ValueKey('${authState.currentTab}_sub'),
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: AppColors.textSecondary,
                                height: 1.45,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Sliding Segmented Tab Bar (Hidden in forgot mode)
                          if (!authState.isForgot)
                            _buildSlidingTabBar(authState, authNotifier),

                          const SizedBox(height: 18),

                          // Error Banner
                          if (authState.errorCode != null)
                            Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.saleRed.withValues(
                                  alpha: 0.08,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.saleRed.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    size: 18,
                                    color: AppColors.saleRed,
                                  ),
                                  const SizedBox(width: 9),
                                  Expanded(
                                    child: Text(
                                      _errorMessage(
                                        strings,
                                        authState.errorCode!,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.saleRed,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Success Banner
                          if (authState.successCode != null)
                            Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.liveGreen.withValues(
                                  alpha: 0.08,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.liveGreen.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle_outline_rounded,
                                    size: 18,
                                    color: AppColors.liveGreen,
                                  ),
                                  const SizedBox(width: 9),
                                  Expanded(
                                    child: Text(
                                      _successMessage(
                                        strings,
                                        authState.successCode!,
                                        authState.email,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.liveGreen,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Form Fields with 3D Flip/Transition
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 320),
                            transitionBuilder: (child, animation) {
                              final rotate =
                                  Tween<double>(
                                    begin: math.pi / 2,
                                    end: 0.0,
                                  ).animate(
                                    CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOutCubic,
                                    ),
                                  );
                              return AnimatedBuilder(
                                animation: rotate,
                                child: child,
                                builder: (context, child) {
                                  return Transform(
                                    transform: Matrix4.identity()
                                      ..setEntry(3, 2, 0.001)
                                      ..rotateY(rotate.value),
                                    alignment: Alignment.center,
                                    child: child,
                                  );
                                },
                              );
                            },
                            child: _buildFormFields(authState, authNotifier),
                          ),

                          const SizedBox(height: 20),

                          // Primary NÉORA editorial action
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: authState.isLoading
                                  ? null
                                  : _handleAuthSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.brandBlack,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: AppColors.brandBlack
                                    .withValues(alpha: 0.6),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: authState.isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: AppColors.primary,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          authState.isForgot
                                              ? strings.sendResetLinkAction
                                              : authState.isRegister
                                              ? strings.createAccountAction
                                              : strings.loginAction,
                                          style: const TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 1.0,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 16,
                                          color: AppColors.primary,
                                        ),
                                      ],
                                    ),
                            ),
                          ),

                          // Switch link for Forgot mode
                          if (authState.isForgot) ...[
                            const SizedBox(height: 14),
                            TextButton(
                              onPressed: () =>
                                  authNotifier.switchTab(AuthTab.login),
                              child: Text(
                                strings.backToLoginAction,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryBurgundy,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Social Login Divider
          Row(
            children: [
              Expanded(
                child: Divider(color: AppColors.cardBorder, thickness: 1),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  strings.continueWithLabel,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              Expanded(
                child: Divider(color: AppColors.cardBorder, thickness: 1),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Social Buttons Row
          Row(
            children: [
              Expanded(
                child: _buildSocialCard(
                  iconWidget: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.softPeach,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'G',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryBurgundy,
                        ),
                      ),
                    ),
                  ),
                  label: 'Google',
                  onTap: _handleAuthSubmit,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSocialCard(
                  iconWidget: const Icon(
                    Icons.apple_rounded,
                    size: 22,
                    color: AppColors.textPrimary,
                  ),
                  label: 'Apple ID',
                  onTap: _handleAuthSubmit,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Three NÉORA customer benefits
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.softPeach.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _PerkItem(icon: '🚚', text: strings.fastDeliveryPerk),
                _PerkItem(icon: '🔄', text: strings.returnsPerk),
                _PerkItem(icon: '👑', text: strings.vipPointsPerk),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Guest Continue Link
          TextButton(
            onPressed: _continueAsGuest,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  strings.continueAsGuestAction,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildSlidingTabBar(AuthState state, AuthViewModel notifier) {
    final strings = AppLocalizations.of(context);
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Stack(
        children: [
          // Sliding Indicator
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            alignment: state.isLogin
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF14120E).withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Tab Buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => notifier.switchTab(AuthTab.login),
                  child: Center(
                    child: Text(
                      strings.loginAction,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: state.isLogin
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => notifier.switchTab(AuthTab.register),
                  child: Center(
                    child: Text(
                      strings.registerTab,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: state.isRegister
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
            hint: 'email@example.com',
            icon: Icons.alternate_email_rounded,
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
          _buildFieldLabel(strings.fullNameLabel),
          _buildTextField(
            controller: _nameController,
            hint: strings.fullNameHint,
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 12),
          _buildFieldLabel(strings.emailAddressLabel),
          _buildTextField(
            controller: _emailController,
            hint: 'email@example.com',
            icon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          _buildFieldLabel(strings.newPasswordLabel),
          _buildTextField(
            controller: _passwordController,
            hint: '••••••••',
            icon: Icons.lock_outline_rounded,
            isPassword: true,
            isObscured: !state.isPasswordVisible,
            onToggleVisibility: notifier.togglePasswordVisibility,
          ),
          const SizedBox(height: 12),
          _buildFieldLabel(strings.confirmPasswordLabel),
          _buildTextField(
            controller: _confirmPasswordController,
            hint: '••••••••',
            icon: Icons.shield_outlined,
            isPassword: true,
            isObscured: !state.isConfirmPasswordVisible,
            onToggleVisibility: notifier.toggleConfirmPasswordVisibility,
          ),
          const SizedBox(height: 14),
          // Terms & Agreement checkbox
          GestureDetector(
            onTap: notifier.toggleAgreeToTerms,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                    value: state.agreeToTerms,
                    onChanged: (_) => notifier.toggleAgreeToTerms(),
                    activeColor: AppColors.primary,
                    checkColor: AppColors.brandBlack,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: strings.termsPrefix,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(
                          text: strings.serviceTermsLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        TextSpan(text: strings.termsConjunction),
                        TextSpan(
                          text: strings.privacyPolicyLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        TextSpan(text: strings.termsSuffix),
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
        _buildFieldLabel(strings.accountOrEmailLabel),
        _buildTextField(
          controller: _emailController,
          hint: 'demo@neora.vn',
          icon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        _buildFieldLabel(strings.passwordLabel),
        _buildTextField(
          controller: _passwordController,
          hint: '••••••••',
          icon: Icons.lock_outline_rounded,
          isPassword: true,
          isObscured: !state.isPasswordVisible,
          onToggleVisibility: notifier.togglePasswordVisibility,
        ),
        const SizedBox(height: 12),
        // Remember Me & Forgot Password Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: notifier.toggleRememberMe,
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: state.rememberMe,
                      onChanged: (_) => notifier.toggleRememberMe(),
                      activeColor: AppColors.primary,
                      checkColor: AppColors.brandBlack,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    strings.rememberLoginLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => notifier.switchTab(AuthTab.forgot),
              child: Text(
                strings.forgotPasswordAction,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryBurgundy,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 2),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isObscured = false,
    VoidCallback? onToggleVisibility,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && isObscured,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 19, color: AppColors.textMuted),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isObscured
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 19,
                    color: AppColors.textMuted,
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialCard({
    required Widget iconWidget,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PerkItem extends StatelessWidget {
  final String icon;
  final String text;

  const _PerkItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 13)),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryBurgundy,
          ),
        ),
      ],
    );
  }
}
