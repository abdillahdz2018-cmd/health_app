import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  String? get role => _user?.role;

  // Cek session saat app dibuka
  Future<void> checkSession() async {
    final savedUser = await AuthService.getSavedUser();
    if (savedUser != null) {
      _user = User.fromJson(savedUser);
      notifyListeners();
    }
  }

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await AuthService.login(email, password);
      if (response['success'] == true) {
        _user = User.fromJson(response['data']['user']);
      }
      return response;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String namaLengkap,
    required String role,
    required String noRt,
    required String noRw,
    required String kelurahan,
    required String kecamatan,
    String? noTelepon,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      return await AuthService.register(
        username: username,
        email: email,
        password: password,
        namaLengkap: namaLengkap,
        role: role,
        noRt: noRt,
        noRw: noRw,
        kelurahan: kelurahan,
        kecamatan: kecamatan,
        noTelepon: noTelepon,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    notifyListeners();
  }
}