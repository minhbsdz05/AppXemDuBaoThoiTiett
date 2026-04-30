class HourlyForecast {
  final DateTime time;
  final double temp;
  final String iconCode;
  final int rainChance;

  HourlyForecast({
    required this.time,
    required this.temp,
    required this.iconCode,
    required this.rainChance,
  });
}

class WeatherEntity {
  final String city;
  final double temperature;
  final double feelsLike;
  final String condition;
  final String iconCode;
  final int humidity;
  final double windSpeed;
  final DateTime sunrise;
  final DateTime sunset;
  final List<HourlyForecast> hourlyForecasts;
  final bool isCachedData;

  WeatherEntity({
    required this.city,
    required this.temperature,
    required this.feelsLike,
    required this.condition,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
    required this.sunrise,
    required this.sunset,
    required this.hourlyForecasts,
    this.isCachedData = false,
  });
}
