import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../profile/models/profile_data.dart';

class CreateOpportunityScreen extends StatefulWidget {
  const CreateOpportunityScreen({super.key});

  @override
  State<CreateOpportunityScreen> createState() =>
      _CreateOpportunityScreenState();
}

class _CreateOpportunityScreenState
    extends State<CreateOpportunityScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _capacityController = TextEditingController();

  String _selectedCategory = 'Environment';

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  bool _isPublishing = false;

  final List<String> _categories = const [
    'Environment',
    'Education',
    'Community',
    'Healthcare',
    'Animals',
    'Other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          _selectedTime ?? const TimeOfDay(hour: 9, minute: 0),
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
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

  String _formatTime(TimeOfDay time) {
    final hour =
        time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;

    final minute =
        time.minute.toString().padLeft(2, '0');

    final period =
        time.period == DayPeriod.am ? 'AM' : 'PM';

    return '$hour:$minute $period';
  }

  DateTime _combineDateAndTime() {
    return DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
  }

  Future<void> _publishOpportunity() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      _showMessage(
        'Please select a date.',
        isError: true,
      );
      return;
    }

    if (_selectedTime == null) {
      _showMessage(
        'Please select a time.',
        isError: true,
      );
      return;
    }

    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage(
        'You are not signed in.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isPublishing = true;
    });

    try {
      final profile = ProfileData.instance;

      final eventDateTime =
          _combineDateAndTime();

      final capacity =
          int.tryParse(
        _capacityController.text.trim(),
      );

      final organizationName =
          profile.name.trim().isEmpty
              ? 'Organization'
              : profile.name.trim();

      final document =
          FirebaseFirestore.instance
              .collection('opportunities')
              .doc();

      final opportunityData = {
        'id': document.id,
        'title':
            _titleController.text.trim(),
        'organization':
            organizationName,
        'organizationId':
            user.uid,
        'location':
            _locationController.text.trim(),
        'dateTime':
            Timestamp.fromDate(eventDateTime),
        'dateDisplay':
            _formatDate(_selectedDate!),
        'timeDisplay':
            _formatTime(_selectedTime!),
        'category':
            _selectedCategory,
        'description':
            _descriptionController.text.trim(),
        'availability':
            '$capacity spots',
        'capacity':
            capacity,
        'imageUrl':
            '',
        'status':
            'published',
        'createdAt':
            FieldValue.serverTimestamp(),
        'updatedAt':
            FieldValue.serverTimestamp(),
      };

      debugPrint(
        'Publishing opportunity: $opportunityData',
      );

      await document.set(opportunityData);

      debugPrint(
        'Opportunity published successfully: ${document.id}',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isPublishing = false;
      });

      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(24),
            ),
            title: const Text(
              'Opportunity published 🎉',
            ),
            content: const Text(
              'Your opportunity has been published successfully and is now available to volunteers.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(
                    dialogContext,
                  ).pop();
                },
                child: const Text('Done'),
              ),
            ],
          );
        },
      );

      if (!mounted) {
        return;
      }

      context.go('/organization');
    } on FirebaseException catch (e) {
      debugPrint(
        'FIREBASE ERROR',
      );
      debugPrint(
        'Code: ${e.code}',
      );
      debugPrint(
        'Message: ${e.message}',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isPublishing = false;
      });

      _showMessage(
        'Firestore error: ${e.code}',
        isError: true,
      );
    } catch (e) {
      debugPrint(
        'CREATE OPPORTUNITY ERROR: $e',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isPublishing = false;
      });

      _showMessage(
        'Something went wrong. Check the debug console.',
        isError: true,
      );
    }
  }

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior:
            SnackBarBehavior.floating,
        duration:
            const Duration(seconds: 4),
        backgroundColor:
            isError
                ? Colors.red.shade700
                : AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.background,
      appBar: AppBar(
        backgroundColor:
            AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
          color:
              AppColors.textPrimary,
        ),
        title: Text(
          'Create Opportunity',
          style: AppTypography
              .textTheme
              .titleLarge
              ?.copyWith(
                fontWeight:
                    FontWeight.w800,
              ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _IntroCard(),

                const SizedBox(
                  height: AppSpacing.xl,
                ),

                Text(
                  'Opportunity details',
                  style: AppTypography
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        fontWeight:
                            FontWeight.w800,
                      ),
                ),

                const SizedBox(
                  height: AppSpacing.lg,
                ),

                _FieldLabel(
                  'Opportunity title',
                ),

                const SizedBox(
                  height: 8,
                ),

                _TextField(
                  controller:
                      _titleController,
                  hint:
                      'e.g. Community Clean-Up',
                  icon: Icons
                      .volunteer_activism_outlined,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter an opportunity title.';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: AppSpacing.lg,
                ),

                _FieldLabel('Category'),

                const SizedBox(
                  height: 8,
                ),

                DropdownButtonFormField<
                    String>(
                  initialValue:
                      _selectedCategory,
                  decoration:
                      _inputDecoration(
                    icon: Icons
                        .category_outlined,
                    hint:
                        'Select category',
                  ),
                  items:
                      _categories.map(
                    (category) {
                      return DropdownMenuItem<
                          String>(
                        value:
                            category,
                        child:
                            Text(category),
                      );
                    },
                  ).toList(),
                  onChanged:
                      (value) {
                    if (value ==
                        null) {
                      return;
                    }

                    setState(() {
                      _selectedCategory =
                          value;
                    });
                  },
                ),

                const SizedBox(
                  height: AppSpacing.lg,
                ),

                _FieldLabel(
                  'Description',
                ),

                const SizedBox(
                  height: 8,
                ),

                _TextField(
                  controller:
                      _descriptionController,
                  hint:
                      'Tell volunteers what they will be doing...',
                  icon: Icons
                      .description_outlined,
                  maxLines: 5,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please add a description.';
                    }

                    if (value.trim().length <
                        20) {
                      return 'Please provide a little more detail.';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: AppSpacing.lg,
                ),

                _FieldLabel(
                  'Location',
                ),

                const SizedBox(
                  height: 8,
                ),

                _TextField(
                  controller:
                      _locationController,
                  hint:
                      'e.g. Central Park',
                  icon: Icons
                      .location_on_outlined,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter a location.';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: AppSpacing.lg,
                ),

                _FieldLabel(
                  'Date & time',
                ),

                const SizedBox(
                  height: 8,
                ),

                Row(
                  children: [
                    Expanded(
                      child:
                          _PickerButton(
                        icon: Icons
                            .calendar_today_outlined,
                        label: _selectedDate ==
                                null
                            ? 'Select date'
                            : _formatDate(
                                _selectedDate!,
                              ),
                        onTap:
                            _selectDate,
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child:
                          _PickerButton(
                        icon: Icons
                            .schedule_outlined,
                        label: _selectedTime ==
                                null
                            ? 'Select time'
                            : _formatTime(
                                _selectedTime!,
                              ),
                        onTap:
                            _selectTime,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: AppSpacing.lg,
                ),

                _FieldLabel(
                  'Volunteer capacity',
                ),

                const SizedBox(
                  height: 8,
                ),

                _TextField(
                  controller:
                      _capacityController,
                  hint: 'e.g. 20',
                  icon: Icons
                      .people_outline,
                  keyboardType:
                      TextInputType.number,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter the volunteer capacity.';
                    }

                    final capacity =
                        int.tryParse(
                      value.trim(),
                    );

                    if (capacity ==
                            null ||
                        capacity <=
                            0) {
                      return 'Enter a valid number.';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: AppSpacing.xl,
                ),

                _PreviewCard(),

                const SizedBox(
                  height: AppSpacing.xl,
                ),

                SizedBox(
                  width:
                      double.infinity,
                  height: 56,
                  child:
                      ElevatedButton.icon(
                    onPressed:
                        _isPublishing
                            ? null
                            : _publishOpportunity,
                    icon:
                        _isPublishing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth:
                                      2,
                                  color:
                                      Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons
                                    .publish_rounded,
                              ),
                    label: Text(
                      _isPublishing
                          ? 'Publishing...'
                          : 'Publish Opportunity',
                    ),
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          AppColors.primary,
                      foregroundColor:
                          Colors.white,
                      disabledBackgroundColor:
                          AppColors.primary
                              .withValues(
                        alpha: 0.6,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          AppRadius.input,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                Center(
                  child: Text(
                    'Your opportunity will be visible to volunteers after publishing.',
                    textAlign:
                        TextAlign.center,
                    style: AppTypography
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
      ),
    );
  }

  InputDecoration _inputDecoration({
    required IconData icon,
    required String hint,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor:
          AppColors.surface,
      border:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          AppRadius.input,
        ),
        borderSide:
            const BorderSide(
          color:
              AppColors.border,
        ),
      ),
      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          AppRadius.input,
        ),
        borderSide:
            const BorderSide(
          color:
              AppColors.border,
        ),
      ),
      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          AppRadius.input,
        ),
        borderSide:
            const BorderSide(
          color:
              AppColors.primary,
          width: 1.5,
        ),
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(20),
      decoration:
          BoxDecoration(
        gradient:
            const LinearGradient(
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
          colors: [
            AppColors.primaryLight,
            Colors.white,
          ],
        ),
        borderRadius:
            BorderRadius.circular(
          24,
        ),
        border:
            Border.all(
          color:
              Colors.white,
          width: 1.5,
        ),
      ),
      child:
          Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration:
                const BoxDecoration(
              color:
                  Colors.white,
              shape:
                  BoxShape.circle,
            ),
            child:
                const Icon(
              Icons
                  .add_task_rounded,
              color:
                  AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(
            width: 16,
          ),
          Expanded(
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  'Create something meaningful.',
                  style: AppTypography
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        fontWeight:
                            FontWeight
                                .w800,
                      ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  'Give volunteers an opportunity to make an impact.',
                  style: AppTypography
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                        color: AppColors
                            .textSecondary,
                        height: 1.4,
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

class _FieldLabel
    extends StatelessWidget {
  const _FieldLabel(
    this.text,
  );

  final String text;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Text(
      text,
      style: AppTypography
          .textTheme
          .bodyMedium
          ?.copyWith(
            fontWeight:
                FontWeight.w700,
            color:
                AppColors.textPrimary,
          ),
    );
  }
}

class _TextField
    extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController
      controller;
  final String hint;
  final IconData icon;
  final int maxLines;
  final TextInputType?
      keyboardType;
  final String? Function(
      String?)? validator;

  @override
  Widget build(
    BuildContext context,
  ) {
    return TextFormField(
      controller:
          controller,
      maxLines:
          maxLines,
      keyboardType:
          keyboardType,
      validator:
          validator,
      decoration:
          InputDecoration(
        hintText:
            hint,
        prefixIcon:
            Padding(
          padding:
              EdgeInsets.only(
            top: maxLines >
                    1
                ? 14
                : 0,
          ),
          child:
              Icon(icon),
        ),
        filled:
            true,
        fillColor:
            AppColors.surface,
        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius
                  .circular(
            AppRadius
                .input,
          ),
          borderSide:
              const BorderSide(
            color:
                AppColors.border,
          ),
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius
                  .circular(
            AppRadius
                .input,
          ),
          borderSide:
              const BorderSide(
            color:
                AppColors.border,
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius
                  .circular(
            AppRadius
                .input,
          ),
          borderSide:
              const BorderSide(
            color:
                AppColors.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class _PickerButton
    extends StatelessWidget {
  const _PickerButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(
    BuildContext context,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(
        AppRadius.input,
      ),
      child:
          Container(
        height: 58,
        padding:
            const EdgeInsets
                .symmetric(
          horizontal: 12,
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
            Icon(
              icon,
              color:
                  AppColors.textSecondary,
              size: 21,
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child:
                  Text(
                label,
                overflow:
                    TextOverflow
                        .ellipsis,
                style: AppTypography
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      color: AppColors
                          .textSecondary,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewCard
    extends StatelessWidget {
  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(
        18,
      ),
      decoration:
          BoxDecoration(
        color:
            AppColors.primaryLight,
        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),
      child:
          Row(
        children: [
          const Icon(
            Icons
                .visibility_outlined,
            color:
                AppColors.primary,
          ),
          const SizedBox(
            width: 12,
          ),
          Expanded(
            child:
                Text(
              'Volunteers will see your opportunity in Explore and can apply directly.',
              style: AppTypography
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                    color: AppColors
                        .textSecondary,
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}