import '../../domain/entities/weather.dart';

class WeatherModel extends Weather {
  const WeatherModel({
    required super.temperatureC,
    required super.windspeedKmh,
    required super.weatherCode,
    required super.isDay,
    super.humidityPct,
    super.apparentTemperatureC,
  });

  factory WeatherModel.fromOpenMeteoJson(Map<String, dynamic> json) {
    final cur = json['current'] as Map<String, dynamic>? ??
        (throw const FormatException('Missing Open-Meteo current payload'));

    return WeatherModel(
      temperatureC: (cur['temperature_2m'] as num).toDouble(),
      windspeedKmh: (cur['wind_speed_10m'] as num?)?.toDouble() ?? 0,
      weatherCode: (cur['weather_code'] as num).toInt(),
      isDay: (cur['is_day'] as num?)?.toInt() ?? 1,
      humidityPct: (cur['relative_humidity_2m'] as num?)?.toDouble(),
      apparentTemperatureC: (cur['apparent_temperature'] as num?)?.toDouble(),
    );
  }

  Weather toEntity() => Weather(
        temperatureC: temperatureC,
        windspeedKmh: windspeedKmh,
        weatherCode: weatherCode,
        isDay: isDay,
        humidityPct: humidityPct,
        apparentTemperatureC: apparentTemperatureC,
      );
}
