import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'place_list_filter.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final placeListFilterProvider =
    StateProvider<PlaceListFilter>((ref) => PlaceListFilter.all);

final searchSortProvider =
    StateProvider<PlaceSortMode>((ref) => PlaceSortMode.recommended);

final regionFilterProvider = StateProvider<int?>((ref) => null);
