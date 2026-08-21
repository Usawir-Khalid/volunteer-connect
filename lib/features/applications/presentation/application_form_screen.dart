import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';

class ApplicationFormScreen extends StatelessWidget {
  const ApplicationFormScreen({
    super.key,
    required this.opportunityId,
  });

  final String opportunityId;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Apply'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Application Form',
              style: textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Opportunity ID: $opportunityId',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'The application form will be implemented after Opportunity Details.',
              style: textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}