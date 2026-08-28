import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../presentation/providers/auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() =>
      _SignupScreenState();
}

class _SignupScreenState
    extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController =
      TextEditingController();

  bool _acceptedTerms = false;
  bool _isLoading = false;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String _selectedRole = 'volunteer';

  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> _signUp() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptedTerms) {
      setState(() {
        _errorMessage =
            'Please agree to the Terms of Service and Privacy Policy.';
      });

      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authRepositoryProvider).signUp(
            fullName: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            role: _selectedRole,
          );

      if (!mounted) return;

      context.go('/home');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = _friendlyAuthError(e);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _friendlyAuthError(Object error) {
    final message = error.toString().toLowerCase();

    if (message.contains('email-already-in-use')) {
      return 'An account already exists with this email.';
    }

    if (message.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    }

    if (message.contains('weak-password')) {
      return 'Please choose a stronger password.';
    }

    if (message.contains('network-request-failed')) {
      return 'Check your internet connection and try again.';
    }

    return 'Something went wrong. Please try again.';
  }

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';

    if (name.isEmpty) {
      return 'Name is required';
    }

    if (name.length < 2) {
      return 'Please enter your full name';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Email is required';
    }

    final regex =
        RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!regex.hasMatch(email)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            const _SignupDecorations(),

            SingleChildScrollView(
              physics:
                  const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                40,
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _BackButton(
                      onPressed: () =>
                          context.go('/login'),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const _SignupHero(),

                  const SizedBox(height: 22),

                  _RoleSelector(
                    selectedRole: _selectedRole,
                    enabled: !_isLoading,
                    onChanged: (role) {
                      setState(() {
                        _selectedRole = role;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  _SignupForm(
                    formKey: _formKey,
                    nameController: _nameController,
                    emailController: _emailController,
                    passwordController:
                        _passwordController,
                    confirmPasswordController:
                        _confirmPasswordController,
                    acceptedTerms:
                        _acceptedTerms,
                    isLoading: _isLoading,
                    obscurePassword:
                        _obscurePassword,
                    obscureConfirmPassword:
                        _obscureConfirmPassword,
                    errorMessage: _errorMessage,
                    onTermsChanged: (value) {
                      setState(() {
                        _acceptedTerms = value;

                        if (value) {
                          _errorMessage = null;
                        }
                      });
                    },
                    onTogglePassword: () {
                      setState(() {
                        _obscurePassword =
                            !_obscurePassword;
                      });
                    },
                    onToggleConfirmPassword: () {
                      setState(() {
                        _obscureConfirmPassword =
                            !_obscureConfirmPassword;
                      });
                    },
                    onCreateAccount: _signUp,
                    onSignIn: () =>
                        context.go('/login'),
                    validateName: _validateName,
                    validateEmail: _validateEmail,
                    validatePassword:
                        _validatePassword,
                    validateConfirmPassword:
                        _validateConfirmPassword,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// BACKGROUND DECORATIONS
// ============================================================================

class _SignupDecorations
    extends StatelessWidget {
  const _SignupDecorations();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -60,
            right: -45,
            child: Container(
              width: 175,
              height: 175,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryLight
                    .withValues(alpha: 0.5),
              ),
            ),
          ),
          Positioned(
            top: 360,
            left: -75,
            child: Container(
              width: 145,
              height: 145,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryLight
                    .withValues(alpha: 0.25),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryLight
                    .withValues(alpha: 0.28),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// BACK BUTTON
// ============================================================================

class _BackButton extends StatelessWidget {
  const _BackButton({
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.78),
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(17),
            border: Border.all(
              color:
                  Colors.white.withValues(alpha: 0.9),
            ),
            boxShadow: [
              BoxShadow(
                color:
                    Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// HERO
// ============================================================================

class _SignupHero extends StatelessWidget {
  const _SignupHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 215,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryLight
                .withValues(alpha: 0.95),
            Colors.white.withValues(alpha: 0.92),
          ],
        ),
        border: Border.all(
          color:
              Colors.white.withValues(alpha: 0.9),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color:
                AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 20,
            right: 20,
            child: _GlassIcon(
              icon: Icons.eco_rounded,
            ),
          ),

          Positioned(
            top: 35,
            left: 26,
            child: Text(
              'BE PART OF\nSOMETHING GOOD.',
              style: AppTypography
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                    color:
                        AppColors.textPrimary,
                    fontWeight:
                        FontWeight.w800,
                    height: 1.02,
                    letterSpacing: -0.5,
                  ),
            ),
          ),

          Positioned(
            top: 112,
            left: 27,
            child: Text(
              'Turn your time into impact.',
              style: AppTypography
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                    color:
                        AppColors.textSecondary,
                    fontWeight:
                        FontWeight.w500,
                  ),
            ),
          ),

          Positioned(
            bottom: 22,
            right: 23,
            child: _CausePills(),
          ),

          const Positioned(
            bottom: 12,
            left: 22,
            child: _LeafDecoration(),
          ),
        ],
      ),
    );
  }
}

class _GlassIcon extends StatelessWidget {
  const _GlassIcon({
    required this.icon,
  });

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 9,
          sigmaY: 9,
        ),
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color:
                Colors.white.withValues(alpha: 0.55),
            shape: BoxShape.circle,
            border: Border.all(
              color:
                  Colors.white.withValues(alpha: 0.85),
            ),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 28,
          ),
        ),
      ),
    );
  }
}

