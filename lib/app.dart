// lib/app.dart

import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart'; // Import bộ Theme chuẩn doanh nghiệp
import 'features/weather/presentation/pages/weather_home_page.dart'; // Import trang chủ

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dự Báo Thời Tiết',
      debugShowCheckedModeBanner: false, // Ẩn chữ DEBBUG ở góc phải

      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Ép ứng dụng luôn dùng Dark Mode cho đẹp
      // Khởi động vào trang Home
      home: const WeatherHomePage(),
    );
  }
}
