import 'package:hive_flutter/hive_flutter.dart';

abstract class FavoritesLocalDataSource {
  Future<Set<int>> getFavoriteIds();
  Future<void> saveFavoriteIds(Set<int> ids);
}

class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  FavoritesLocalDataSourceImpl(this._box);

  final Box<dynamic> _box;

  static const String _key = 'favorite_place_ids';

  @override
  Future<Set<int>> getFavoriteIds() async {
    final raw = _box.get(_key);
    if (raw is List) {
      return raw.map((e) => e as int).toSet();
    }
    return {};
  }

  @override
  Future<void> saveFavoriteIds(Set<int> ids) async {
    await _box.put(_key, ids.toList());
  }
}
