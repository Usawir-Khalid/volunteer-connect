import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../models/profile_data.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  late final TextEditingController _bioController;

  bool _isSaving = false;

  final List<String> _availableInterests = const [
    'Environment',
    'Education',
    'Community',
    'Animals',
    'Healthcare',
    'Remote',
    'Youth',
    'Senior Support',
  ];

  late Set<String> _selectedInterests;

  @override
  void initState() {
    super.initState();

    final profile =
        ProfileData.instance;

    _nameController =
        TextEditingController(
      text: profile.name,
    );

    _locationController =
        TextEditingController(
      text: profile.location,
    );

    _bioController =
        TextEditingController(
      text: profile.bio,
    );

    _selectedInterests =
        Set<String>.from(
      profile.interests,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _bioController.dispose();

    super.dispose();
  }

  Future<void> _saveProfile() async {
    final name =
        _nameController.text.trim();

    final location =
        _locationController.text.trim();

    final bio =
        _bioController.text.trim();

    if (name.isEmpty) {
      _showMessage(
        'Please enter your name.',
      );
      return;
    }

    if (location.isEmpty) {
      _showMessage(
        'Please select your location.',
      );
      return;
    }

    if (_selectedInterests.isEmpty) {
      _showMessage(
        'Please select at least one interest.',
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final success =
        await ProfileData.instance
            .updateProfile(
      name: name,
      location: location,
      bio: bio,
      interests:
          _selectedInterests,
    );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Profile updated successfully.',
          ),
        ),
      );

      Navigator.of(context).pop();
    } else {
      _showMessage(
        'Unable to save your profile. Please try again.',
      );
    }
  }

  void _showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<void> _showLocationPicker() async {
    const locations = [
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
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.all(
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Location',
                  style: AppTypography
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                const SizedBox(
                  height: AppSpacing.md,
                ),
                ...locations.map(
                  (location) {
                    final selected =
                        location ==
                            _locationController
                                .text;

                    return ListTile(
                      contentPadding:
                          EdgeInsets.zero,
                      leading: Icon(
                        selected
                            ? Icons
                                .radio_button_checked
                            : Icons
                                .radio_button_off,
                        color: selected
                            ? AppColors.primary
                            : AppColors
                                .textSecondary,
                      ),
                      title:
                          Text(location),
                      onTap: () {
                        Navigator.pop(
                          sheetContext,
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

    setState(() {
      _locationController.text =
          selected;
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile =
        ProfileData.instance;

    return Scaffold(
      backgroundColor:
          AppColors.background,
      appBar: AppBar(
        title:
            const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: AppTypography
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                fontWeight:
                    FontWeight.w700,
              ),
            ),

            const SizedBox(
              height: AppSpacing.lg,
            ),

            _FieldLabel(
              label: 'Name',
            ),

            const SizedBox(
              height: AppSpacing.xs,
            ),

            TextField(
              controller:
                  _nameController,
              textInputAction:
                  TextInputAction.next,
              decoration:
                  const InputDecoration(
                prefixIcon: Icon(
                  Icons
                      .person_outline_rounded,
                ),
                hintText:
                    'Enter your name',
              ),
            ),

            const SizedBox(
              height: AppSpacing.md,
            ),

            _FieldLabel(
              label: 'Email',
            ),

            const SizedBox(
              height: AppSpacing.xs,
            ),

            TextField(
              readOnly: true,
              controller:
                  TextEditingController(
                text: profile.email,
              ),
              decoration:
                  const InputDecoration(
                prefixIcon: Icon(
                  Icons
                      .email_outlined,
                ),
              ),
            ),

            const SizedBox(
              height: AppSpacing.md,
            ),

            _FieldLabel(
              label: 'Location',
            ),

            const SizedBox(
              height: AppSpacing.xs,
            ),

            TextField(
              readOnly: true,
              controller:
                  _locationController,
              onTap:
                  _showLocationPicker,
              decoration:
                  InputDecoration(
                prefixIcon:
                    const Icon(
                  Icons
                      .location_on_outlined,
                ),
                suffixIcon:
                    const Icon(
                  Icons
                      .keyboard_arrow_down_rounded,
                ),
                hintText:
                    'Select location',
              ),
            ),

            const SizedBox(
              height: AppSpacing.xl,
            ),

            Text(
              'About You',
              style: AppTypography
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                fontWeight:
                    FontWeight.w700,
              ),
            ),

            const SizedBox(
              height: AppSpacing.md,
            ),

            _FieldLabel(
              label: 'Bio',
            ),

            const SizedBox(
              height: AppSpacing.xs,
            ),

            TextField(
              controller:
                  _bioController,
              minLines: 3,
              maxLines: 5,
              decoration:
                  const InputDecoration(
                hintText:
                    'Tell organizations a little about yourself',
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(
              height: AppSpacing.xl,
            ),

            Text(
              'Your Interests',
              style: AppTypography
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                fontWeight:
                    FontWeight.w700,
              ),
            ),

            const SizedBox(
              height: AppSpacing.xs,
            ),

            Text(
              'Select the causes you care about.',
              style: AppTypography
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                color:
                    AppColors.textSecondary,
              ),
            ),

            const SizedBox(
              height: AppSpacing.md,
            ),

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(
                AppSpacing.md,
              ),
              decoration:
                  BoxDecoration(
                color:
                    AppColors.surface,
                borderRadius:
                    BorderRadius.circular(
                  AppRadius.card,
                ),
                border:
                    Border.all(
                  color:
                      AppColors.border,
                ),
              ),
              child: Wrap(
                spacing:
                    AppSpacing.sm,
                runSpacing:
                    AppSpacing.sm,
                children:
                    _availableInterests
                        .map(
                  (interest) {
                    final selected =
                        _selectedInterests
                            .contains(
                      interest,
                    );

                    return FilterChip(
                      label:
                          Text(interest),
                      selected:
                          selected,
                      onSelected:
                          (value) {
                        setState(() {
                          if (value) {
                            _selectedInterests
                                .add(
                              interest,
                            );
                          } else {
                            _selectedInterests
                                .remove(
                              interest,
                            );
                          }
                        });
                      },
                      selectedColor:
                          AppColors
                              .primaryLight,
                      checkmarkColor:
                          AppColors.primary,
                      labelStyle:
                          AppTypography
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                            color: selected
                                ? AppColors
                                    .primary
                                : AppColors
                                    .textPrimary,
                            fontWeight:
                                selected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                          ),
                      side: BorderSide(
                        color: selected
                            ? AppColors
                                .primary
                            : AppColors.border,
                      ),
                    );
                  },
                ).toList(),
              ),
            ),

            const SizedBox(
              height: AppSpacing.xl,
            ),

            SizedBox(
              width: double.infinity,
              height: 52,
              child:
                  ElevatedButton(
                onPressed:
                    _isSaving
                        ? null
                        : _saveProfile,
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Save Changes',
                      ),
              ),
            ),

            const SizedBox(
              height: AppSpacing.lg,
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel
    extends StatelessWidget {
  const _FieldLabel({
    required this.label,
  });

  final String label;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Text(
      label,
      style: AppTypography
          .textTheme
          .labelLarge
          ?.copyWith(
        fontWeight:
            FontWeight.w600,
      ),
    );
  }
}