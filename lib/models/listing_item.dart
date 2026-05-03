import 'package:cloud_firestore/cloud_firestore.dart';

class ListingItem {
  final String id;
  final String title;
  final String condition;
  final String location;
  final String imageUrl;
  final String description;
  final String category;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  ListingItem({
    required this.id,
    required this.title,
    required this.condition,
    required this.location,
    required this.imageUrl,
    required this.description,
    required this.category,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create from Firestore document
  factory ListingItem.fromFirestore(Map<String, dynamic> data, String id) {
    return ListingItem(
      id: id,
      title: data['title'] ?? '',
      condition: data['condition'] ?? '',
      location: data['location'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      userId: data['userId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'condition': condition,
      'location': location,
      'imageUrl': imageUrl,
      'description': description,
      'category': category,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
