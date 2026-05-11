import 'package:flutter/material.dart';

import '../services/user_profile_service.dart';
import '../utils/app_paddings.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserProfileService _profileService = UserProfileService();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _bioController;

  Future<void> _loadBio() async {
    final user = _profileService.currentUser;

    if (user == null) return;

    final bio = await _profileService.getBio(user.uid);

    if (!mounted) return;

    _bioController.text = bio;
  }

  @override
  void initState() {
    super.initState();
    final user = _profileService.currentUser;

    _nameController = TextEditingController(
      text: user?.displayName ?? user?.email?.split('@').first ?? '',
    );

    _emailController = TextEditingController(
      text: user?.email ?? '',
    );

    _bioController = TextEditingController(text: '');

    _loadBio();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final user = _profileService.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to edit profile.')),
      );
      return;
    }

    try {
      await _profileService.updateProfile(
        userId: user.uid,
        displayName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        bio: _bioController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppPaddings.screen,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const CircleAvatar(radius: 42, backgroundColor: Colors.grey),
                const SizedBox(height: 24),
                CustomTextField(
                  controller: _nameController,
                  hintText: 'Name',
                  icon: Icons.person_outline,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Name is required'
                      : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _emailController,
                  hintText: 'Email',
                  icon: Icons.email_outlined,
                  readOnly: true,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _bioController,
                  hintText: 'Bio',
                  icon: Icons.info_outline,
                  maxLines: 3,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Bio is required'
                      : null,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryButton(text: 'Save', onPressed: _save),
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