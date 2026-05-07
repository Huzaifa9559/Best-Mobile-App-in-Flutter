import '../../domain/repositories/favorites_repository.dart';
import '../datasources/local/favorites_local_datasource.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl(this._local);

  final FavoritesLocalDataSource _local;

  @override
  Future<Set<int>> getFavoriteIds() => _local.getFavoriteIds();

  @override
  Future<bool> isFavorite(int placeId) async {
    final ids = await _local.getFavoriteIds();
    return ids.contains(placeId);
  }

  @override
  Future<void> toggleFavorite(int placeId) async {
    final ids = await _local.getFavoriteIds();
    if (ids.contains(placeId)) {
      ids.remove(placeId);
    } else {
      ids.add(placeId);
    }
    await _local.saveFavoriteIds(ids);
  }
}
