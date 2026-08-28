import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';

class MyOpportunitiesScreen extends StatelessWidget {
  const MyOpportunitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text('Please sign in again.'),
        ),
      );
    }

    final stream = FirebaseFirestore.instance
        .collection('opportunities')
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
        title: const Text('My Opportunities'),
      ),
      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint(
              'MY OPPORTUNITIES ERROR: '
              '${snapshot.error}',
            );

            return const _ErrorState();
          }

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          final documents =
              snapshot.data?.docs ?? [];

          if (documents.isEmpty) {
            return const _EmptyState();
          }

          documents.sort((a, b) {
            final aTime =
                a.data()['createdAt'] as Timestamp?;
            final bTime =
                b.data()['createdAt'] as Timestamp?;

            if (aTime == null && bTime == null) {
              return 0;
            }

            if (aTime == null) return 1;
            if (bTime == null) return -1;

            return bTime.compareTo(aTime);
          });

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            children: [
              _HeaderCard(
                count: documents.length,
              ),
              const SizedBox(
                height: AppSpacing.lg,
              ),
              ...documents.map(
                (document) => Padding(
                  padding: const EdgeInsets.only(
                    bottom: 14,
                  ),
                  child: _OpportunityCard(
                    document: document,
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push(
            '/organization/create-opportunity',
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(
          Icons.add_rounded,
        ),
        label: const Text(
          'Create',
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.count,
  });

  final int count;

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
            right: -10,
            top: -18,
            child: Icon(
              Icons.eco_rounded,
              size: 100,
              color:
                  AppColors.primary.withValues(
                alpha: 0.07,
              ),
            ),
          ),
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.event_note_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your opportunities',
                      style: AppTypography
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '$count ${count == 1 ? 'opportunity' : 'opportunities'} published',
                      style: AppTypography
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                        color:
                            AppColors.textSecondary,
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

class _OpportunityCard extends StatelessWidget {
  const _OpportunityCard({
    required this.document,
  });

  final QueryDocumentSnapshot<
      Map<String, dynamic>> document;

  @override
  Widget build(BuildContext context) {
    final data = document.data();

    final title =
        data['title'] as String? ??
            'Untitled Opportunity';

    final category =
        data['category'] as String? ??
            'Volunteer';

    final location =
        data['location'] as String? ??
            'Location';

    final date =
        data['dateDisplay'] as String? ??
            'Date';

    final time =
        data['timeDisplay'] as String? ??
            'Time';

    final availability =
        data['availability'] as String? ??
            'Open';

    final status =
        data['status'] as String? ??
            'published';

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
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTypography
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(
                status: status,
              ),
            ],
          ),
          const SizedBox(height: 10),
          _CategoryPill(
            category: category,
          ),
          const SizedBox(height: 16),
          _DetailRow(
            icon: Icons.location_on_outlined,
            text: location,
          ),
          const SizedBox(height: 9),
          _DetailRow(
            icon: Icons.calendar_today_outlined,
            text: '$date • $time',
          ),
          const SizedBox(height: 9),
          _DetailRow(
            icon: Icons.people_outline,
            text: availability,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showEditDialog(
                      context,
                      document,
                    );
                  },
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 18,
                  ),
                  label: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _confirmDelete(
                      context,
                      document,
                    );
                  },
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                  ),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        Colors.red.shade700,
                    side: BorderSide(
                      color:
                          Colors.red.shade200,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(
    BuildContext context,
    QueryDocumentSnapshot<
        Map<String, dynamic>> document,
  ) async {
    final data = document.data();

    final titleController =
        TextEditingController(
      text: data['title'] as String? ?? '',
    );

    final descriptionController =
        TextEditingController(
      text:
          data['description'] as String? ?? '',
    );

    final locationController =
        TextEditingController(
      text:
          data['location'] as String? ?? '',
    );

    final capacityController =
        TextEditingController(
      text:
          '${data['capacity'] ?? ''}',
    );

    final categories = const [
      'Environment',
      'Education',
      'Community',
      'Healthcare',
      'Animals',
      'Other',
    ];

    String category =
        data['category'] as String? ??
            'Environment';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder:
              (dialogContext, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(24),
              ),
              title: const Text(
                'Edit Opportunity',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    TextField(
                      controller:
                          titleController,
                      decoration:
                          const InputDecoration(
                        labelText: 'Title',
                        prefixIcon: Icon(
                          Icons
                              .volunteer_activism_outlined,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<
                        String>(
                      initialValue: category,
                      decoration:
                          const InputDecoration(
                        labelText: 'Category',
                        prefixIcon: Icon(
                          Icons
                              .category_outlined,
                        ),
                      ),
                      items: categories
                          .map(
                            (item) =>
                                DropdownMenuItem<
                                    String>(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }

                        setDialogState(() {
                          category = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller:
                          descriptionController,
                      maxLines: 4,
                      decoration:
                          const InputDecoration(
                        labelText: 'Description',
                        prefixIcon: Icon(
                          Icons
                              .description_outlined,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller:
                          locationController,
                      decoration:
                          const InputDecoration(
                        labelText: 'Location',
                        prefixIcon: Icon(
                          Icons
                              .location_on_outlined,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller:
                          capacityController,
                      keyboardType:
                          TextInputType.number,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Volunteer capacity',
                        prefixIcon: Icon(
                          Icons.people_outline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(
                      dialogContext,
                    ).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final title =
                        titleController.text
                            .trim();

                    final description =
                        descriptionController
                            .text
                            .trim();

                    final location =
                        locationController.text
                            .trim();

                    final capacity =
                        int.tryParse(
                      capacityController.text
                          .trim(),
                    );

                    if (title.isEmpty ||
                        description.isEmpty ||
                        location.isEmpty ||
                        capacity == null ||
                        capacity <= 0) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please complete all fields correctly.',
                          ),
                        ),
                      );
                      return;
                    }

                    try {
                      await FirebaseFirestore
                          .instance
                          .collection(
                              'opportunities')
                          .doc(document.id)
                          .update({
                        'title': title,
                        'category': category,
                        'description':
                            description,
                        'location': location,
                        'capacity': capacity,
                        'availability':
                            '$capacity spots',
                        'updatedAt':
                            FieldValue
                                .serverTimestamp(),
                      });

                      if (!context.mounted) {
                        return;
                      }

                      Navigator.of(
                        dialogContext,
                      ).pop();

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Opportunity updated successfully.',
                          ),
                          backgroundColor:
                              AppColors.primary,
                        ),
                      );
                    } on FirebaseException catch (e) {
                      debugPrint(
                        'EDIT OPPORTUNITY ERROR: '
                        '${e.code} - ${e.message}',
                      );

                      if (!context.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Could not update opportunity: ${e.code}',
                          ),
                          backgroundColor:
                              Colors.red.shade700,
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Save Changes',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    capacityController.dispose();
  }

  Future<void> _confirmDelete(
    BuildContext context,
    QueryDocumentSnapshot<
        Map<String, dynamic>> document,
  ) async {
    final shouldDelete =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(24),
          ),
          title: const Text(
            'Delete opportunity?',
          ),
          content: const Text(
            'This will permanently remove the opportunity from your organization.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              style: TextButton.styleFrom(
                foregroundColor:
                    Colors.red.shade700,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('opportunities')
          .doc(document.id)
          .delete();

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Opportunity deleted.',
          ),
          backgroundColor:
              AppColors.primary,
        ),
      );
    } on FirebaseException catch (e) {
      debugPrint(
        'DELETE OPPORTUNITY ERROR: '
        '${e.code} - ${e.message}',
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not delete opportunity: ${e.code}',
          ),
          backgroundColor:
              Colors.red.shade700,
        ),
      );
    }
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({
    required this.category,
  });

  final String category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius:
            BorderRadius.circular(30),
      ),
      child: Text(
        category,
        style: AppTypography
            .textTheme
            .labelMedium
            ?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius:
            BorderRadius.circular(30),
      ),
      child: Text(
        status == 'published'
            ? 'Published'
            : status,
        style: AppTypography
            .textTheme
            .labelSmall
            ?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
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
          size: 19,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: AppTypography
                .textTheme
                .bodySmall
                ?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.eco_rounded,
                color: AppColors.primary,
                size: 42,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No opportunities yet',
              style: AppTypography
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first volunteer opportunity and start building your community.',
              textAlign: TextAlign.center,
              style: AppTypography
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.push(
                  '/organization/create-opportunity',
                );
              },
              icon: const Icon(
                Icons.add_rounded,
              ),
              label: const Text(
                'Create Opportunity',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: AppColors.textSecondary,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Could not load opportunities',
              style: AppTypography
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your connection and try again.',
              textAlign: TextAlign.center,
              style: AppTypography
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}