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
    return PlaceModel(
      id: json['id'] as int,
      albumId: json['albumId'] as int,
      title: json['title'] as String,
      url: json['url'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
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
