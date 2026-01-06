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

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) return false;

    final extractedUserData =
        json.decode(prefs.getString('userData')!) as Map<String, dynamic>;
    _token = extractedUserData['token'];
    _user = User(
      id: extractedUserData['userId'],
      name: extractedUserData['name'],
      email: extractedUserData['email'],
      profilePhotoUrl: extractedUserData['profilePhotoUrl'],
      token: _token,
    );
    notifyListeners();
    return true;
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse('${AppConstants.baseUrl}/login');
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
        throw Exception(responseData['message'] ?? 'Login failed');
      }

      // Laravel API returns: { success: true, data: { user: {...}, token: "..." } }
      final data = responseData['data'] ?? responseData;
      _token = data['token'];
      final userJson = data['user'];
      _user = User.fromJson(userJson..['token'] = _token);

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
    } catch (error) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(
    String name,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse('${AppConstants.baseUrl}/register');
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
        // Laravel validation errors usually return 422
        if (response.statusCode == 422) {
          final errors = responseData['errors'];
          if (errors != null && errors is Map<String, dynamic>) {
            String errorMessage = '';
            for (var errorList in errors.values) {
              if (errorList is List) {
                errorMessage += errorList.join(' ');
              }
            }
            throw Exception(
              errorMessage.isNotEmpty ? errorMessage : 'Validation failed',
            );
          }
        }
        throw Exception(responseData['message'] ?? 'Registration failed');
      }

      // Auto login after register if API returns token, otherwise user needs to login
      if (responseData['token'] != null) {
        _token = responseData['token'];
        final userJson = responseData['user'];
        userJson['token'] = _token;
        _user = User.fromJson(userJson);

        final prefs = await SharedPreferences.getInstance();
        final userData = json.encode({
          'token': _token,
          'userId': _user!.id,
          'name': _user!.name,
          'email': _user!.email,
          'profilePhotoUrl': _user!.profilePhotoUrl,
        });
        await prefs.setString('userData', userData);
      }
    } catch (error) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    // Call API logout if needed
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
    notifyListeners();
  }
}
