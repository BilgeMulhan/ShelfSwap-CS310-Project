import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import '../models/listing_item.dart';

class ListingsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  Future<String> uploadListingImage(XFile imageFile, String userId) async {
    final bytes = await imageFile.readAsBytes();
    const mimeType = 'image/jpeg';
    final base64Data = base64Encode(bytes);

    return 'data:$mimeType;base64,$base64Data';
  }

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

  Future<String> addListing(ListingItem listing) async {
    final docRef = _firestore.collection('listings').doc();
    final now = Timestamp.now();

    await docRef.set({
      ...listing.toFirestore(),
      'id': docRef.id,
      'createdBy': listing.userId,
      'userId': listing.userId,
      'createdAt': now,
      'updatedAt': now,
    });

    return docRef.id;
  }

  Future<void> updateListing(
    String listingId,
    Map<String, dynamic> updates,
  ) async {
    final safeUpdates = Map<String, dynamic>.from(updates)
      ..remove('id')
      ..remove('userId')
      ..remove('createdBy')
      ..remove('createdAt');

    await _firestore.collection('listings').doc(listingId).update({
      ...safeUpdates,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> deleteListing(String listingId) async {
    await _firestore.collection('listings').doc(listingId).delete();
  }

  Future<ListingItem?> getListing(String listingId) async {
    final doc = await _firestore.collection('listings').doc(listingId).get();

    if (doc.exists) {
      return ListingItem.fromFirestore(doc.data()!, doc.id);
    }

    return null;
  }

  Stream<List<String>> getFavoriteIds(String userId) {
    return _firestore
        .collection('favorites')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => doc.data()['listingId']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toList();
    });
  }

  Future<void> addFavorite(String userId, String listingId) async {
    final favoriteId = '${userId}_$listingId';

    await _firestore.collection('favorites').doc(favoriteId).set({
      'id': favoriteId,
      'createdBy': userId,
      'userId': userId,
      'listingId': listingId,
      'createdAt': Timestamp.now(),
    });
  }

  Future<void> removeFavorite(String userId, String listingId) async {
    await _firestore
        .collection('favorites')
        .doc('${userId}_$listingId')
        .delete();
  }
}