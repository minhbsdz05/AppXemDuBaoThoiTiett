import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../../core/network/network_info.dart';
import '../../data/datasources/weather_local_data_source.dart';
import '../../data/datasources/weather_remote_data_source.dart';
import '../../data/repositories/weather_repository_impl.dart';
import '../../domain/entities/weather_entity.dart';

final httpClientProvider = Provider((ref) => http.Client());
final connectivityProvider = Provider((ref) => Connectivity());
final networkInfoProvider = Provider<NetworkInfo>(
  (ref) => NetworkInfoImpl(ref.watch(connectivityProvider)),
);

final remoteDataSourceProvider = Provider<WeatherRemoteDataSource>(
  (ref) => WeatherRemoteDataSourceImpl(client: ref.watch(httpClientProvider)),
);
final localDataSourceProvider = Provider<WeatherLocalDataSource>(
  (ref) => WeatherLocalDataSourceImpl(),
);

final weatherRepositoryProvider = Provider((ref) {
  return WeatherRepositoryImpl(
    remoteDataSource: ref.watch(remoteDataSourceProvider),
    localDataSource: ref.watch(localDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

final weatherProvider = FutureProvider.family<WeatherEntity, String>((
  ref,
  cityName,
) async {
  final repository = ref.watch(weatherRepositoryProvider);
  return await repository.getWeather(cityName);
});
