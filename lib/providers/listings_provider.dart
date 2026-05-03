import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/listing_item.dart';
import '../services/listings_service.dart';

class ListingsProvider extends ChangeNotifier {
  final ListingsService _listingsService = ListingsService();

  List<ListingItem> _listings = [];
  List<ListingItem> _userListings = [];
  List<String> _favoriteIds = [];

  bool _isLoading = false;
  String? _errorMessage;

  StreamSubscription<List<ListingItem>>? _listingsSub;
  StreamSubscription<List<ListingItem>>? _userListingsSub;
  StreamSubscription<List<String>>? _favoritesSub;

  List<ListingItem> get listings => _listings;
  List<ListingItem> get userListings => _userListings;
  List<String> get favoriteIds => _favoriteIds;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<ListingItem> get favoriteListings {
    return _listings.where((item) => _favoriteIds.contains(item.id)).toList();
  }

  // Load all listings
  void loadListings() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _listingsSub?.cancel();

    _listingsSub = _listingsService.getListings().listen(
      (listings) {
        _listings = listings;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Load user's own listings
  void loadUserListings(String userId) {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _userListingsSub?.cancel();

    _userListingsSub = _listingsService.getUserListings(userId).listen(
      (listings) {
        _userListings = listings;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Load user's favorite listing IDs
  void loadFavorites(String userId) {
    _favoritesSub?.cancel();

    _favoritesSub = _listingsService.getFavoriteIds(userId).listen(
      (ids) {
        _favoriteIds = ids;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  // Check whether a listing is favorite
  bool isFavorite(String listingId) {
    return _favoriteIds.contains(listingId);
  }

  // Add/remove favorite
  Future<bool> toggleFavorite(String userId, String listingId) async {
    try {
      if (isFavorite(listingId)) {
        await _listingsService.removeFavorite(userId, listingId);
      } else {
        await _listingsService.addFavorite(userId, listingId);
      }

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Add new listing
  Future<bool> addListing(ListingItem listing) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _listingsService.addListing(listing);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update listing
  Future<bool> updateListing(
    String listingId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _listingsService.updateListing(listingId, updates);

      // Immediately update local lists for instant UI update
      _updateLocalListing(listingId, updates);

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Helper method to update listing in local lists
  void _updateLocalListing(String listingId, Map<String, dynamic> updates) {
    final generalIndex = _listings.indexWhere((item) => item.id == listingId);

    if (generalIndex != -1) {
      final updatedItem = _listings[generalIndex].copyWith(updates: updates);
      _listings[generalIndex] = updatedItem;
    }

    final userIndex = _userListings.indexWhere((item) => item.id == listingId);

    if (userIndex != -1) {
      final updatedItem = _userListings[userIndex].copyWith(updates: updates);
      _userListings[userIndex] = updatedItem;
    }
  }

  // Delete listing
  Future<bool> deleteListing(String listingId) async {
    try {
      await _listingsService.deleteListing(listingId);

      // Immediately remove from local lists for instant UI update
      _listings.removeWhere((item) => item.id == listingId);
      _userListings.removeWhere((item) => item.id == listingId);
      _favoriteIds.removeWhere((id) => id == listingId);

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Upload an item image and return a Firestore-friendly base64 data URI
  Future<String> uploadListingImage(XFile imageFile, String userId) async {
    return await _listingsService.uploadListingImage(imageFile, userId);
  }

  // Get single listing
  Future<ListingItem?> getListing(String listingId) async {
    try {
      return await _listingsService.getListing(listingId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  @override
  void dispose() {
    _listingsSub?.cancel();
    _userListingsSub?.cancel();
    _favoritesSub?.cancel();
    super.dispose();
  }
}