import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/place.dart';
import '../../domain/entities/weather.dart';
import 'dependency_injection.dart';

final weatherForPlaceProvider = FutureProvider.family<Weather, Place>((
  ref,
  place,
) async {
  final (lat, lon) = place.coordinates;
  return ref.read(getWeatherUseCaseProvider).call(
        latitude: lat,
        longitude: lon,
      );
});
