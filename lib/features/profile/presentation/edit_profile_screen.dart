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
  final _formKey = GlobalKey<FormState>();

  final ProfileData _profile = ProfileData.instance;

  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  late final TextEditingController _bioController;

  late Set<String> _selectedInterests;

  static const List<_InterestOption> _interests = [
    _InterestOption(
      name: 'Environment',
      icon: Icons.eco_outlined,
    ),
    _InterestOption(
      name: 'Education',
      icon: Icons.school_outlined,
    ),
    _InterestOption(
      name: 'Community',
      icon: Icons.groups_outlined,
    ),
    _InterestOption(
      name: 'Animals',
      icon: Icons.pets_outlined,
    ),
    _InterestOption(
      name: 'Healthcare',
      icon: Icons.health_and_safety_outlined,
    ),
    _InterestOption(
      name: 'Remote',
      icon: Icons.laptop_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: _profile.name,
    );

    _locationController = TextEditingController(
      text: _profile.location,
    );

    _bioController = TextEditingController(
      text: _profile.bio,
    );

    _selectedInterests =
        Set<String>.from(_profile.interests);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _bioController.dispose();

    super.dispose();
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        _selectedInterests.add(interest);
      }
    });
  }

  void _saveProfile() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    _profile.updateProfile(
      name: _nameController.text.trim(),
      location: _locationController.text.trim(),
      bio: _bioController.text.trim(),
      interests: _selectedInterests,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Profile updated successfully',
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _buildAvatar(),

                const SizedBox(
                  height: AppSpacing.xl,
                ),

                _buildSectionTitle(
                  'Personal Information',
                ),

                const SizedBox(
                  height: AppSpacing.md,
                ),

                _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hint: 'Enter your name',
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter your name';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: AppSpacing.md,
                ),

                _buildEmailField(),

                const SizedBox(
                  height: AppSpacing.md,
                ),

                _buildTextField(
                  controller: _locationController,
                  label: 'Location',
                  hint: 'Enter your location',
                  icon: Icons.location_on_outlined,
                ),

                const SizedBox(
                  height: AppSpacing.md,
                ),

                _buildTextField(
                  controller: _bioController,
                  label: 'About You',
                  hint:
                      'Tell organizations a little about you',
                  icon: Icons.edit_note_outlined,
                  maxLines: 4,
                  maxLength: 200,
                ),

                const SizedBox(
                  height: AppSpacing.xl,
                ),

                _buildSectionTitle(
                  'Your Interests',
                ),

                const SizedBox(
                  height: AppSpacing.xs,
                ),

                Text(
                  'Choose the causes you would like to '
                  'volunteer for.',
                  style:
                      AppTypography.textTheme.bodyMedium,
                ),

                const SizedBox(
                  height: AppSpacing.md,
                ),

                _buildInterestSelector(),

                const SizedBox(
                  height: AppSpacing.xl,
                ),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    child: const Text(
                      'Save Changes',
                    ),
                  ),
                ),

                const SizedBox(
                  height: AppSpacing.sm,
                ),

                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Cancel',
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

  Widget _buildAvatar() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(
                  alpha: 0.18,
                ),
                width: 3,
              ),
            ),
            child: const Icon(
              Icons.person_outline,
              size: 48,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(
            height: AppSpacing.sm,
          ),

          TextButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Profile photo selection will be added later.',
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.camera_alt_outlined,
              size: 18,
            ),
            label: const Text(
              'Change Photo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.textTheme.titleLarge,
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          'Email',
          style:
              AppTypography.textTheme.titleSmall,
        ),

        const SizedBox(
          height: AppSpacing.xs,
        ),

        TextFormField(
          initialValue: _profile.email,
          readOnly: true,
          decoration: InputDecoration(
            hintText: 'Your account email',
            prefixIcon: const Icon(
              Icons.email_outlined,
            ),
            suffixIcon: const Icon(
              Icons.lock_outline,
              size: 18,
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                AppRadius.input,
              ),
              borderSide: const BorderSide(
                color: AppColors.border,
              ),
            ),
            enabledBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                AppRadius.input,
              ),
              borderSide: const BorderSide(
                color: AppColors.border,
              ),
            ),
          ),
        ),

        const SizedBox(
          height: AppSpacing.xs,
        ),

        Text(
          'This is the email associated with your account.',
          style: AppTypography
              .textTheme
              .bodySmall,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
              AppTypography.textTheme.titleSmall,
        ),

        const SizedBox(
          height: AppSpacing.xs,
        ),

        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          maxLength: maxLength,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Padding(
              padding: EdgeInsets.only(
                bottom: maxLines > 1 ? 55 : 0,
              ),
              child: Icon(icon),
            ),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                AppRadius.input,
              ),
              borderSide: const BorderSide(
                color: AppColors.border,
              ),
            ),
            enabledBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                AppRadius.input,
              ),
              borderSide: const BorderSide(
                color: AppColors.border,
              ),
            ),
            focusedBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                AppRadius.input,
              ),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInterestSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppSpacing.md,
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
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: _interests.map(
          (interest) {
            final selected =
                _selectedInterests.contains(
              interest.name,
            );

            return InkWell(
              onTap: () {
                _toggleInterest(
                  interest.name,
                );
              },
              borderRadius:
                  BorderRadius.circular(
                AppRadius.pill,
              ),
              child: AnimatedContainer(
                duration: const Duration(
                  milliseconds: 180,
                ),
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary
                      : AppColors.primaryLight,
                  borderRadius:
                      BorderRadius.circular(
                    AppRadius.pill,
                  ),
                  border: Border.all(
                    color: selected
                        ? AppColors.primary
                        : AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Icon(
                      interest.icon,
                      size: 17,
                      color: selected
                          ? AppColors.white
                          : AppColors.primary,
                    ),

                    const SizedBox(
                      width: AppSpacing.xs,
                    ),

                    Text(
                      interest.name,
                      style: AppTypography
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                        color: selected
                            ? AppColors.white
                            : AppColors.primary,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ).toList(),
      ),
    );
  }
}

class _InterestOption {
  const _InterestOption({
    required this.name,
    required this.icon,
  });

  final String name;
  final IconData icon;
}