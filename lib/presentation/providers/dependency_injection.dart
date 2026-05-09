import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/network/network_info.dart';
import '../../data/datasources/local/favorites_local_datasource.dart';
import '../../data/datasources/local/places_local_datasource.dart';
import '../../data/datasources/remote/places_remote_datasource.dart';
import '../../data/datasources/remote/weather_remote_datasource.dart';
import '../../data/repositories/favorites_repository_impl.dart';
import '../../data/repositories/places_repository_impl.dart';
import '../../data/repositories/weather_repository_impl.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../domain/repositories/places_repository.dart';
import '../../domain/repositories/weather_repository.dart';
import '../../domain/usecases/get_places.dart';
import '../../domain/usecases/get_weather.dart';
import '../../domain/usecases/toggle_favorite.dart';

final placesBoxProvider = Provider<Box<dynamic>>((ref) {
  throw UnimplementedError('placesBoxProvider must be overridden');
});

final appBoxProvider = Provider<Box<dynamic>>((ref) {
  throw UnimplementedError('appBoxProvider must be overridden');
});

final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      connectTimeout: kIsWeb ? null : const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );
});

final connectivityProvider = Provider<Connectivity>((ref) => Connectivity());

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(ref.watch(connectivityProvider));
});

final placesRemoteDsProvider = Provider<PlacesRemoteDataSource>((ref) {
  return PlacesRemoteDataSourceImpl(ref.watch(dioProvider));
});

final weatherRemoteDsProvider = Provider<WeatherRemoteDataSource>((ref) {
  return WeatherRemoteDataSourceImpl(ref.watch(dioProvider));
});

final placesLocalDsProvider = Provider<PlacesLocalDataSource>((ref) {
  return PlacesLocalDataSourceImpl(ref.watch(placesBoxProvider));
});

final favoritesLocalDsProvider = Provider<FavoritesLocalDataSource>((ref) {
  return FavoritesLocalDataSourceImpl(ref.watch(appBoxProvider));
});

final placesRepositoryProvider = Provider<PlacesRepository>((ref) {
  return PlacesRepositoryImpl(
    networkInfo: ref.watch(networkInfoProvider),
    remote: ref.watch(placesRemoteDsProvider),
    local: ref.watch(placesLocalDsProvider),
  );
});

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return WeatherRepositoryImpl(ref.watch(weatherRemoteDsProvider));
});

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepositoryImpl(ref.watch(favoritesLocalDsProvider));
});

final getPlacesUseCaseProvider = Provider<GetPlaces>((ref) {
  return GetPlaces(ref.watch(placesRepositoryProvider));
});

final getWeatherUseCaseProvider = Provider<GetWeather>((ref) {
  return GetWeather(ref.watch(weatherRepositoryProvider));
});

final toggleFavoriteUseCaseProvider = Provider<ToggleFavorite>((ref) {
  return ToggleFavorite(ref.watch(favoritesRepositoryProvider));
});
