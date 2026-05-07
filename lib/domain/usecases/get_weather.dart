import '../entities/weather.dart';
import '../repositories/weather_repository.dart';

class GetWeather {
  GetWeather(this._repository);

  final WeatherRepository _repository;

  Future<Weather> call({
    required double latitude,
    required double longitude,
  }) =>
      _repository.getCurrentWeather(
        latitude: latitude,
        longitude: longitude,
      );
}
