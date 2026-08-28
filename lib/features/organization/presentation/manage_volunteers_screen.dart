import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';

class ManageVolunteersScreen extends StatelessWidget {
  const ManageVolunteersScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final uid =
        FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text(
            'Please sign in again.',
          ),
        ),
      );
    }

    final applicationsStream =
        FirebaseFirestore.instance
            .collection('applications')
            .where(
              'organizationId',
              isEqualTo: uid,
            )
            .snapshots();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
        ),
        title: const Text(
          'Manage Volunteers',
        ),
      ),
      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: applicationsStream,
        builder: (
          context,
          snapshot,
        ) {
          if (snapshot.hasError) {
            debugPrint(
              'MANAGE VOLUNTEERS ERROR: '
              '${snapshot.error}',
            );

            return const _ErrorState();
          }

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const _LoadingState();
          }

          final applications =
              List<QueryDocumentSnapshot<
                  Map<String, dynamic>>>.from(
            snapshot.data?.docs ?? [],
          );

          applications.sort(
            (a, b) {
              final aTime =
                  a.data()['submittedAt']
                      as Timestamp?;

              final bTime =
                  b.data()['submittedAt']
                      as Timestamp?;

              if (aTime == null &&
                  bTime == null) {
                return 0;
              }

              if (aTime == null) {
                return 1;
              }

              if (bTime == null) {
                return -1;
              }

              return bTime.compareTo(aTime);
            },
          );

          if (applications.isEmpty) {
            return const _EmptyState();
          }

          final pending =
              applications.where(
            (document) {
              return document.data()['status'] ==
                  'pending';
            },
          ).length;

          final accepted =
              applications.where(
            (document) {
              return document.data()['status'] ==
                  'accepted';
            },
          ).length;

          return ListView(
            padding:
                const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            children: [
              _SummaryCard(
                total: applications.length,
                pending: pending,
                accepted: accepted,
              ),

              const SizedBox(
                height: AppSpacing.lg,
              ),

              Row(
                children: [
                  const Icon(
                    Icons.people_alt_outlined,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    'Applicants',
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
                          AppColors.textSecondary,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: AppSpacing.md,
              ),

              ...applications.map(
                (document) {
                  return Padding(
                    padding:
                        const EdgeInsets.only(
                      bottom: AppSpacing.md,
                    ),
                    child:
                        _VolunteerCard(
                      document: document,
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

// =============================================================================
// SUMMARY CARD
// =============================================================================

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.total,
    required this.pending,
    required this.accepted,
  });

  final int total;
  final int pending;
  final int accepted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient:
            const LinearGradient(
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
          colors: [
            AppColors.primaryLight,
            Colors.white,
          ],
        ),
        borderRadius:
            BorderRadius.circular(26),
        border: Border.all(
          color: Colors.white,
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -16,
            top: -26,
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
              Expanded(
                child: _MiniStat(
                  value:
                      '$total',
                  label:
                      'Applicants',
                  icon:
                      Icons.people_alt_outlined,
                ),
              ),
              Container(
                width: 1,
                height: 60,
                color:
                    AppColors.border,
              ),
              Expanded(
                child: _MiniStat(
                  value:
                      '$pending',
                  label:
                      'Pending',
                  icon:
                      Icons
                          .hourglass_empty_rounded,
                ),
              ),
              Container(
                width: 1,
                height: 60,
                color:
                    AppColors.border,
              ),
              Expanded(
                child: _MiniStat(
                  value:
                      '$accepted',
                  label:
                      'Accepted',
                  icon:
                      Icons
                          .check_circle_outline_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// MINI STAT
// =============================================================================

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color:
              AppColors.primary,
          size: 24,
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          value,
          style: AppTypography
              .textTheme
              .headlineMedium
              ?.copyWith(
            fontWeight:
                FontWeight.w800,
          ),
        ),
        Text(
          label,
          textAlign:
              TextAlign.center,
          style: AppTypography
              .textTheme
              .bodySmall
              ?.copyWith(
            color:
                AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// VOLUNTEER CARD
// =============================================================================

class _VolunteerCard
    extends StatelessWidget {
  const _VolunteerCard({
    required this.document,
  });

  final QueryDocumentSnapshot<
      Map<String, dynamic>> document;

  @override
  Widget build(BuildContext context) {
    final data =
        document.data();

    final name =
        data['volunteerName']
                as String? ??
            'Volunteer';

    final email =
        data['volunteerEmail']
                as String? ??
            '';

    final opportunity =
        data['opportunityTitle']
                as String? ??
            'Opportunity';

    final phone =
        data['phone']
                as String? ??
            '';

    final message =
        data['message']
                as String? ??
            '';

    final status =
        data['status']
                as String? ??
            'pending';

    return Container(
      padding:
          const EdgeInsets.all(18),
      decoration:
          BoxDecoration(
        gradient:
            const LinearGradient(
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
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
          color:
              AppColors.border,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            bottom: -30,
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
                    CrossAxisAlignment
                        .start,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration:
                        const BoxDecoration(
                      color:
                          AppColors
                              .primaryLight,
                      shape:
                          BoxShape.circle,
                    ),
                    child:
                        const Icon(
                      Icons
                          .person_rounded,
                      color:
                          AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(
                    width: 13,
                  ),
                  Expanded(
                    child:
                        Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          name,
                          style:
                              AppTypography
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Text(
                          email,
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
                    width: 8,
                  ),
                  _StatusBadge(
                    status: status,
                  ),
                ],
              ),

              const SizedBox(
                height: 16,
              ),

              Container(
                padding:
                    const EdgeInsets.all(14),
                decoration:
                    BoxDecoration(
                  color: AppColors
                      .primaryLight
                      .withValues(
                    alpha: 0.60,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),
                child:
                    Row(
                  children: [
                    const Icon(
                      Icons.event_outlined,
                      color:
                          AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child:
                          Text(
                        opportunity,
                        style:
                            AppTypography
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 14,
              ),

              _InfoRow(
                icon:
                    Icons.phone_outlined,
                text: phone.isEmpty
                    ? 'No phone provided'
                    : phone,
              ),

              if (message.isNotEmpty) ...[
                const SizedBox(
                  height: 10,
                ),
                _InfoRow(
                  icon: Icons
                      .chat_bubble_outline_rounded,
                  text: message,
                ),
              ],

              if (status ==
                  'pending') ...[
                const SizedBox(
                  height: 18,
                ),
                Row(
                  children: [
                    Expanded(
                      child:
                          OutlinedButton.icon(
                        onPressed: () {
                          _confirmStatusChange(
                            context,
                            document,
                            'rejected',
                          );
                        },
                        icon:
                            const Icon(
                          Icons.close_rounded,
                          size: 18,
                        ),
                        label:
                            const Text(
                          'Reject',
                        ),
                        style:
                            OutlinedButton
                                .styleFrom(
                          foregroundColor:
                              Colors
                                  .red
                                  .shade700,
                          side:
                              BorderSide(
                            color:
                                Colors.red
                                    .shade200,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child:
                          ElevatedButton.icon(
                        onPressed: () {
                          _confirmStatusChange(
                            context,
                            document,
                            'accepted',
                          );
                        },
                        icon:
                            const Icon(
                          Icons
                              .check_rounded,
                          size: 18,
                        ),
                        label:
                            const Text(
                          'Accept',
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              if (status ==
                  'accepted') ...[
                const SizedBox(
                  height: 18,
                ),
                SizedBox(
                  width:
                      double.infinity,
                  child:
                      OutlinedButton.icon(
                    onPressed: () {
                      _confirmStatusChange(
                        context,
                        document,
                        'completed',
                      );
                    },
                    icon:
                        const Icon(
                      Icons
                          .check_circle_outline_rounded,
                    ),
                    label:
                        const Text(
                      'Mark Completed',
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Future<void>
      _confirmStatusChange(
    BuildContext context,
    QueryDocumentSnapshot<
            Map<String, dynamic>>
        document,
    String status,
  ) async {
    final action =
        switch (status) {
      'accepted' => 'accept',
      'rejected' => 'reject',
      'completed' =>
        'mark this volunteer as completed',
      _ => 'update',
    };

    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            '${action[0].toUpperCase()}'
            '${action.substring(1)}?',
          ),
          content: Text(
            'Are you sure you want to '
            '$action this application?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child:
                  const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child:
                  const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (confirmed != true ||
        !context.mounted) {
      return;
    }

    await _updateStatus(
      context,
      document,
      status,
    );
  }

  Future<void> _updateStatus(
    BuildContext context,
    QueryDocumentSnapshot<
            Map<String, dynamic>>
        document,
    String status,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('applications')
          .doc(document.id)
          .update({
        'status': status,
        'updatedAt':
            FieldValue.serverTimestamp(),
      });

      if (!context.mounted) {
        return;
      }

      final message =
          switch (status) {
        'accepted' =>
          'Volunteer accepted.',
        'rejected' =>
          'Application rejected.',
        'completed' =>
          'Volunteer marked as completed.',
        _ =>
          'Application updated.',
      };

      ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
            Text(message),
        backgroundColor:
            AppColors.primary,
        behavior:
            SnackBarBehavior.floating,
      ),
    );
    } on FirebaseException catch (e) {
      debugPrint(
        'UPDATE APPLICATION ERROR: '
        '${e.code} - ${e.message}',
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Could not update application: '
            '${e.code}',
          ),
          backgroundColor:
              Colors.red.shade700,
          behavior:
              SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint(
        'UPDATE APPLICATION ERROR: $e',
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: const Text(
            'Something went wrong. '
            'Please try again.',
          ),
          backgroundColor:
              Colors.red.shade700,
          behavior:
              SnackBarBehavior.floating,
        ),
      );
    }
  }
}

// =============================================================================
// INFO ROW
// =============================================================================

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 19,
          color:
              AppColors.textSecondary,
        ),
        const SizedBox(
          width: 9,
        ),
        Expanded(
          child:
              Text(
            text,
            style:
                AppTypography
                    .textTheme
                    .bodySmall
                    ?.copyWith(
              color:
                  AppColors
                      .textSecondary,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// STATUS BADGE
// =============================================================================

class _StatusBadge
    extends StatelessWidget {
  const _StatusBadge({
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    final isRejected =
        status == 'rejected';

    final isAccepted =
        status == 'accepted';

    final isCompleted =
        status == 'completed';

    final label =
        switch (status) {
      'accepted' =>
        'Accepted',
      'rejected' =>
        'Rejected',
      'completed' =>
        'Completed',
      _ =>
        'Pending',
    };

    final background =
        isRejected
            ? Colors.red.shade50
            : isAccepted
                ? Colors.green.shade50
                : isCompleted
                    ? Colors.blue.shade50
                    : AppColors
                        .primaryLight;

    final foreground =
        isRejected
            ? Colors.red.shade700
            : isAccepted
                ? Colors.green.shade700
                : isCompleted
                    ? Colors.blue.shade700
                    : AppColors.primary;

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration:
          BoxDecoration(
        color: background,
        borderRadius:
            BorderRadius.circular(30),
      ),
      child:
          Text(
        label,
        style:
            AppTypography
                .textTheme
                .labelSmall
                ?.copyWith(
          color: foreground,
          fontWeight:
              FontWeight.w700,
        ),
      ),
    );
  }
}

// =============================================================================
// EMPTY STATE
// =============================================================================

class _EmptyState
    extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(32),
        child: Stack(
          alignment:
              Alignment.center,
          children: [
            Positioned(
              right: 0,
              bottom: 10,
              child: Icon(
                Icons.eco_rounded,
                size: 140,
                color:
                    AppColors.primary
                        .withValues(
                  alpha: 0.045,
                ),
              ),
            ),
            Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Container(
                  width: 86,
                  height: 86,
                  decoration:
                      const BoxDecoration(
                    color:
                        AppColors
                            .primaryLight,
                    shape:
                        BoxShape.circle,
                  ),
                  child:
                      const Icon(
                    Icons
                        .people_outline_rounded,
                    color:
                        AppColors.primary,
                    size: 42,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  'No volunteers yet',
                  style: AppTypography
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  'When volunteers apply to your opportunities, their applications will appear here.',
                  textAlign:
                      TextAlign.center,
                  style: AppTypography
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                    color: AppColors
                        .textSecondary,
                    height: 1.45,
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

// =============================================================================
// LOADING STATE
// =============================================================================

class _LoadingState
    extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration:
                const BoxDecoration(
              color:
                  AppColors.primaryLight,
              shape:
                  BoxShape.circle,
            ),
            child:
                const Padding(
              padding:
                  EdgeInsets.all(22),
              child:
                  CircularProgressIndicator(
                strokeWidth: 3,
                color:
                    AppColors.primary,
              ),
            ),
          ),
          const SizedBox(
            height: 18,
          ),
          Text(
            'Loading volunteers...',
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
    );
  }
}

// =============================================================================
// ERROR STATE
// =============================================================================

class _ErrorState
    extends StatelessWidget {
  const _ErrorState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration:
                  const BoxDecoration(
                color:
                    AppColors
                        .primaryLight,
                shape:
                    BoxShape.circle,
              ),
              child:
                  const Icon(
                Icons
                    .cloud_off_rounded,
                color:
                    AppColors
                        .textSecondary,
                size: 40,
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            Text(
              'Could not load volunteers',
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
              height: 8,
            ),
            Text(
              'Please check your connection and try again.',
              textAlign:
                  TextAlign.center,
              style: AppTypography
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
    );
  }
}