import '../../domain/entities/place.dart';

class PlaceModel extends Place {
  const PlaceModel({
    required super.id,
    required super.albumId,
    required super.title,
    required super.url,
    required super.thumbnailUrl,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int;
    return PlaceModel(
      id: id,
      albumId: json['albumId'] as int,
      title: json['title'] as String,
      url: 'https://picsum.photos/seed/$id/600/400',
      thumbnailUrl: 'https://picsum.photos/seed/$id/150/150',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'albumId': albumId,
        'title': title,
        'url': url,
        'thumbnailUrl': thumbnailUrl,
      };

  Place toEntity() => Place(
        id: id,
        albumId: albumId,
        title: title,
        url: url,
        thumbnailUrl: thumbnailUrl,
      );
}
