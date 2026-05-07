import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/place.dart';
import 'favorites_notifier.dart';
import 'place_list_filter.dart';
import 'places_notifier.dart';
import 'search_filter_providers.dart';

/// Applies search text, filter chips, optional album (region), and sort to loaded places.
final displayedPlacesProvider = Provider<AsyncValue<List<Place>>>((ref) {
  final placesAsync = ref.watch(placesProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final filter = ref.watch(placeListFilterProvider);
  final sort = ref.watch(searchSortProvider);
  final region = ref.watch(regionFilterProvider);
  final favAsync = ref.watch(favoritesProvider);
  final favorites = favAsync.valueOrNull ?? <int>{};

  return placesAsync.when(
    data: (view) {
      var list = List<Place>.from(view.items);

      if (region != null) {
        list = list.where((p) => p.albumId == region).toList();
      }

      if (filter == PlaceListFilter.favorites) {
        list = list.where((p) => favorites.contains(p.id)).toList();
      } else if (filter == PlaceListFilter.recent) {
        list = [...list]..sort((a, b) => b.id.compareTo(a.id));
      }

      if (query.isNotEmpty) {
        list = list
            .where((p) => p.title.toLowerCase().contains(query))
            .toList();
      }

      switch (sort) {
        case PlaceSortMode.recommended:
          break;
        case PlaceSortMode.nameAZ:
          list.sort((a, b) => a.title.compareTo(b.title));
          break;
        case PlaceSortMode.recentIds:
          list.sort((a, b) => b.id.compareTo(a.id));
          break;
      }

      return AsyncData(list);
    },
    loading: () => const AsyncLoading(),
    error: (e, s) => AsyncError(e, s),
  );
});
