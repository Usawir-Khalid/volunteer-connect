import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../profile/models/profile_data.dart';
import '../models/opportunity.dart';
import 'opportunity_details_screen.dart';
import 'widgets/filter_bottom_sheet.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  late final List<Opportunity> _opportunities;

  final Set<String> _bookmarkedIds = <String>{};

  String _selectedCategory = 'All';
  String _selectedLocation = 'Any location';
  String _selectedDate = 'Any date';
  String _selectedDistance = 'Within 10 miles';

  @override
  void initState() {
    super.initState();

    _opportunities = Opportunity.mockOpportunities();

    _searchController.addListener(_onSearchChanged);
    ProfileData.instance.addListener(_onProfileChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();

    ProfileData.instance.removeListener(_onProfileChanged);

    super.dispose();
  }

  void _onSearchChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _onProfileChanged() {
    if (!mounted) return;
    setState(() {});
  }

  // ---------------------------------------------------------------------------
  // LOCATION
  // ---------------------------------------------------------------------------

  String get _location {
    final location = ProfileData.instance.location.trim();

    if (location.isEmpty) {
      return 'Your location';
    }

    return location;
  }

  // ---------------------------------------------------------------------------
  // FILTERING
  // ---------------------------------------------------------------------------

  List<Opportunity> get _filteredOpportunities {
    final query = _searchController.text.trim().toLowerCase();

    return _opportunities.where((opportunity) {
      // Search
      if (query.isNotEmpty) {
        final searchableText = [
          opportunity.title,
          opportunity.organization,
          opportunity.category,
          opportunity.location,
          opportunity.description,
        ].join(' ').toLowerCase();

        if (!searchableText.contains(query)) {
          return false;
        }
      }

      // Category
      if (_selectedCategory != 'All' &&
          opportunity.category != _selectedCategory) {
        return false;
      }

      // Distance
      if (_selectedDistance == 'Within 1 mile' &&
          opportunity.distance > 1) {
        return false;
      }

      if (_selectedDistance == 'Within 5 miles' &&
          opportunity.distance > 5) {
        return false;
      }

      if (_selectedDistance == 'Within 10 miles' &&
          opportunity.distance > 10) {
        return false;
      }

      // Location
      if (_selectedLocation == 'Near me' &&
          opportunity.distance > 10) {
        return false;
      }

      // Date
      final now = DateTime.now();

      if (_selectedDate == 'This week') {
        final endDate = now.add(
          const Duration(days: 7),
        );

        if (opportunity.dateTime.isAfter(endDate)) {
          return false;
        }
      }

      if (_selectedDate == 'This month') {
        final endDate = DateTime(
          now.year,
          now.month + 1,
          0,
          23,
          59,
          59,
        );

        if (opportunity.dateTime.isAfter(endDate)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  bool get _hasActiveFilters {
    return _selectedCategory != 'All' ||
        _selectedLocation != 'Any location' ||
        _selectedDate != 'Any date' ||
        _selectedDistance != 'Within 10 miles';
  }

  // ---------------------------------------------------------------------------
  // FILTERS
  // ---------------------------------------------------------------------------

  void _openFilters() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FilterBottomSheet(
          selectedCategory: _selectedCategory,
          selectedLocation: _selectedLocation,
          selectedDate: _selectedDate,
          selectedDistance: _selectedDistance,
          onApply: (
            category,
            location,
            date,
            distance,
          ) {
            setState(() {
              _selectedCategory = category;
              _selectedLocation = location;
              _selectedDate = date;
              _selectedDistance = distance;
            });
          },
          onClear: () {
            setState(() {
              _selectedCategory = 'All';
              _selectedLocation = 'Any location';
              _selectedDate = 'Any date';
              _selectedDistance = 'Within 10 miles';
            });
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // OPPORTUNITY
  // ---------------------------------------------------------------------------

  void _openOpportunity(Opportunity opportunity) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OpportunityDetailsScreen(
          opportunityId: opportunity.id,
        ),
      ),
    );
  }

  void _toggleBookmark(Opportunity opportunity) {
    setState(() {
      if (_bookmarkedIds.contains(opportunity.id)) {
        _bookmarkedIds.remove(opportunity.id);
      } else {
        _bookmarkedIds.add(opportunity.id);
      }
    });
  }

  // ---------------------------------------------------------------------------
  // CLEAR
  // ---------------------------------------------------------------------------

  void _clearEverything() {
    _searchController.clear();

    setState(() {
      _selectedCategory = 'All';
      _selectedLocation = 'Any location';
      _selectedDate = 'Any date';
      _selectedDistance = 'Within 10 miles';
    });
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final opportunities = _filteredOpportunities;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ----------------------------------------------------------------
              // HEADER
              // ----------------------------------------------------------------

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

              // ----------------------------------------------------------------
              // LOCATION
              // ----------------------------------------------------------------

              _LocationField(
                location: _location,
              ),

              const SizedBox(
                height: AppSpacing.md,
              ),

              // ----------------------------------------------------------------
              // SEARCH + FILTER
              // ----------------------------------------------------------------

              Row(
                children: [
                  Expanded(
                    child: _SearchField(
                      controller: _searchController,
                    ),
                  ),
                  const SizedBox(
                    width: AppSpacing.sm,
                  ),
                  _FilterButton(
                    active: _hasActiveFilters,
                    onPressed: _openFilters,
                  ),
                ],
              ),

              const SizedBox(
                height: AppSpacing.xl,
              ),

              // ----------------------------------------------------------------
              // CATEGORIES
              // ----------------------------------------------------------------

              Text(
                'Categories',
                style: AppTypography.textTheme.titleLarge,
              ),

              const SizedBox(
                height: AppSpacing.md,
              ),

              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _CategoryChip(
                    label: 'All',
                    selected: _selectedCategory == 'All',
                    onTap: () {
                      setState(() {
                        _selectedCategory = 'All';
                      });
                    },
                  ),
                  _CategoryChip(
                    label: 'Environment',
                    selected:
                        _selectedCategory == 'Environment',
                    onTap: () {
                      setState(() {
                        _selectedCategory = 'Environment';
                      });
                    },
                  ),
                  _CategoryChip(
                    label: 'Education',
                    selected:
                        _selectedCategory == 'Education',
                    onTap: () {
                      setState(() {
                        _selectedCategory = 'Education';
                      });
                    },
                  ),
                  _CategoryChip(
                    label: 'Healthcare',
                    selected:
                        _selectedCategory == 'Healthcare',
                    onTap: () {
                      setState(() {
                        _selectedCategory = 'Healthcare';
                      });
                    },
                  ),
                  _CategoryChip(
                    label: 'Community',
                    selected:
                        _selectedCategory == 'Community',
                    onTap: () {
                      setState(() {
                        _selectedCategory = 'Community';
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(
                height: AppSpacing.xl,
              ),

              // ----------------------------------------------------------------
              // RESULTS HEADER
              // ----------------------------------------------------------------

              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Volunteer opportunities',
                      style:
                          AppTypography.textTheme.titleLarge,
                    ),
                  ),
                  Text(
                    '${opportunities.length} found',
                    style: AppTypography
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                          color:
                              AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),

              const SizedBox(
                height: AppSpacing.md,
              ),

              // ----------------------------------------------------------------
              // RESULTS
              // ----------------------------------------------------------------

              if (opportunities.isEmpty)
                _EmptyState(
                  onClear: _clearEverything,
                )
              else
                Column(
                  children: opportunities.map(
                    (opportunity) {
                      return Padding(
                        padding:
                            const EdgeInsets.only(
                          bottom: AppSpacing.md,
                        ),
                        child: _ExploreOpportunityCard(
                          opportunity: opportunity,
                          isBookmarked:
                              _bookmarkedIds.contains(
                            opportunity.id,
                          ),
                          onBookmark: () {
                            _toggleBookmark(
                              opportunity,
                            );
                          },
                          onTap: () {
                            _openOpportunity(
                              opportunity,
                            );
                          },
                        ),
                      );
                    },
                  ).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// LOCATION FIELD
// =============================================================================

class _LocationField extends StatelessWidget {
  const _LocationField({
    required this.location,
  });

  final String location;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppRadius.input,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.location_on_outlined,
            color: AppColors.primary,
            size: 19,
          ),
          const SizedBox(
            width: AppSpacing.sm,
          ),
          Expanded(
            child: Text(
              location,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SEARCH FIELD
// =============================================================================

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppRadius.input,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: TextField(
        controller: controller,
        style: AppTypography.textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Search opportunities...',
          hintStyle: AppTypography
              .textTheme
              .bodyMedium
              ?.copyWith(
                color: AppColors.textMuted,
              ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 21,
            color: AppColors.textSecondary,
          ),
          suffixIcon: ValueListenableBuilder<
              TextEditingValue>(
            valueListenable: controller,
            builder: (
              context,
              value,
              child,
            ) {
              if (value.text.isEmpty) {
                return const SizedBox.shrink();
              }

              return IconButton(
                onPressed: controller.clear,
                icon: const Icon(
                  Icons.close_rounded,
                  size: 19,
                ),
              );
            },
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(
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

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.active,
    required this.onPressed,
  });

  final bool active;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: active
              ? AppColors.primaryLight
              : AppColors.surface,
          side: BorderSide(
            color: active
                ? AppColors.primary
                : AppColors.border,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppRadius.input,
            ),
          ),
        ),
        child: Icon(
          Icons.tune_rounded,
          color: active
              ? AppColors.primary
              : AppColors.textPrimary,
        ),
      ),
    );
  }
}

// =============================================================================
// CATEGORY CHIP
// =============================================================================

class _CategoryChip extends StatelessWidget {
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 160,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : AppColors.surface,
          borderRadius: BorderRadius.circular(
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
    required this.isBookmarked,
    required this.onBookmark,
    required this.onTap,
  });

  final Opportunity opportunity;
  final bool isBookmarked;
  final VoidCallback onBookmark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(
        AppRadius.card,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          AppRadius.card,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(
            AppSpacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
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
              // Top row
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.volunteer_activism_outlined,
                      color: AppColors.primary,
                      size: 28,
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
                          opportunity.title,
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
                          height: 4,
                        ),
                        Text(
                          opportunity.organization,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: AppTypography
                              .textTheme
                              .bodySmall,
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    onPressed: onBookmark,
                    visualDensity:
                        VisualDensity.compact,
                    icon: Icon(
                      isBookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: isBookmarked
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: AppSpacing.md,
              ),

              // Description
              if (opportunity.description
                  .trim()
                  .isNotEmpty)
                Text(
                  opportunity.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography
                      .textTheme
                      .bodyMedium,
                ),

              const SizedBox(
                height: AppSpacing.md,
              ),

              // Location
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 17,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  Expanded(
                    child: Text(
                      opportunity.location,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: AppTypography
                          .textTheme
                          .bodySmall,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 8,
              ),

              // Date
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(
                    width: 7,
                  ),
                  Text(
                    _formatDate(
                      opportunity.dateTime,
                    ),
                    style: AppTypography
                        .textTheme
                        .bodySmall,
                  ),
                  const SizedBox(
                    width: AppSpacing.md,
                  ),
                  const Icon(
                    Icons.access_time_rounded,
                    size: 17,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  Text(
                    _formatTime(
                      opportunity.dateTime,
                    ),
                    style: AppTypography
                        .textTheme
                        .bodySmall,
                  ),
                ],
              ),

              const SizedBox(
                height: AppSpacing.md,
              ),

              // Bottom row
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color:
                          AppColors.primaryLight,
                      borderRadius:
                          BorderRadius.circular(
                        AppRadius.pill,
                      ),
                    ),
                    child: Text(
                      opportunity.category,
                      style: AppTypography
                          .textTheme
                          .labelSmall
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
                    Icons.chevron_right_rounded,
                    color:
                        AppColors.textSecondary,
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
    final hour = date.hour % 12 == 0
        ? 12
        : date.hour % 12;

    final minute =
        date.minute.toString().padLeft(2, '0');

    final period = date.hour >= 12
        ? 'PM'
        : 'AM';

    return '$hour:$minute $period';
  }
}

// =============================================================================
// EMPTY STATE
// =============================================================================

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.onClear,
  });

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppRadius.card,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 32,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          Text(
            'No opportunities found',
            style:
                AppTypography.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(
            height: AppSpacing.xs,
          ),

          Text(
            'Try changing your search or filters.',
            style:
                AppTypography.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          OutlinedButton(
            onPressed: onClear,
            child: const Text(
              'Clear filters',
            ),
          ),
        ],
      ),
    );
  }
}