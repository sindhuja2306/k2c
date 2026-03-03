import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? get currentUser => _authService.currentUser;
  bool get isLoggedIn => _authService.isLoggedIn;
  bool get isAdmin => _authService.isAdmin;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _authService.login(email, password);
      if (success) {
        _errorMessage = null;
      } else {
        _errorMessage = 'Invalid credentials';
      }
      return success;
    } catch (e) {
      _errorMessage = 'Login failed: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _authService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        address: address,
      );
      if (!success) {
        _errorMessage = 'Registration failed';
      }
      return success;
    } catch (e) {
      _errorMessage = 'Registration failed: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
    notifyListeners();
  }

  // Update Profile
  Future<bool> updateProfile(UserModel user) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _authService.updateProfile(user);
      return success;
    } catch (e) {
      _errorMessage = 'Update failed: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
