import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  String _searchQuery = '';

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
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success =
          await context.read<ListingsProvider>().deleteListing(listingId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Listing deleted successfully'
                : 'Failed to delete listing',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings'),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppPaddings.screen,
          child: Consumer<ListingsProvider>(
            builder: (context, listingsProvider, child) {
              if (listingsProvider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final userListings = listingsProvider.userListings;

              final filteredListings = userListings.where((item) {
                final query = _searchQuery.toLowerCase().trim();

                if (query.isEmpty) return true;

                return item.title.toLowerCase().contains(query) ||
                    item.description.toLowerCase().contains(query) ||
                    item.category.toLowerCase().contains(query) ||
                    item.condition.toLowerCase().contains(query) ||
                    item.location.toLowerCase().contains(query);
              }).toList();

              if (userListings.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('No listings yet'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.addItem),
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
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.addItem),
                        child: const Text('+ Add New'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: filteredListings.isEmpty
                        ? const Center(
                            child: Text('No matching listings found'),
                          )
                        : ListView.builder(
                            itemCount: filteredListings.length,
                            itemBuilder: (context, index) {
                              final item = filteredListings[index];

                              return ListingCard(
                                key: ValueKey(item.id),
                                item: item,
                                trailingLabel: 'Edit',
                                onTrailingPressed: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.addItem,
                                  arguments: item,
                                ),
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