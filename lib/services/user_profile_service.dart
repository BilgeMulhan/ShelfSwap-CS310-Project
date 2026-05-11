import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<String> getBio(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    final data = doc.data();
    return data?['bio']?.toString() ?? '';
  }

  Future<void> updateProfile({
    required String userId,
    required String displayName,
    required String email,
    required String bio,
  }) async {
    final user = _auth.currentUser;

    if (user == null || user.uid != userId) {
      throw Exception('You must be logged in to update your profile.');
    }

    await user.updateDisplayName(displayName.trim());
    await user.reload();

    await _firestore.collection('users').doc(userId).set({
      'id': userId,
      'createdBy': userId,
      'displayName': displayName.trim(),
      'email': email,
      'bio': bio.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}