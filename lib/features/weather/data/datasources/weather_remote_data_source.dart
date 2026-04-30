import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

abstract class WeatherRemoteDataSource {
  Future<WeatherModel> getWeather(String cityName);
}

class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  final http.Client client;
  static const String apiKey =
      'b7f73a4f451c8ee834406c3cfab4a8e9'; // Key của bạn
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';

  WeatherRemoteDataSourceImpl({required this.client});

  @override
  Future<WeatherModel> getWeather(String cityName) async {
    // Gọi song song 2 API để lấy full data
    final weatherUrl = Uri.parse(
      '$baseUrl/weather?q=$cityName&appid=$apiKey&units=metric&lang=vi',
    );
    final forecastUrl = Uri.parse(
      '$baseUrl/forecast?q=$cityName&appid=$apiKey&units=metric&lang=vi',
    );

    final responses = await Future.wait([
      client.get(weatherUrl),
      client.get(forecastUrl),
    ]);

    if (responses[0].statusCode == 200 && responses[1].statusCode == 200) {
      final weatherJson = jsonDecode(responses[0].body);
      final forecastJson = jsonDecode(responses[1].body);

      // Gộp 8 mốc thời gian (24 tiếng tới) vào chung JSON
      weatherJson['forecast'] = forecastJson['list'].take(8).toList();

      return WeatherModel.fromJson(weatherJson);
    } else {
      throw Exception('Không tải được dữ liệu từ API');
    }
  }
}
