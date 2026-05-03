import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/listings_provider.dart';
import '../providers/requests_provider.dart';
import '../utils/app_paddings.dart';
import '../utils/app_routes.dart';
import '../utils/app_text_styles.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;

      if (user != null) {
        context.read<ListingsProvider>().loadUserListings(user.uid);
        context.read<RequestsProvider>().loadRequests(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final listingsProvider = context.watch<ListingsProvider>();
    final requestsProvider = context.watch<RequestsProvider>();

    final firebaseUser = authProvider.user;

    final userName = firebaseUser?.displayName ??
        firebaseUser?.email?.split('@').first ??
        'User';

    final userEmail = firebaseUser?.email ?? 'No email';

    final userListings = listingsProvider.userListings;
    final incomingRequests = requestsProvider.incomingRequests;

    final firstActiveItem =
        userListings.isNotEmpty ? userListings.first.title : null;

    final firstIncomingRequest = incomingRequests.isNotEmpty
        ? 'Borrow request from ${incomingRequests.first.senderName}'
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: AppPaddings.screen,
          child: Column(
            children: [
              const CircleAvatar(
                radius: 42,
                backgroundColor: Colors.grey,
              ),
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
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.editProfile,
                ),
              ),

              ListTile(
                leading: const Icon(Icons.inventory_2_outlined),
                title: const Text('Items'),
                subtitle: firstActiveItem == null
                    ? null
                    : Text('Active: $firstActiveItem'),
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.myListings,
                ),
              ),

              ListTile(
                leading: const Icon(Icons.chat_bubble_outline),
                title: const Text('Requests'),
                subtitle: firstIncomingRequest == null
                    ? null
                    : Text(firstIncomingRequest),
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.requests,
                ),
              ),

              ListTile(
                leading: const Icon(Icons.favorite_border),
                title: const Text('Favorites'),
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.favorites,
                ),
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
      ),
    );
  }
}