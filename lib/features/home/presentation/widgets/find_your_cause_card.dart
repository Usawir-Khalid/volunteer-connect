import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';

class FindYourCauseCard extends StatelessWidget {
  const FindYourCauseCard({
    super.key,
    required this.onExplore,
  });

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.large),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryLight,
            AppColors.surface,
          ],
        ),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.14),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Decorative translucent circles.
          Positioned(
            top: -45,
            right: -30,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.40),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            bottom: -55,
            left: -35,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Floating cause bubbles.
          Positioned(
            top: 28,
            right: 24,
            child: _CauseBubble(
              icon: Icons.favorite_outline_rounded,
              size: 48,
            ),
          ),

          Positioned(
            top: 88,
            right: 82,
            child: _CauseBubble(
              icon: Icons.school_outlined,
              size: 42,
            ),
          ),

          Positioned(
            top: 38,
            right: 88,
            child: _CauseBubble(
              icon: Icons.pets_outlined,
              size: 38,
            ),
          ),

          Positioned(
            top: 102,
            right: 25,
            child: _CauseBubble(
              icon: Icons.laptop_mac_outlined,
              size: 40,
            ),
          ),

          Positioned(
            bottom: 30,
            right: 58,
            child: _CauseBubble(
              icon: Icons.groups_outlined,
              size: 36,
            ),
          ),

          // Main content.
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: SizedBox(
              width: 210,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.input),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 8,
                        sigmaY: 8,
                      ),
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.70),
                          borderRadius: BorderRadius.circular(
                            AppRadius.input,
                          ),
                          border: Border.all(
                            color: AppColors.surface.withValues(alpha: 0.75),
                          ),
                        ),
                        child: const Icon(
                          Icons.explore_outlined,
                          color: AppColors.primary,
                          size: 23,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  Text(
                    'Find Your Cause',
                    style: AppTypography.textTheme.headlineMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  Text(
                    'Discover opportunities that match what matters to you.',
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
                  ),

                  const Spacer(),

                  InkWell(
                    onTap: onExplore,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.78),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.16),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Explore opportunities',
                            style: AppTypography.textTheme.labelMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColors.primary,
                            size: 17,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CauseBubble extends StatelessWidget {
  const _CauseBubble({
    required this.icon,
    required this.size,
  });

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 8,
          sigmaY: 8,
        ),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.72),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.surface.withValues(alpha: 0.90),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: size * 0.43,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}