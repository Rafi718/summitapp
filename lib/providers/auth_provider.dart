import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? get currentUser => _authService.currentUser;
  bool get isLoggedIn => _authService.isLoggedIn;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    await _authService.init();
    _isLoading = false;
    notifyListeners();
  }

  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();
    final error = await _authService.register(name: name, email: email, password: password);
    _isLoading = false;
    notifyListeners();
    return error;
  }

  Future<String?> login({required String email, required String password}) async {
    _isLoading = true;
    notifyListeners();
    final error = await _authService.login(email: email, password: password);
    _isLoading = false;
    notifyListeners();
    return error;
  }

  Future<void> logout() async {
    await _authService.logout();
    notifyListeners();
  }

  Future<void> updateProfile({String? name, String? phone, String? photo}) async {
    await _authService.updateProfile(name: name, phone: phone, photo: photo);
    notifyListeners();
  }

  AuthService get service => _authService;
}
