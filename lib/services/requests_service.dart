import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/request_item.dart';

class RequestsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<RequestItem>> getIncomingRequests(String userId) {
    return _firestore
        .collection('swap_requests')
        .where('receiverId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RequestItem.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Stream<List<RequestItem>> getOutgoingRequests(String userId) {
    return _firestore
        .collection('swap_requests')
        .where('senderId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RequestItem.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Future<void> createRequest(RequestItem request) async {
    await _firestore.collection('swap_requests').add(request.toFirestore());
  }

  Future<void> updateRequestStatus(String requestId, String status) async {
    await _firestore.collection('swap_requests').doc(requestId).update({
      'status': status,
    });
  }
}