import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Colors.black;
  static const Color background = Colors.white;
  static const Color cardBackground = Color(0xFFF5F5F5); // Light Grey
  static const Color textPrimary = Colors.black;
  static const Color textSecondary = Colors.grey;
  static const Color accent = Color(0xFFC0C0C0); // Silver
  static const Color error = Colors.redAccent;
}

class AppConstants {
  // Base URL configuration for different environments
  // Android Emulator: 10.0.2.2
  // iOS Simulator: localhost
  // Physical Device: Your computer's local IP (e.g., 192.168.1.100)

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/api/v1';
    }

    // For mobile platforms
    if (Platform.isAndroid) {
      // Android Emulator uses 10.0.2.2 to access host machine
      return 'http://10.0.2.2:8000/api/v1';
    } else if (Platform.isIOS) {
      // iOS Simulator can use localhost
      return 'http://localhost:8000/api/v1';
    }

    // Default fallback
    return 'http://localhost:8000/api/v1';
  }

  // For physical device testing, use your computer's IP
  // Uncomment and replace with your IP when testing on real device:
  // static const String baseUrl = 'http://192.168.1.XXX:8000/api/v1';

  static String get storageUrl {
    // Base URL for accessing storage/images
    final base = baseUrl.replaceAll('/api/v1', '');
    return '$base/storage';
  }

  // Helper to get full image URL
  static String getImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return 'https://via.placeholder.com/300x300?text=No+Image';
    }
    if (path.startsWith('http')) {
      return path;
    }
    return '$storageUrl/$path';
  }
}
