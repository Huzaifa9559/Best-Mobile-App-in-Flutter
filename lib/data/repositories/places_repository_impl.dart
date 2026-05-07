import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/place.dart';
import '../../domain/repositories/places_repository.dart';
import '../datasources/local/places_local_datasource.dart';
import '../datasources/remote/places_remote_datasource.dart';

class PlacesRepositoryImpl implements PlacesRepository {
  PlacesRepositoryImpl({
    required NetworkInfo networkInfo,
    required PlacesRemoteDataSource remote,
    required PlacesLocalDataSource local,
  })  : _networkInfo = networkInfo,
        _remote = remote,
        _local = local;

  final NetworkInfo _networkInfo;
  final PlacesRemoteDataSource _remote;
  final PlacesLocalDataSource _local;

  @override
  Future<List<Place>> getPlaces({
    int start = 0,
    int limit = 20,
    bool forceRefresh = false,
  }) async {
    final online = await _networkInfo.isConnected;

    if (online) {
      try {
        if (forceRefresh && start == 0) {
          await _local.cachePlacesJson('[]');
        }
        final models =
            await _remote.fetchPhotos(start: start, limit: limit);
        await _local.mergePlaces(models);
        return models.map((m) => m.toEntity()).toList();
      } catch (_) {
        final cached = await _local.readCachedPlaces();
        if (cached.isNotEmpty) {
          final slice = cached.skip(start).take(limit).toList();
          return slice.map((m) => m.toEntity()).toList();
        }
        throw const ServerFailure('Could not load places');
      }
    }

    final cached = await _local.readCachedPlaces();
    if (cached.isEmpty) {
      throw const CacheFailure('No offline data');
    }
    final slice = cached.skip(start).take(limit).toList();
    return slice.map((m) => m.toEntity()).toList();
  }
}
