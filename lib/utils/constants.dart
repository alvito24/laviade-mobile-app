import 'package:flutter/material.dart';
import 'dart:io' show Platform;

class AppColors {
  static const Color primary = Colors.black;
  static const Color background = Colors.white;
  static const Color cardBackground = Color(0xFFF5F5F5); // Light Grey
  static const Color textPrimary = Colors.black;
  static const Color textSecondary = Colors.grey;
  static const Color accent = Color(0xFF2B2B2B); // Dark accent
  static const Color error = Colors.redAccent;
  static const Color success = Color(0xFF4CAF50);
}

class AppConstants {
  // Base URL Configuration
  // - Android Emulator: 10.0.2.2
  // - iOS Simulator: localhost
  // - Physical Device: Your computer's local IP (e.g., 192.168.1.100)
  // - Production: Your actual domain

  static String get baseUrl {
    // For development, detect platform
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api/v1'; // Android Emulator
    } else if (Platform.isIOS) {
      return 'http://localhost:8000/api/v1'; // iOS Simulator
    }
    return 'http://localhost:8000/api/v1'; // Fallback
  }

  // Use this for physical device testing - replace with your IP
  // static const String baseUrl = 'http://192.168.1.100:8000/api/v1';

  // API Endpoints
  static const String loginEndpoint = '/login';
  static const String registerEndpoint = '/register';
  static const String logoutEndpoint = '/logout';
  static const String userEndpoint = '/user';
  static const String productsEndpoint = '/products';
  static const String cartEndpoint = '/cart';
  static const String ordersEndpoint = '/orders';
  static const String checkoutEndpoint = '/checkout';
  static const String profileEndpoint = '/profile';
  static const String addressesEndpoint = '/addresses';
  static const String wishlistEndpoint = '/wishlist';
  static const String bannersEndpoint = '/banners';
  static const String categoriesEndpoint = '/categories';
}
