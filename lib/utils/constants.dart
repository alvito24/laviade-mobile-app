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
  // Use localhost for Windows, 10.0.2.2 for Android Emulator
  static const String baseUrl = 'http://localhost:8000/api/v1'; 
}
