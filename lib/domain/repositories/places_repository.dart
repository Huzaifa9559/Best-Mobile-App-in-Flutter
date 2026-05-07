import '../entities/place.dart';

abstract class PlacesRepository {
  Future<List<Place>> getPlaces({
    int start = 0,
    int limit = 20,
    bool forceRefresh = false,
  });
}
