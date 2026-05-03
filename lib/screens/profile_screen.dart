import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_paddings.dart';
import '../utils/app_routes.dart';
import '../utils/app_text_styles.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final firebaseUser = authProvider.user;
          final userName = firebaseUser?.displayName ?? firebaseUser?.email?.split('@').first ?? 'User';
          final userEmail = firebaseUser?.email ?? 'No email';

          return SafeArea(
            child: Padding(
              padding: AppPaddings.screen,
              child: Column(
                children: [
                  const CircleAvatar(radius: 42, backgroundColor: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    userName,
                    style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 4),
                  Text(userEmail),
                  const SizedBox(height: 24),
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Edit Profile'),
                    onTap: () => Navigator.pushNamed(context, AppRoutes.editProfile),
                  ),
                  ListTile(
                    leading: const Icon(Icons.inventory_2_outlined),
                    title: const Text('Items'),
                    subtitle: const Text('Active: Vintage Lamp'),
                    onTap: () => Navigator.pushNamed(context, AppRoutes.myListings),
                  ),
                  ListTile(
                    leading: const Icon(Icons.chat_bubble_outline),
                    title: const Text('Requests'),
                    subtitle: const Text('Borrow request from Ahmet'),
                    onTap: () => Navigator.pushNamed(context, AppRoutes.requests),
                  ),
                  ListTile(
                    leading: const Icon(Icons.favorite_border),
                    title: const Text('Favorites'),
                    onTap: () => Navigator.pushNamed(context, AppRoutes.favorites),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Logout'),
                    onTap: () {
                      authProvider.signOut();
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.signIn,
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}