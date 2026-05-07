import '../repositories/favorites_repository.dart';

class ToggleFavorite {
  ToggleFavorite(this._repository);

  final FavoritesRepository _repository;

  Future<void> call(int placeId) => _repository.toggleFavorite(placeId);
}
