import '../../domain/entities/weather_entity.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/weather_local_data_source.dart';
import '../datasources/weather_remote_data_source.dart';
import '../../../../core/network/network_info.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource remoteDataSource;
  final WeatherLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  WeatherRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<WeatherEntity> getWeather(String cityName) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteWeather = await remoteDataSource.getWeather(cityName);
        await localDataSource.cacheWeather(cityName, remoteWeather);
        return remoteWeather;
      } catch (e) {
        return _getCachedData(cityName);
      }
    } else {
      return _getCachedData(cityName);
    }
  }

  Future<WeatherEntity> _getCachedData(String cityName) async {
    final localWeather = await localDataSource.getLastWeather(cityName);
    return WeatherEntity(
      city: localWeather.city,
      temperature: localWeather.temperature,
      feelsLike: localWeather.feelsLike,
      condition: localWeather.condition,
      iconCode: localWeather.iconCode,
      humidity: localWeather.humidity,
      windSpeed: localWeather.windSpeed,
      sunrise: localWeather.sunrise,
      sunset: localWeather.sunset,
      hourlyForecasts: localWeather.hourlyForecasts,
      isCachedData: true,
    );
  }
}
