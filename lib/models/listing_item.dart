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

  factory ListingItem.fromFirestore(Map<String, dynamic> data, String id) {
    return ListingItem(
      id: id,
      title: data['title']?.toString().trim() ?? '',
      condition: data['condition']?.toString().trim() ?? '',
      location: data['location']?.toString().trim() ?? '',
      imageUrl: data['imageUrl']?.toString().trim() ?? '',
      description: data['description']?.toString().trim() ?? '',
      category: data['category']?.toString().trim() ?? '',
      userId: (data['userId'] ?? data['createdBy'])?.toString().trim() ?? '',
      createdAt: _timestampToDate(data['createdAt']),
      updatedAt: _timestampToDate(data['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'condition': condition,
      'location': location,
      'imageUrl': imageUrl,
      'description': description,
      'category': category,
      'userId': userId,
      'createdBy': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  ListingItem copyWith({Map<String, dynamic>? updates}) {
    if (updates == null) return this;

    return ListingItem(
      id: id,
      title: updates['title'] ?? title,
      condition: updates['condition'] ?? condition,
      location: updates['location'] ?? location,
      imageUrl: updates['imageUrl'] ?? imageUrl,
      description: updates['description'] ?? description,
      category: updates['category'] ?? category,
      userId: userId,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  static DateTime _timestampToDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }
}