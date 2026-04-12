import 'package:flutter/material.dart';
import '../utils/app_paddings.dart';
import '../widgets/primary_button.dart';
import '../utils/app_text_styles.dart';

class ItemDetailsScreen extends StatelessWidget {
  const ItemDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageWidth = screenWidth < 360 ? 100.0 : 120.0;
    final imageHeight = screenWidth < 360 ? 150.0 : 180.0;
    return Scaffold(
      appBar: AppBar(title: const Text('Item Details')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppPaddings.screen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  'https://images.unsplash.com/photo-1544947950-fa07a98d237f',
                  width: imageWidth,
                  height: imageHeight,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Calculus Book',
                  style: AppTextStyles.title,
                ),
              ),
              const SizedBox(height: 16),
              const Text('Description:'),
              const SizedBox(height: 4),
              const Text('Introduction to Calculus - good condition.'),
              const SizedBox(height: 12),
              const Text('Owner: Ahmet Y.'),
              const SizedBox(height: 6),
              const Text('Location: Sabanci University'),
              const SizedBox(height: 20),
              PrimaryButton(text: 'Send Swap Request', onPressed: () {}),
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