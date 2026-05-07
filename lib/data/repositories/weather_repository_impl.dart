import '../../domain/entities/weather.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/remote/weather_remote_datasource.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  WeatherRepositoryImpl(this._remote);

  final WeatherRemoteDataSource _remote;

  @override
  Future<Weather> getCurrentWeather({
    required double latitude,
    required double longitude,
  }) async {
    final model = await _remote.fetchCurrentWeather(
      latitude: latitude,
      longitude: longitude,
    );
    return model.toEntity();
  }
}
