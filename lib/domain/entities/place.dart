import 'package:equatable/equatable.dart';

/// Travel place sourced from JSONPlaceholder photos API.
class Place extends Equatable {
  const Place({
    required this.id,
    required this.albumId,
    required this.title,
    required this.url,
    required this.thumbnailUrl,
  });

  final int id;
  final int albumId;
  final String title;
  final String url;
  final String thumbnailUrl;

  /// Deterministic demo coordinates for maps / weather.
  (double lat, double lon) get coordinates {
    final lat =
        ((id * 17) % 160 - 80).toDouble().clamp(-60.0, 60.0);
    final lon =
        ((id * 31) % 360 - 180).toDouble().clamp(-180.0, 180.0);
    return (lat, lon);
  }

  String get displayTitle =>
      title.split(' ').take(4).join(' ').trim().isEmpty
          ? 'Place $id'
          : title.split(' ').take(4).join(' ');

  String get regionLabel => 'Album $albumId';

  @override
  List<Object?> get props => [id, albumId, title, url, thumbnailUrl];
}
