import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../profile/models/profile_data.dart';

class ApplicationFormScreen extends StatefulWidget {
  const ApplicationFormScreen({
    super.key,
    required this.opportunityId,
  });

  final String opportunityId;

  @override
  State<ApplicationFormScreen> createState() =>
      _ApplicationFormScreenState();
}

class _ApplicationFormScreenState
    extends State<ApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();

  bool _isLoading = true;
  bool _isSubmitting = false;

  Map<String, dynamic>? _opportunity;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      _nameController.text =
          ProfileData.instance.name.trim().isEmpty
              ? (user.displayName ?? '')
              : ProfileData.instance.name;

      _emailController.text =
          user.email ?? ProfileData.instance.email;
    }

    try {
      final document = await FirebaseFirestore.instance
          .collection('opportunities')
          .doc(widget.opportunityId)
          .get();

      if (!mounted) return;

      if (document.exists) {
        setState(() {
          _opportunity = document.data();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('APPLICATION LOAD ERROR: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitApplication() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage(
        'Please sign in before applying.',
        isError: true,
      );
      return;
    }

    if (_opportunity == null) {
      _showMessage(
        'This opportunity could not be found.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final firestore = FirebaseFirestore.instance;

      // ------------------------------------------------------------
      // Prevent duplicate applications
      // ------------------------------------------------------------

      final existing = await firestore
          .collection('applications')
          .where(
            'opportunityId',
            isEqualTo: widget.opportunityId,
          )
          .where(
            'volunteerId',
            isEqualTo: user.uid,
          )
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        if (!mounted) return;

        setState(() {
          _isSubmitting = false;
        });

        _showMessage(
          'You have already applied for this opportunity.',
          isError: true,
        );

        return;
      }

      // ------------------------------------------------------------
      // Opportunity information
      // ------------------------------------------------------------

      final organizationId =
          _opportunity!['organizationId'] as String? ?? '';

      final organization =
          _opportunity!['organization'] as String? ??
              'Organization';

      final opportunityTitle =
          _opportunity!['title'] as String? ??
              'Volunteer Opportunity';

      final category =
          _opportunity!['category'] as String? ??
              'Volunteer';

      final location =
          _opportunity!['location'] as String? ??
              'Location';

      final dateDisplay =
          _opportunity!['dateDisplay'] as String? ??
              'Date';

      final timeDisplay =
          _opportunity!['timeDisplay'] as String? ??
              'Time';

      // ------------------------------------------------------------
      // Create application
      // ------------------------------------------------------------

      final applicationDocument =
          firestore.collection('applications').doc();

      final applicationData = {
        'id': applicationDocument.id,

        // Opportunity
        'opportunityId': widget.opportunityId,
        'opportunityTitle': opportunityTitle,
        'organizationId': organizationId,
        'organization': organization,
        'category': category,
        'location': location,
        'dateDisplay': dateDisplay,
        'timeDisplay': timeDisplay,

        // Volunteer
        'volunteerId': user.uid,
        'volunteerName':
            _nameController.text.trim(),
        'volunteerEmail':
            _emailController.text.trim(),
        'phone':
            _phoneController.text.trim(),
        'message':
            _messageController.text.trim(),

        // Application state
        'status': 'pending',
        'submittedAt':
            FieldValue.serverTimestamp(),
        'updatedAt':
            FieldValue.serverTimestamp(),
      };

      await applicationDocument.set(applicationData);

      debugPrint(
        'APPLICATION CREATED: ${applicationDocument.id}',
      );

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      await _showSuccessDialog();

      if (!mounted) return;

      context.go('/home');
    } on FirebaseException catch (e) {
      debugPrint(
        'APPLICATION FIREBASE ERROR: '
        '${e.code} - ${e.message}',
      );

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      _showMessage(
        'Could not submit application: ${e.code}',
        isError: true,
      );
    } catch (e) {
      debugPrint(
        'APPLICATION SUBMIT ERROR: $e',
      );

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      _showMessage(
        'Something went wrong. Please try again.',
        isError: true,
      );
    }
  }

  Future<void> _showSuccessDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryLight,
                  Colors.white,
                ],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  bottom: -20,
                  child: Icon(
                    Icons.eco_rounded,
                    size: 110,
                    color: AppColors.primary.withValues(
                      alpha: 0.06,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 78,
                      height: 78,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary
                                .withValues(alpha: 0.10),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.volunteer_activism_rounded,
                        color: AppColors.primary,
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Application submitted! 🎉',
                      textAlign: TextAlign.center,
                      style: AppTypography
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Your application has been sent to the organization. You can track its status from Applications.',
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
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                        child: const Text('Done'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor:
              isError
                  ? Colors.red.shade700
                  : AppColors.primary,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    final opportunity = _opportunity;

    if (opportunity == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Apply'),
        ),
        body: const _EmptyApplicationState(),
      );
    }

    final title =
        opportunity['title'] as String? ??
            'Volunteer Opportunity';

    final organization =
        opportunity['organization'] as String? ??
            'Organization';

    final location =
        opportunity['location'] as String? ??
            'Location';

    final date =
        opportunity['dateDisplay'] as String? ??
            'Date';

    final time =
        opportunity['timeDisplay'] as String? ??
            'Time';

    final category =
        opportunity['category'] as String? ??
            'Volunteer';

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
        title: const Text('Apply Now'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            children: [
              _ApplicationHeroCard(
                title: title,
                organization: organization,
                category: category,
              ),

              const SizedBox(height: AppSpacing.lg),

              _OpportunitySummary(
                location: location,
                date: date,
                time: time,
              ),

              const SizedBox(height: AppSpacing.xl),

              Text(
                'Your application',
                style: AppTypography
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Tell the organization a little about yourself.',
                style: AppTypography
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              const _FieldLabel('Full Name'),

              const SizedBox(height: 8),

              _StyledField(
                controller: _nameController,
                hint: 'Your full name',
                icon: Icons.person_outline_rounded,
                textInputAction:
                    TextInputAction.next,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.md),

              const _FieldLabel('Email address'),

              const SizedBox(height: 8),

              _StyledField(
                controller: _emailController,
                hint: 'you@example.com',
                icon: Icons.email_outlined,
                keyboardType:
                    TextInputType.emailAddress,
                textInputAction:
                    TextInputAction.next,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Please enter your email';
                  }

                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }

                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.md),

              const _FieldLabel('Phone number'),

              const SizedBox(height: 8),

              _StyledField(
                controller: _phoneController,
                hint: 'Your phone number',
                icon: Icons.phone_outlined,
                keyboardType:
                    TextInputType.phone,
                textInputAction:
                    TextInputAction.next,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Please enter your phone number';
                  }

                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.md),

              const _FieldLabel(
                'Why do you want to volunteer?',
              ),

              const SizedBox(height: 8),

              _StyledField(
                controller: _messageController,
                hint:
                    'Tell the organization why you would like to help...',
                icon: Icons.edit_outlined,
                maxLines: 5,
                textInputAction:
                    TextInputAction.newline,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Please tell us why you want to volunteer';
                  }

                  if (value.trim().length < 10) {
                    return 'Please provide a little more detail';
                  }

                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.xl),

              Container(
                padding: const EdgeInsets.all(18),
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
                      BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.white,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.verified_outlined,
                      color: AppColors.primary,
                      size: 26,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your application will be sent directly to $organization.',
                        style: AppTypography
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                          color:
                              AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              SizedBox(
                height: 56,
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed:
                      _isSubmitting
                          ? null
                          : _submitApplication,
                  icon:
                      _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.send_rounded,
                            ),
                  label: Text(
                    _isSubmitting
                        ? 'Submitting...'
                        : 'Submit Application',
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'By submitting, you confirm that the information provided is accurate.',
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
      ),
    );
  }
}

