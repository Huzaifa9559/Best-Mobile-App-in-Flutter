import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../models/weather_model.dart';

abstract class WeatherRemoteDataSource {
  Future<WeatherModel> fetchCurrentWeather({
    required double latitude,
    required double longitude,
  });
}

class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  WeatherRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<WeatherModel> fetchCurrentWeather({
    required double latitude,
    required double longitude,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.openMeteoForecast,
      queryParameters: <String, dynamic>{
        'latitude': latitude,
        'longitude': longitude,
        'current':
            'temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,is_day,wind_speed_10m',
      },
    );
    final data = response.data;
    if (data == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: 'Empty weather body',
      );
    }
    return WeatherModel.fromOpenMeteoJson(data);
  }
}
