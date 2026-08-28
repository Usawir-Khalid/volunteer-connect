import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../profile/models/profile_data.dart';
import '../models/opportunity.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  String _location = 'San Francisco, CA';
  String _selectedCategory = 'All';

  final Set<String> _bookmarkedIds = {};

  final List<String> _categories = const [
    'All',
    'Environment',
    'Education',
    'Healthcare',
    'Community',
    'Animals',
  ];

  bool _isLoading = true;
  String? _loadError;

  List<Opportunity> _allOpportunities = [];

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    _loadLocation();
    _loadOpportunities();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ===========================================================================
  // LOAD LOCATION
  // ===========================================================================

  Future<void> _loadLocation() async {
    await ProfileData.instance.loadCurrentUser();

    if (!mounted) return;

    setState(() {
      _location = ProfileData.instance.location;
    });
  }

  // ===========================================================================
  // LOAD OPPORTUNITIES
  //
  // IMPORTANT:
  // Explore intentionally combines:
  //
  // 1. Existing mock opportunities
  // 2. Real opportunities published to Firestore
  //
  // This allows the MVP to have useful discovery content while also
  // demonstrating the complete organization -> volunteer flow.
  // ===========================================================================

  Future<void> _loadOpportunities() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        if (!mounted) return;

        setState(() {
          _allOpportunities =
              Opportunity.mockOpportunities();
          _isLoading = false;
          _loadError = null;
        });

        return;
      }

      // -----------------------------------------------------------------------
      // START WITH MOCK DATA
      // -----------------------------------------------------------------------

      final mockOpportunities =
          Opportunity.mockOpportunities();

      // -----------------------------------------------------------------------
      // LOAD REAL FIRESTORE OPPORTUNITIES
      // -----------------------------------------------------------------------

      final snapshot = await _firestore
          .collection('opportunities')
          .get();

      final firestoreOpportunities =
          <Opportunity>[];

      for (final document in snapshot.docs) {
        try {
          final data = document.data();

          // -------------------------------------------------------------------
          // PUBLICATION STATUS
          // -------------------------------------------------------------------

          final status = _stringValue(
                data['status'],
              )
              ?.trim()
              .toLowerCase();

          if (status == 'draft' ||
              status == 'unpublished' ||
              status == 'archived') {
            continue;
          }

          // -------------------------------------------------------------------
          // DATE
          // -------------------------------------------------------------------

          final dateTime =
              _parseDateTime(data['dateTime']) ??
                  _parseDateTime(data['date']) ??
                  DateTime.now().add(
                    const Duration(days: 1),
                  );

          // -------------------------------------------------------------------
          // BASIC FIELDS
          // -------------------------------------------------------------------

          final title =
              _stringValue(
                    data['title'],
                  )?.trim() ??
                  'Volunteer Opportunity';

          final organization =
              _stringValue(
                    data['organization'],
                  )?.trim() ??
                  _stringValue(
                    data['organizationName'],
                  )?.trim() ??
                  'Local Organization';

          final location =
              _stringValue(
                    data['location'],
                  )?.trim() ??
                  'Location not specified';

          final category =
              _normalizeCategory(
            _stringValue(
                  data['category'],
                )?.trim() ??
                'Community',
          );

          final description =
              _stringValue(
                    data['description'],
                  )?.trim() ??
                  '';

          final imageUrl =
              _stringValue(
                    data['imageUrl'],
                  )?.trim() ??
                  '';

          final availability =
              _stringValue(
                    data['availability'],
                  )?.trim() ??
                  _availabilityFromData(
                    data,
                  );

          final distance =
              _doubleValue(
                    data['distance'],
                  ) ??
                  0.0;

          // -------------------------------------------------------------------
          // CREATE OPPORTUNITY MODEL
          // -------------------------------------------------------------------

          firestoreOpportunities.add(
            Opportunity(
              id: document.id,
              title: title,
              organization: organization,
              location: location,
              dateTime: dateTime,
              dateDisplay:
                  _formatDateForDisplay(
                dateTime,
              ),
              timeDisplay:
                  _formatTime(
                dateTime,
              ),
              distance: distance,
              category: category,
              description: description,
              availability: availability,
              imageUrl: imageUrl,
            ),
          );
        } catch (e) {
          // One malformed document should never prevent the remaining
          // opportunities from appearing.
          debugPrint(
            'Skipping invalid opportunity '
            '${document.id}: $e',
          );
        }
      }

      // -----------------------------------------------------------------------
      // MERGE REAL + MOCK DATA
      //
      // Firestore data gets priority if an ID somehow matches a mock ID.
      // -----------------------------------------------------------------------

      final opportunitiesById =
          <String, Opportunity>{};

      // Add mock opportunities first.
      for (final opportunity
          in mockOpportunities) {
        opportunitiesById[
                opportunity.id] =
            opportunity;
      }

      // Add Firestore opportunities second.
      // This means real data wins if there is an ID collision.
      for (final opportunity
          in firestoreOpportunities) {
        opportunitiesById[
                opportunity.id] =
            opportunity;
      }

      final opportunities =
          opportunitiesById.values.toList();

      // -----------------------------------------------------------------------
      // SORT EVERYTHING BY UPCOMING DATE
      // -----------------------------------------------------------------------

      opportunities.sort(
        (a, b) {
          return a.dateTime.compareTo(
            b.dateTime,
          );
        },
      );

      if (!mounted) return;

      setState(() {
        _allOpportunities =
            opportunities;
        _isLoading = false;
      });
    } on FirebaseException catch (e) {
      debugPrint(
        'Explore Firestore error: '
        '${e.code} - ${e.message}',
      );

      // -----------------------------------------------------------------------
      // IMPORTANT FALLBACK
      //
      // Even if Firestore temporarily fails, the mock opportunities should
      // still remain available in the MVP.
      // -----------------------------------------------------------------------

      if (!mounted) return;

      setState(() {
        _allOpportunities =
            Opportunity.mockOpportunities();
        _isLoading = false;
        _loadError =
            'Live opportunities could not be loaded. '
            'Showing available opportunities.';
      });
    } catch (e) {
      debugPrint(
        'Explore opportunities load error: $e',
      );

      if (!mounted) return;

      setState(() {
        _allOpportunities =
            Opportunity.mockOpportunities();
        _isLoading = false;
        _loadError =
            'Live opportunities could not be loaded. '
            'Showing available opportunities.';
      });
    }
  }

  // ===========================================================================
  // FIRESTORE VALUE HELPERS
  // ===========================================================================

  String? _stringValue(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is String) {
      return value;
    }

    return value.toString();
  }

  double? _doubleValue(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value);
    }

    return null;
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  String _availabilityFromData(
    Map<String, dynamic> data,
  ) {
    final spots =
        _doubleValue(data['spots']) ??
            _doubleValue(
              data['volunteersNeeded'],
            ) ??
            _doubleValue(
              data['maxVolunteers'],
            ) ??
            _doubleValue(
              data['capacity'],
            );

    if (spots != null) {
      return '${spots.toInt()} spots';
    }

    return 'Open';
  }

  String _normalizeCategory(
    String category,
  ) {
    final normalized =
        category.trim();

    if (normalized.isEmpty) {
      return 'Community';
    }

    switch (normalized.toLowerCase()) {
      case 'health':
      case 'healthcare':
      case 'medical':
        return 'Healthcare';

      case 'environment':
      case 'environmental':
        return 'Environment';

      case 'education':
        return 'Education';

      case 'animals':
      case 'animal':
        return 'Animals';

      case 'community':
        return 'Community';

      default:
        return normalized;
    }
  }

  // ===========================================================================
  // DATE / TIME FORMATTING
  // ===========================================================================

  String _formatDateForDisplay(
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

    final dayOfWeek =
        days[date.weekday - 1];

    final month =
        months[date.month - 1];

    return '$dayOfWeek, $month ${date.day}';
  }

  String _formatTime(
    DateTime date,
  ) {
    final hour = date.hour % 12 == 0
        ? 12
        : date.hour % 12;

    final minute = date.minute
        .toString()
        .padLeft(2, '0');

    final period =
        date.hour >= 12
            ? 'PM'
            : 'AM';

    return '$hour:$minute $period';
  }

  // ===========================================================================
  // FILTERED OPPORTUNITIES
  // ===========================================================================

  List<Opportunity>
      get _filteredOpportunities {
    final search =
        _searchController.text
            .trim()
            .toLowerCase();

    return _allOpportunities.where(
      (opportunity) {
        final matchesCategory =
            _selectedCategory ==
                    'All' ||
                opportunity.category ==
                    _selectedCategory;

        final matchesSearch =
            search.isEmpty ||
                opportunity.title
                    .toLowerCase()
                    .contains(search) ||
                opportunity.organization
                    .toLowerCase()
                    .contains(search) ||
                opportunity.category
                    .toLowerCase()
                    .contains(search) ||
                opportunity.location
                    .toLowerCase()
                    .contains(search) ||
                opportunity.description
                    .toLowerCase()
                    .contains(search);

        return matchesCategory &&
            matchesSearch;
      },
    ).toList();
  }

  // ===========================================================================
  // LOCATION PICKER
  // ===========================================================================

  Future<void>
      _showLocationPicker() async {
    final locations = [
      'San Francisco, CA',
      'New York, NY',
      'Lahore, Pakistan',
      'Dubai, UAE',
      'Any location',
    ];

    final selected =
        await showModalBottomSheet<String>(
      context: context,
      backgroundColor:
          AppColors.surface,
      isScrollControlled: true,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
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
                            .location_on_outlined,
                        color:
                            AppColors
                                .primary,
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Text(
                      'Select Location',
                      style: AppTypography
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: AppSpacing.xs,
                ),
                Text(
                  'Choose where you want to '
                  'discover volunteer '
                  'opportunities.',
                  style: AppTypography
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                    color: AppColors
                        .textSecondary,
                  ),
                ),
                const SizedBox(
                  height: AppSpacing.md,
                ),
                ...locations.map(
                  (location) {
                    final isSelected =
                        location ==
                            _location;

                    return ListTile(
                      contentPadding:
                          EdgeInsets.zero,
                      leading: Icon(
                        isSelected
                            ? Icons
                                .radio_button_checked_rounded
                            : Icons
                                .radio_button_off_rounded,
                        color: isSelected
                            ? AppColors
                                .primary
                            : AppColors
                                .textSecondary,
                      ),
                      title: Text(
                        location,
                        style: AppTypography
                            .textTheme
                            .bodyLarge
                            ?.copyWith(
                          fontWeight:
                              isSelected
                                  ? FontWeight
                                      .w600
                                  : FontWeight
                                      .w400,
                        ),
                      ),
                      trailing:
                          isSelected
                              ? const Icon(
                                  Icons
                                      .check_rounded,
                                  color:
                                      AppColors
                                          .primary,
                                )
                              : null,
                      onTap: () {
                        Navigator.pop(
                          context,
                          location,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected == null ||
        !mounted) {
      return;
    }

    final success =
        await ProfileData.instance
            .updateLocation(
      selected,
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        _location = selected;
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to save your location.',
          ),
        ),
      );
    }
  }

  // ===========================================================================
  // CATEGORY
  // ===========================================================================

  void _selectCategory(
    String category,
  ) {
    setState(() {
      _selectedCategory =
          category;
    });
  }

  // ===========================================================================
  // FILTERS
  // ===========================================================================

  Future<void> _showFilters() async {
    String selectedSort =
        'Recommended';

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor:
          AppColors.surface,
      isScrollControlled: true,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (
            context,
            setSheetState,
          ) {
            return SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Filters',
                          style: AppTypography
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            setSheetState(() {
                              selectedSort =
                                  'Recommended';
                            });
                          },
                          child:
                              const Text(
                            'Reset',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height:
                          AppSpacing.md,
                    ),
                    Text(
                      'Sort by',
                      style: AppTypography
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height:
                          AppSpacing.sm,
                    ),
                    RadioGroup<String>(
                      groupValue:
                          selectedSort,
                      onChanged:
                          (value) {
                        if (value ==
                            null) {
                          return;
                        }

                        setSheetState(() {
                          selectedSort =
                              value;
                        });
                      },
                      child:
                          const Column(
                        children: [
                          RadioListTile<
                              String>(
                            contentPadding:
                                EdgeInsets
                                    .zero,
                            value:
                                'Recommended',
                            title:
                                Text(
                              'Recommended',
                            ),
                          ),
                          RadioListTile<
                              String>(
                            contentPadding:
                                EdgeInsets
                                    .zero,
                            value:
                                'Nearest',
                            title:
                                Text(
                              'Nearest',
                            ),
                          ),
                          RadioListTile<
                              String>(
                            contentPadding:
                                EdgeInsets
                                    .zero,
                            value:
                                'Upcoming',
                            title:
                                Text(
                              'Upcoming',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height:
                          AppSpacing.md,
                    ),
                    SizedBox(
                      width:
                          double.infinity,
                      height: 50,
                      child:
                          ElevatedButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                          );
                        },
                        child:
                            const Text(
                          'Apply Filters',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ===========================================================================
  // BOOKMARK
  // ===========================================================================

  void _toggleBookmark(
    String opportunityId,
  ) {
    setState(() {
      if (_bookmarkedIds
          .contains(opportunityId)) {
        _bookmarkedIds.remove(
          opportunityId,
        );
      } else {
        _bookmarkedIds.add(
          opportunityId,
        );
      }
    });
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final opportunities =
        _filteredOpportunities;

    return Scaffold(
      backgroundColor:
          AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child:
                  RefreshIndicator(
                color:
                    AppColors.primary,
                onRefresh:
                    _loadOpportunities,
                child:
                    SingleChildScrollView(
                  physics:
                      const AlwaysScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.xl,
                  ),
                  child:
                      Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      // ========================================================
                      // HEADER
                      // ========================================================

                      Text(
                        'Explore',
                        style: AppTypography
                            .textTheme
                            .headlineMedium
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
                        'Find opportunities '
                        'that match your '
                        'interests.',
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
                        height:
                            AppSpacing.lg,
                      ),

                      // ========================================================
                      // LOCATION
                      // ========================================================

                      _LocationField(
                        location:
                            _location,
                        onTap:
                            _showLocationPicker,
                      ),

                      const SizedBox(
                        height:
                            AppSpacing.md,
                      ),

                      // ========================================================
                      // SEARCH
                      // ========================================================

                      Row(
                        children: [
                          Expanded(
                            child:
                                _SearchField(
                              controller:
                                  _searchController,
                            ),
                          ),
                          const SizedBox(
                            width:
                                AppSpacing.sm,
                          ),
                          _FilterButton(
                            onTap:
                                _showFilters,
                          ),
                        ],
                      ),

                      const SizedBox(
                        height:
                            AppSpacing.lg,
                      ),

                      // ========================================================
                      // CATEGORIES
                      // ========================================================

                      Text(
                        'Categories',
                        style: AppTypography
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),

                      const SizedBox(
                        height:
                            AppSpacing.sm,
                      ),

                      SizedBox(
                        height: 44,
                        child:
                            ListView.separated(
                          scrollDirection:
                              Axis.horizontal,
                          itemCount:
                              _categories
                                  .length,
                          separatorBuilder:
                              (
                            context,
                            index,
                          ) =>
                                  const SizedBox(
                            width:
                                AppSpacing.sm,
                          ),
                          itemBuilder:
                              (
                            context,
                            index,
                          ) {
                            final category =
                                _categories[
                                    index];

                            return _CategoryChip(
                              label:
                                  category,
                              selected:
                                  category ==
                                      _selectedCategory,
                              onTap: () {
                                _selectCategory(
                                  category,
                                );
                              },
                            );
                          },
                        ),
                      ),

                      const SizedBox(
                        height:
                            AppSpacing.xl,
                      ),

                      // ========================================================
                      // RESULTS HEADER
                      // ========================================================

                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .center,
                        children: [
                          Expanded(
                            child:
                                Text(
                              'Volunteer '
                              'opportunities',
                              style: AppTypography
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),
                          ),
                          if (!_isLoading)
                            Text(
                              '${opportunities.length} found',
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

                      const SizedBox(
                        height:
                            AppSpacing.md,
                      ),

                      // ========================================================
                      // FIRESTORE FALLBACK NOTICE
                      // ========================================================

                      if (!_isLoading &&
                          _loadError != null)
                        Padding(
                          padding:
                              const EdgeInsets
                                  .only(
                            bottom:
                                AppSpacing.md,
                          ),
                          child:
                              Container(
                            width:
                                double.infinity,
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal:
                                  AppSpacing.md,
                              vertical:
                                  AppSpacing.sm,
                            ),
                            decoration:
                                BoxDecoration(
                              color: AppColors
                                  .primaryLight
                                  .withValues(
                                alpha: 0.45,
                              ),
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                AppRadius
                                    .card,
                              ),
                            ),
                            child:
                                Row(
                              children: [
                                const Icon(
                                  Icons
                                      .info_outline_rounded,
                                  size: 18,
                                  color:
                                      AppColors
                                          .primary,
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  child:
                                      Text(
                                    _loadError!,
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
                                ),
                              ],
                            ),
                          ),
                        ),

                      // ========================================================
                      // LOADING
                      // ========================================================

                      if (_isLoading)
                        const _ExploreLoadingState()

                      // ========================================================
                      // EMPTY
                      // ========================================================

                      else if (opportunities
                          .isEmpty)
                        _EmptyExploreState(
                          onClear: () {
                            setState(() {
                              _selectedCategory =
                                  'All';
                              _searchController
                                  .clear();
                            });
                          },
                          hasActiveFilters:
                              _selectedCategory !=
                                      'All' ||
                                  _searchController
                                      .text
                                      .trim()
                                      .isNotEmpty,
                        )

                      // ========================================================
                      // RESULTS
                      // ========================================================

                      else
                        ...opportunities.map(
                          (
                            opportunity,
                          ) {
                            return Padding(
                              padding:
                                  const EdgeInsets
                                      .only(
                                bottom:
                                    AppSpacing.md,
                              ),
                              child:
                                  _ExploreOpportunityCard(
                                opportunity:
                                    opportunity,
                                bookmarked:
                                    _bookmarkedIds
                                        .contains(
                                  opportunity.id,
                                ),
                                onBookmark:
                                    () {
                                  _toggleBookmark(
                                    opportunity
                                        .id,
                                  );
                                },
                                onTap: () {
                                  context.push(
                                    '/opportunity/${opportunity.id}',
                                  );
                                },
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
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

class _ExploreLoadingState
    extends StatelessWidget {
  const _ExploreLoadingState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width:
              double.infinity,
          height: 180,
          decoration:
              BoxDecoration(
            gradient:
                LinearGradient(
              begin:
                  Alignment.topLeft,
              end:
                  Alignment.bottomRight,
              colors: [
                AppColors
                    .primaryLight
                    .withValues(
                  alpha: 0.55,
                ),
                AppColors.surface,
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
          child:
              const Center(
            child:
                CircularProgressIndicator(
              color:
                  AppColors.primary,
            ),
          ),
        ),
        const SizedBox(
          height:
              AppSpacing.md,
        ),
        Text(
          'Finding opportunities '
          'for you...',
          style: AppTypography
              .textTheme
              .bodyMedium
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
// LOCATION FIELD
// =============================================================================

class _LocationField
    extends StatelessWidget {
  const _LocationField({
    required this.location,
    required this.onTap,
  });

  final String location;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color:
          Colors.transparent,
      child:
          InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(
          AppRadius.input,
        ),
        child:
            Container(
          width:
              double.infinity,
          height: 48,
          padding:
              const EdgeInsets.symmetric(
            horizontal:
                AppSpacing.md,
          ),
          decoration:
              BoxDecoration(
            color:
                AppColors.surface,
            borderRadius:
                BorderRadius.circular(
              AppRadius.input,
            ),
            border:
                Border.all(
              color:
                  AppColors.border,
            ),
          ),
          child:
              Row(
            children: [
              const Icon(
                Icons
                    .location_on_outlined,
                color:
                    AppColors.primary,
                size: 21,
              ),
              const SizedBox(
                width:
                    AppSpacing.sm,
              ),
              Expanded(
                child:
                    Text(
                  location,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: AppTypography
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                    color:
                        AppColors
                            .textSecondary,
                  ),
                ),
              ),
              const Icon(
                Icons
                    .keyboard_arrow_down_rounded,
                color:
                    AppColors
                        .textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// SEARCH FIELD
// =============================================================================

class _SearchField
    extends StatelessWidget {
  const _SearchField({
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration:
          BoxDecoration(
        color:
            AppColors.surface,
        borderRadius:
            BorderRadius.circular(
          AppRadius.input,
        ),
        border:
            Border.all(
          color:
              AppColors.border,
        ),
      ),
      child:
          TextField(
        controller:
            controller,
        textInputAction:
            TextInputAction.search,
        decoration:
            InputDecoration(
          hintText:
              'Search opportunities...',
          prefixIcon:
              const Icon(
            Icons.search_rounded,
            color:
                AppColors
                    .textSecondary,
          ),
          suffixIcon:
              controller.text
                      .isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        controller.clear();
                      },
                      icon:
                          const Icon(
                        Icons
                            .close_rounded,
                      ),
                    )
                  : null,
          border:
              InputBorder.none,
          contentPadding:
              const EdgeInsets
                  .symmetric(
            horizontal:
                AppSpacing.md,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// FILTER BUTTON
// =============================================================================

class _FilterButton
    extends StatelessWidget {
  const _FilterButton({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color:
          AppColors.surface,
      borderRadius:
          BorderRadius.circular(
        AppRadius.input,
      ),
      child:
          InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(
          AppRadius.input,
        ),
        child:
            Container(
          width: 52,
          height: 52,
          decoration:
              BoxDecoration(
            borderRadius:
                BorderRadius.circular(
              AppRadius.input,
            ),
            border:
                Border.all(
              color:
                  AppColors.border,
            ),
          ),
          child:
              const Icon(
            Icons.tune_rounded,
            color:
                AppColors
                    .textPrimary,
            size: 21,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// CATEGORY CHIP
// =============================================================================

class _CategoryChip
    extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.primary
          : AppColors.surface,
      borderRadius:
          BorderRadius.circular(
        AppRadius.pill,
      ),
      child:
          InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(
          AppRadius.pill,
        ),
        child:
            Container(
          padding:
              const EdgeInsets
                  .symmetric(
            horizontal: 18,
            vertical: 10,
          ),
          decoration:
              BoxDecoration(
            borderRadius:
                BorderRadius.circular(
              AppRadius.pill,
            ),
            border:
                Border.all(
              color: selected
                  ? AppColors
                      .primary
                  : AppColors
                      .border,
            ),
          ),
          child:
              Text(
            label,
            style: AppTypography
                .textTheme
                .labelLarge
                ?.copyWith(
              color: selected
                  ? AppColors
                      .surface
                  : AppColors
                      .textPrimary,
              fontWeight: selected
                  ? FontWeight.w700
                  : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// OPPORTUNITY CARD
// =============================================================================

class _ExploreOpportunityCard
    extends StatelessWidget {
  const _ExploreOpportunityCard({
    required this.opportunity,
    required this.bookmarked,
    required this.onBookmark,
    required this.onTap,
  });

  final Opportunity opportunity;
  final bool bookmarked;
  final VoidCallback onBookmark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color:
          AppColors.surface,
      borderRadius:
          BorderRadius.circular(
        AppRadius.card,
      ),
      child:
          InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(
          AppRadius.card,
        ),
        child:
            Container(
          width:
              double.infinity,
          padding:
              const EdgeInsets.all(
            AppSpacing.md,
          ),
          decoration:
              BoxDecoration(
            borderRadius:
                BorderRadius.circular(
              AppRadius.card,
            ),
            border:
                Border.all(
              color:
                  AppColors.border,
            ),
            gradient:
                LinearGradient(
              begin:
                  Alignment.topLeft,
              end:
                  Alignment.bottomRight,
              colors: [
                AppColors.surface,
                AppColors
                    .primaryLight
                    .withValues(
                  alpha: 0.10,
                ),
              ],
            ),
          ),
          child:
              Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration:
                        BoxDecoration(
                      color:
                          AppColors
                              .primaryLight,
                      borderRadius:
                          BorderRadius
                              .circular(
                        14,
                      ),
                    ),
                    child:
                        const Icon(
                      Icons
                          .volunteer_activism_outlined,
                      color:
                          AppColors
                              .primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(
                    width:
                        AppSpacing.md,
                  ),
                  Expanded(
                    child:
                        Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          opportunity
                              .title,
                          maxLines:
                              2,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              AppTypography
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                            fontWeight:
                                FontWeight
                                    .w700,
                          ),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Text(
                          opportunity
                              .organization,
                          maxLines:
                              1,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              AppTypography
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
                  IconButton(
                    onPressed:
                        onBookmark,
                    visualDensity:
                        VisualDensity
                            .compact,
                    icon:
                        Icon(
                      bookmarked
                          ? Icons
                              .bookmark_rounded
                          : Icons
                              .bookmark_border_rounded,
                      color:
                          bookmarked
                              ? AppColors
                                  .primary
                              : AppColors
                                  .textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height:
                    AppSpacing.md,
              ),

              if (opportunity
                  .description
                  .trim()
                  .isNotEmpty)
                Text(
                  opportunity
                      .description,
                  maxLines: 2,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style:
                      AppTypography
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                    color:
                        AppColors
                            .textSecondary,
                    height: 1.4,
                  ),
                ),

              const SizedBox(
                height:
                    AppSpacing.md,
              ),

              Row(
                children: [
                  const Icon(
                    Icons
                        .location_on_outlined,
                    size: 18,
                    color:
                        AppColors
                            .textSecondary,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child:
                        Text(
                      opportunity
                          .location,
                      maxLines: 1,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          AppTypography
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                        color: AppColors
                            .textSecondary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height:
                    AppSpacing.xs,
              ),

              Row(
                children: [
                  const Icon(
                    Icons
                        .calendar_today_outlined,
                    size: 17,
                    color:
                        AppColors
                            .textSecondary,
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  Text(
                    _formatDate(
                      opportunity
                          .dateTime,
                    ),
                    style:
                        AppTypography
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                      color: AppColors
                          .textSecondary,
                    ),
                  ),
                  const SizedBox(
                    width:
                        AppSpacing.md,
                  ),
                  const Icon(
                    Icons
                        .access_time_rounded,
                    size: 18,
                    color:
                        AppColors
                            .textSecondary,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    _formatTime(
                      opportunity
                          .dateTime,
                    ),
                    style:
                        AppTypography
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                      color: AppColors
                          .textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height:
                    AppSpacing.md,
              ),

              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 13,
                      vertical: 8,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          AppColors
                              .primaryLight,
                      borderRadius:
                          BorderRadius
                              .circular(
                        AppRadius
                            .pill,
                      ),
                    ),
                    child:
                        Text(
                      opportunity
                          .category,
                      style:
                          AppTypography
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                        color:
                            AppColors
                                .primary,
                        fontWeight:
                            FontWeight
                                .w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (opportunity
                      .availability
                      .trim()
                      .isNotEmpty)
                    Text(
                      opportunity
                          .availability,
                      style:
                          AppTypography
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                        color: AppColors
                            .textSecondary,
                      ),
                    ),
                  const SizedBox(
                    width: 6,
                  ),
                  const Icon(
                    Icons
                        .chevron_right_rounded,
                    color:
                        AppColors
                            .textSecondary,
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

    return '${months[date.month - 1]} '
        '${date.day}, ${date.year}';
  }

  String _formatTime(
    DateTime date,
  ) {
    final hour =
        date.hour % 12 == 0
            ? 12
            : date.hour % 12;

    final minute =
        date.minute
            .toString()
            .padLeft(
          2,
          '0',
        );

    final period =
        date.hour >= 12
            ? 'PM'
            : 'AM';

    return '$hour:$minute $period';
  }
}

// =============================================================================
// EMPTY STATE
// =============================================================================

class _EmptyExploreState
    extends StatelessWidget {
  const _EmptyExploreState({
    required this.onClear,
    required this.hasActiveFilters,
  });

  final VoidCallback onClear;
  final bool hasActiveFilters;

  @override
  Widget build(BuildContext context) {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        AppSpacing.xl,
      ),
      decoration:
          BoxDecoration(
        gradient:
            LinearGradient(
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
          colors: [
            AppColors.primaryLight
                .withValues(
              alpha: 0.45,
            ),
            AppColors.surface,
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
      child:
          Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration:
                const BoxDecoration(
              color:
                  AppColors.primaryLight,
              shape:
                  BoxShape.circle,
            ),
            child:
                const Icon(
              Icons.search_off_rounded,
              color:
                  AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(
            height:
                AppSpacing.md,
          ),
          Text(
            hasActiveFilters
                ? 'Nothing found'
                : 'No opportunities yet',
            textAlign:
                TextAlign.center,
            style: AppTypography
                .textTheme
                .titleLarge
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
            hasActiveFilters
                ? 'Try changing your search '
                  'or category to discover '
                  'more opportunities.'
                : 'New volunteer opportunities '
                  'will appear here when '
                  'organizations publish them.',
            textAlign:
                TextAlign.center,
            style: AppTypography
                .textTheme
                .bodyMedium
                ?.copyWith(
              color:
                  AppColors
                      .textSecondary,
              height: 1.4,
            ),
          ),
          if (hasActiveFilters) ...[
            const SizedBox(
              height:
                  AppSpacing.lg,
            ),
            OutlinedButton(
              onPressed:
                  onClear,
              child:
                  const Text(
                'Clear Search & Filters',
              ),
            ),
          ],
        ],
      ),
    );
  }
}