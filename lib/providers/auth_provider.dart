import 'package:flutter/material.dart';
import 'package:plastik60_app/models/user.dart';
import 'package:plastik60_app/services/auth_service.dart';
import 'package:plastik60_app/services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  late final AuthService _authService;

  User? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get error => _error;

  AuthProvider() {
    _authService = AuthService(_storageService);
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final isLoggedIn = await _authService.checkAuth();
      _isAuthenticated = isLoggedIn;
      _user = isLoggedIn ? _authService.currentUser : null;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _authService.login(email, password);
      _isAuthenticated = success;
      _user = success ? _authService.currentUser : null;
      return success;
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _authService.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        address: null,
      );
      _user = success ? _authService.currentUser : null;
      _isAuthenticated = success;
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _user = null;
      _isAuthenticated = false;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String phone,
    String? address,
    String? city,
    String? province,
    String? postalCode,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _authService.updateProfile(
        name: name,
        phone: phone,
        address: address,
        city: city,
        province: province,
        postalCode: postalCode,
      );

      if (success) {
        _user = _authService.currentUser;
      }

      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
