import 'package:flutter/material.dart';
import '../models/listing_item.dart';
import '../utils/app_colors.dart';

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
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/placeholder_item.png',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
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
                      style: const TextStyle(fontWeight: FontWeight.w600),
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