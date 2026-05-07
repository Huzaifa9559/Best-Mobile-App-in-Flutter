import '../entities/weather.dart';

abstract class WeatherRepository {
  Future<Weather> getCurrentWeather({
    required double latitude,
    required double longitude,
  });
}
