import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';

abstract class WeatherLocalDataSource {
  Future<void> cacheWeather(String cityName, WeatherModel weather);
  Future<WeatherModel> getLastWeather(String cityName);
}

class WeatherLocalDataSourceImpl implements WeatherLocalDataSource {
  @override
  Future<void> cacheWeather(String cityName, WeatherModel weather) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
      'CACHE_${cityName.toUpperCase()}',
      jsonEncode(weather.toJson()),
    );
  }

  @override
  Future<WeatherModel> getLastWeather(String cityName) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('CACHE_${cityName.toUpperCase()}');
    if (jsonString != null) {
      return WeatherModel.fromJson(jsonDecode(jsonString));
    } else {
      throw Exception('Không có dữ liệu offline cho thành phố này');
    }
  }
}
