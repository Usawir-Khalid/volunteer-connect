import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../models/profile_data.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {
  final ProfileData _profile = ProfileData.instance;

  @override
  void initState() {
    super.initState();
    _profile.addListener(_onProfileChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _profile.refreshAuthenticatedEmail();
  }

  @override
  void dispose() {
    _profile.removeListener(_onProfileChanged);
    super.dispose();
  }

  void _onProfileChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _buildHeader(),

              const SizedBox(
                height: AppSpacing.lg,
              ),

              _buildProfileCard(context),

              const SizedBox(
                height: AppSpacing.xl,
              ),

              _buildSectionTitle(
                'Your Impact',
              ),

              const SizedBox(
                height: AppSpacing.md,
              ),

              _buildImpactCard(),

              const SizedBox(
                height: AppSpacing.xl,
              ),

              _buildSectionTitle(
                'Your Interests',
              ),

              const SizedBox(
                height: AppSpacing.md,
              ),

              _buildInterestsCard(),

              const SizedBox(
                height: AppSpacing.xl,
              ),

              _buildSectionTitle(
                'Account',
              ),

              const SizedBox(
                height: AppSpacing.md,
              ),

              _buildAccountCard(context),

              const SizedBox(
                height: AppSpacing.xl,
              ),

              _buildLogoutButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      'Profile',
      style: AppTypography
          .textTheme
          .headlineLarge,
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(
          AppRadius.card,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(
                  alpha: 0.15,
                ),
                width: 3,
              ),
            ),
            child: const Icon(
              Icons.person_outline,
              size: 42,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          Text(
            _profile.name,
            textAlign: TextAlign.center,
            style: AppTypography
                .textTheme
                .headlineSmall,
          ),

          const SizedBox(
            height: AppSpacing.xs,
          ),

          Text(
            _profile.email,
            textAlign: TextAlign.center,
            style: AppTypography
                .textTheme
                .bodyMedium,
          ),

          if (_profile.location.isNotEmpty) ...[
            const SizedBox(
              height: AppSpacing.xs,
            ),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color:
                      AppColors.textSecondary,
                ),

                const SizedBox(
                  width: 4,
                ),

                Text(
                  _profile.location,
                  style: AppTypography
                      .textTheme
                      .bodySmall,
                ),
              ],
            ),
          ],

          const SizedBox(
            height: AppSpacing.lg,
          ),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                context.push(
                  '/profile/edit',
                );
              },
              icon: const Icon(
                Icons.edit_outlined,
                size: 18,
              ),
              label: const Text(
                'Edit Profile',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    String title,
  ) {
    return Text(
      title,
      style: AppTypography
          .textTheme
          .titleLarge,
    );
  }

  Widget _buildImpactCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryLight
            .withValues(
          alpha: 0.55,
        ),
        borderRadius:
            BorderRadius.circular(
          AppRadius.card,
        ),
        border: Border.all(
          color: AppColors.primary.withValues(
            alpha: 0.12,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ImpactStat(
              value: '12',
              label: 'Opportunities',
              icon: Icons
                  .volunteer_activism_outlined,
            ),
          ),

          _buildDivider(),

          Expanded(
            child: _ImpactStat(
              value: '48',
              label: 'Hours',
              icon:
                  Icons.schedule_outlined,
            ),
          ),

          _buildDivider(),

          Expanded(
            child: _ImpactStat(
              value: '8',
              label: 'Events',
              icon:
                  Icons.event_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 62,
      color: AppColors.border,
    );
  }

  Widget _buildInterestsCard() {
    final interests =
        _profile.interests.toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(
          AppRadius.card,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: interests.isEmpty
          ? Text(
              'No interests selected yet.',
              style: AppTypography
                  .textTheme
                  .bodyMedium,
            )
          : Wrap(
              spacing: AppSpacing.sm,
              runSpacing:
                  AppSpacing.sm,
              children:
                  interests.map(
                (interest) {
                  return Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal:
                          AppSpacing.md,
                      vertical:
                          AppSpacing.sm,
                    ),
                    decoration:
                        BoxDecoration(
                      color: AppColors
                          .primaryLight,
                      borderRadius:
                          BorderRadius
                              .circular(
                        AppRadius.pill,
                      ),
                    ),
                    child: Text(
                      interest,
                      style: AppTypography
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                        color: AppColors
                            .primary,
                        fontWeight:
                            FontWeight
                                .w600,
                      ),
                    ),
                  );
                },
              ).toList(),
            ),
    );
  }

  Widget _buildAccountCard(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(
          AppRadius.card,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          _ProfileMenuItem(
            icon: Icons
                .bookmark_outline,
            title:
                'Saved Opportunities',
            subtitle:
                'Opportunities you want to revisit',
            onTap: () {
              context.push(
                '/profile/saved',
              );
            },
          ),

          const Divider(
            height: 1,
            indent: 60,
          ),

          _ProfileMenuItem(
            icon:
                Icons.history_outlined,
            title:
                'Volunteer History',
            subtitle:
                'View your past volunteer activity',
            onTap: () {
              context.push(
                '/profile/history',
              );
            },
          ),

          const Divider(
            height: 1,
            indent: 60,
          ),

          _ProfileMenuItem(
            icon:
                Icons.settings_outlined,
            title: 'Settings',
            subtitle:
                'Manage your app preferences',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(
    BuildContext context,
  ) {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () {
          _showLogoutDialog(context);
        },
        icon: const Icon(
          Icons.logout,
          color: AppColors.error,
        ),
        label: const Text(
          'Log Out',
          style: TextStyle(
            color: AppColors.error,
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(
    BuildContext context,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Log Out?',
          ),
          content: const Text(
            'Are you sure you want to log out of '
            'Volunteer Connect?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),

            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child: const Text(
                'Log Out',
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ImpactStat
    extends StatelessWidget {
  const _ImpactStat({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          size: 22,
          color: AppColors.primary,
        ),

        const SizedBox(
          height: AppSpacing.xs,
        ),

        Text(
          value,
          style: AppTypography
              .textTheme
              .headlineSmall
              ?.copyWith(
            color:
                AppColors.textPrimary,
            fontWeight:
                FontWeight.w700,
          ),
        ),

        const SizedBox(
          height: 2,
        ),

        Text(
          label,
          textAlign:
              TextAlign.center,
          maxLines: 2,
          overflow:
              TextOverflow.ellipsis,
          style: AppTypography
              .textTheme
              .labelSmall,
        ),
      ],
    );
  }
}

class _ProfileMenuItem
    extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(
    BuildContext context,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(
        AppRadius.card,
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(
          AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration:
                  BoxDecoration(
                color:
                    AppColors.primaryLight,
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),
              child: Icon(
                icon,
                color:
                    AppColors.primary,
                size: 21,
              ),
            ),

            const SizedBox(
              width: AppSpacing.md,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    title,
                    style: AppTypography
                        .textTheme
                        .titleMedium,
                  ),

                  const SizedBox(
                    height: 2,
                  ),

                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow:
                        TextOverflow
                            .ellipsis,
                    style: AppTypography
                        .textTheme
                        .bodySmall,
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right,
              color:
                  AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}