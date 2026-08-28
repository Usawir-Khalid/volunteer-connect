import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  ApplicationStatus? _selectedStatus;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>>
      get _applicationsStream {
    final user = _auth.currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('applications')
        .where(
          'volunteerId',
          isEqualTo: user.uid,
        )
        .snapshots();
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>>
      _filterApplications(
    List<QueryDocumentSnapshot<Map<String, dynamic>>>
        documents,
  ) {
    if (_selectedStatus == null) {
      return documents;
    }

    final statusName =
        _statusToFirestoreValue(
      _selectedStatus!,
    );

    return documents.where((document) {
      final data = document.data();

      return data['status'] == statusName;
    }).toList();
  }

  String _statusToFirestoreValue(
    ApplicationStatus status,
  ) {
    switch (status) {
      case ApplicationStatus.pending:
        return 'pending';

      case ApplicationStatus.accepted:
        return 'accepted';

      case ApplicationStatus.completed:
        return 'completed';

      case ApplicationStatus.rejected:
        return 'rejected';
    }
  }

  Application _toApplication(
    QueryDocumentSnapshot<Map<String, dynamic>>
        document,
  ) {
    final data = document.data();

    final status =
        _parseStatus(
      data['status'] as String?,
    );

    final submittedAt =
        _timestampToDate(
      data['submittedAt'],
    );

    final dateTime =
        _timestampToDate(
      data['eventDate'],
    ) ??
        submittedAt ??
        DateTime.now();

    return Application(
      id:
          data['id'] as String? ??
              document.id,

      opportunityId:
          data['opportunityId'] as String? ??
              '',

      title:
          data['opportunityTitle'] as String? ??
              'Volunteer Opportunity',

      organization:
          data['organization'] as String? ??
              'Organization',

      category:
          data['category'] as String? ??
              'Volunteer',

      location:
          data['location'] as String? ??
              'Location',

      dateTime: dateTime,

      status: status,

      submittedDate:
          submittedAt ??
              DateTime.now(),

      description:
          data['message'] as String? ??
              '',
    );
  }

  ApplicationStatus _parseStatus(
    String? value,
  ) {
    switch (value?.toLowerCase()) {
      case 'accepted':
        return ApplicationStatus.accepted;

      case 'completed':
        return ApplicationStatus.completed;

      case 'rejected':
        return ApplicationStatus.rejected;

      case 'pending':
      default:
        return ApplicationStatus.pending;
    }
  }

  DateTime? _timestampToDate(
    dynamic value,
  ) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder<
            QuerySnapshot<Map<String, dynamic>>>(
          stream: _applicationsStream,
          builder: (
            context,
            snapshot,
          ) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const _ApplicationsLoading();
            }

            if (snapshot.hasError) {
              debugPrint(
                'APPLICATIONS LOAD ERROR: '
                '${snapshot.error}',
              );

              return _ApplicationsError(
                onRetry: () {
                  setState(() {});
                },
              );
            }

            final documents =
                snapshot.data?.docs ?? [];

            final applications =
                _filterApplications(
              documents,
            );

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        _HeaderCard(
                          totalApplications:
                              documents.length,
                        ),

                        const SizedBox(
                          height: AppSpacing.lg,
                        ),

                        Text(
                          'Application status',
                          style: AppTypography
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),

                        const SizedBox(
                          height: AppSpacing.sm,
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

                        const SizedBox(
                          height: AppSpacing.lg,
                        ),

                        Row(
                          children: [
                            Text(
                              'Your applications',
                              style: AppTypography
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                fontWeight:
                                    FontWeight.w800,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${applications.length}',
                              style: AppTypography
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                color:
                                    AppColors
                                        .textSecondary,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ],
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
                    padding:
                        const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      AppSpacing.xxl,
                    ),
                    sliver: SliverList(
                      delegate:
                          SliverChildBuilderDelegate(
                        (
                          context,
                          index,
                        ) {
                          final document =
                              applications[index];

                          final application =
                              _toApplication(
                            document,
                          );

                          return Padding(
                            padding:
                                const EdgeInsets.only(
                              bottom:
                                  AppSpacing.md,
                            ),
                            child:
                                _ApplicationCard(
                              application:
                                  application,
                              onTap: () {
                                Navigator.of(
                                  context,
                                ).push(
                                  MaterialPageRoute(
                                    builder:
                                        (_) =>
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
                        childCount:
                            applications.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.totalApplications,
  });

  final int totalApplications;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            right: -12,
            top: -24,
            child: Icon(
              Icons.eco_rounded,
              size: 120,
              color: AppColors.primary.withValues(
                alpha: 0.07,
              ),
            ),
          ),
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration:
                        const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.assignment_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'My Applications',
                      style: AppTypography
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                totalApplications == 0
                    ? 'Start applying and your applications will appear here.'
                    : '$totalApplications application${totalApplications == 1 ? '' : 's'} submitted',
                style: AppTypography
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                  color:
                      AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ],
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
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                AppColors.primaryLight,
              ],
            ),
            borderRadius:
                BorderRadius.circular(
              AppRadius.card,
            ),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -18,
                bottom: -28,
                child: Icon(
                  Icons.eco_rounded,
                  size: 110,
                  color:
                      AppColors.primary
                          .withValues(
                    alpha: 0.045,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration:
                            const BoxDecoration(
                          color:
                              AppColors
                                  .primaryLight,
                          shape:
                              BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons
                              .volunteer_activism_rounded,
                          color:
                              AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(
                        width: AppSpacing.sm,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              application.title,
                              maxLines: 2,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style:
                                  AppTypography
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),
                            const SizedBox(
                              height:
                                  AppSpacing.xs,
                            ),
                            Text(
                              application
                                  .organization,
                              maxLines: 1,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style:
                                  AppTypography
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                color:
                                    AppColors
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
                              BorderRadius
                                  .circular(
                            AppRadius.pill,
                          ),
                        ),
                        child: Text(
                          application.category,
                          style:
                              AppTypography
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                            color:
                                AppColors
                                    .primary,
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
                            AppColors
                                .textMuted,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
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

  String _formatTime(DateTime date) {
    final hour =
        date.hour == 0
            ? 12
            : date.hour > 12
                ? date.hour - 12
                : date.hour;

    final minute =
        date.minute
            .toString()
            .padLeft(2, '0');

    final period =
        date.hour >= 12
            ? 'PM'
            : 'AM';

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
              color:
                  AppColors.textSecondary,
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
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              right: 15,
              bottom: 10,
              child: Icon(
                Icons.eco_rounded,
                size: 120,
                color:
                    AppColors.primary
                        .withValues(
                  alpha: 0.05,
                ),
              ),
            ),
            Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Container(
                  width: 82,
                  height: 82,
                  decoration:
                      const BoxDecoration(
                    color:
                        AppColors
                            .primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons
                        .assignment_outlined,
                    size: 36,
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
                    color:
                        AppColors
                            .textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ApplicationsLoading
    extends StatelessWidget {
  const _ApplicationsLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
      ),
    );
  }
}

class _ApplicationsError
    extends StatelessWidget {
  const _ApplicationsError({
    required this.onRetry,
  });

  final VoidCallback onRetry;

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
              width: 78,
              height: 78,
              decoration:
                  const BoxDecoration(
                color:
                    AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 36,
                color:
                    AppColors.textSecondary,
              ),
            ),
            const SizedBox(
              height: AppSpacing.lg,
            ),
            Text(
              'Could not load applications',
              textAlign:
                  TextAlign.center,
              style: AppTypography
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                fontWeight:
                    FontWeight.w700,
              ),
            ),
            const SizedBox(
              height: AppSpacing.sm,
            ),
            Text(
              'Please check your connection and try again.',
              textAlign:
                  TextAlign.center,
              style: AppTypography
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                color:
                    AppColors
                        .textSecondary,
              ),
            ),
            const SizedBox(
              height: AppSpacing.lg,
            ),
            OutlinedButton(
              onPressed: onRetry,
              child:
                  const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}