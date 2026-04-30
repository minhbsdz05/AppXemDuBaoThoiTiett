// lib/features/weather/presentation/providers/location_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider quản lý danh sách thành phố
final savedLocationsProvider =
    StateNotifierProvider<LocationNotifier, List<String>>((ref) {
      return LocationNotifier();
    });

class LocationNotifier extends StateNotifier<List<String>> {
  LocationNotifier() : super(['Hanoi', 'Ho Chi Minh']) {
    _loadLocations(); // Load dữ liệu khi app khởi động
  }

  static const _key = 'saved_cities';

  // Tải danh sách từ Local Storage
  Future<void> _loadLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCities = prefs.getStringList(_key);
    if (savedCities != null && savedCities.isNotEmpty) {
      state = savedCities;
    }
  }

  // Thêm thành phố mới
  Future<void> addCity(String city) async {
    if (!state.contains(city)) {
      final newState = [...state, city];
      state = newState;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, newState);
    }
  }

  // Xóa thành phố
  Future<void> removeCity(String city) async {
    final newState = state.where((c) => c != city).toList();
    // Đảm bảo luôn có ít nhất 1 thành phố
    if (newState.isNotEmpty) {
      state = newState;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, newState);
    }
  }
}
