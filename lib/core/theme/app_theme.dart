// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';

/// 1. QUẢN LÝ KHOẢNG CÁCH (SPACING) ĐỒNG NHẤT
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

/// 2. QUẢN LÝ MÀU SẮC CHỦ ĐẠO
class AppColors {
  static const Color primaryDark = Color(0xFF0F2027);
  static const Color primaryMedium = Color(0xFF203A43);
  static const Color primaryLight = Color(0xFF2C5364);
  static const Color accent = Colors.amberAccent;
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color glassBackground = Color(
    0x1AFFFFFF,
  ); // Trắng trong suốt 10%
  static const Color glassBorder = Color(0x33FFFFFF); // Trắng trong suốt 20%
}

/// 3. CẤU HÌNH MATERIAL 3 & TYPOGRAPHY
class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.transparent, // Để lộ nền Gradient
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        surface: AppColors.primaryDark,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 80,
          fontWeight: FontWeight.w200,
          color: AppColors.textPrimary,
          height: 1.1,
        ),
        headlineLarge: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          letterSpacing: 1.2,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: 1.5,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: AppColors.textPrimary),
        bodyMedium: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        labelSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
