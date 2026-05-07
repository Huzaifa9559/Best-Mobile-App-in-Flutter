abstract class FavoritesRepository {
  Future<Set<int>> getFavoriteIds();
  Future<void> toggleFavorite(int placeId);
  Future<bool> isFavorite(int placeId);
}
