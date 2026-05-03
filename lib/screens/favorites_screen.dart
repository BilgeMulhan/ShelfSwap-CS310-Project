import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/listing_item.dart';
import '../providers/auth_provider.dart';
import '../providers/listings_provider.dart';
import '../utils/app_paddings.dart';
import '../widgets/listing_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;

      if (user != null) {
        final listingsProvider = context.read<ListingsProvider>();

        listingsProvider.loadListings();
        listingsProvider.loadFavorites(user.uid);
      }
    });
  }

  List<ListingItem> _filterFavorites(List<ListingItem> favorites) {
    final query = _searchQuery.toLowerCase().trim();

    if (query.isEmpty) return favorites;

    return favorites.where((item) {
      return item.title.toLowerCase().contains(query) ||
          item.description.toLowerCase().contains(query) ||
          item.category.toLowerCase().contains(query) ||
          item.condition.toLowerCase().contains(query) ||
          item.location.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppPaddings.screen,
          child: Consumer<ListingsProvider>(
            builder: (context, listingsProvider, child) {
              if (user == null) {
                return const Center(
                  child: Text('Please log in to see your favorites.'),
                );
              }

              if (listingsProvider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final favoriteItems =
                  _filterFavorites(listingsProvider.favoriteListings);

              return Column(
                children: [
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search items...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: favoriteItems.isEmpty
                        ? Center(
                            child: Text(
                              _searchQuery.trim().isEmpty
                                  ? 'No favorite items yet'
                                  : 'No matching favorite items found',
                            ),
                          )
                        : ListView.builder(
                            itemCount: favoriteItems.length,
                            itemBuilder: (context, index) {
                              final item = favoriteItems[index];

                              return ListingCard(
                                key: ValueKey(item.id),
                                item: item,
                                showFavorite: true,
                                isFavorite: true,
                                onFavoritePressed: () {
                                  listingsProvider.toggleFavorite(
                                    user.uid,
                                    item.id,
                                  );
                                },
                                showRemove: true,
                                onRemove: () {
                                  listingsProvider.toggleFavorite(
                                    user.uid,
                                    item.id,
                                  );
                                },
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