import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({
    super.key,
    required this.selectedCategory,
    required this.selectedLocation,
    required this.selectedDate,
    required this.selectedDistance,
    required this.onApply,
    required this.onClear,
  });

  final String selectedCategory;
  final String selectedLocation;
  final String selectedDate;
  final String selectedDistance;

  final Function(
    String category,
    String location,
    String date,
    String distance,
  ) onApply;

  final VoidCallback onClear;

  @override
  State<FilterBottomSheet> createState() =>
      _FilterBottomSheetState();
}

class _FilterBottomSheetState
    extends State<FilterBottomSheet> {
  late String _category;
  late String _location;
  late String _date;
  late String _distance;

  static const categories = [
    'All',
    'Environment',
    'Education',
    'Healthcare',
    'Community',
  ];

  static const locations = [
    'Any location',
    'Near me',
  ];

  static const dates = [
    'Any date',
    'This week',
    'This month',
  ];

  static const distances = [
    'Within 1 mile',
    'Within 5 miles',
    'Within 10 miles',
  ];

  @override
  void initState() {
    super.initState();

    _category = widget.selectedCategory;
    _location = widget.selectedLocation;
    _date = widget.selectedDate;
    _distance = widget.selectedDistance;
  }

  void _applyFilters() {
    widget.onApply(
      _category,
      _location,
      _date,
      _distance,
    );

    Navigator.pop(context);
  }

  void _clearFilters() {
    widget.onClear();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.large),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(
                        AppRadius.pill,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Filter Opportunities',
                            style: AppTypography
                                .textTheme.headlineMedium,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Refine your search to find the right fit.',
                            style: AppTypography
                                .textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close_rounded,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                _FilterSection(
                  title: 'Category',
                  options: categories,
                  selectedOption: _category,
                  onSelected: (value) {
                    setState(() {
                      _category = value;
                    });
                  },
                ),

                const SizedBox(height: AppSpacing.lg),

                _FilterSection(
                  title: 'Location',
                  options: locations,
                  selectedOption: _location,
                  onSelected: (value) {
                    setState(() {
                      _location = value;
                    });
                  },
                ),

                const SizedBox(height: AppSpacing.lg),

                _FilterSection(
                  title: 'Date',
                  options: dates,
                  selectedOption: _date,
                  onSelected: (value) {
                    setState(() {
                      _date = value;
                    });
                  },
                ),

                const SizedBox(height: AppSpacing.lg),

                _FilterSection(
                  title: 'Distance',
                  options: distances,
                  selectedOption: _distance,
                  onSelected: (value) {
                    setState(() {
                      _distance = value;
                    });
                  },
                ),

                const SizedBox(height: AppSpacing.xl),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _clearFilters,
                        child: const Text('Clear'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _applyFilters,
                        child: const Text('Show Results'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({
    required this.title,
    required this.options,
    required this.selectedOption,
    required this.onSelected,
  });

  final String title;
  final List<String> options;
  final String selectedOption;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),

        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: options.map((option) {
            final selected = option == selectedOption;

            return GestureDetector(
              onTap: () => onSelected(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primaryLight
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(
                    AppRadius.pill,
                  ),
                  border: Border.all(
                    color: selected
                        ? AppColors.primary
                        : AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (selected)
                      const Padding(
                        padding: EdgeInsets.only(
                          right: AppSpacing.xs,
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ),
                    Text(
                      option,
                      style: AppTypography
                          .textTheme.labelLarge
                          ?.copyWith(
                        color: selected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}