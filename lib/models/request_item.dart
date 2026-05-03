import 'package:cloud_firestore/cloud_firestore.dart';

class RequestItem {
  final String id;
  final String senderId;
  final String senderEmail;
  final String receiverId;
  final String itemId;
  final String itemTitle;
  final String location;
  final String message;
  final String status;
  final DateTime createdAt;

  RequestItem({
    required this.id,
    required this.senderId,
    required this.senderEmail,
    required this.receiverId,
    required this.itemId,
    required this.itemTitle,
    required this.location,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  factory RequestItem.fromFirestore(Map<String, dynamic> data, String id) {
    return RequestItem(
      id: id,
      senderId: data['senderId']?.toString() ?? '',
      senderEmail: data['senderEmail']?.toString() ?? '',
      receiverId: data['receiverId']?.toString() ?? '',
      itemId: data['itemId']?.toString() ?? '',
      itemTitle: data['itemTitle']?.toString() ?? '',
      location: data['location']?.toString() ?? '',
      message: data['message']?.toString() ?? '',
      status: data['status']?.toString() ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'senderEmail': senderEmail,
      'receiverId': receiverId,
      'itemId': itemId,
      'itemTitle': itemTitle,
      'location': location,
      'message': message,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  String get senderName {
    if (senderEmail.isEmpty) return 'Unknown user';
    return senderEmail.split('@').first;
  }

  String get time {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
}