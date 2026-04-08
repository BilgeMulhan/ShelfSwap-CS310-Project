import 'package:flutter/material.dart';
import '../utils/app_paddings.dart';
import '../utils/app_routes.dart';
import '../widgets/primary_button.dart';

class PreviewScreen extends StatelessWidget {
  const PreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppPaddings.screen,
          child: Column(
            children: [
              Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Center(child: Text('Image')),
              ),
              const SizedBox(height: 16),
              const Text('Calculus Book', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              const Align(alignment: Alignment.centerLeft, child: Text('Description:')),
              const SizedBox(height: 4),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Introduction to Calculus textbook. Used but in very good condition. No missing pages.'),
              ),
              const SizedBox(height: 12),
              const Align(alignment: Alignment.centerLeft, child: Text('Condition: Used')),
              const SizedBox(height: 6),
              const Align(alignment: Alignment.centerLeft, child: Text('Category: Textbooks')),
              const SizedBox(height: 6),
              const Align(alignment: Alignment.centerLeft, child: Text('Location: Sabanci University')),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      text: 'Publish',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Published'),
                            content: const Text('Your listing has been published successfully.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    AppRoutes.myListings,
                                    (route) => false,
                                  );
                                },
                                child: const Text('OK'),
                              )
                            ],
                          ),
                        );
                      },
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