import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  // Login
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final response = await ApiService.post('/auth/login', {
      'email': email,
      'password': password,
    });

    if (response['success'] == true) {
      // Simpan token dan data user
      await ApiService.saveToken(response['data']['token']);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(response['data']['user']));
    }

    return response;
  }

  // Register
  static Future<Map<String, dynamic>> register({
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
    return await ApiService.post('/auth/register', {
      'username': username,
      'email': email,
      'password': password,
      'nama_lengkap': namaLengkap,
      'role': role,
      'no_rt': noRt,
      'no_rw': noRw,
      'kelurahan': kelurahan,
      'kecamatan': kecamatan,
      if (noTelepon != null) 'no_telepon': noTelepon,
    });
  }

  // Logout
  static Future<void> logout() async {
    await ApiService.clearToken();
  }

  // Ambil data user yang tersimpan
  static Future<Map<String, dynamic>?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    if (userStr == null) return null;
    return jsonDecode(userStr);
  }

  // Cek apakah sudah login
  static Future<bool> isLoggedIn() async {
    final token = await ApiService.getToken();
    return token != null;
  }
}