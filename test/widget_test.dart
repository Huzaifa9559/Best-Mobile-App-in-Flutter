import 'package:flutter_test/flutter_test.dart';
import 'package:smart_travel_companion/domain/entities/place.dart';

void main() {
  test('Place coordinates are deterministic', () {
    const p = Place(
      id: 7,
      albumId: 1,
      title: 'Test place title',
      url: 'https://example.com/600/1',
      thumbnailUrl: 'https://example.com/150/1',
    );
    final (lat, lon) = p.coordinates;
    expect(lat, inInclusiveRange(-60, 60));
    expect(lon, inInclusiveRange(-180, 180));
  });
}
