import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/listings_provider.dart';
import '../utils/app_paddings.dart';
import '../utils/app_routes.dart';
import '../utils/app_text_styles.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/listing_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load listings when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ListingsProvider>().loadListings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth < 360 ? 16.0 : 20.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ShelfSwap'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<ListingsProvider>(
        builder: (context, listingsProvider, _) {
          final listings = listingsProvider.listings;
          final isLoading = listingsProvider.isLoading;

          return SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search listings...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Latest Listings', style: AppTextStyles.sectionTitle),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.myListings),
                        child: const Text('See all'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : listings.isEmpty
                            ? const Center(child: Text('No listings available'))
                            : ListView.builder(
                                itemCount: listings.length,
                                itemBuilder: (context, index) {
                                  final item = listings[index];
                                  return ListingCard(
                                    key: ValueKey(item.id),
                                    item: item,
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      AppRoutes.itemDetails,
                                      arguments: item,
                                    ),
                                  );
                                },
                              ),
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
