import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../domain/entities/place.dart';
import '../providers/filtered_places_provider.dart';
import '../providers/place_list_filter.dart';
import '../providers/places_notifier.dart';
import '../providers/search_filter_providers.dart';
import '../providers/theme_mode_provider.dart';
import '../widgets/animated_places_list.dart';
import '../widgets/app_drawer.dart';
import '../widgets/offline_banner.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchController.text = ref.read(searchQueryProvider);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(searchQueryProvider.notifier).state = value.trim();
    });
  }

  void _openDetail(Place place) {
    context.push('/detail/${place.id}', extra: place);
  }

  @override
  Widget build(BuildContext context) {
    final placesAsync = ref.watch(placesProvider);
    final displayed = ref.watch(displayedPlacesProvider);
    final filter = ref.watch(placeListFilterProvider);
    final query = ref.watch(searchQueryProvider);
    final sort = ref.watch(searchSortProvider);
    final epoch = placesAsync.valueOrNull?.epoch ?? 0;
    final listIdentity = '$epoch-${filter.name}-$query-${sort.name}';
    final activeFilterCount = (sort != PlaceSortMode.recommended ? 1 : 0) +
        (filter != PlaceListFilter.all ? 1 : 0) +
        (ref.watch(regionFilterProvider) != null ? 1 : 0);

    return OfflineBannerHost(
      child: Scaffold(
        drawer: const AppDrawer(),
        appBar: AppBar(
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: const Text(AppStrings.explorePlaces),
          actions: [
            IconButton(
              tooltip: 'Toggle theme',
              onPressed: () =>
                  ref.read(themeModeProvider.notifier).toggle(),
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  ref.watch(themeModeProvider) == ThemeMode.dark
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                  key: ValueKey(ref.watch(themeModeProvider)),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Notifications',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No new travel alerts (demo).'),
                  ),
                );
              },
              icon: const Icon(Icons.notifications_none_rounded),
            ),
          ],
        ),
        body: placesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => _ErrorState(
            message: err.toString(),
            onRetry: () => ref.read(placesProvider.notifier).refresh(),
          ),
          data: (_) => displayed.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => _ErrorState(
              message: err.toString(),
              onRetry: () => ref.read(placesProvider.notifier).refresh(),
            ),
            data: (places) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: AppStrings.searchHint,
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_searchController.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  ref
                                      .read(searchQueryProvider.notifier)
                                      .state = '';
                                  setState(() {});
                                },
                              ),
                            IconButton(
                              icon: Badge(
                                isLabelVisible: activeFilterCount > 0,
                                label: Text('$activeFilterCount'),
                                backgroundColor:
                                    AppColors.primaryPurple,
                                child: const Icon(Icons.tune_rounded),
                              ),
                              onPressed: () =>
                                  context.pushNamed('search'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _FilterChip(
                          label: 'All',
                          selected: filter == PlaceListFilter.all,
                          onTap: () => ref
                              .read(placeListFilterProvider.notifier)
                              .state = PlaceListFilter.all,
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Favorites',
                          selected: filter == PlaceListFilter.favorites,
                          onTap: () => ref
                              .read(placeListFilterProvider.notifier)
                              .state = PlaceListFilter.favorites,
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Recent',
                          selected: filter == PlaceListFilter.recent,
                          onTap: () => ref
                              .read(placeListFilterProvider.notifier)
                              .state = PlaceListFilter.recent,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: places.isEmpty
                        ? _EmptyState(
                            onClear: () {
                              ref.read(searchQueryProvider.notifier).state =
                                  '';
                              ref
                                  .read(placeListFilterProvider.notifier)
                                  .state = PlaceListFilter.all;
                              ref.read(regionFilterProvider.notifier).state =
                                  null;
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : RefreshIndicator(
                            onRefresh: () =>
                                ref.read(placesProvider.notifier).refresh(),
                            child: AnimatedPlacesList(
                              key: ValueKey(listIdentity),
                              listIdentity: listIdentity,
                              places: places,
                              onPlaceTap: _openDetail,
                              onNearEnd: () => ref
                                  .read(placesProvider.notifier)
                                  .loadMore(),
                            ),
                          ),
                  ),
                  if (ref.watch(placesProvider).value?.loadingMore == true)
                    const LinearProgressIndicator(minHeight: 3),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryPurple
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? AppColors.primaryPurple : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Theme.of(context).hintColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded,
                size: 72, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              AppStrings.noPlacesFound,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting search or filters.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onClear,
              child: const Text(AppStrings.clearFilters),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 56, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text(AppStrings.retry),
            ),
          ],
        ),
      ),
    );
  }
}
