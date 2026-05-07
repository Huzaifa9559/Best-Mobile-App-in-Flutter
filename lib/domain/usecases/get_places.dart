import '../entities/place.dart';
import '../repositories/places_repository.dart';

class GetPlaces {
  GetPlaces(this._repository);

  final PlacesRepository _repository;

  Future<List<Place>> call({
    int start = 0,
    int limit = 20,
    bool forceRefresh = false,
  }) {
    return _repository.getPlaces(
      start: start,
      limit: limit,
      forceRefresh: forceRefresh,
    );
  }
}
