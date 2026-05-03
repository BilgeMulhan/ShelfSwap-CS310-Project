import 'dart:async';

import 'package:flutter/material.dart';
import '../models/request_item.dart';
import '../services/requests_service.dart';

class RequestsProvider extends ChangeNotifier {
  final RequestsService _requestsService = RequestsService();

  List<RequestItem> _incomingRequests = [];
  List<RequestItem> _outgoingRequests = [];
  bool _isLoading = false;
  String? _errorMessage;

  StreamSubscription<List<RequestItem>>? _incomingSub;
  StreamSubscription<List<RequestItem>>? _outgoingSub;

  List<RequestItem> get incomingRequests => _incomingRequests;
  List<RequestItem> get outgoingRequests => _outgoingRequests;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void loadRequests(String userId) {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _incomingSub?.cancel();
    _outgoingSub?.cancel();

    _incomingSub = _requestsService.getIncomingRequests(userId).listen(
      (requests) {
        _incomingRequests = requests;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );

    _outgoingSub = _requestsService.getOutgoingRequests(userId).listen(
      (requests) {
        _outgoingRequests = requests;
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

  Future<bool> createRequest(RequestItem request) async {
    try {
      await _requestsService.createRequest(request);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateRequestStatus(String requestId, String status) async {
    try {
      await _requestsService.updateRequestStatus(requestId, status);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _incomingSub?.cancel();
    _outgoingSub?.cancel();
    super.dispose();
  }
}