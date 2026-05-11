import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = true;
  String? _errorMessage;

  StreamSubscription<User?>? _authSubscription;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _authSubscription = _authService.authStateChanges.listen(
      (user) {
        _user = user;
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

  Future<bool> signUp(
    String email,
    String password, {
    String? displayName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final error = await _authService.signUp(
      email,
      password,
      displayName: displayName,
    );

    _isLoading = false;

    if (error != null) {
      _errorMessage = error;
      notifyListeners();
      return false;
    }

    notifyListeners();
    return true;
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final error = await _authService.signIn(email, password);

    _isLoading = false;

    if (error != null) {
      _errorMessage = error;
      notifyListeners();
      return false;
    }

    notifyListeners();
    return true;
  }

  Future<void> signOut() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await _authService.signOut();

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}