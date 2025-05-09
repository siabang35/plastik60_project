import 'package:flutter/foundation.dart';
import 'package:plastik60_app/config/constants.dart';
import 'package:plastik60_app/models/user.dart';
import 'package:plastik60_app/services/api_service.dart';
import 'package:plastik60_app/services/storage_service.dart';

class AuthService extends ChangeNotifier {
  final StorageService _storageService;
  final ApiService _apiService;

  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  AuthService(this._storageService)
    : _apiService = ApiService(storageService: _storageService);

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  // Check if user is already authenticated
  Future<bool> checkAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _storageService.getString(AppConstants.tokenKey);
      if (token == null) {
        _isAuthenticated = false;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final userData = await _apiService.get(AppConstants.userEndpoint);
      if (userData != null) {
        _currentUser = User.fromJson(userData['data']);
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Token is invalid or expired
        await _storageService.remove(AppConstants.tokenKey);
        await _storageService.remove(AppConstants.userKey);
        _isAuthenticated = false;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Login with email and password
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.post(
        AppConstants.loginEndpoint,
        data: {'email': email, 'password': password},
        requiresAuth: false,
      );

      if (response != null && response['token'] != null) {
        await _storageService.setString(
          AppConstants.tokenKey,
          response['token'],
        );

        if (response['user'] != null) {
          _currentUser = User.fromJson(response['user']);
          await _storageService.setString(
            AppConstants.userKey,
            response['user'].toString(),
          );
        }

        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Invalid credentials';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register a new user
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? address,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.post(
        AppConstants.registerEndpoint,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
          'phone': phone,
          'address': address,
        },
        requiresAuth: false,
      );

      if (response != null && response['token'] != null) {
        await _storageService.setString(
          AppConstants.tokenKey,
          response['token'],
        );

        if (response['user'] != null) {
          _currentUser = User.fromJson(response['user']);
          await _storageService.setString(
            AppConstants.userKey,
            response['user'].toString(),
          );
        }

        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout user
  Future<bool> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.post(AppConstants.logoutEndpoint);

      // Clear local storage
      await _storageService.remove(AppConstants.tokenKey);
      await _storageService.remove(AppConstants.userKey);

      _currentUser = null;
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // Even if API call fails, clear local storage
      await _storageService.remove(AppConstants.tokenKey);
      await _storageService.remove(AppConstants.userKey);

      _currentUser = null;
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  // Forgot password
  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.post(
        AppConstants.forgotPasswordEndpoint,
        data: {'email': email},
        requiresAuth: false,
      );

      _isLoading = false;
      if (response != null && response['success'] == true) {
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to send password reset email';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    required String name,
    required String phone,
    String? address,
    String? city,
    String? province,
    String? postalCode,
  }) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.put(
        AppConstants.updateProfileEndpoint,
        data: {
          'name': name,
          'phone': phone,
          'address': address,
          'city': city,
          'province': province,
          'postal_code': postalCode,
        },
      );

      if (response != null && response['data'] != null) {
        _currentUser = User.fromJson(response['data']);
        await _storageService.setString(
          AppConstants.userKey,
          response['data'].toString(),
        );

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to update profile';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.put(
        AppConstants.changePasswordEndpoint,
        data: {
          'current_password': currentPassword,
          'password': newPassword,
          'password_confirmation': confirmPassword,
        },
      );

      _isLoading = false;
      if (response != null && response['success'] == true) {
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to change password';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
