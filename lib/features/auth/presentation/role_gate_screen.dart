import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../profile/models/profile_data.dart';

class RoleGateScreen extends StatefulWidget {
  const RoleGateScreen({
    super.key,
  });

  @override
  State<RoleGateScreen> createState() =>
      _RoleGateScreenState();
}

class _RoleGateScreenState
    extends State<RoleGateScreen> {
  final ProfileData _profile =
      ProfileData.instance;

  String? _error;

  @override
  void initState() {
    super.initState();

    _resolveRole();
  }

  Future<void> _resolveRole() async {
    try {
      await _profile.loadCurrentUser();

      if (!mounted) return;

      if (_profile.isOrganization) {
        context.go('/organization');
      } else {
        context.go('/volunteer');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error =
            'We could not load your account. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: _error == null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.eco_rounded,
                        color: AppColors.primary,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Setting things up...',
                      style: AppTypography
                          .textTheme
                          .headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Preparing your Volunteer Connect experience.',
                      textAlign: TextAlign.center,
                      style: AppTypography
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            color:
                                AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 24),
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.error,
                      size: 44,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: AppTypography
                          .textTheme
                          .bodyLarge,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _error = null;
                        });

                        _resolveRole();
                      },
                      child: const Text(
                        'Try again',
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}