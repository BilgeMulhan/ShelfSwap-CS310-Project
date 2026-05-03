import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/listing_item.dart';
import '../models/request_item.dart';
import '../providers/listings_provider.dart';
import '../providers/requests_provider.dart';
import '../utils/app_paddings.dart';
import '../utils/app_text_styles.dart';
import '../widgets/primary_button.dart';

class ItemDetailsScreen extends StatefulWidget {
  final ListingItem? item;

  const ItemDetailsScreen({
    super.key,
    this.item,
  });

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isSendingRequest = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        context.read<ListingsProvider>().loadFavorites(currentUser.uid);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Widget _buildItemImage(
    String displayImage,
    double imageWidth,
    double imageHeight,
  ) {
    if (displayImage.startsWith('data:image')) {
      final base64String = displayImage.split(',').last;
      final bytes = base64Decode(base64String);

      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        width: imageWidth,
        height: imageHeight,
      );
    }

    if (displayImage.startsWith('http')) {
      return Image.network(
        displayImage,
        fit: BoxFit.cover,
        width: imageWidth,
        height: imageHeight,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: imageWidth,
            height: imageHeight,
            color: Colors.grey.shade200,
            child: const Icon(Icons.image_not_supported),
          );
        },
      );
    }

    return Image.asset(
      displayImage,
      fit: BoxFit.cover,
      width: imageWidth,
      height: imageHeight,
    );
  }

  Future<void> _sendSwapRequest(User currentUser, ListingItem item) async {
    setState(() {
      _isSendingRequest = true;
    });

    final request = RequestItem(
      id: '',
      senderId: currentUser.uid,
      senderEmail: currentUser.email ?? '',
      receiverId: item.userId,
      itemId: item.id,
      itemTitle: item.title,
      location: item.location,
      message: _messageController.text.trim(),
      status: 'pending',
      createdAt: DateTime.now(),
    );

    final success = await context.read<RequestsProvider>().createRequest(request);

    if (!mounted) return;

    setState(() {
      _isSendingRequest = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Swap request sent' : 'Failed to send request',
        ),
      ),
    );

    if (success) {
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final currentUser = FirebaseAuth.instance.currentUser;

    final imageWidth = screenWidth < 360 ? 100.0 : 120.0;
    final imageHeight = screenWidth < 360 ? 150.0 : 180.0;

    final item = widget.item;

    final displayImage = item?.imageUrl ?? 'assets/images/placeholder_item.png';
    final displayTitle = item?.title ?? 'Item Details';
    final displayCondition = item?.condition ?? 'Unknown';
    final displayLocation = item?.location ?? 'Unknown';
    final displayDescription = item?.description ?? 'No details available.';

    final isOwnItem =
        currentUser != null && item != null && currentUser.uid == item.userId;

    final canSendRequest =
        currentUser != null && item != null && currentUser.uid != item.userId;

    return Scaffold(
      appBar: AppBar(
        title: Text(displayTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppPaddings.screen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildItemImage(
                    displayImage,
                    imageWidth,
                    imageHeight,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Center(
                child: Text(
                  displayTitle,
                  style: AppTextStyles.title,
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 16),

              Text('Condition: $displayCondition'),
              const SizedBox(height: 8),
              Text('Location: $displayLocation'),
              const SizedBox(height: 12),

              const Text('Description:'),
              const SizedBox(height: 4),
              Text(displayDescription),

              const SizedBox(height: 20),

              if (currentUser != null && item != null)
                Consumer<ListingsProvider>(
                  builder: (context, listingsProvider, child) {
                    final isFavorite = listingsProvider.isFavorite(item.id);

                    return SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final success =
                              await listingsProvider.toggleFavorite(
                            currentUser.uid,
                            item.id,
                          );

                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? isFavorite
                                        ? 'Removed from favorites'
                                        : 'Added to favorites'
                                    : 'Failed to update favorites',
                              ),
                            ),
                          );
                        },
                        icon: Icon(
                          isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                        ),
                        label: Text(
                          isFavorite
                              ? 'Remove from Favorites'
                              : 'Add to Favorites',
                        ),
                      ),
                    );
                  },
                ),

              if (currentUser == null)
                const Center(
                  child: Text('Please log in to add favorites or send requests.'),
                ),

              if (isOwnItem)
                const Center(
                  child: Text('This is your own listing.'),
                ),

              if (canSendRequest) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _messageController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Optional message',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  text: _isSendingRequest
                      ? 'Sending...'
                      : 'Send Swap Request',
                  onPressed: () {
                    if (_isSendingRequest) return;
                    _sendSwapRequest(currentUser, item);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}