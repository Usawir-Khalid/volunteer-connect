import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';

class SavedOpportunitiesScreen extends StatelessWidget {
  const SavedOpportunitiesScreen({
    super.key,
  });

  static const List<_SavedOpportunity> _opportunities = [
    _SavedOpportunity(
      id: '1',
      title: 'Community Clean-Up',
      organization: 'Green Earth Alliance',
      location: 'Central Park',
      category: 'Environment',
      date: 'Sat, Aug 23',
      time: '9:00 AM',
      icon: Icons.eco_outlined,
    ),
    _SavedOpportunity(
      id: '3',
      title: 'Food Bank Sorting',
      organization: 'City Harvest',
      location: 'Community Food Center',
      category: 'Community',
      date: 'Mon, Aug 25',
      time: '2:00 PM',
      icon: Icons.volunteer_activism_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Saved Opportunities'),
      ),
      body: _opportunities.isEmpty
          ? _buildEmptyState(context)
          : ListView.separated(
              padding: const EdgeInsets.all(
                AppSpacing.lg,
              ),
              itemCount: _opportunities.length,
              separatorBuilder: (_, _) {
                return const SizedBox(
                  height: AppSpacing.md,
                );
              },
              itemBuilder: (context, index) {
                final opportunity = _opportunities[index];

                return _SavedOpportunityCard(
                  opportunity: opportunity,
                  onTap: () {
                    context.push(
                      '/opportunity/${opportunity.id}',
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bookmark_outline,
                size: 34,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(
              height: AppSpacing.lg,
            ),
            Text(
              'No saved opportunities',
              style: AppTypography.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: AppSpacing.sm,
            ),
            Text(
              'Save opportunities you are interested in '
              'and they will appear here.',
              style: AppTypography.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: AppSpacing.lg,
            ),
            ElevatedButton.icon(
              onPressed: () {
                context.go('/home');
              },
              icon: const Icon(
                Icons.explore_outlined,
              ),
              label: const Text(
                'Explore Opportunities',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedOpportunityCard extends StatelessWidget {
  const _SavedOpportunityCard({
    required this.opportunity,
    required this.onTap,
  });

  final _SavedOpportunity opportunity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          AppRadius.card,
        ),
        child: Container(
          padding: const EdgeInsets.all(
            AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(
              AppRadius.card,
            ),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(
                    16,
                  ),
                ),
                child: Icon(
                  opportunity.icon,
                  color: AppColors.primary,
                  size: 26,
                ),
              ),

              const SizedBox(
                width: AppSpacing.md,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      opportunity.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.textTheme.titleMedium,
                    ),

                    const SizedBox(
                      height: AppSpacing.xs,
                    ),

                    Text(
                      opportunity.organization,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.textTheme.bodySmall,
                    ),

                    const SizedBox(
                      height: AppSpacing.sm,
                    ),

                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 15,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Expanded(
                          child: Text(
                            opportunity.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.textTheme.labelSmall,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Expanded(
                          child: Text(
                            '${opportunity.date} • ${opportunity.time}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.textTheme.labelSmall,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: AppSpacing.sm,
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(
                          AppRadius.pill,
                        ),
                      ),
                      child: Text(
                        opportunity.category,
                        style: AppTypography
                            .textTheme
                            .labelSmall
                            ?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width: AppSpacing.sm,
              ),

              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SavedOpportunity {
  const _SavedOpportunity({
    required this.id,
    required this.title,
    required this.organization,
    required this.location,
    required this.category,
    required this.date,
    required this.time,
    required this.icon,
  });

  final String id;
  final String title;
  final String organization;
  final String location;
  final String category;
  final String date;
  final String time;
  final IconData icon;
}