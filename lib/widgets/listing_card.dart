import 'dart:convert';

import 'package:flutter/material.dart';
import '../models/listing_item.dart';
import '../utils/app_colors.dart';
import '../utils/app_paddings.dart';
import '../utils/app_text_styles.dart';

class ListingCard extends StatelessWidget {
  final ListingItem item;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final bool showRemove;
  final String? trailingLabel;
  final VoidCallback? onTrailingPressed;
  final bool showFavorite;
  final bool isFavorite;
  final VoidCallback? onFavoritePressed;

  const ListingCard({
    super.key,
    required this.item,
    this.onTap,
    this.onRemove,
    this.showRemove = false,
    this.trailingLabel,
    this.onTrailingPressed,
    this.showFavorite = false,
    this.isFavorite = false,
    this.onFavoritePressed,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize = screenWidth * 0.16;

    return Card(
      color: Colors.white,
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: AppPaddings.card,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: item.imageUrl.startsWith('http')
                    ? Image.network(
                        item.imageUrl,
                        width: imageSize,
                        height: imageSize,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: imageSize,
                            height: imageSize,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image_not_supported),
                          );
                        },
                      )
                    : item.imageUrl.startsWith('data:image')
                        ? Image.memory(
                            base64Decode(item.imageUrl.split(',').last),
                            width: imageSize,
                            height: imageSize,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            item.imageUrl,
                            width: imageSize,
                            height: imageSize,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: imageSize,
                                height: imageSize,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image_not_supported),
                              );
                            },
                          ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: AppTextStyles.sectionTitle.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text('Condition: ${item.condition.isNotEmpty ? item.condition : 'Unknown'}'),
                    Text('Location: ${item.location.isNotEmpty ? item.location : 'Unknown'}'),
                  ],
                ),
              ),
              Column(
                children: [
                  if (trailingLabel != null)
                    OutlinedButton(
                      onPressed: onTrailingPressed,
                      child: Text(trailingLabel!),
                    ),
                  if (showRemove)
                    IconButton(
                      onPressed: onRemove,
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.danger,
                      ),
                    ),
                  if (showFavorite)
                    IconButton(
                      onPressed: onFavoritePressed,
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? AppColors.danger : Colors.grey,
                      ),
                    ),  
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
