import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../providers/place_list_filter.dart';
import '../providers/places_notifier.dart';
import '../providers/search_filter_providers.dart';

class SearchFilterScreen extends ConsumerWidget {
  const SearchFilterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sort = ref.watch(searchSortProvider);
    final filter = ref.watch(placeListFilterProvider);
    final region = ref.watch(regionFilterProvider);
    final albums = ref.watch(placesProvider).maybeWhen(
          data: (v) {
            final ids = v.items.map((p) => p.albumId).toSet().toList();
            ids.sort();
            return ids;
          },
          orElse: () => <int>[],
        );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search & Filters'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Sort by',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<PlaceSortMode>(
              value: sort,
              items: const [
                DropdownMenuItem(
                  value: PlaceSortMode.recommended,
                  child: Text('Recommended'),
                ),
                DropdownMenuItem(
                  value: PlaceSortMode.nameAZ,
                  child: Text('Name (A–Z)'),
                ),
                DropdownMenuItem(
                  value: PlaceSortMode.recentIds,
                  child: Text('Recent IDs'),
                ),
              ],
              onChanged: (v) {
                if (v != null) {
                  ref.read(searchSortProvider.notifier).state = v;
                }
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Show',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: filter == PlaceListFilter.all,
                  onSelected: (_) => ref
                      .read(placeListFilterProvider.notifier)
                      .state = PlaceListFilter.all,
                ),
                ChoiceChip(
                  label: const Text('Favorites'),
                  selected: filter == PlaceListFilter.favorites,
                  onSelected: (_) => ref
                      .read(placeListFilterProvider.notifier)
                      .state = PlaceListFilter.favorites,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Region (album)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int?>(
              value: region,
              hint: const Text('All Regions'),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('All Regions'),
                ),
                ...albums.map(
                  (a) => DropdownMenuItem<int?>(
                    value: a,
                    child: Text('Album $a'),
                  ),
                ),
              ],
              onChanged: (v) => ref.read(regionFilterProvider.notifier).state = v,
            ),
            const Spacer(),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () => context.pop(),
              child: const Text('Apply Filters'),
            ),
          ],
        ),
      ),
    );
  }
}
