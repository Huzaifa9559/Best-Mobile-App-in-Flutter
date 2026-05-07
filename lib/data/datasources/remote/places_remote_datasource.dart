import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../models/place_model.dart';

abstract class PlacesRemoteDataSource {
  Future<List<PlaceModel>> fetchPhotos({
    int start = 0,
    int limit = 20,
  });
}

class PlacesRemoteDataSourceImpl implements PlacesRemoteDataSource {
  PlacesRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<PlaceModel>> fetchPhotos({
    int start = 0,
    int limit = 20,
  }) async {
    final response = await _dio.get<dynamic>(
      ApiConstants.jsonPlaceholderPhotos,
      queryParameters: <String, dynamic>{
        '_start': start,
        '_limit': limit,
      },
    );
    final data = response.data;
    if (data is! List<dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: 'Expected JSON array of places',
      );
    }
    return data
        .map((e) => PlaceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
