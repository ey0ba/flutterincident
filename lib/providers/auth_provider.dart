import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/storage.dart';

class AuthProvider with ChangeNotifier {
  final SecureStorageService _storage = SecureStorageService();

  bool _isLoggedIn = false;
  String? _accessToken;
  String? _username;

  bool get isLoggedIn => _isLoggedIn;
  String? get accessToken => _accessToken;
  String? get username => _username;

  Future<bool> _hasNetworkConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> login(String username, String password) async {
    int retries = 3;
    const Duration delayBetweenRetries = Duration(seconds: 2); // Exponential backoff base
    const Duration timeoutDuration = Duration(seconds: 59); // Timeout for HTTP requests

    if (!await _hasNetworkConnection()) {
      throw Exception("No network connection available.");
    }

    while (retries > 0) {
      try {
        print("Attempting login...");

        final response = await http
            .post(
              Uri.parse('https://incident.com.et/api/token/'),
              headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
              },
              body: {'username': username, 'password': password},
            )
            .timeout(timeoutDuration); // Set timeout for the HTTP request

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          _accessToken = data['access'];
          await _storage.saveData('access_token', _accessToken!);
          await _storage.saveData('username', username);

          _isLoggedIn = true;
          _username = username;
          notifyListeners();
          return; // Success
        } else {
          throw Exception('Invalid credentials');
        }
      } catch (e) {
        retries--;
        if (retries == 0) {
          throw Exception('Failed to login after multiple attempts: $e');
        }
        await Future.delayed(delayBetweenRetries * (3 - retries)); // Exponential backoff
      }
    }
  }

  Future<void> submitForm(Map<String, dynamic> formData) async {
    const Duration timeoutDuration = Duration(seconds: 10);

    if (!await _hasNetworkConnection()) {
      print("No network connection. Caching form data locally.");
      await _cacheFormLocally(formData);
      return;
    }

    try {
      final response = await http
          .post(
            Uri.parse('https://incident.com.et/api/forms/submit/'),
            headers: {
              'Authorization': 'Bearer $_accessToken',
              'Content-Type': 'application/json',
            },
            body: json.encode(formData),
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 201) {
        print("Form submitted successfully.");
      } else {
        print("Server error. Caching form data locally.");
        await _cacheFormLocally(formData);
      }
    } catch (e) {
      print("Error submitting form: $e. Caching form data locally.");
      await _cacheFormLocally(formData);
    }
  }

  Future<void> _cacheFormLocally(Map<String, dynamic> formData) async {
    final box = await Hive.openBox('form_cache');
    await box.add(formData);
    print("Form data cached locally.");
  }

  Future<void> syncCachedForms() async {
    if (!await _hasNetworkConnection()) {
      print("No network connection. Cannot sync cached forms.");
      return;
    }

    final box = await Hive.openBox('form_cache');
    final cachedForms = box.values.toList();

    for (var formData in cachedForms) {
      try {
        final response = await http
            .post(
              Uri.parse('https://incident.com.et/api/forms/submit/'),
              headers: {
                'Authorization': 'Bearer $_accessToken',
                'Content-Type': 'application/json',
              },
              body: json.encode(formData),
            )
            .timeout(Duration(seconds: 10));

        if (response.statusCode == 201) {
          print("Cached form submitted successfully.");
          await box.deleteAt(cachedForms.indexOf(formData));
        } else {
          print("Failed to submit cached form: ${response.statusCode}");
        }
      } catch (e) {
        print("Error syncing cached form: $e");
      }
    }
  }

  Future<void> logout() async {
    print("Logging out...");
    _isLoggedIn = false;
    _accessToken = null;
    _username = null;

    await _storage.clearData();
    notifyListeners();
    print("Logout successful!");
  }

  Future<void> loadUser() async {
    print("Loading user session...");
    _accessToken = await _storage.readData('access_token');
    _username = await _storage.readData('username');

    _isLoggedIn = _accessToken != null;
    notifyListeners();

    if (_isLoggedIn) {
      print("User session restored.");
      print("Access token: $_accessToken");
      print("Username: $_username");
    } else {
      print("No user session found.");
    }
  }
}