class _ApplicationHeroCard extends StatelessWidget {
  const _ApplicationHeroCard({
    required this.title,
    required this.organization,
    required this.category,
  });

  final String title;
  final String organization;
  final String category;

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
            right: -16,
            bottom: -20,
            child: Icon(
              Icons.eco_rounded,
              size: 120,
              color: AppColors.primary.withValues(
                alpha: 0.07,
              ),
            ),
          ),
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
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
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: AppTypography
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                organization,
                style: AppTypography
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OpportunitySummary extends StatelessWidget {
  const _OpportunitySummary({
    required this.location,
    required this.date,
    required this.time,
  });

  final String location;
  final String date;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          _SummaryRow(
            icon: Icons.location_on_outlined,
            label: location,
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            icon: Icons.calendar_today_outlined,
            label: date,
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            icon: Icons.schedule_outlined,
            label: time,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTypography
                .textTheme
                .bodyMedium
                ?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography
          .textTheme
          .bodyMedium
          ?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _StyledField extends StatelessWidget {
  const _StyledField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Padding(
          padding: EdgeInsets.only(
            top: maxLines > 1 ? 14 : 0,
          ),
          child: Icon(icon),
        ),
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }
}

class _EmptyApplicationState
    extends StatelessWidget {
  const _EmptyApplicationState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.eco_rounded,
                color: AppColors.primary,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Opportunity unavailable',
              style: AppTypography
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We could not find this opportunity.',
              textAlign: TextAlign.center,
              style: AppTypography
                  .textTheme
                  .bodyMedium
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