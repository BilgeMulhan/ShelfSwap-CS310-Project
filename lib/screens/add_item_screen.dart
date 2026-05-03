import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
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

  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;

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

  Future<String> _imageToSmallBase64(XFile imageFile) async {
    final originalBytes = await imageFile.readAsBytes();

    final decodedImage = img.decodeImage(originalBytes);
    if (decodedImage == null) {
      throw Exception('Could not decode image');
    }

    final resizedImage = img.copyResize(
      decodedImage,
      width: 300,
    );

    final jpgBytes = img.encodeJpg(
      resizedImage,
      quality: 40,
    );

    final base64Image = base64Encode(jpgBytes);
    final imageData = 'data:image/jpeg;base64,$base64Image';

    final imageSizeBytes = utf8.encode(imageData).length;

    if (imageSizeBytes > 900000) {
      throw Exception('Image is still too large. Please choose a smaller image.');
    }

    return imageData;
  }

  Future<void> _pickImage() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();

      if (!mounted) return;

      setState(() {
        _selectedImage = image;
        _selectedImageBytes = bytes;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not pick image: $e')),
      );
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

    try {
      if (_isEditing) {
        String imageUrl = widget.itemToEdit!.imageUrl;

        if (_selectedImage != null) {
          imageUrl = await _imageToSmallBase64(_selectedImage!);
        }

        final updates = {
          'title': _itemNameController.text.trim(),
          'condition': _conditionController.text.trim(),
          'location': _locationController.text.trim(),
          'description': _descriptionController.text.trim(),
          'category': _categoryController.text.trim(),
          'imageUrl': imageUrl,
        };

        final success = await listingsProvider.updateListing(
          widget.itemToEdit!.id,
          updates,
        );

        if (!mounted) return;

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item updated successfully!')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                listingsProvider.errorMessage ?? 'Failed to update item',
              ),
            ),
          );
        }
      } else {
        String imageUrl = 'assets/images/placeholder_item.png';

        if (_selectedImage != null) {
          imageUrl = await _imageToSmallBase64(_selectedImage!);
        }

        final listing = ListingItem(
          id: '',
          title: _itemNameController.text.trim(),
          condition: _conditionController.text.trim(),
          location: _locationController.text.trim(),
          imageUrl: imageUrl,
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

          _formKey.currentState!.reset();
          _itemNameController.clear();
          _categoryController.clear();
          _conditionController.clear();
          _locationController.clear();
          _descriptionController.clear();

          setState(() {
            _selectedImage = null;
            _selectedImageBytes = null;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                listingsProvider.errorMessage ?? 'Failed to add item',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save item: $e')),
      );
    }
  }

  Widget _buildImagePreview(double imageBoxSize) {
    if (_selectedImageBytes != null) {
      return Image.memory(
        _selectedImageBytes!,
        fit: BoxFit.cover,
        width: imageBoxSize,
        height: imageBoxSize,
      );
    }

    if (widget.itemToEdit != null && widget.itemToEdit!.imageUrl.isNotEmpty) {
      final imageUrl = widget.itemToEdit!.imageUrl;

      if (imageUrl.startsWith('http')) {
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: imageBoxSize,
          height: imageBoxSize,
        );
      }

      if (imageUrl.startsWith('data:image')) {
        return Image.memory(
          base64Decode(imageUrl.split(',').last),
          fit: BoxFit.cover,
          width: imageBoxSize,
          height: imageBoxSize,
        );
      }

      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        width: imageBoxSize,
        height: imageBoxSize,
      );
    }

    return const Center(
      child: Text('Tap to upload'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageBoxSize = screenWidth < 360 ? 100.0 : 120.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Item' : 'Add Item'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppPaddings.screen,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: InkWell(
                    onTap: _pickImage,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: imageBoxSize,
                      width: imageBoxSize,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _buildImagePreview(imageBoxSize),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _itemNameController,
                  hintText: 'Item Name',
                  icon: Icons.inventory_2_outlined,
                  validator: (value) {
                    return value == null || value.trim().isEmpty
                        ? 'Item name is required'
                        : null;
                  },
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _categoryController,
                  hintText: 'Category',
                  icon: Icons.category_outlined,
                  validator: (value) {
                    return value == null || value.trim().isEmpty
                        ? 'Category is required'
                        : null;
                  },
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _conditionController,
                  hintText: 'Condition',
                  icon: Icons.star_outline,
                  validator: (value) {
                    return value == null || value.trim().isEmpty
                        ? 'Condition is required'
                        : null;
                  },
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _locationController,
                  hintText: 'Location',
                  icon: Icons.location_on_outlined,
                  validator: (value) {
                    return value == null || value.trim().isEmpty
                        ? 'Location is required'
                        : null;
                  },
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _descriptionController,
                  hintText: 'Description of the item',
                  icon: Icons.description_outlined,
                  maxLines: 3,
                  validator: (value) {
                    return value == null || value.trim().isEmpty
                        ? 'Description is required'
                        : null;
                  },
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  text: _isEditing ? 'Update Listing' : 'Add Listing',
                  onPressed: _saveListing,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}