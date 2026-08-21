import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';

class OpportunityDetailsScreen extends StatelessWidget {
  const OpportunityDetailsScreen({
    super.key,
    required this.opportunityId,
  });

  final String opportunityId;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Opportunity Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Opportunity',
              style: textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Opportunity ID: $opportunityId',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Opportunity details will be implemented in the next step.',
              style: textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}