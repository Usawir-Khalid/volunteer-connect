import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../profile/models/profile_data.dart';

class OrganizationDashboardScreen
    extends StatelessWidget {
  const OrganizationDashboardScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final profile = ProfileData.instance;
    final uid =
        FirebaseAuth.instance.currentUser?.uid;

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
              _Header(
                name: profile.name,
              ),
              const SizedBox(
                height: AppSpacing.xl,
              ),
              _WelcomeCard(),
              const SizedBox(
                height: AppSpacing.xl,
              ),
              Text(
                'Your organization',
                style: AppTypography
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(
                height: AppSpacing.md,
              ),
              if (uid == null)
                const _StatsRow(
                  events: 0,
                  volunteers: 0,
                )
              else
                _LiveStats(
                  uid: uid,
                ),
              const SizedBox(
                height: AppSpacing.xl,
              ),
              _ActionCard(
                icon:
                    Icons.add_circle_outline_rounded,
                title: 'Create an opportunity',
                subtitle:
                    'Post a volunteer event and start building your team.',
                onTap: () {
                  context.push(
                    '/organization/create-opportunity',
                  );
                },
              ),
              const SizedBox(height: 12),
              _ActionCard(
                icon: Icons.groups_outlined,
                title: 'Manage volunteers',
                subtitle:
                    'Review applications and build your volunteer team.',
                onTap: () {
                  context.push(
                    '/organization/manage-volunteers',
                  );
                },
              ),
              const SizedBox(height: 12),
              _ActionCard(
                icon:
                    Icons.event_note_outlined,
                title: 'My opportunities',
                subtitle:
                    'View, edit and manage your published opportunities.',
                onTap: () {
                  context.push(
                    '/organization/my-opportunities',
                  );
                },
              ),
              const SizedBox(
                height: AppSpacing.xl,
              ),
              _ImpactTip(),
              const SizedBox(
                height: AppSpacing.xl,
              ),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await FirebaseAuth
                        .instance
                        .signOut();

                    if (!context.mounted) {
                      return;
                    }

                    ProfileData.instance.clear();

                    context.go('/login');
                  },
                  icon: const Icon(
                    Icons.logout_rounded,
                  ),
                  label: const Text(
                    'Log out',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveStats extends StatelessWidget {
  const _LiveStats({
    required this.uid,
  });

  final String uid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('opportunities')
          .where(
            'organizationId',
            isEqualTo: uid,
          )
          .snapshots(),
      builder: (context, opportunitySnapshot) {
        final eventCount =
            opportunitySnapshot.data?.docs.length ??
                0;

        return StreamBuilder<
            QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('applications')
              .where(
                'organizationId',
                isEqualTo: uid,
              )
              .snapshots(),
          builder: (
            context,
            applicationSnapshot,
          ) {
            final volunteerCount =
                applicationSnapshot.data?.docs
                        .map(
                          (doc) =>
                              doc.data()['volunteerId']
                                  as String? ??
                              doc.id,
                        )
                        .toSet()
                        .length ??
                    0;

            return _StatsRow(
              events: eventCount,
              volunteers: volunteerCount,
            );
          },
        );
      },
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.events,
    required this.volunteers,
  });

  final int events;
  final int volunteers;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.event_outlined,
            value: '$events',
            label: 'Events',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.people_outline,
            value: '$volunteers',
            label: 'Volunteers',
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.name,
  });

  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Organization',
                style: AppTypography
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                  color:
                      AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name.isEmpty
                    ? 'Welcome 👋'
                    : 'Hi, $name 👋',
                style: AppTypography
                    .textTheme
                    .headlineMedium
                    ?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.business_rounded,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryLight,
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Colors.white,
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -30,
            child: Icon(
              Icons.eco_rounded,
              size: 120,
              color:
                  AppColors.primary.withValues(
                alpha: 0.07,
              ),
            ),
          ),
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.volunteer_activism_rounded,
                  color: AppColors.primary,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Make an impact together.',
                      style: AppTypography
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Create meaningful opportunities and connect with people who want to help.',
                      style: AppTypography
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                        color:
                            AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: AppTypography
                .textTheme
                .headlineMedium
                ?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: AppTypography
                .textTheme
                .bodySmall
                ?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
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
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius:
          BorderRadius.circular(
        AppRadius.card,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(
          AppRadius.card,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(
              AppRadius.card,
            ),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTypography
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                        color:
                            AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImpactTip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppColors.primaryLight,
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.eco_rounded,
            color: AppColors.primary,
            size: 27,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Every opportunity you create gives someone a chance to make a difference.',
              style: AppTypography
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}