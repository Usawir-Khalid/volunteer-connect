import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../profile/models/profile_data.dart';
import 'widgets/category_chips.dart';
import 'widgets/featured_opportunity_card.dart';
import 'widgets/find_your_cause_card.dart';
import 'widgets/home_header.dart';
import 'widgets/impact_summary.dart';
import 'widgets/nearby_opportunity_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.onExplore,
  });

  final VoidCallback? onExplore;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProfileData _profile = ProfileData.instance;

  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();

    _profile.addListener(_onProfileChanged);
  }

  @override
  void dispose() {
    _profile.removeListener(_onProfileChanged);
    super.dispose();
  }

  void _onProfileChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  String get _userName {
    final name = _profile.name.trim();

    if (name.isEmpty || name == 'Volunteer') {
      return 'Volunteer';
    }

    return name;
  }

  String get _location {
    final location = _profile.location.trim();

    if (location.isEmpty) {
      return 'Your location';
    }

    return location;
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _openExplore() {
    widget.onExplore?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    // ------------------------------------------------------
                    // HEADER
                    // ------------------------------------------------------
                    HomeHeader(
                      userName: _userName,
                    ),

                    const SizedBox(
                      height: AppSpacing.lg,
                    ),

                    // ------------------------------------------------------
                    // LOCATION
                    // ------------------------------------------------------
                    Container(
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
                            size: 19,
                            color: AppColors.primary,
                          ),
                          const SizedBox(
                            width: AppSpacing.sm,
                          ),
                          Expanded(
                            child: Text(
                              _location,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: AppSpacing.sm,
                    ),

                    // ------------------------------------------------------
                    // SEARCH
                    // ------------------------------------------------------
                    Container(
                      height: 50,
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
                      child: TextField(
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
                            color: AppColors.textSecondary,
                            size: 21,
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 38,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: AppSpacing.xl,
                    ),

                    // ------------------------------------------------------
                    // FEATURED
                    // ------------------------------------------------------
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Featured for You',
                            style: AppTypography
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        TextButton(
                          onPressed: _openExplore,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'See all',
                            style: AppTypography
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: AppSpacing.md,
                    ),

                    const FeaturedOpportunityCard(
                      title: 'Community Clean-Up',
                      organization: 'Green Earth Alliance',
                      location: 'Central Park',
                      dateTime: 'Sat, Oct 24 • 9:00 AM',
                      imageUrl:
                          'https://images.unsplash.com/photo-1559027615-cd4628902d4a?w=1000',
                      opportunityId: '1',
                    ),

                    const SizedBox(
                      height: AppSpacing.xl,
                    ),

                    // ------------------------------------------------------
                    // CATEGORIES
                    // ------------------------------------------------------
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Explore by Category',
                            style: AppTypography
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        TextButton(
                          onPressed: _openExplore,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'View all',
                            style: AppTypography
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: AppSpacing.md,
                    ),

                    CategoryChips(
                      selectedCategory: _selectedCategory,
                      onCategorySelected: _onCategorySelected,
                    ),

                    const SizedBox(
                      height: AppSpacing.xl,
                    ),

                    // ------------------------------------------------------
                    // FIND YOUR CAUSE
                    // ------------------------------------------------------
                    FindYourCauseCard(
                      onExplore: _openExplore,
                    ),

                    const SizedBox(
                      height: AppSpacing.xl,
                    ),

                    // ------------------------------------------------------
                    // NEAR YOU
                    // ------------------------------------------------------
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Near You',
                            style: AppTypography
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        TextButton(
                          onPressed: _openExplore,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'See all',
                            style: AppTypography
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: AppSpacing.md,
                    ),

                    const NearbyOpportunityCard(
                      title: 'Tree Planting Initiative',
                      organization: 'Green Earth',
                      distance: '1.2 miles away',
                      category: 'Environment',
                      icon: Icons.eco_outlined,
                    ),

                    const SizedBox(
                      height: AppSpacing.sm,
                    ),

                    const NearbyOpportunityCard(
                      title: 'Food Bank Sorting',
                      organization: 'City Harvest',
                      distance: '2.5 miles away',
                      category: 'Food Security',
                      icon: Icons.volunteer_activism_outlined,
                    ),

                    const SizedBox(
                      height: AppSpacing.xl,
                    ),

                    // ------------------------------------------------------
                    // YOUR JOURNEY
                    // ------------------------------------------------------
                    Text(
                      'Your Journey',
                      style: AppTypography
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),

                    const SizedBox(
                      height: AppSpacing.md,
                    ),

                    const ImpactSummary(
                      opportunities: 12,
                      hours: 48,
                      events: 8,
                    ),

                    const SizedBox(
                      height: AppSpacing.xl,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}