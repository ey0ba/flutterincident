import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:jwt_decoder/jwt_decoder.dart';


class AuthProvider with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  bool _isLoggedIn = false;
  String? _accessToken;
  String? _username;
  String? _institutionName; // Store institution name for user context

  bool get isLoggedIn => _isLoggedIn;
  String? get accessToken => _accessToken;
  String? get username => _username;
  String? get institutionName => _institutionName;

  Future<void> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/token/'), // Replace with your Django API endpoint
        body: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access'];
        _isLoggedIn = true;

        // Decode the token to extract additional claims
        final Map<String, dynamic> decodedToken = JwtDecoder.decode(_accessToken!);
        print('Decoded Token: $decodedToken'); // Add this line for debugging
        _username = username;
        _institutionName = decodedToken['institution_name'] ?? 'Unknown';

        // Store token and other data securely
        await _storage.write(key: 'access_token', value: _accessToken);
        await _storage.write(key: 'username', value: _username);
        await _storage.write(key: 'institution_name', value: _institutionName);

        notifyListeners(); // Notify UI of state change
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
    _institutionName = null;

    // Clear the token and other stored data
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'username');
    await _storage.delete(key: 'institution_name');

    notifyListeners(); // Notify UI of state change
  }

  Future<void> loadUser() async {
    // Check if token exists on app startup
    _accessToken = await _storage.read(key: 'access_token');
    _username = await _storage.read(key: 'username');
    _institutionName = await _storage.read(key: 'institution_name');

    if (_accessToken != null && !JwtDecoder.isExpired(_accessToken!)) {
      _isLoggedIn = true;
    } else {
      // Token is expired or doesn't exist
      _isLoggedIn = false;
      await logout(); // Clear data if token is invalid
    }

    notifyListeners(); // Notify UI of state change
  }
}
