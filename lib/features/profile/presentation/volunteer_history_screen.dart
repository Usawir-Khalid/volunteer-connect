import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';

class VolunteerHistoryScreen extends StatelessWidget {
  const VolunteerHistoryScreen({super.key});

  static const List<_HistoryItem> _history = [
    _HistoryItem(
      title: 'Community Clean-Up',
      organization: 'Green Earth Alliance',
      date: 'Aug 21, 2026',
      hours: '3 hours',
      category: 'Environment',
      icon: Icons.eco_outlined,
    ),
    _HistoryItem(
      title: 'Food Bank Sorting',
      organization: 'City Harvest',
      date: 'Aug 15, 2026',
      hours: '2 hours',
      category: 'Community',
      icon: Icons.volunteer_activism_outlined,
    ),
    _HistoryItem(
      title: 'Reading Program',
      organization: 'Bright Futures',
      date: 'Aug 10, 2026',
      hours: '2 hours',
      category: 'Education',
      icon: Icons.school_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Volunteer History'),
      ),
      body: _history.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(
                AppSpacing.lg,
              ),
              itemCount: _history.length,
              separatorBuilder: (_, _) {
                return const SizedBox(
                  height: AppSpacing.md,
                );
              },
              itemBuilder: (context, index) {
                return _HistoryCard(
                  item: _history[index],
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
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
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history_outlined,
                size: 34,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(
              height: AppSpacing.lg,
            ),
            Text(
              'No volunteer history yet',
              style: AppTypography.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: AppSpacing.sm,
            ),
            Text(
              'Your completed volunteer opportunities '
              'will appear here.',
              style: AppTypography.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.item,
  });

  final _HistoryItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              item.icon,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(
            width: AppSpacing.md,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTypography.textTheme.titleMedium,
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  item.organization,
                  style: AppTypography.textTheme.bodySmall,
                ),

                const SizedBox(
                  height: AppSpacing.sm,
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
                    Text(
                      item.date,
                      style:
                          AppTypography.textTheme.labelSmall,
                    ),
                    const SizedBox(
                      width: AppSpacing.sm,
                    ),
                    Text(
                      '•',
                      style:
                          AppTypography.textTheme.labelSmall,
                    ),
                    const SizedBox(
                      width: AppSpacing.sm,
                    ),
                    Text(
                      item.hours,
                      style:
                          AppTypography.textTheme.labelSmall,
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
                    item.category,
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
        ],
      ),
    );
  }
}

class _HistoryItem {
  const _HistoryItem({
    required this.title,
    required this.organization,
    required this.date,
    required this.hours,
    required this.category,
    required this.icon,
  });

  final String title;
  final String organization;
  final String date;
  final String hours;
  final String category;
  final IconData icon;
}