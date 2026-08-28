import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingPage {
  const _OnboardingPage({
    required this.image,
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonLabel,
  });

  final String image;
  final IconData icon;
  final String title;
  final String description;
  final String buttonLabel;
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;

  int _currentPage = 0;

  static const List<_OnboardingPage> _pages = [
    _OnboardingPage(
      image:
          'assets/images/onboarding/onboarding_1_make_a_difference.png',
      icon: Icons.volunteer_activism_rounded,
      title: 'Make a Difference',
      description:
          'Discover meaningful volunteer opportunities around you and start your journey of impact.',
      buttonLabel: 'Continue',
    ),
    _OnboardingPage(
      image:
          'assets/images/onboarding/onboarding_2_find_what_matters.png',
      icon: Icons.explore_rounded,
      title: 'Find What Matters',
      description:
          'Discover opportunities that match your interests and passions.',
      buttonLabel: 'Continue',
    ),
    _OnboardingPage(
      image:
          'assets/images/onboarding/onboarding_3_turn_time_into_impact.png',
      icon: Icons.favorite_rounded,
      title: 'Turn Time Into Impact',
      description:
          'Every hour you give can help build a stronger, kinder and better community.',
      buttonLabel: 'Get Started',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _continue() {
    if (_currentPage == _pages.length - 1) {
      context.go('/login');
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  void _skip() {
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _OnboardingPageView(
                    page: _pages[index],
                    onSkip: _skip,
                  );
                },
              ),
            ),
            _BottomControls(
              currentPage: _currentPage,
              pages: _pages,
              onContinue: _continue,
              onSkip: _skip,
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageView extends StatelessWidget {
  const _OnboardingPageView({
    required this.page,
    required this.onSkip,
  });

  final _OnboardingPage page;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        0,
      ),
      child: Column(
        children: [
          Expanded(
            flex: 6,
            child: _IllustrationArea(
              image: page.image,
              onSkip: onSkip,
            ),
          ),
          const SizedBox(height: 10),
          _PageIcon(
            icon: page.icon,
          ),
          const SizedBox(height: 8),
          Text(
            page.title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 345,
            ),
            child: Text(
              page.description,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IllustrationArea extends StatelessWidget {
  const _IllustrationArea({
    required this.image,
    required this.onSkip,
  });

  final String image;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Main illustration.
            Positioned(
              left: 0,
              right: 0,
              top: 4,
              bottom: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(
                    AppRadius.card,
                  ),
                  border: Border.all(
                    color: AppColors.border.withValues(
                      alpha: 0.55,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textPrimary.withValues(
                        alpha: 0.035,
                      ),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    AppRadius.card,
                  ),
                  child: Image.asset(
                    image,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (
                      context,
                      error,
                      stackTrace,
                    ) {
                      return Container(
                        color: AppColors.surface,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          size: 42,
                          color: AppColors.textMuted,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Functional top-right Skip button.
            Positioned(
              top: 4,
              right: 0,
              child: _GlassSkipButton(
                onTap: onSkip,
              ),
            ),

            // Subtle glassmorphism accents.
            Positioned(
              left: width * 0.07,
              top: height * 0.12,
              child: const _GlassOrb(
                size: 28,
              ),
            ),

            Positioned(
              right: width * 0.08,
              top: height * 0.20,
              child: const _GlassOrb(
                size: 20,
              ),
            ),

            // Left decorative leaves.
            Positioned(
              left: -12,
              bottom: -8,
              child: const _LargeLeafCluster(
                flip: false,
              ),
            ),

            // Right decorative leaves.
            Positioned(
              right: -12,
              bottom: -8,
              child: const _LargeLeafCluster(
                flip: true,
              ),
            ),

            // Additional subtle glass accents.
            Positioned(
              left: width * 0.10,
              bottom: height * 0.05,
              child: const _GlassOrb(
                size: 18,
              ),
            ),

            Positioned(
              right: width * 0.11,
              bottom: height * 0.07,
              child: const _GlassOrb(
                size: 14,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GlassSkipButton extends StatelessWidget {
  const _GlassSkipButton({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(20),
        bottomLeft: Radius.circular(20),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 10,
          sigmaY: 10,
        ),
        child: Material(
          color: AppColors.white.withValues(
            alpha: 0.70,
          ),
          child: InkWell(
            onTap: onTap,
            child: Container(
              width: 72,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.white.withValues(
                    alpha: 0.50,
                  ),
                ),
              ),
              child: Text(
                'Skip',
                style: AppTypography.textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassOrb extends StatelessWidget {
  const _GlassOrb({
    required this.size,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 7,
          sigmaY: 7,
        ),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white.withValues(
              alpha: 0.18,
            ),
            border: Border.all(
              color: AppColors.white.withValues(
                alpha: 0.45,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LargeLeafCluster extends StatelessWidget {
  const _LargeLeafCluster({
    required this.flip,
  });

  final bool flip;

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.bottomCenter,
      transform: Matrix4.identity()
        ..scaleByDouble(
          flip ? -1.0 : 1.0,
          1.0,
          1.0,
          1.0,
        ),
      child: SizedBox(
        width: 92,
        height: 125,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Stem.
            Positioned(
              left: 43,
              bottom: 0,
              child: Container(
                width: 4,
                height: 105,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: 0.48,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            // Main leaf.
            Positioned(
              left: 20,
              bottom: 66,
              child: _DecorativeLeaf(
                width: 36,
                height: 22,
                rotation: -0.55,
              ),
            ),

            // Upper leaf.
            Positioned(
              left: 42,
              bottom: 86,
              child: _DecorativeLeaf(
                width: 42,
                height: 25,
                rotation: 0.20,
              ),
            ),

            // Middle leaf.
            Positioned(
              left: 47,
              bottom: 43,
              child: _DecorativeLeaf(
                width: 31,
                height: 19,
                rotation: 0.65,
              ),
            ),

            // Small lower leaf.
            Positioned(
              left: 14,
              bottom: 30,
              child: _DecorativeLeaf(
                width: 27,
                height: 17,
                rotation: -0.75,
              ),
            ),

            // Small tip leaf.
            Positioned(
              left: 48,
              bottom: 106,
              child: _DecorativeLeaf(
                width: 25,
                height: 15,
                rotation: 0.50,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DecorativeLeaf extends StatelessWidget {
  const _DecorativeLeaf({
    required this.width,
    required this.height,
    required this.rotation,
  });

  final double width;
  final double height;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withValues(
            alpha: 0.82,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(width),
            topRight: Radius.circular(width),
            bottomLeft: Radius.circular(height),
            bottomRight: Radius.circular(width * 0.25),
          ),
          border: Border.all(
            color: AppColors.primary.withValues(
              alpha: 0.20,
            ),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(
                alpha: 0.06,
              ),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageIcon extends StatelessWidget {
  const _PageIcon({
    required this.icon,
  });

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withValues(
            alpha: 0.12,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(
              alpha: 0.08,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: AppColors.primary,
        size: 24,
      ),
    );
  }
}

class _BottomControls extends StatelessWidget {
  const _BottomControls({
    required this.currentPage,
    required this.pages,
    required this.onContinue,
    required this.onSkip,
  });

  final int currentPage;
  final List<_OnboardingPage> pages;
  final VoidCallback onContinue;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        4,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Column(
        children: [
          // Page indicators.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              pages.length,
              (index) {
                final selected = index == currentPage;

                return AnimatedContainer(
                  duration: const Duration(
                    milliseconds: 220,
                  ),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 4,
                  ),
                  width: selected ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary
                        : AppColors.border,
                    borderRadius: BorderRadius.circular(
                      AppRadius.pill,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Main CTA.
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppRadius.pill,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    pages[currentPage].buttonLabel,
                    style: AppTypography.textTheme.titleMedium?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(
                    width: AppSpacing.sm,
                  ),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xs),

          // Bottom Skip.
          SizedBox(
            height: 34,
            child: TextButton(
              onPressed: onSkip,
              child: Text(
                'Skip',
                style: AppTypography.textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}