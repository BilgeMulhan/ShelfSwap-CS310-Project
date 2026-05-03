import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/listing_item.dart';
import '../providers/listings_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_paddings.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class AddItemScreen extends StatefulWidget {
  final ListingItem? itemToEdit;

  const AddItemScreen({super.key, this.itemToEdit});

  // Factory constructor to handle route arguments
  factory AddItemScreen.fromRouteArguments(Object? arguments) {
    if (arguments is ListingItem) {
      return AddItemScreen(itemToEdit: arguments);
    }
    return const AddItemScreen();
  }

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

  bool get _isEditing => widget.itemToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _itemNameController.text = widget.itemToEdit!.title;
      _categoryController.text = widget.itemToEdit!.category;
      _conditionController.text = widget.itemToEdit!.condition;
      _locationController.text = widget.itemToEdit!.location;
      _descriptionController.text = widget.itemToEdit!.description;
    }
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _categoryController.dispose();
    _conditionController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveListing() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final listingsProvider = context.read<ListingsProvider>();

    final user = authProvider.user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to save items')),
      );
      return;
    }

    if (_isEditing) {
      // Update existing listing
      final updates = {
        'title': _itemNameController.text.trim(),
        'condition': _conditionController.text.trim(),
        'location': _locationController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _categoryController.text.trim(),
      };

      final success = await listingsProvider.updateListing(widget.itemToEdit!.id, updates);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item updated successfully!')),
        );
        Navigator.pop(context); // Go back to previous screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(listingsProvider.errorMessage ?? 'Failed to update item')),
        );
      }
    } else {
      // Add new listing
      final listing = ListingItem(
        id: '', // Will be set by Firestore
        title: _itemNameController.text.trim(),
        condition: _conditionController.text.trim(),
        location: _locationController.text.trim(),
        imageUrl: 'assets/images/placeholder_item.png', // Default image for now
        description: _descriptionController.text.trim(),
        category: _categoryController.text.trim(),
        userId: user.uid,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await listingsProvider.addListing(listing);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item added successfully!')),
        );
        // Clear form
        _formKey.currentState!.reset();
        _itemNameController.clear();
        _categoryController.clear();
        _conditionController.clear();
        _locationController.clear();
        _descriptionController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(listingsProvider.errorMessage ?? 'Failed to add item')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageBoxSize = screenWidth < 360 ? 100.0 : 120.0;
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Item' : 'Add Item')),
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
                  PrimaryButton(text: _isEditing ? 'Update Listing' : 'Add Listing', onPressed: _saveListing),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }