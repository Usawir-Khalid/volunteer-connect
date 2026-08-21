import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';

class FeaturedOpportunityCard extends StatelessWidget {
  const FeaturedOpportunityCard({
    super.key,
    required this.title,
    required this.organization,
    required this.location,
    required this.dateTime,
    required this.imageUrl,
    this.opportunityId = '1',
  });

  final String title;
  final String organization;
  final String location;
  final String dateTime;
  final String imageUrl;
  final String opportunityId;

  void _openOpportunity(BuildContext context) {
    context.push('/opportunity/$opportunityId');
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 340,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          AppRadius.card,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // --------------------------------------------------------------
            // BACKGROUND IMAGE
            // --------------------------------------------------------------
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return Container(
                  color: AppColors.primaryLight,
                  child: const Center(
                    child: Icon(
                      Icons.volunteer_activism_outlined,
                      size: 56,
                      color: AppColors.primary,
                    ),
                  ),
                );
              },
              loadingBuilder: (
                context,
                child,
                loadingProgress,
              ) {
                if (loadingProgress == null) {
                  return child;
                }

                return Container(
                  color: AppColors.primaryLight,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            ),

            // --------------------------------------------------------------
            // SUBTLE IMAGE OVERLAY
            // --------------------------------------------------------------
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [
                      0.0,
                      0.45,
                      1.0,
                    ],
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black54,
                    ],
                  ),
                ),
              ),
            ),

            // --------------------------------------------------------------
            // BOOKMARK
            // --------------------------------------------------------------
            Positioned(
              top: AppSpacing.md,
              right: AppSpacing.md,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(
                    alpha: 0.95,
                  ),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  tooltip: 'Save opportunity',
                  onPressed: () {
                    // Bookmark persistence will be connected later.
                  },
                  icon: const Icon(
                    Icons.bookmark_border_rounded,
                    color: AppColors.textPrimary,
                    size: 21,
                  ),
                ),
              ),
            ),

            // --------------------------------------------------------------
            // INFORMATION PANEL
            // --------------------------------------------------------------
            Positioned(
              left: AppSpacing.md,
              right: AppSpacing.md,
              bottom: AppSpacing.md,
              child: Container(
                padding: const EdgeInsets.all(
                  AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(
                    alpha: 0.96,
                  ),
                  borderRadius: BorderRadius.circular(
                    AppRadius.card,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: 0.10,
                      ),
                      blurRadius: 14,
                      offset: const Offset(
                        0,
                        4,
                      ),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Featured badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(
                          AppRadius.pill,
                        ),
                      ),
                      child: Text(
                        'FEATURED',
                        style: AppTypography
                            .textTheme
                            .labelMedium
                            ?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                      ),
                    ),

                    const SizedBox(
                      height: AppSpacing.sm,
                    ),

                    // Title
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),

                    const SizedBox(
                      height: AppSpacing.xs,
                    ),

                    // Organization
                    Text(
                      organization,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),

                    const SizedBox(
                      height: AppSpacing.sm,
                    ),

                    // Location
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 15,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(
                          width: AppSpacing.xs,
                        ),
                        Expanded(
                          child: Text(
                            location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                    ),

                    const SizedBox(
                      height: AppSpacing.xs,
                    ),

                    // Date
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(
                          width: AppSpacing.xs,
                        ),
                        Expanded(
                          child: Text(
                            dateTime,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                    ),

                    const SizedBox(
                      height: AppSpacing.md,
                    ),

                    // ------------------------------------------------------
                    // JOIN NOW
                    // ------------------------------------------------------
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          _openOpportunity(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.surface,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              AppRadius.input,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Text(
                              'Join Now',
                              style: AppTypography
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    color:
                                        AppColors.surface,
                                    fontWeight:
                                        FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(
                              width: AppSpacing.sm,
                            ),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
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