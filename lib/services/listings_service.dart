import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/listing_item.dart';

class ListingsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get all listings (for home screen)
  Stream<List<ListingItem>> getListings() {
    return _firestore
        .collection('listings')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ListingItem.fromFirestore(doc.data(), doc.id);
          }).toList();
        });
  }

  // Get user's own listings
  Stream<List<ListingItem>> getUserListings(String userId) {
    return _firestore
        .collection('listings')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ListingItem.fromFirestore(doc.data(), doc.id);
          }).toList();
        });
  }

  // Add new listing
  Future<String> addListing(ListingItem listing) async {
    final docRef = await _firestore.collection('listings').add(listing.toFirestore());
    return docRef.id;
  }

  // Update listing
  Future<void> updateListing(String listingId, Map<String, dynamic> updates) async {
    await _firestore.collection('listings').doc(listingId).update({
      ...updates,
      'updatedAt': Timestamp.now(),
    });
  }

  // Delete listing
  Future<void> deleteListing(String listingId) async {
    await _firestore.collection('listings').doc(listingId).delete();
  }

  // Get single listing by ID
  Future<ListingItem?> getListing(String listingId) async {
    final doc = await _firestore.collection('listings').doc(listingId).get();
    if (doc.exists) {
      return ListingItem.fromFirestore(doc.data()!, doc.id);
    }
    return null;
  }
}
