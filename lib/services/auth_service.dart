import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthService with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  // Try to auto login from saved preferences
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) return false;

    try {
      final extractedUserData =
          json.decode(prefs.getString('userData')!) as Map<String, dynamic>;
      _token = extractedUserData['token'];
      _user = User(
        id: extractedUserData['userId'],
        name: extractedUserData['name'],
        email: extractedUserData['email'],
        phone: extractedUserData['phone'],
        profilePhotoUrl: extractedUserData['profilePhotoUrl'],
        token: _token,
      );
      notifyListeners();
      return true;
    } catch (e) {
      // Invalid saved data, clear it
      await prefs.remove('userData');
      return false;
    }
  }

  // Login with email and password
  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse(
      '${AppConstants.baseUrl}${AppConstants.loginEndpoint}',
    );
    try {
      final response = await http.post(
        url,
        body: json.encode({'email': email, 'password': password}),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode != 200) {
        // Handle validation errors
        if (response.statusCode == 422 && responseData['errors'] != null) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          String errorMessage = '';
          errors.forEach((key, value) {
            if (value is List) {
              errorMessage += value.join(' ');
            }
          });
          throw Exception(
            errorMessage.isNotEmpty ? errorMessage : 'Validasi gagal',
          );
        }
        throw Exception(responseData['message'] ?? 'Login gagal');
      }

      // Laravel API returns: { success: true, data: { user: {...}, token: "..." } }
      final data = responseData['data'] ?? responseData;
      _token = data['token'];

      final userJson = data['user'];
      _user = User.fromJson({...userJson, 'token': _token});

      await _saveUserData();
    } catch (error) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register new user
  Future<void> register(
    String name,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse(
      '${AppConstants.baseUrl}${AppConstants.registerEndpoint}',
    );
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode != 201 && response.statusCode != 200) {
        // Handle Laravel validation errors (422)
        if (response.statusCode == 422 && responseData['errors'] != null) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          String errorMessage = '';
          errors.forEach((key, value) {
            if (value is List) {
              errorMessage += '${value.join(' ')} ';
            }
          });
          throw Exception(
            errorMessage.isNotEmpty ? errorMessage.trim() : 'Validasi gagal',
          );
        }
        throw Exception(responseData['message'] ?? 'Registrasi gagal');
      }

      // Laravel API returns: { success: true, data: { user: {...}, token: "..." } }
      final data = responseData['data'] ?? responseData;

      if (data['token'] != null) {
        _token = data['token'];
        final userJson = data['user'];
        _user = User.fromJson({...userJson, 'token': _token});
        await _saveUserData();
      }
    } catch (error) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get current user profile from API
  Future<void> fetchUserProfile() async {
    if (_token == null) return;

    final url = Uri.parse(
      '${AppConstants.baseUrl}${AppConstants.userEndpoint}',
    );
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final data = responseData['data'] ?? responseData;
        _user = User.fromJson({...data, 'token': _token});
        await _saveUserData();
        notifyListeners();
      } else if (response.statusCode == 401) {
        // Token expired, logout
        await logout();
      }
    } catch (e) {
      // Silent fail - user data might be stale but still usable
      debugPrint('Error fetching user profile: $e');
    }
  }

  // Update user profile
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? gender,
    DateTime? birthDate,
  }) async {
    if (_token == null) return;

    _isLoading = true;
    notifyListeners();

    final url = Uri.parse(
      '${AppConstants.baseUrl}${AppConstants.profileEndpoint}',
    );
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (phone != null) body['phone'] = phone;
      if (gender != null) body['gender'] = gender;
      if (birthDate != null) {
        body['birth_date'] = birthDate.toIso8601String().split('T')[0];
      }

      final response = await http.put(
        url,
        body: json.encode(body),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final data = responseData['data'] ?? responseData;
        _user = User.fromJson({...data, 'token': _token});
        await _saveUserData();
      } else {
        throw Exception(responseData['message'] ?? 'Gagal memperbarui profil');
      }
    } catch (error) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    if (_token != null) {
      // Call API logout to invalidate token
      try {
        final url = Uri.parse(
          '${AppConstants.baseUrl}${AppConstants.logoutEndpoint}',
        );
        await http.post(
          url,
          headers: {
            'Authorization': 'Bearer $_token',
            'Accept': 'application/json',
          },
        );
      } catch (e) {
        // Ignore errors - we're logging out anyway
      }
    }

    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
    notifyListeners();
  }

  // Save user data to SharedPreferences
  Future<void> _saveUserData() async {
    if (_user == null || _token == null) return;

    final prefs = await SharedPreferences.getInstance();
    final userData = json.encode({
      'token': _token,
      'userId': _user!.id,
      'name': _user!.name,
      'email': _user!.email,
      'phone': _user!.phone,
      'profilePhotoUrl': _user!.profilePhotoUrl,
    });
    await prefs.setString('userData', userData);
  }
}
