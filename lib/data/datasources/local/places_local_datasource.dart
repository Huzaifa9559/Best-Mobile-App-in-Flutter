import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../../models/place_model.dart';

abstract class PlacesLocalDataSource {
  Future<void> cachePlacesJson(String jsonList);
  Future<List<PlaceModel>> readCachedPlaces();

  /// Merges [places] into stored cache by id (upsert).
  Future<void> mergePlaces(List<PlaceModel> places);
}

class PlacesLocalDataSourceImpl implements PlacesLocalDataSource {
  PlacesLocalDataSourceImpl(this._box);

  final Box<dynamic> _box;

  static const String _key = 'places_json';

  @override
  Future<void> cachePlacesJson(String jsonList) async {
    await _box.put(_key, jsonList);
  }

  @override
  Future<List<PlaceModel>> readCachedPlaces() async {
    final raw = _box.get(_key);
    if (raw is! String || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => PlaceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> mergePlaces(List<PlaceModel> places) async {
    final existing = await readCachedPlaces();
    final byId = <int, PlaceModel>{
      for (final p in existing) p.id: p,
    };
    for (final p in places) {
      byId[p.id] = p;
    }
    final merged = byId.values.toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    await cachePlacesJson(jsonEncode(merged.map((e) => e.toJson()).toList()));
  }
}
