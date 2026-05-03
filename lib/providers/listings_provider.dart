import 'package:flutter/material.dart';
import '../models/listing_item.dart';
import '../services/listings_service.dart';

class ListingsProvider extends ChangeNotifier {
  final ListingsService _listingsService = ListingsService();

  List<ListingItem> _listings = [];
  List<ListingItem> _userListings = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ListingItem> get listings => _listings;
  List<ListingItem> get userListings => _userListings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load all listings
  void loadListings() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _listingsService.getListings().listen(
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

  // Load user's listings
  void loadUserListings(String userId) {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _listingsService.getUserListings(userId).listen(
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
  Future<bool> updateListing(String listingId, Map<String, dynamic> updates) async {
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
    // Update in general listings
    final generalIndex = _listings.indexWhere((item) => item.id == listingId);
    if (generalIndex != -1) {
      final updatedItem = _listings[generalIndex].copyWith(updates: updates);
      _listings[generalIndex] = updatedItem;
    }

    // Update in user listings
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
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
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
}