class _CausePills extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CausePill(
          icon: Icons.eco_rounded,
          label: 'Nature',
        ),
        const SizedBox(width: 6),
        _CausePill(
          icon: Icons.favorite_rounded,
          label: 'Care',
        ),
        const SizedBox(width: 6),
        _CausePill(
          icon: Icons.school_rounded,
          label: 'Learn',
        ),
      ],
    );
  }
}

class _CausePill extends StatelessWidget {
  const _CausePill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 8,
          sigmaY: 8,
        ),
        child: Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color:
                Colors.white.withValues(alpha: 0.55),
            borderRadius:
                BorderRadius.circular(15),
            border: Border.all(
              color:
                  Colors.white.withValues(alpha: 0.8),
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _LeafDecoration
    extends StatelessWidget {
  const _LeafDecoration();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Transform.rotate(
          angle: -0.55,
          child: const Icon(
            Icons.eco_rounded,
            color: AppColors.primary,
            size: 46,
          ),
        ),
        Transform.rotate(
          angle: 0.45,
          child: const Icon(
            Icons.eco_rounded,
            color: AppColors.primaryLight,
            size: 57,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// ROLE SELECTOR
// ============================================================================

class _RoleSelector extends StatelessWidget {
  const _RoleSelector({
    required this.selectedRole,
    required this.onChanged,
    required this.enabled,
  });

  final String selectedRole;
  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          'I want to join as',
          style: AppTypography
              .textTheme
              .labelLarge
              ?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _RoleCard(
                role: 'volunteer',
                icon:
                    Icons.volunteer_activism_outlined,
                title: 'Volunteer',
                subtitle:
                    'Find opportunities',
                selected:
                    selectedRole == 'volunteer',
                enabled: enabled,
                onTap: () =>
                    onChanged('volunteer'),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _RoleCard(
                role: 'organization',
                icon:
                    Icons.business_outlined,
                title: 'Organization',
                subtitle:
                    'Create opportunities',
                selected:
                    selectedRole == 'organization',
                enabled: enabled,
                onTap: () =>
                    onChanged('organization'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.role,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String role;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryLight
              : Colors.white.withValues(
                  alpha: 0.78,
                ),
          borderRadius:
              BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary
                        .withValues(alpha: 0.10),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration:
                  const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: selected
                    ? AppColors.primary
                    : AppColors.textSecondary,
                size: 21,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              title,
              style: AppTypography
                  .textTheme
                  .titleSmall
                  ?.copyWith(
                    color:
                        AppColors.textPrimary,
                    fontWeight:
                        FontWeight.w800,
                  ),
            ),

            const SizedBox(height: 2),

            Text(
              subtitle,
              style: AppTypography
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                    color:
                        AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// FORM
// ============================================================================

class _SignupForm extends StatelessWidget {
  const _SignupForm({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.acceptedTerms,
    required this.isLoading,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.errorMessage,
    required this.onTermsChanged,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    required this.onCreateAccount,
    required this.onSignIn,
    required this.validateName,
    required this.validateEmail,
    required this.validatePassword,
    required this.validateConfirmPassword,
  });

  final GlobalKey<FormState> formKey;

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController
      confirmPasswordController;

  final bool acceptedTerms;
  final bool isLoading;

  final bool obscurePassword;
  final bool obscureConfirmPassword;

  final String? errorMessage;

  final ValueChanged<bool> onTermsChanged;

  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;

  final VoidCallback onCreateAccount;
  final VoidCallback onSignIn;

  final String? Function(String?) validateName;
  final String? Function(String?) validateEmail;
  final String? Function(String?) validatePassword;
  final String? Function(String?)
      validateConfirmPassword;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        20,
        22,
        20,
        20,
      ),
      decoration: BoxDecoration(
        color:
            Colors.white.withValues(alpha: 0.84),
        borderRadius:
            BorderRadius.circular(28),
        border: Border.all(
          color:
              Colors.white.withValues(alpha: 0.9),
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(alpha: 0.035),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              'Create your account',
              style: AppTypography
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    color:
                        AppColors.textPrimary,
                    fontWeight:
                        FontWeight.w800,
                  ),
            ),

            const SizedBox(height: 4),

            Text(
              'A few details and you’re ready to start.',
              style: AppTypography
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                    color:
                        AppColors.textSecondary,
                  ),
            ),

            const SizedBox(height: 21),

            const _FieldLabel(
              label: 'Full name',
            ),

            const SizedBox(height: 7),

            _AuthField(
              controller: nameController,
              hint: 'Your name',
              icon:
                  Icons.person_outline_rounded,
              validator: validateName,
              enabled: !isLoading,
            ),

            const SizedBox(height: 15),

            const _FieldLabel(
              label: 'Email address',
            ),

            const SizedBox(height: 7),

            _AuthField(
              controller: emailController,
              hint: 'you@example.com',
              icon:
                  Icons.mail_outline_rounded,
              keyboardType:
                  TextInputType.emailAddress,
              validator: validateEmail,
              enabled: !isLoading,
            ),

            const SizedBox(height: 15),

            const _FieldLabel(
              label: 'Password',
            ),

            const SizedBox(height: 7),

            _AuthField(
              controller: passwordController,
              hint: 'At least 6 characters',
              icon:
                  Icons.lock_outline_rounded,
              obscureText: obscurePassword,
              validator: validatePassword,
              enabled: !isLoading,
              suffixIcon: IconButton(
                onPressed: isLoading
                    ? null
                    : onTogglePassword,
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),

            const SizedBox(height: 15),

            const _FieldLabel(
              label: 'Confirm password',
            ),

            const SizedBox(height: 7),

            _AuthField(
              controller:
                  confirmPasswordController,
              hint: 'Re-enter your password',
              icon:
                  Icons.lock_reset_outlined,
              obscureText:
                  obscureConfirmPassword,
              validator:
                  validateConfirmPassword,
              enabled: !isLoading,
              suffixIcon: IconButton(
                onPressed: isLoading
                    ? null
                    : onToggleConfirmPassword,
                icon: Icon(
                  obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),

            const SizedBox(height: 16),

            GestureDetector(
              onTap: isLoading
                  ? null
                  : () => onTermsChanged(
                        !acceptedTerms,
                      ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration:
                        const Duration(
                      milliseconds: 180,
                    ),
                    width: 24,
                    height: 24,
                    decoration:
                        BoxDecoration(
                      color: acceptedTerms
                          ? AppColors.primary
                          : Colors.white,
                      borderRadius:
                          BorderRadius.circular(7),
                      border: Border.all(
                        color: acceptedTerms
                            ? AppColors.primary
                            : AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: acceptedTerms
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 17,
                          )
                        : null,
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      'I agree to the Terms of Service and Privacy Policy.',
                      style: AppTypography
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                            color:
                                AppColors.textSecondary,
                            height: 1.3,
                          ),
                    ),
                  ),
                ],
              ),
            ),

            if (errorMessage != null) ...[
              const SizedBox(height: 14),
              _ErrorMessage(
                message: errorMessage!,
              ),
            ],

            const SizedBox(height: 19),

            SizedBox(
              width: double.infinity,
              height: 57,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : onCreateAccount,
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.primary,
                  foregroundColor:
                      Colors.white,
                  elevation: 0,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(18),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Text(
                            'Create Account',
                            style: AppTypography
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color:
                                      Colors.white,
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                          ),
                          const SizedBox(
                            width: 9,
                          ),
                          const Icon(
                            Icons
                                .arrow_forward_rounded,
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 17),

            Center(
              child: Wrap(
                children: [
                  Text(
                    'Already have an account? ',
                    style: AppTypography
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                          color:
                              AppColors.textSecondary,
                        ),
                  ),
                  GestureDetector(
                    onTap: isLoading
                        ? null
                        : onSignIn,
                    child: Text(
                      'Sign in',
                      style: AppTypography
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            color:
                                AppColors.primary,
                            fontWeight:
                                FontWeight.w800,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// SHARED FIELD
// ============================================================================

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTypography
          .textTheme
          .labelLarge
          ?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.enabled,
    this.keyboardType,
    this.validator,
    this.obscureText = false,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool enabled;

  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;

  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
      obscureText: obscureText,
      style: AppTypography
          .textTheme
          .bodyLarge
          ?.copyWith(
            color: AppColors.textPrimary,
          ),
      decoration: InputDecoration(
        hintText: hint,

        prefixIcon: Icon(
          icon,
          color: AppColors.textSecondary,
          size: 22,
        ),

        suffixIcon: suffixIcon,

        filled: true,

        fillColor:
            Colors.white.withValues(alpha: 0.92),

        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(17),
          borderSide:
              const BorderSide(
            color: AppColors.border,
          ),
        ),

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(17),
          borderSide:
              const BorderSide(
            color: AppColors.border,
          ),
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(17),
          borderSide:
              const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// ERROR
// ============================================================================

class _ErrorMessage
    extends StatelessWidget {
  const _ErrorMessage({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            AppColors.error.withValues(alpha: 0.08),
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 19,
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              message,
              style: AppTypography
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                    color: AppColors.error,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}