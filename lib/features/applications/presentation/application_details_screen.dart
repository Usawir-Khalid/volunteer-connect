import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../models/application.dart';

class ApplicationDetailsScreen
    extends StatelessWidget {
  const ApplicationDetailsScreen({
    super.key,
    required this.application,
  });

  final Application application;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.background,
      appBar: AppBar(
        backgroundColor:
            AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
          ),
        ),
        title: const Text(
          'Application Details',
        ),
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            _HeaderCard(
              application: application,
            ),

            const SizedBox(
              height: AppSpacing.lg,
            ),

            Text(
              'Opportunity',
              style: AppTypography
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight:
                        FontWeight.w700,
                  ),
            ),

            const SizedBox(
              height: AppSpacing.sm,
            ),

            _DescriptionCard(
              application: application,
            ),

            const SizedBox(
              height: AppSpacing.lg,
            ),

            Text(
              'Details',
              style: AppTypography
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight:
                        FontWeight.w700,
                  ),
            ),

            const SizedBox(
              height: AppSpacing.sm,
            ),

            _DetailsCard(
              application: application,
            ),

            const SizedBox(
              height: AppSpacing.lg,
            ),

            Text(
              'Application Progress',
              style: AppTypography
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight:
                        FontWeight.w700,
                  ),
            ),

            const SizedBox(
              height: AppSpacing.sm,
            ),

            _Timeline(
              status: application.status,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.application,
  });

  final Application application;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(
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
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  application.title,
                  style: AppTypography
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                        fontWeight:
                            FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(
                width: AppSpacing.sm,
              ),
              _StatusBadge(
                status:
                    application.status,
              ),
            ],
          ),

          const SizedBox(
            height: AppSpacing.sm,
          ),

          Text(
            application.organization,
            style: AppTypography
                .textTheme
                .bodyMedium
                ?.copyWith(
                  color:
                      AppColors.textSecondary,
                ),
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          Row(
            children: [
              const Icon(
                Icons.category_outlined,
                size: 17,
                color:
                    AppColors.primary,
              ),
              const SizedBox(
                width: AppSpacing.xs,
              ),
              Text(
                application.category,
                style: AppTypography
                    .textTheme
                    .bodySmall
                    ?.copyWith(
                      color: AppColors
                          .textSecondary,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DescriptionCard
    extends StatelessWidget {
  const _DescriptionCard({
    required this.application,
  });

  final Application application;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(
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
      child: Text(
        application.description,
        style: AppTypography
            .textTheme
            .bodyMedium
            ?.copyWith(
              color:
                  AppColors.textSecondary,
              height: 1.5,
            ),
      ),
    );
  }
}

class _DetailsCard
    extends StatelessWidget {
  const _DetailsCard({
    required this.application,
  });

  final Application application;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(
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
      child: Column(
        children: [
          _DetailRow(
            icon:
                Icons.location_on_outlined,
            label: 'Location',
            value:
                application.location,
          ),

          const Divider(
            height: AppSpacing.lg,
          ),

          _DetailRow(
            icon:
                Icons.calendar_today_outlined,
            label: 'Date',
            value:
                _formatDate(
              application.dateTime,
            ),
          ),

          const Divider(
            height: AppSpacing.lg,
          ),

          _DetailRow(
            icon:
                Icons.access_time_outlined,
            label: 'Time',
            value:
                _formatTime(
              application.dateTime,
            ),
          ),

          const Divider(
            height: AppSpacing.lg,
          ),

          _DetailRow(
            icon:
                Icons.send_outlined,
            label: 'Applied',
            value:
                _formatDate(
              application.submittedDate,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(
    DateTime date,
  ) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime(
    DateTime date,
  ) {
    final hour = date.hour == 0
        ? 12
        : date.hour > 12
            ? date.hour - 12
            : date.hour;

    final minute =
        date.minute.toString().padLeft(
              2,
              '0',
            );

    final period =
        date.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }
}

class _DetailRow
    extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color:
                AppColors.primaryLight,
            borderRadius:
                BorderRadius.circular(
              AppRadius.input,
            ),
          ),
          child: Icon(
            icon,
            size: 19,
            color:
                AppColors.primary,
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
                label,
                style: AppTypography
                    .textTheme
                    .labelMedium
                    ?.copyWith(
                      color: AppColors
                          .textMuted,
                    ),
              ),

              const SizedBox(
                height: 2,
              ),

              Text(
                value,
                style: AppTypography
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      fontWeight:
                          FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Timeline
    extends StatelessWidget {
  const _Timeline({
    required this.status,
  });

  final ApplicationStatus status;

  @override
  Widget build(BuildContext context) {
    final steps = _steps();

    return Container(
      padding:
          const EdgeInsets.all(
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
        children: List.generate(
          steps.length,
          (index) {
            final step = steps[index];

            return _TimelineStep(
              title: step.title,
              subtitle: step.subtitle,
              completed: step.completed,
              active: step.active,
              isLast:
                  index == steps.length - 1,
            );
          },
        ),
      ),
    );
  }

  List<_TimelineData> _steps() {
    switch (status) {
      case ApplicationStatus.pending:
        return const [
          _TimelineData(
            title: 'Application submitted',
            subtitle:
                'Your application has been received.',
            completed: true,
            active: false,
          ),
          _TimelineData(
            title: 'Under review',
            subtitle:
                'The organization is reviewing applications.',
            completed: false,
            active: true,
          ),
          _TimelineData(
            title: 'Decision',
            subtitle:
                'Waiting for the organization’s decision.',
            completed: false,
            active: false,
          ),
        ];

      case ApplicationStatus.accepted:
        return const [
          _TimelineData(
            title: 'Application submitted',
            subtitle:
                'Your application has been received.',
            completed: true,
            active: false,
          ),
          _TimelineData(
            title: 'Under review',
            subtitle:
                'Your application was reviewed.',
            completed: true,
            active: false,
          ),
          _TimelineData(
            title: 'Accepted',
            subtitle:
                'You have been accepted for this opportunity.',
            completed: true,
            active: true,
          ),
        ];

      case ApplicationStatus.completed:
        return const [
          _TimelineData(
            title: 'Application submitted',
            subtitle:
                'Your application was received.',
            completed: true,
            active: false,
          ),
          _TimelineData(
            title: 'Accepted',
            subtitle:
                'You were accepted for this opportunity.',
            completed: true,
            active: false,
          ),
          _TimelineData(
            title: 'Completed',
            subtitle:
                'You completed this volunteer opportunity.',
            completed: true,
            active: true,
          ),
        ];

      case ApplicationStatus.rejected:
        return const [
          _TimelineData(
            title: 'Application submitted',
            subtitle:
                'Your application was received.',
            completed: true,
            active: false,
          ),
          _TimelineData(
            title: 'Under review',
            subtitle:
                'Your application was reviewed.',
            completed: true,
            active: false,
          ),
          _TimelineData(
            title: 'Not selected',
            subtitle:
                'This application was not selected.',
            completed: true,
            active: true,
          ),
        ];
    }
  }
}

class _TimelineData {
  const _TimelineData({
    required this.title,
    required this.subtitle,
    required this.completed,
    required this.active,
  });

  final String title;
  final String subtitle;
  final bool completed;
  final bool active;
}

class _TimelineStep
    extends StatelessWidget {
  const _TimelineStep({
    required this.title,
    required this.subtitle,
    required this.completed,
    required this.active,
    required this.isLast,
  });

  final String title;
  final String subtitle;
  final bool completed;
  final bool active;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration:
                      BoxDecoration(
                    shape: BoxShape.circle,
                    color: completed
                        ? AppColors.primary
                        : AppColors
                            .secondarySurface,
                    border: Border.all(
                      color: completed
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                  ),
                  child: completed
                      ? const Icon(
                          Icons.check,
                          size: 14,
                          color:
                              AppColors.white,
                        )
                      : null,
                ),

                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin:
                          const EdgeInsets
                              .symmetric(
                        vertical:
                            AppSpacing.xs,
                      ),
                      color: completed
                          ? AppColors
                              .primaryLight
                          : AppColors.border,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(
            width: AppSpacing.md,
          ),

          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.only(
                bottom: AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography
                        .textTheme
                        .bodyLarge
                        ?.copyWith(
                          fontWeight:
                              FontWeight.w700,
                          color: active
                              ? AppColors.primary
                              : AppColors
                                  .textPrimary,
                        ),
                  ),

                  const SizedBox(
                    height: 3,
                  ),

                  Text(
                    subtitle,
                    style: AppTypography
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                          color: AppColors
                              .textSecondary,
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

class _StatusBadge
    extends StatelessWidget {
  const _StatusBadge({
    required this.status,
  });

  final ApplicationStatus status;

  @override
  Widget build(BuildContext context) {
    Color background;
    Color foreground;

    switch (status) {
      case ApplicationStatus.pending:
        background =
            AppColors.warning.withValues(
          alpha: 0.12,
        );
        foreground = AppColors.warning;
        break;

      case ApplicationStatus.accepted:
        background =
            AppColors.success.withValues(
          alpha: 0.12,
        );
        foreground = AppColors.success;
        break;

      case ApplicationStatus.completed:
        background =
            AppColors.info.withValues(
          alpha: 0.12,
        );
        foreground = AppColors.info;
        break;

      case ApplicationStatus.rejected:
        background =
            AppColors.error.withValues(
          alpha: 0.12,
        );
        foreground = AppColors.error;
        break;
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius:
            BorderRadius.circular(
          AppRadius.pill,
        ),
      ),
      child: Text(
        status.displayName,
        style: AppTypography
            .textTheme
            .labelMedium
            ?.copyWith(
              color: foreground,
              fontWeight:
                  FontWeight.w700,
            ),
      ),
    );
  }
}