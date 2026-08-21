import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Explore',
                style: AppTypography.textTheme.headlineLarge,
              ),

              const SizedBox(
                height: AppSpacing.xs,
              ),

              Text(
                'Find opportunities that match your interests.',
                style: AppTypography.textTheme.bodyMedium,
              ),

              const SizedBox(
                height: AppSpacing.lg,
              ),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.border,
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: AppColors.primary,
                    ),
                    SizedBox(
                      width: AppSpacing.sm,
                    ),
                    Expanded(
                      child: Text(
                        'San Francisco, CA',
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: AppSpacing.md,
              ),

              Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.border,
                  ),
                ),
                child: const Row(
                  children: [
                    SizedBox(
                      width: AppSpacing.md,
                    ),
                    Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(
                      width: AppSpacing.sm,
                    ),
                    Text(
                      'Search opportunities...',
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: AppSpacing.lg,
              ),

              Text(
                'Categories',
                style: AppTypography.textTheme.titleLarge,
              ),

              const SizedBox(
                height: AppSpacing.md,
              ),

              Row(
                children: [
                  _CategoryChip(
                    label: 'All',
                    selected: true,
                  ),
                  const SizedBox(
                    width: AppSpacing.sm,
                  ),
                  _CategoryChip(
                    label: 'Environment',
                  ),
                  const SizedBox(
                    width: AppSpacing.sm,
                  ),
                  _CategoryChip(
                    label: 'Education',
                  ),
                ],
              ),

              const SizedBox(
                height: AppSpacing.lg,
              ),

              Text(
                'Volunteer opportunities',
                style: AppTypography.textTheme.titleLarge,
              ),

              const SizedBox(
                height: AppSpacing.md,
              ),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(
                  AppSpacing.lg,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.border,
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.volunteer_activism_outlined,
                      size: 40,
                      color: AppColors.primary,
                    ),

                    SizedBox(
                      height: AppSpacing.md,
                    ),

                    Text(
                      'Community Clean-Up',
                    ),

                    SizedBox(
                      height: AppSpacing.xs,
                    ),

                    Text(
                      'Green Earth Alliance',
                    ),

                    SizedBox(
                      height: AppSpacing.sm,
                    ),

                    Text(
                      'Central Park • 1.2 miles away',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    this.selected = false,
  });

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.primary
            : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected
              ? AppColors.primary
              : AppColors.border,
        ),
      ),
      child: Text(
        label,
        style: AppTypography.textTheme.bodySmall?.copyWith(
          color: selected
              ? AppColors.white
              : AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}