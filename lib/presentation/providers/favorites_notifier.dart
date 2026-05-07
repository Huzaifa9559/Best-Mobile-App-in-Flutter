import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dependency_injection.dart';

class FavoritesNotifier extends AsyncNotifier<Set<int>> {
  @override
  Future<Set<int>> build() {
    return ref.read(favoritesRepositoryProvider).getFavoriteIds();
  }

  Future<void> toggle(int placeId) async {
    await ref.read(toggleFavoriteUseCaseProvider).call(placeId);
    state = AsyncData(await ref.read(favoritesRepositoryProvider).getFavoriteIds());
  }

  Future<bool> isFavorite(int placeId) async {
    final ids = state.value ?? {};
    return ids.contains(placeId);
  }
}

final favoritesProvider =
    AsyncNotifierProvider<FavoritesNotifier, Set<int>>(FavoritesNotifier.new);
