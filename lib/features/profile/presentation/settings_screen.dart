import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState
    extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _applicationUpdates = true;
  bool _opportunityReminders = true;

  Future<void> _sendPasswordReset() async {
    final email =
        FirebaseAuth.instance.currentUser?.email;

    if (email == null || email.isEmpty) {
      _showMessage(
        'No email address is associated with this account.',
      );
      return;
    }

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(
        email: email,
      );

      if (!mounted) return;

      _showMessage(
        'Password reset email sent to $email.',
      );
    } on FirebaseAuthException {
      if (!mounted) return;

      _showMessage(
        'Unable to send password reset email.',
      );
    }
  }

  void _showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.background,
      appBar: AppBar(
        title:
            const Text('Settings'),
      ),
      body: ListView(
        padding:
            const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: [
          Text(
            'Notifications',
            style: AppTypography
                .textTheme
                .titleLarge
                ?.copyWith(
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          _SettingsCard(
            children: [
              SwitchListTile.adaptive(
                contentPadding:
                    EdgeInsets.zero,
                title:
                    const Text(
                  'Notifications',
                ),
                subtitle:
                    const Text(
                  'Receive important updates from Volunteer Connect.',
                ),
                value:
                    _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled =
                        value;
                  });
                },
              ),

              const Divider(),

              SwitchListTile.adaptive(
                contentPadding:
                    EdgeInsets.zero,
                title:
                    const Text(
                  'Application Updates',
                ),
                subtitle:
                    const Text(
                  'Get notified when your application status changes.',
                ),
                value:
                    _applicationUpdates,
                onChanged:
                    _notificationsEnabled
                        ? (value) {
                            setState(() {
                              _applicationUpdates =
                                  value;
                            });
                          }
                        : null,
              ),

              const Divider(),

              SwitchListTile.adaptive(
                contentPadding:
                    EdgeInsets.zero,
                title:
                    const Text(
                  'Opportunity Reminders',
                ),
                subtitle:
                    const Text(
                  'Receive reminders about upcoming volunteer opportunities.',
                ),
                value:
                    _opportunityReminders,
                onChanged:
                    _notificationsEnabled
                        ? (value) {
                            setState(() {
                              _opportunityReminders =
                                  value;
                            });
                          }
                        : null,
              ),
            ],
          ),

          const SizedBox(
            height: AppSpacing.xl,
          ),

          Text(
            'Account',
            style: AppTypography
                .textTheme
                .titleLarge
                ?.copyWith(
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          _SettingsCard(
            children: [
              ListTile(
                contentPadding:
                    EdgeInsets.zero,
                leading:
                    const Icon(
                  Icons
                      .lock_outline_rounded,
                  color:
                      AppColors.primary,
                ),
                title:
                    const Text(
                  'Change Password',
                ),
                subtitle:
                    const Text(
                  'Send a password reset email.',
                ),
                trailing:
                    const Icon(
                  Icons.chevron_right,
                ),
                onTap:
                    _sendPasswordReset,
              ),
            ],
          ),

          const SizedBox(
            height: AppSpacing.xl,
          ),

          Text(
            'About',
            style: AppTypography
                .textTheme
                .titleLarge
                ?.copyWith(
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          _SettingsCard(
            children: [
              ListTile(
                contentPadding:
                    EdgeInsets.zero,
                leading:
                    const Icon(
                  Icons.info_outline,
                  color:
                      AppColors.primary,
                ),
                title:
                    const Text(
                  'About Volunteer Connect',
                ),
                subtitle:
                    const Text(
                  'Volunteer Connect helps you discover and participate in meaningful community opportunities.',
                ),
              ),

              const Divider(),

              ListTile(
                contentPadding:
                    EdgeInsets.zero,
                leading:
                    const Icon(
                  Icons.verified_outlined,
                  color:
                      AppColors.primary,
                ),
                title:
                    const Text(
                  'Version',
                ),
                subtitle:
                    const Text(
                  '1.0.0',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsCard
    extends StatelessWidget {
  const _SettingsCard({
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration:
          BoxDecoration(
        color:
            AppColors.surface,
        borderRadius:
            BorderRadius.circular(
          AppRadius.card,
        ),
        border:
            Border.all(
          color:
              AppColors.border,
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}