import 'package:flutter/material.dart';
import '../utils/app_paddings.dart';
import '../widgets/primary_button.dart';
import '../utils/app_text_styles.dart';
import '../models/listing_item.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ItemDetailsScreen extends StatelessWidget {
  final ListingItem? item;

  const ItemDetailsScreen({super.key, this.item});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final currentUser = FirebaseAuth.instance.currentUser;
    final imageWidth = screenWidth < 360 ? 100.0 : 120.0;
    final imageHeight = screenWidth < 360 ? 150.0 : 180.0;

    final displayImage = item?.imageUrl ?? 'assets/images/placeholder_item.png';
    final displayTitle = item?.title ?? 'Item Details';
    final displayCondition = item?.condition ?? 'Unknown';
    final displayLocation = item?.location ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(title: Text(displayTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppPaddings.screen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: displayImage.startsWith('http')
                    ? Image.network(
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
                      )
                    : Image.asset(
                        displayImage,
                        fit: BoxFit.cover,
                        width: imageWidth,
                        height: imageHeight,
                      ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  displayTitle,
                  style: AppTextStyles.title,
                ),
              ),
              const SizedBox(height: 16),
              Text('Condition: $displayCondition'),
              const SizedBox(height: 8),
              Text('Location: $displayLocation'),
              const SizedBox(height: 12),
              const Text('Description:'),
              const SizedBox(height: 4),
              Text(item != null ? 'Details about ${item!.title}.' : 'No details available.'),
              const SizedBox(height: 20),
              if (currentUser != null && item != null && currentUser.uid != item!.userId)
                PrimaryButton(
                  text: 'Send Swap Request',
                  onPressed: () {},
                ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {},
                child: const Text('Add to Favorites'),
              ),
              const SizedBox(height: 12),
              TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Optional message',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}