import '../models/user_model.dart';

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  // Login
  Future<bool> login(String email, String password) async {
    try {
      // TODO: Implement API call
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      // Mock user data
      _currentUser = UserModel(
        id: '1',
        name: 'John Doe',
        email: email,
        phone: '1234567890',
        address: '123 Main St',
        role: email.contains('admin') ? UserRole.admin : UserRole.customer,
      );

      return true;
    } catch (e) {
      return false;
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
    try {
      // TODO: Implement API call
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      _currentUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        phone: phone,
        address: address,
        role: UserRole.customer,
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _currentUser = null;
  }

  // Update Profile
  Future<bool> updateProfile(UserModel user) async {
    try {
      // TODO: Implement API call
      await Future.delayed(const Duration(seconds: 1));
      _currentUser = user;
      return true;
    } catch (e) {
      return false;
    }
  }
}
