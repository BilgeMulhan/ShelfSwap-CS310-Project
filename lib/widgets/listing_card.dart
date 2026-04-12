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

  const ListingCard({
    super.key,
    required this.item,
    this.onTap,
    this.onRemove,
    this.showRemove = false,
    this.trailingLabel,
    this.onTrailingPressed,
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
                child: Image.asset(
                  item.imageUrl,
                  width: imageSize,
                  height: imageSize,
                  fit: BoxFit.cover,
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
                    Text('Condition: ${item.condition}'),
                    Text('Location: ${item.location}'),
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}