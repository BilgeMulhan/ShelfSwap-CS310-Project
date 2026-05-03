import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/listing_item.dart';
import '../providers/listings_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_paddings.dart';
import '../utils/app_routes.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/listing_card.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  @override
  void initState() {
    super.initState();
    // Load user's listings when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.user;
      if (user != null) {
        context.read<ListingsProvider>().loadUserListings(user.uid);
      }
    });
  }

  Future<void> _deleteListing(String listingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Listing'),
        content: const Text('Are you sure you want to delete this listing?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await context.read<ListingsProvider>().deleteListing(listingId);
      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing deleted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete listing')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Listings')),
      body: SafeArea(
        child: Padding(
          padding: AppPaddings.screen,
          child: Consumer<ListingsProvider>(
            builder: (context, listingsProvider, child) {
              if (listingsProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final userListings = listingsProvider.userListings;

              if (userListings.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('No listings yet'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.addItem),
                        child: const Text('Add Your First Listing'),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.addItem),
                        child: const Text('+ Add New'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: userListings.length,
                      itemBuilder: (context, index) {
                        final item = userListings[index];
                        return ListingCard(
                          item: item,
                          trailingLabel: 'Edit',
                          onTrailingPressed: () => Navigator.pushNamed(context, AppRoutes.addItem),
                          showRemove: true,
                          onRemove: () => _deleteListing(item.id),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
