import 'package:equatable/equatable.dart';

class Weather extends Equatable {
  const Weather({
    required this.temperatureC,
    required this.windspeedKmh,
    required this.weatherCode,
    required this.isDay,
    this.humidityPct,
    this.apparentTemperatureC,
  });

  final double temperatureC;
  final double windspeedKmh;
  final int weatherCode;
  final int isDay;
  final double? humidityPct;
  final double? apparentTemperatureC;

  String get conditionLabel => _labelForCode(weatherCode);

  static String _labelForCode(int code) {
    if (code == 0) return 'Clear sky';
    if (code <= 3) return 'Partly cloudy';
    if (code <= 48) return 'Foggy';
    if (code <= 67) return 'Rain / Drizzle';
    if (code <= 77) return 'Snow';
    if (code <= 82) return 'Rain showers';
    if (code <= 86) return 'Snow showers';
    if (code <= 99) return 'Thunderstorm';
    return 'Variable';
  }

  @override
  List<Object?> get props => [
        temperatureC,
        windspeedKmh,
        weatherCode,
        isDay,
        humidityPct,
        apparentTemperatureC,
      ];
}
