import 'package:flutter/material.dart';
import '../utils/app_paddings.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _bioController;
  Future<void> _loadBio() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        _bioController.text = data?['bio'] ?? '';
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;

    _nameController = TextEditingController(
      text: user?.displayName ?? user?.email?.split('@').first ?? '',
    );

    _emailController = TextEditingController(
      text: user?.email ?? '',
    );

    _bioController = TextEditingController(
      text: '',
    );

    _loadBio();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // update name
        await user.updateDisplayName(_nameController.text.trim());
        await user.reload();

        // save bio to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'bio': _bioController.text.trim(),
        }, SetOptions(merge: true));
      }

      if (!mounted) return;

      Navigator.pop(context);
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
                  validator: (value) => value == null || value.trim().isEmpty ? 'Name is required' : null,
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
                  validator: (value) => value == null || value.trim().isEmpty ? 'Bio is required' : null,
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
                    Expanded(child: PrimaryButton(text: 'Save', onPressed: _save)),
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