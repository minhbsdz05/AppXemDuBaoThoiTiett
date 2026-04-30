import '../../domain/entities/weather_entity.dart';

class WeatherModel extends WeatherEntity {
  WeatherModel({
    required super.city,
    required super.temperature,
    required super.feelsLike,
    required super.condition,
    required super.iconCode,
    required super.humidity,
    required super.windSpeed,
    required super.sunrise,
    required super.sunset,
    required super.hourlyForecasts,
    super.isCachedData,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    var hourlyList = <HourlyForecast>[];
    if (json['forecast'] != null) {
      hourlyList = (json['forecast'] as List)
          .map(
            (e) => HourlyForecast(
              time: DateTime.parse(e['dt_txt']),
              temp: e['main']['temp'].toDouble(),
              iconCode: e['weather'][0]['icon'],
              rainChance: (e['pop'] * 100).round(),
            ),
          )
          .toList();
    }

    return WeatherModel(
      city: json['name'] ?? '',
      temperature: (json['main']['temp'] ?? 0).toDouble(),
      feelsLike: (json['main']['feels_like'] ?? 0).toDouble(),
      condition: json['weather'][0]['description'] ?? '',
      iconCode: json['weather'][0]['icon'] ?? '01d',
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: (json['wind']['speed'] ?? 0).toDouble(),
      sunrise: DateTime.fromMillisecondsSinceEpoch(
        (json['sys']['sunrise'] ?? 0) * 1000,
      ),
      sunset: DateTime.fromMillisecondsSinceEpoch(
        (json['sys']['sunset'] ?? 0) * 1000,
      ),
      hourlyForecasts: hourlyList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': city,
      'main': {
        'temp': temperature,
        'feels_like': feelsLike,
        'humidity': humidity,
      },
      'weather': [
        {'description': condition, 'icon': iconCode},
      ],
      'wind': {'speed': windSpeed},
      'sys': {
        'sunrise': sunrise.millisecondsSinceEpoch ~/ 1000,
        'sunset': sunset.millisecondsSinceEpoch ~/ 1000,
      },
      'forecast': hourlyForecasts
          .map(
            (e) => {
              'dt_txt': e.time.toIso8601String(),
              'main': {'temp': e.temp},
              'weather': [
                {'icon': e.iconCode},
              ],
              'pop': e.rainChance / 100.0,
            },
          )
          .toList(),
    };
  }
}
