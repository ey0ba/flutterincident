import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/storage.dart';

class AuthProvider with ChangeNotifier {
  final SecureStorageService _storage = SecureStorageService();

  bool _isLoggedIn = false;
  String? _accessToken;
  String? _username;

  bool get isLoggedIn => _isLoggedIn;
  String? get accessToken => _accessToken;
  String? get username => _username;

  Future<void> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/token/'),
        body: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access'];

        // Save tokens and username securely
        await _storage.saveData('access_token', _accessToken!);
        await _storage.saveData('username', username);

        _isLoggedIn = true;
        _username = username;
        notifyListeners();
      } else {
        throw Exception('Invalid credentials');
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _accessToken = null;
    _username = null;

    await _storage.clearData();
    notifyListeners();
  }

  Future<void> loadUser() async {
    _accessToken = await _storage.readData('access_token');
    _username = await _storage.readData('username');

    _isLoggedIn = _accessToken != null;
    notifyListeners();
  }
}
