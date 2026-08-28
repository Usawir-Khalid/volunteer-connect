import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../models/opportunity.dart';

class OpportunityDetailsScreen extends StatefulWidget {
  const OpportunityDetailsScreen({
    super.key,
    required this.opportunityId,
  });

  final String opportunityId;

  @override
  State<OpportunityDetailsScreen> createState() =>
      _OpportunityDetailsScreenState();
}

class _OpportunityDetailsScreenState
    extends State<OpportunityDetailsScreen> {
  bool _isBookmarked = false;

  late Future<Opportunity?> _opportunityFuture;

  @override
  void initState() {
    super.initState();
    _opportunityFuture = _loadOpportunity();
  }

  // ============================================================
  // LOAD OPPORTUNITY
  // ============================================================

  Future<Opportunity?> _loadOpportunity() async {
    // ----------------------------------------------------------
    // 1. First check Firestore.
    // ----------------------------------------------------------
    try {
      final document = await FirebaseFirestore.instance
          .collection('opportunities')
          .doc(widget.opportunityId)
          .get();

      if (document.exists && document.data() != null) {
        final data = document.data()!;

        final opportunity = _opportunityFromFirestore(
          document.id,
          data,
        );

        if (opportunity != null) {
          return opportunity;
        }
      }
    } catch (e) {
      debugPrint(
        'Error loading Firestore opportunity: $e',
      );
    }

    // ----------------------------------------------------------
    // 2. If not found in Firestore, check mock opportunities.
    // ----------------------------------------------------------
    final mockOpportunities =
        Opportunity.mockOpportunities();

    for (final opportunity in mockOpportunities) {
      if (opportunity.id == widget.opportunityId) {
        return opportunity;
      }
    }

    // ----------------------------------------------------------
    // 3. Nothing found.
    // ----------------------------------------------------------
    return null;
  }

  // ============================================================
  // FIRESTORE → OPPORTUNITY MODEL
  // ============================================================

  Opportunity? _opportunityFromFirestore(
    String documentId,
    Map<String, dynamic> data,
  ) {
    try {
      final rawDateTime = data['dateTime'];

      DateTime? dateTime;

      if (rawDateTime is Timestamp) {
        dateTime = rawDateTime.toDate();
      } else if (rawDateTime is DateTime) {
        dateTime = rawDateTime;
      } else if (rawDateTime is String) {
        dateTime = DateTime.tryParse(rawDateTime);
      }

      if (dateTime == null) {
        debugPrint(
          'Opportunity $documentId has no valid dateTime.',
        );
        return null;
      }

      final title =
          (data['title'] as String? ?? '').trim();

      final organization =
          (data['organization'] as String? ?? 'Organization')
              .trim();

      final location =
          (data['location'] as String? ?? '').trim();

      final category =
          (data['category'] as String? ?? 'Other').trim();

      final description =
          (data['description'] as String? ?? '').trim();

      final availability =
          (data['availability'] as String? ?? '').trim();

      final imageUrl =
          (data['imageUrl'] as String? ?? '').trim();

      final rawDistance = data['distance'];

      final distance = rawDistance is num
          ? rawDistance.toDouble()
          : 0.0;

      return Opportunity(
        id: documentId,
        title: title.isEmpty
            ? 'Volunteer Opportunity'
            : title,
        organization: organization.isEmpty
            ? 'Organization'
            : organization,
        location: location.isEmpty
            ? 'Location not specified'
            : location,
        dateTime: dateTime,
        dateDisplay:
            (data['dateDisplay'] as String?) ??
                _formatDateForDisplay(dateTime),
        timeDisplay:
            (data['timeDisplay'] as String?) ??
                _formatTime(dateTime),
        distance: distance,
        category: category.isEmpty
            ? 'Other'
            : category,
        description: description,
        availability: availability.isEmpty
            ? 'Spots available'
            : availability,
        imageUrl: imageUrl,
      );
    } catch (e) {
      debugPrint(
        'Error converting Firestore opportunity: $e',
      );
      return null;
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder<Opportunity?>(
          future: _opportunityFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return _buildLoadingState();
            }

            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data == null) {
              return _buildNotFoundState();
            }

            return _buildDetails(snapshot.data!);
          },
        ),
      ),
    );
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget _buildLoadingState() {
    return Column(
      children: [
        _buildTopBar(
          showBookmark: false,
        ),
        const Expanded(
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2.5,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // NOT FOUND
  // ============================================================

  Widget _buildNotFoundState() {
    return Column(
      children: [
        _buildTopBar(
          showBookmark: false,
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(
                AppSpacing.xl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.search_off_rounded,
                      color: AppColors.primary,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Opportunity not found',
                    style: AppTypography
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This opportunity may have been removed or is no longer available.',
                    textAlign: TextAlign.center,
                    style: AppTypography
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                          color:
                              AppColors.textSecondary,
                          height: 1.5,
                        ),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: () {
                      context.pop();
                    },
                    child: const Text(
                      'Go Back',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DETAILS
  // ============================================================

  Widget _buildDetails(
    Opportunity opportunity,
  ) {
    return Column(
      children: [
        _buildTopBar(
          showBookmark: true,
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // ------------------------------------------------
                // HERO
                // ------------------------------------------------
                _buildHeroCard(opportunity),

                const SizedBox(
                  height: AppSpacing.xl,
                ),

                // ------------------------------------------------
                // QUICK INFORMATION
                // ------------------------------------------------
                Text(
                  'Opportunity details',
                  style: AppTypography
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),

                const SizedBox(
                  height: AppSpacing.md,
                ),

                _InfoCard(
                  icon: Icons.location_on_outlined,
                  title: 'Location',
                  value: opportunity.location,
                ),

                const SizedBox(
                  height: AppSpacing.sm,
                ),

                _InfoCard(
                  icon: Icons.calendar_today_outlined,
                  title: 'Date',
                  value:
                      _formatDate(opportunity.dateTime),
                ),

                const SizedBox(
                  height: AppSpacing.sm,
                ),

                _InfoCard(
                  icon: Icons.access_time_rounded,
                  title: 'Time',
                  value:
                      _formatTime(opportunity.dateTime),
                ),

                const SizedBox(
                  height: AppSpacing.sm,
                ),

                _InfoCard(
                  icon: Icons.people_outline_rounded,
                  title: 'Volunteer spots',
                  value: opportunity.availability,
                ),

                if (opportunity.distance > 0) ...[
                  const SizedBox(
                    height: AppSpacing.sm,
                  ),
                  _InfoCard(
                    icon: Icons.near_me_outlined,
                    title: 'Distance',
                    value:
                        '${opportunity.distance.toStringAsFixed(1)} miles away',
                  ),
                ],

                const SizedBox(
                  height: AppSpacing.xl,
                ),

                // ------------------------------------------------
                // ABOUT
                // ------------------------------------------------
                Text(
                  'About this opportunity',
                  style: AppTypography
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),

                const SizedBox(
                  height: AppSpacing.md,
                ),

                _buildAboutCard(opportunity),

                const SizedBox(
                  height: AppSpacing.xl,
                ),

                // ------------------------------------------------
                // WHAT YOU'LL DO
                // ------------------------------------------------
                Text(
                  "What you'll do",
                  style: AppTypography
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),

                const SizedBox(
                  height: AppSpacing.md,
                ),

                const _BulletPoint(
                  text:
                      'Participate in the volunteer activity with the community.',
                ),

                const _BulletPoint(
                  text:
                      'Work together with other volunteers and organizers.',
                ),

                const _BulletPoint(
                  text:
                      'Contribute your time and skills toward a meaningful cause.',
                ),

                const _BulletPoint(
                  text:
                      'Help create a positive impact in the local community.',
                ),

                const SizedBox(
                  height: AppSpacing.xl,
                ),

                // ------------------------------------------------
                // ORGANIZATION
                // ------------------------------------------------
                Text(
                  'Organized by',
                  style: AppTypography
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),

                const SizedBox(
                  height: AppSpacing.md,
                ),

                _buildOrganizationCard(
                  opportunity,
                ),

                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),

        // --------------------------------------------------------
        // APPLY BUTTON
        // --------------------------------------------------------
        _buildApplyBar(opportunity),
      ],
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _buildTopBar({
    required bool showBookmark,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        8,
        6,
        8,
        4,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              context.pop();
            },
            icon: const Icon(
              Icons.arrow_back_rounded,
            ),
            color: AppColors.textPrimary,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'Opportunity Details',
              style: AppTypography
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          if (showBookmark)
            IconButton(
              onPressed: () {
                setState(() {
                  _isBookmarked =
                      !_isBookmarked;
                });
              },
              icon: Icon(
                _isBookmarked
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                color: _isBookmarked
                    ? AppColors.primary
                    : AppColors.textPrimary,
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // HERO CARD
  // ============================================================

  Widget _buildHeroCard(
    Opportunity opportunity,
  ) {
    return Container(
      width: double.infinity,
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
        borderRadius:
            BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary
                .withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative leaf.
          Positioned(
            right: -4,
            bottom: -8,
            child: Icon(
              Icons.eco_rounded,
              size: 88,
              color: AppColors.primary
                  .withValues(alpha: 0.08),
            ),
          ),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 66,
                    height: 66,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons
                          .volunteer_activism_rounded,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white
                          .withValues(alpha: 0.8),
                      borderRadius:
                          BorderRadius.circular(
                        AppRadius.pill,
                      ),
                    ),
                    child: Text(
                      opportunity.category,
                      style: AppTypography
                          .textTheme
                          .labelMedium
                          ?.copyWith(
                            color:
                                AppColors.primary,
                            fontWeight:
                                FontWeight.w800,
                          ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              Text(
                opportunity.title,
                style: AppTypography
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                      fontWeight:
                          FontWeight.w800,
                      height: 1.15,
                    ),
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  const Icon(
                    Icons.business_outlined,
                    size: 17,
                    color:
                        AppColors.textSecondary,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      opportunity.organization,
                      style: AppTypography
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            color: AppColors
                                .textSecondary,
                            fontWeight:
                                FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: Colors.white
                      .withValues(alpha: 0.72),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.people_alt_outlined,
                      size: 18,
                      color:
                          AppColors.primary,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      opportunity.availability,
                      style: AppTypography
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                            color:
                                AppColors.primary,
                            fontWeight:
                                FontWeight.w700,
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

  // ============================================================
  // ABOUT CARD
  // ============================================================

  Widget _buildAboutCard(
    Opportunity opportunity,
  ) {
    final description =
        opportunity.description.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
        description.isEmpty
            ? 'Join this volunteer opportunity and make a meaningful contribution to your community.'
            : description,
        style: AppTypography
            .textTheme
            .bodyMedium
            ?.copyWith(
              height: 1.6,
              color:
                  AppColors.textSecondary,
            ),
      ),
    );
  }

  // ============================================================
  // ORGANIZATION CARD
  // ============================================================

  Widget _buildOrganizationCard(
    Opportunity opportunity,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.business_rounded,
              color: AppColors.primary,
              size: 25,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  opportunity.organization,
                  style: AppTypography
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        fontWeight:
                            FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Volunteer organization',
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
          const Icon(
            Icons.verified_rounded,
            color: AppColors.primary,
            size: 22,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // APPLY BAR
  // ============================================================

  Widget _buildApplyBar(
    Opportunity opportunity,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        12,
        AppSpacing.lg,
        14,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: () {
            context.push(
              '/opportunity/${opportunity.id}/apply',
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor:
                AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                AppRadius.input,
              ),
            ),
          ),
          child: const Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Text(
                'Apply Now',
                style: TextStyle(
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
              SizedBox(width: 9),
              Icon(
                Icons.arrow_forward_rounded,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DATE / TIME HELPERS
  // ============================================================

  static String _formatDateForDisplay(
    DateTime date,
  ) {
    const days = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

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

    return '${days[date.weekday - 1]}, '
        '${months[date.month - 1]} ${date.day}';
  }

  static String _formatDate(
    DateTime date,
  ) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]} '
        '${date.day}, ${date.year}';
  }

  static String _formatTime(
    DateTime date,
  ) {
    final hour = date.hour % 12 == 0
        ? 12
        : date.hour % 12;

    final minute = date.minute
        .toString()
        .padLeft(2, '0');

    final period =
        date.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }
}

// =============================================================================
// INFO CARD
// =============================================================================

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
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
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius:
                  BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 21,
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
                  title,
                  style: AppTypography
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                        color: AppColors
                            .textSecondary,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style: AppTypography
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                        fontWeight:
                            FontWeight.w700,
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

// =============================================================================
// BULLET POINT
// =============================================================================

class _BulletPoint extends StatelessWidget {
  const _BulletPoint({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(
              top: 7,
            ),
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(
            width: AppSpacing.sm,
          ),
          Expanded(
            child: Text(
              text,
              style: AppTypography
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                    height: 1.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}