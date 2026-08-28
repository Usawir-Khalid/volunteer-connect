import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.userName,
  });

  final String userName;

  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'Good morning';
    }

    if (hour >= 12 && hour < 17) {
      return 'Good afternoon';
    }

    if (hour >= 17 && hour < 21) {
      return 'Good evening';
    }

    return 'Hello';
  }

  String _getSubtitle() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'Ready to make an impact?';
    }

    if (hour >= 12 && hour < 17) {
      return 'Ready to make an impact?';
    }

    if (hour >= 17 && hour < 21) {
      return 'Make a difference today.';
    }

    return 'Looking for ways to make an impact?';
  }

  @override
  Widget build(BuildContext context) {
    final greeting = _getGreeting();
    final subtitle = _getSubtitle();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting, $userName 👋',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(
                height: AppSpacing.xs,
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(
          width: AppSpacing.sm,
        ),

        _HeaderButton(
          icon: Icons.notifications_none_rounded,
          onPressed: () {},
        ),

        const SizedBox(
          width: AppSpacing.sm,
        ),

        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(
              AppRadius.input,
            ),
            border: Border.all(
              color: AppColors.primary.withValues(
                alpha: 0.25,
              ),
              width: 1.2,
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.person_outline_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(
        AppRadius.input,
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(
          AppRadius.input,
        ),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              AppRadius.input,
            ),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Icon(
            icon,
            color: AppColors.textPrimary,
            size: 21,
          ),
        ),
      ),
    );
  }
}