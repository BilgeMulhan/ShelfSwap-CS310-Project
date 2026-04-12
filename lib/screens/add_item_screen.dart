import 'package:flutter/material.dart';
import '../utils/app_paddings.dart';
import '../utils/app_routes.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _itemNameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _conditionController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _itemNameController.dispose();
    _categoryController.dispose();
    _conditionController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _previewListing() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Success'),
          content: const Text('Item information is valid. Redirecting to preview.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.preview);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageBoxSize = screenWidth < 360 ? 100.0 : 120.0;
    return Scaffold(
      appBar: AppBar(title: const Text('Add Item')),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppPaddings.screen,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              Center(
                child: Container(
                  height: imageBoxSize,
                  width: imageBoxSize,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: const Center(
                    child: Text('Tap to upload'),
                  ),
                ),
              ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _itemNameController,
                    hintText: 'Item Name',
                    icon: Icons.inventory_2_outlined,
                    validator: (value) => value == null || value.trim().isEmpty ? 'Item name is required' : null,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _categoryController,
                    hintText: 'Category',
                    icon: Icons.category_outlined,
                    validator: (value) => value == null || value.trim().isEmpty ? 'Category is required' : null,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _conditionController,
                    hintText: 'Condition',
                    icon: Icons.star_outline,
                    validator: (value) => value == null || value.trim().isEmpty ? 'Condition is required' : null,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _locationController,
                    hintText: 'Location',
                    icon: Icons.location_on_outlined,
                    validator: (value) => value == null || value.trim().isEmpty ? 'Location is required' : null,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _descriptionController,
                    hintText: 'Description of the item',
                    icon: Icons.description_outlined,
                    maxLines: 3,
                    validator: (value) => value == null || value.trim().isEmpty ? 'Description is required' : null,
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(text: 'Preview Listing', onPressed: _previewListing),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }