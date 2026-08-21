import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../models/application.dart';
import 'application_details_screen.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({
    super.key,
  });

  @override
  State<ApplicationsScreen> createState() =>
      _ApplicationsScreenState();
}

class _ApplicationsScreenState
    extends State<ApplicationsScreen> {
  final List<Application> _applications =
      Application.mockApplications();

  ApplicationStatus? _selectedStatus;

  List<Application> get _filteredApplications {
    if (_selectedStatus == null) {
      return _applications;
    }

    return _applications
        .where(
          (application) =>
              application.status == _selectedStatus,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final applications = _filteredApplications;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Applications',
                      style: AppTypography
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),

                    const SizedBox(
                      height: AppSpacing.xs,
                    ),

                    Text(
                      'Keep track of the opportunities you’ve applied for.',
                      style: AppTypography
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            color:
                                AppColors.textSecondary,
                          ),
                    ),

                    const SizedBox(
                      height: AppSpacing.lg,
                    ),

                    SizedBox(
                      height: 42,
                      child: ListView(
                        scrollDirection:
                            Axis.horizontal,
                        children: [
                          _StatusChip(
                            label: 'All',
                            selected:
                                _selectedStatus ==
                                    null,
                            onTap: () {
                              setState(() {
                                _selectedStatus =
                                    null;
                              });
                            },
                          ),
                          _StatusChip(
                            label: 'Pending',
                            selected:
                                _selectedStatus ==
                                    ApplicationStatus
                                        .pending,
                            onTap: () {
                              setState(() {
                                _selectedStatus =
                                    ApplicationStatus
                                        .pending;
                              });
                            },
                          ),
                          _StatusChip(
                            label: 'Accepted',
                            selected:
                                _selectedStatus ==
                                    ApplicationStatus
                                        .accepted,
                            onTap: () {
                              setState(() {
                                _selectedStatus =
                                    ApplicationStatus
                                        .accepted;
                              });
                            },
                          ),
                          _StatusChip(
                            label: 'Completed',
                            selected:
                                _selectedStatus ==
                                    ApplicationStatus
                                        .completed,
                            onTap: () {
                              setState(() {
                                _selectedStatus =
                                    ApplicationStatus
                                        .completed;
                              });
                            },
                          ),
                          _StatusChip(
                            label: 'Rejected',
                            selected:
                                _selectedStatus ==
                                    ApplicationStatus
                                        .rejected,
                            onTap: () {
                              setState(() {
                                _selectedStatus =
                                    ApplicationStatus
                                        .rejected;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (applications.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyApplications(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.xxl,
                ),
                sliver: SliverList(
                  delegate:
                      SliverChildBuilderDelegate(
                    (context, index) {
                      final application =
                          applications[index];

                      return Padding(
                        padding:
                            const EdgeInsets.only(
                          bottom: AppSpacing.md,
                        ),
                        child: _ApplicationCard(
                          application: application,
                          onTap: () {
                            Navigator.of(context)
                                .push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    ApplicationDetailsScreen(
                                  application:
                                      application,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    childCount: applications.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        right: AppSpacing.sm,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 180),
          padding:
              const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary
                : AppColors.surface,
            borderRadius:
                BorderRadius.circular(
              AppRadius.pill,
            ),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: AppTypography
                .textTheme
                .labelLarge
                ?.copyWith(
                  color: selected
                      ? AppColors.white
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }
}

class _ApplicationCard
    extends StatelessWidget {
  const _ApplicationCard({
    required this.application,
    required this.onTap,
  });

  final Application application;
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
          padding:
              const EdgeInsets.all(
            AppSpacing.md,
          ),
          decoration: BoxDecoration(
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
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          application.title,
                          maxLines: 2,
                          overflow:
                              TextOverflow.ellipsis,
                          style: AppTypography
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight:
                                    FontWeight.w700,
                              ),
                        ),

                        const SizedBox(
                          height: AppSpacing.xs,
                        ),

                        Text(
                          application.organization,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
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
                height: AppSpacing.md,
              ),

              Row(
                children: [
                  Expanded(
                    child: _InfoItem(
                      icon: Icons
                          .calendar_today_outlined,
                      text: _formatDate(
                        application.dateTime,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _InfoItem(
                      icon: Icons
                          .access_time_outlined,
                      text: _formatTime(
                        application.dateTime,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: AppSpacing.sm,
              ),

              _InfoItem(
                icon: Icons
                    .location_on_outlined,
                text:
                    application.location,
              ),

              const SizedBox(
                height: AppSpacing.md,
              ),

              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal:
                          AppSpacing.sm,
                      vertical:
                          AppSpacing.xs,
                    ),
                    decoration:
                        BoxDecoration(
                      color: AppColors
                          .primaryLight,
                      borderRadius:
                          BorderRadius.circular(
                        AppRadius.pill,
                      ),
                    ),
                    child: Text(
                      application.category,
                      style: AppTypography
                          .textTheme
                          .labelMedium
                          ?.copyWith(
                            color:
                                AppColors.primary,
                            fontWeight:
                                FontWeight.w600,
                          ),
                    ),
                  ),

                  const Spacer(),

                  const Icon(
                    Icons
                        .arrow_forward_ios_rounded,
                    size: 14,
                    color:
                        AppColors.textMuted,
                  ),
                ],
              ),
            ],
          ),
        ),
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
        date.minute.toString().padLeft(2, '0');

    final period =
        date.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }
}

class _StatusBadge extends StatelessWidget {
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

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color:
              AppColors.textSecondary,
        ),
        const SizedBox(
          width: AppSpacing.xs,
        ),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            style: AppTypography
                .textTheme
                .bodySmall
                ?.copyWith(
                  color: AppColors
                      .textSecondary,
                ),
          ),
        ),
      ],
    );
  }
}

class _EmptyApplications
    extends StatelessWidget {
  const _EmptyApplications();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration:
                  BoxDecoration(
                color:
                    AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons
                    .assignment_outlined,
                size: 34,
                color:
                    AppColors.primary,
              ),
            ),

            const SizedBox(
              height: AppSpacing.lg,
            ),

            Text(
              'No applications here',
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

            Text(
              'Applications you submit will appear here.',
              textAlign:
                  TextAlign.center,
              style: AppTypography
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                    color: AppColors
                        .textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}