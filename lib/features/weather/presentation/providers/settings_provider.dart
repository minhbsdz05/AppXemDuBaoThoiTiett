// lib/features/weather/presentation/providers/settings_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- ENUMS CHO CÁC ĐƠN VỊ ---
enum TempUnit { celsius, fahrenheit }

enum WindUnit { kmh, mph, ms }

// --- LỚP TRẠNG THÁI (STATE) ---
class SettingsState {
  final bool isDarkMode;
  final TempUnit tempUnit;
  final WindUnit windUnit;
  final bool notificationsEnabled;

  SettingsState({
    this.isDarkMode = true, // Mặc định là Dark Mode cho đẹp với app thời tiết
    this.tempUnit = TempUnit.celsius,
    this.windUnit = WindUnit.kmh,
    this.notificationsEnabled = false,
  });

  SettingsState copyWith({
    bool? isDarkMode,
    TempUnit? tempUnit,
    WindUnit? windUnit,
    bool? notificationsEnabled,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      tempUnit: tempUnit ?? this.tempUnit,
      windUnit: windUnit ?? this.windUnit,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

// --- PROVIDER ---
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    return SettingsNotifier();
  },
);

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState()) {
    _loadSettings();
  }

  // Khóa lưu trữ Local
  static const _keyTheme = 'setting_theme';
  static const _keyTemp = 'setting_temp';
  static const _keyWind = 'setting_wind';
  static const _keyNoti = 'setting_noti';

  // 1. Tải cấu hình từ SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = SettingsState(
      isDarkMode: prefs.getBool(_keyTheme) ?? true,
      tempUnit: TempUnit.values[prefs.getInt(_keyTemp) ?? 0],
      windUnit: WindUnit.values[prefs.getInt(_keyWind) ?? 0],
      notificationsEnabled: prefs.getBool(_keyNoti) ?? false,
    );
  }

  // 2. Các hàm cập nhật và lưu Local
  Future<void> toggleTheme(bool isDark) async {
    state = state.copyWith(isDarkMode: isDark);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTheme, isDark);
  }

  Future<void> setTempUnit(TempUnit unit) async {
    state = state.copyWith(tempUnit: unit);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTemp, unit.index);
  }

  Future<void> setWindUnit(WindUnit unit) async {
    state = state.copyWith(windUnit: unit);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyWind, unit.index);
  }

  Future<void> toggleNotifications(bool isEnabled) async {
    state = state.copyWith(notificationsEnabled: isEnabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNoti, isEnabled);
  }
}
